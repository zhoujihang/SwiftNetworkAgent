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
typealias NetworkUploadSuccess<T: UploadRequestProtocol> = (_ parseResponse: T.ResponseType?) -> Void
typealias NetworkUploadFailure = (_ error: Error) -> Void

class NetworkUploadAgent<T: UploadRequestProtocol> {
    
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
    
    func upload(progress: @escaping NetworkUploadProgress, success: @escaping NetworkUploadSuccess<T>, failure: @escaping NetworkUploadFailure) -> NetworkUploadAgent {
        self.networkProgress = progress
        self.networkSuccess = success
        self.networkFailure = failure
        
        let multipartFormData = self.customUploadRequest.multipartFormDataBlock
        let url = self.customUploadRequest.requestUrl
        let method = Alamofire.HTTPMethod.post
        let headers = self.customUploadRequest.headers
        
        let encodingCompletion: (((Alamofire.SessionManager.MultipartFormDataEncodingResult) -> Void)?) = {
            [weak self] encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                self?.alamofireUploadRequest = upload.uploadProgress { progress in
                    if let progressBlock = self?.networkProgress {
                        progressBlock(progress)
                    }
                }.responseJSON { jsonResponse in
                    switch jsonResponse.result {
                    case .success(let json):
                        if let successBlock = self?.networkSuccess {
                            let parse = self?.customUploadRequest.parse(json)
                            successBlock(parse)
                        }
                    case .failure(let error):
                        if let failureBlock = self?.networkFailure {
                            failureBlock(error)
                        }
                    }
                }
            case .failure(let error):
                if let failureBlock = self?.networkFailure {
                    failureBlock(error)
                }
            }
        }
        self.cancel()
        self.uploadSessionManager.upload(multipartFormData: multipartFormData, to: url, method: method, headers: headers, encodingCompletion: encodingCompletion)
        return self
    }
    
    @discardableResult
    func cancel() -> NetworkUploadAgent {
        self.alamofireUploadRequest?.cancel()
        return self
    }
    
}
// MARK: - 扩展 生成configuration
extension NetworkUploadAgent {
    fileprivate static func generateConfiguration(by request: T) -> URLSessionConfiguration {
        var additionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        for (key, value) in request.headers{
            additionalHeaders.updateValue(value, forKey: key)
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = additionalHeaders
        configuration.timeoutIntervalForRequest = request.timeoutForRequest
        
        return configuration
    }
}
