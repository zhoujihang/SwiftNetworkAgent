//
//  UploadRequestProtocol.swift
//  SwiftNetworkAgent
//
//  Created by 周际航 on 2017/3/15.
//  Copyright © 2017年 com.zjh. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - 协议 UploadRequestProtocol
protocol UploadRequestProtocol {
    associatedtype ResponseType
    func parse(_ json: Any) -> ResponseType?
    
    var requestUrl: String {get}                // 必须主动实现，无默认值
    var headers: [String: String] {get}
    var commonHeaders: [String: String] {get}
    var encodedURLRequest: URLRequest? {get}
    var timeoutForRequest: TimeInterval {get}
    
    var multipartFormDataBlock: ((MultipartFormData) -> Void)? {get}        // MultipartFormData 格式数据
    var uploadData: Data? {get}                                             // Data 二进制格式数据
}
extension UploadRequestProtocol {
    var timeoutForRequest: TimeInterval {return 60}
    
    var parameters: [String: Any] {return [:]}
    var headers: [String: String] {return [:]}
    var commonHeaders: [String: String] {return NetworkHeaderTool.commonRequestHeader()}
    
    var encodedURLRequest: URLRequest? {
        do {
            let originalRequest = try URLRequest(url: self.requestUrl, method: HTTPMethod.post, headers: headers)
            let encodedURLRequest = try URLEncoding.default.encode(originalRequest, with: parameters)
            return encodedURLRequest
        } catch {
            return nil
        }
    }
}
