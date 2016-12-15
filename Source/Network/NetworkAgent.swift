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

class NetworkAgent<T: RequestProtocol> {
    
    typealias NetworkSuccess = (_ parseResponse: T.ResponseType?) -> Void
    typealias NetworkFailure = (_ error: Error) -> Void
    typealias NetworkParseSuccess = (_ parseResponse: Any) -> Void
    
    fileprivate var customRequest: T
    
    fileprivate var sessionManager: Alamofire.SessionManager
    fileprivate var alamofireRequest: Alamofire.DataRequest?
    
    fileprivate var networkSuccess: NetworkSuccess?
    fileprivate var networkFailure: NetworkFailure?
    fileprivate var networkParseSuccess: NetworkParseSuccess?
    
    // MARK: 初始化
    init(_ request: T) {
        self.customRequest = request
        let configuration = NetworkAgent.generateConfiguration(by: request)
        self.sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    // MARK: 发起请求方法
    func requestParseResponse(success: @escaping NetworkSuccess, failture: @escaping NetworkFailure) -> Self {
        self.networkSuccess = success
        self.networkFailure = failture
        
        let handler: ((Alamofire.DataResponse<Any>) -> Void) = {
            [weak self] response in
            
            switch response.result {
            case .success(let json):
                if let success = self?.networkSuccess {
                    let parse = self?.customRequest.parse(json)
                    success(parse)
                }
            case .failure(let error):
                if let failure = self?.networkFailure {
                    failure(error)
                }
            }
        }
        self.cancel()
        self.alamofireRequest = self.generateAlamofireRequest().responseJSON(completionHandler: handler)
        return self
    }
    
    @discardableResult
    func cancel() -> Self {
        self.alamofireRequest?.cancel()
        return self
    }
    
    
    
}


// MARK: - 扩展 生成configuration
extension NetworkAgent {
    fileprivate static func generateConfiguration(by request: T) -> URLSessionConfiguration {
        var additionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        for (key, value) in request.headers {
            additionalHeaders.updateValue(value, forKey: key)
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = additionalHeaders
        configuration.timeoutIntervalForRequest = request.timeoutForRequest
        
        return configuration
    }
}
// MARK: - 扩展 生成alamofireRequest
extension NetworkAgent {
    fileprivate func generateAlamofireRequest() -> Alamofire.DataRequest {
        let request = self.customRequest
        
        let url = request.requestUrl
        let method: Alamofire.HTTPMethod = request.method == .Get ? Alamofire.HTTPMethod.get : Alamofire.HTTPMethod.post
        let parameters = request.parameters
        let headers = request.headers
        
        let alamofireRequest = self.sessionManager.request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate()
        return alamofireRequest
    }
}




