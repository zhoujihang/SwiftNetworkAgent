//
//  RequestProtocol.swift
//  Mara
//
//  Created by 周际航 on 2016/12/14.
//  Copyright © 2016年 com.maramara. All rights reserved.
//

import Foundation
import Alamofire

enum RequestMethod {
    case Get
    case Post
}
// MARK: - 协议 RequestProtocol
protocol RequestProtocol {
    
    associatedtype ResponseType
    func parse(_ json: Any) -> ResponseType?
    
    var requestUrl: String {get}                // 必须主动实现，无默认值
    var method: RequestMethod {get}
    var parameters: [String: Any] {get}
    
    var headers: [String: String] {get}         // 单个请求自己的header
    var commonHeaders: [String: String] {get}   // 通用header

    var timeoutForRequest: TimeInterval {get}
    
}
extension RequestProtocol {
    
    var method: RequestMethod {return .Get}
    
    var parameters: [String: Any] {return [:]}
    var headers: [String: String] {return [:]}
    var commonHeaders: [String: String] {return [:]}
    
    var timeoutForRequest: TimeInterval {return 30}
}






// MARK: - 协议 UploadRequestProtocol
protocol UploadRequestProtocol: RequestProtocol {
    
    var multipartFormDataBlock: ((MultipartFormData) -> Void) {get}         // 必须主动实现，无默认值
    
}
extension UploadRequestProtocol {
    var method: RequestMethod {return .Post}
    var timeoutForRequest: TimeInterval {return 60}
}






