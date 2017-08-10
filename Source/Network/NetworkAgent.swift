//
//  NetworkAgent.swift
//  Mara
//
//  Created by 周际航 on 2016/12/14.
//  Copyright © 2016年 com.maramara. All rights reserved.
//

import Foundation
import Alamofire

extension RequestProtocol {
    var net_agent: NetworkAgent<Self> { return NetworkAgent(self) }
}

typealias NetworkSuccess<T: RequestProtocol> = (_ parseResponse: T.ResponseType) -> Void
typealias NetworkFailure = (_ error: RequestError) -> Void

final class NetworkAgent<T: RequestProtocol> {
    
    fileprivate(set) var isFinished: Bool = false               // 请求是否已经完成
    fileprivate(set) var isCanceled: Bool = false               // 请求是否被cancel
    fileprivate(set) var customRequest: T
    
    fileprivate var isHintErrorInfo: Bool = true                // 是否使用吐司工具提示用户网络错误的信息，默认提示
    fileprivate weak var needLoadingVC: UIViewController?     // 需要自动显示loading的页面
    
    fileprivate var sessionManager: Alamofire.SessionManager
    fileprivate var alamofireRequest: Alamofire.DataRequest?
    
    fileprivate var networkSuccess: NetworkSuccess<T>?
    fileprivate var networkFailure: NetworkFailure?
    
    // MARK: 初始化
    init(_ request: T) {
        self.customRequest = request
        let configuration = NetworkAgent.generateConfiguration(by: request)
        self.sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func requestParseResponse(success: @escaping NetworkSuccess<T>, failure: @escaping NetworkFailure) -> NetworkAgent {
        self.cancel()
        
        self.networkSuccess = success
        self.networkFailure = { [weak self] error in
            self?.commonFailureBlock(error)
            failure(error)
        }
        
        let handler = self.responseCompletionHandler()
        self.alamofireRequest = self.generateAlamofireRequest().responseJSON(completionHandler: handler)
        return self
    }
    
    @discardableResult
    func cancel() -> NetworkAgent {
        self.alamofireRequest?.cancel()
        self.isCanceled = true
        return self
    }
    
}

// MARK: - 扩展 预处理网络结果
extension NetworkAgent {
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
                
                if let parse = self?.customRequest.parse(json) {
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
        let info = "数据访问失败，请稍后再试"
        
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
fileprivate extension NetworkAgent {
    static func generateConfiguration(by request: T) -> URLSessionConfiguration {
        var additionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        for (key, value) in request.commonHeaders {
            additionalHeaders.updateValue(value, forKey: key)
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = additionalHeaders
        configuration.timeoutIntervalForRequest = request.timeoutForRequest
        
        return configuration
    }
}
// MARK: - 扩展 生成alamofireRequest
fileprivate extension NetworkAgent {
    
    func generateAlamofireRequest() -> Alamofire.DataRequest {
        let request = self.customRequest
        
        let url = request.requestUrl
        let method: Alamofire.HTTPMethod = request.method == .Get ? Alamofire.HTTPMethod.get : Alamofire.HTTPMethod.post
        let parameters = request.parameters
        let headers = request.headers
        
        let alamofireRequest = self.sessionManager.request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers)
        return alamofireRequest
    }
}
// MARK: - 扩展 针对 LoadingTool 的加载框便利方法
extension NetworkAgent {
    func needLoading(_ viewController: UIViewController) -> NetworkAgent {
        self.needLoadingVC = viewController
        self.needLoadingVC?.ldt_loadingCountAdd()
        return self
    }
}
// MARK: - 扩展 针对 HintTool 的错误弹窗便利方法
extension NetworkAgent {
    func hintErrorInfo(_ hint: Bool) -> NetworkAgent {
        self.isHintErrorInfo = hint
        return self
    }
}
// MARK: - 扩展 debug下，默认打印错误信息
extension NetworkAgent {
    fileprivate func printNetworkError(_ error: RequestError) {
        #if DEBUG
            let request = self.customRequest
            let url = request.requestUrl
            let method: Alamofire.HTTPMethod = request.method == .Get ? Alamofire.HTTPMethod.get : Alamofire.HTTPMethod.post
            let parameters = request.parameters
            let headers = request.headers
            
            debugPrint("=========================")
            debugPrint("网络返回错误 url:\(url)")
            debugPrint("method:\(method)")
            debugPrint("parameters:\(parameters)")
            debugPrint("headers:\(headers)")
            debugPrint("error:\(error)")
            debugPrint("=========================")
        #endif
    }
}


