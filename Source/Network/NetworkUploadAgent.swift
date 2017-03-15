//
//  NetworkUploadAgent.swift
//  Mara
//
//  Created by 周际航 on 2016/12/14.
//  Copyright © 2016年 com.maramara. All rights reserved.
//

import Foundation
import Alamofire

extension UploadRequestProtocol {
    var net_agent: NetworkUploadAgent<Self> {return NetworkUploadAgent(self)}
}

typealias NetworkUploadProgress = (_ progress: Progress) -> Void
typealias NetworkUploadSuccess<T: UploadRequestProtocol> = (_ parseResponse: T.ResponseType) -> Void
typealias NetworkUploadFailure = (_ error: RequestError) -> Void

final class NetworkUploadAgent<T: UploadRequestProtocol> {
    
    fileprivate(set) var isFinished: Bool = false               // 请求是否已经完成
    fileprivate(set) var isCanceled: Bool = false               // 请求是否被cancel
    
    fileprivate var isHintErrorInfo: Bool = true                // 是否使用吐司工具提示用户网络错误的信息，默认提示
    fileprivate weak var needLoadingVC: UIViewController?     // 需要自动显示loading的页面
    
    fileprivate var customUploadRequest: T
    
    fileprivate var uploadSessionManager: Alamofire.SessionManager
    fileprivate var alamofireUploadRequest: Alamofire.UploadRequest?
    
    fileprivate var networkProgress: NetworkUploadProgress?
    fileprivate var networkSuccess: NetworkUploadSuccess<T>?
    fileprivate var networkFailure: NetworkUploadFailure?
    
    init(_ uploadRequest: T) {
        self.customUploadRequest = uploadRequest
        let configuration = NetworkUploadAgent.generateConfiguration(by: uploadRequest)
        self.uploadSessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    // MARK: 上传 data 二进制数据
    func uploadData(progress: @escaping NetworkUploadProgress, success: @escaping NetworkUploadSuccess<T>, failure: @escaping NetworkUploadFailure) -> NetworkUploadAgent {
        guard let uploadData = self.customUploadRequest.uploadData else {
            assert(false, "NetworkUploadAgent<\(type(of: self.customUploadRequest))>: uploadData不可为nil")
            return self
        }
        self.cancel()
        self.networkProgress = progress
        self.networkSuccess = success
        self.networkFailure = {
            [weak self] error in
            self?.commonFailureBlock(error)
            failure(error)
        }
        
        let url = self.customUploadRequest.requestUrl
        let method = Alamofire.HTTPMethod.post
        let headers = self.customUploadRequest.headers
        
        let handler = self.responseCompletionHandler()
        self.uploadSessionManager.upload(uploadData, to: url, method: method, headers: headers).uploadProgress(closure: progress).responseJSON(completionHandler: handler)
        return self
    }
    
    // MARK: 上传 multipartFormData 数据
    func uploadMultipartFormData(progress: @escaping NetworkUploadProgress, success: @escaping NetworkUploadSuccess<T>, failure: @escaping NetworkUploadFailure) -> NetworkUploadAgent {
        guard let multipartFormData = self.customUploadRequest.multipartFormDataBlock else {
            assert(false, "NetworkUploadAgent<\(type(of: self.customUploadRequest))>: multipartFormData不可为nil")
            return self
        }
        self.cancel()
        self.networkProgress = progress
        self.networkSuccess = success
        self.networkFailure = {
            [weak self] error in
            self?.commonFailureBlock(error)
            failure(error)
        }
        
        let url = self.customUploadRequest.requestUrl
        let method = Alamofire.HTTPMethod.post
        let headers = self.customUploadRequest.headers
        
        let handler = self.responseCompletionHandler()
        let encodingCompletion: (((Alamofire.SessionManager.MultipartFormDataEncodingResult) -> Void)?) = {
            [weak self] encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                self?.alamofireUploadRequest = upload.uploadProgress { progress in
                    self?.networkProgress?(progress)
                    }.responseJSON(completionHandler: handler)
            case .failure(let error):
                defer {
                    self?.isFinished = true
                    self?.needLoadingVC?.ldt_loadingCountReduce()
                }
                self?.networkFailure?(RequestError.alamofireError(error))
            }
        }
        self.uploadSessionManager.upload(multipartFormData: multipartFormData, to: url, method: method, headers: headers, encodingCompletion: encodingCompletion)
        return self
    }
    
    @discardableResult
    func cancel() -> NetworkUploadAgent {
        self.alamofireUploadRequest?.cancel()
        self.isCanceled = true
        return self
    }
}
// MARK: - 扩展 预处理网络结果
extension NetworkUploadAgent {
    fileprivate func responseCompletionHandler() -> (Alamofire.DataResponse<Any>) -> Void {
        let handler: ((Alamofire.DataResponse<Any>) -> Void) = {
            [weak self] response in
            
            defer {
                self?.isFinished = true
                self?.needLoadingVC?.ldt_loadingCountReduce()
            }
            
            // 1. 无 response 错误
            guard let httpReponse = response.response else {
                self?.networkFailure?(RequestError.responseNone)
                return
            }
            switch response.result {
            // 2. alamofire的错误
            case .failure(let error):
                self?.networkFailure?(RequestError.alamofireError(error))
            case .success(let json):
                if httpReponse.statusCode != 200 {
                    guard let dic = json as? [String: Any] else {
                        self?.networkFailure?(RequestError.responseParseNil(json))
                        return
                    }
                    guard let errorModel = RequestErrorModel(JSON: dic) else {
                        self?.networkFailure?(RequestError.responseParseNil(json))
                        return
                    }
                    // 3. 非 200 错误
                    self?.networkFailure?(RequestError.responseCodeError(errorModel))
                    return
                }
                
                if let parse = self?.customUploadRequest.parse(json) {
                    self?.networkSuccess?(parse)
                } else {
                    // 4. 返回结果转模型失败错误
                    self?.networkFailure?(RequestError.responseParseNil(json))
                }
            }
        }
        return handler
    }
    
    fileprivate func commonFailureBlock(_ error: RequestError) {
        self.printNetworkError(error)
        guard self.isHintErrorInfo else {return}
        let info = "上传失败"
        
        switch error {
        case RequestError.alamofireError(let error):
            // alamofire错误
            guard let afError = error as? AFError else {break}
            
            switch afError {
            case .responseValidationFailed(reason: let reason):
                switch reason {
                case .unacceptableStatusCode(code: let code):
                    if code == 401 {
                        // 交由 OAuth2Handler处理过了，这里不再重复提示
                        return
                    }
                default: break
                }
            default: break
            }
            info.ext_hint()
            return
        case RequestError.responseCodeError(let errorModel):
            // 后台提示错误
            if let message = errorModel.error?.message {
                message.ext_hint()
                return
            }
            info.ext_hint()
            return
        default:
            info.ext_hint()
        }
    }
}

// MARK: - 扩展 生成configuration
extension NetworkUploadAgent {
    fileprivate static func generateConfiguration(by request: T) -> URLSessionConfiguration {
        var additionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        for (key, value) in request.commonHeaders{
            additionalHeaders.updateValue(value, forKey: key)
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = additionalHeaders
        configuration.timeoutIntervalForRequest = request.timeoutForRequest
        
        return configuration
    }
}

// MARK: - 扩展 针对 LoadingTool 的加载框便利方法
extension NetworkUploadAgent {
    func needLoading(_ viewController: UIViewController) -> NetworkUploadAgent {
        self.needLoadingVC = viewController
        self.needLoadingVC?.ldt_loadingCountAdd()
        return self
    }
}
// MARK: - 扩展 针对 HintTool 的错误弹窗便利方法
extension NetworkUploadAgent {
    func hintErrorInfo(_ hint: Bool) -> NetworkUploadAgent {
        self.isHintErrorInfo = hint
        return self
    }
}

// MARK: - 扩展 debug下，默认打印错误信息
extension NetworkUploadAgent {
    fileprivate func printNetworkError(_ error: RequestError) {
        #if DEBUG
            let request = self.customUploadRequest
            let url = request.requestUrl
            let parameters = request.parameters
            let headers = request.headers
            
            debugPrint("=========================")
            debugPrint("网络返回错误 url:\(url)")
            debugPrint("method:post")
            debugPrint("parameters:\(parameters)")
            debugPrint("headers:\(headers)")
            debugPrint("error:\(error)")
            debugPrint("=========================")
        #endif
    }
}
