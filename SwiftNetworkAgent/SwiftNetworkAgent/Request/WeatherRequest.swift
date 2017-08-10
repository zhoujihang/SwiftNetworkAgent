//
//  WeatherRequest.swift
//  SwiftNetworkAgent
//
//  Created by 周际航 on 2017/8/9.
//  Copyright © 2017年 com.zjh. All rights reserved.
//

import Foundation

class WeatherRequest: RequestProtocol {
    typealias ResponseType = WeatherRequestResponse
    
    func parse(_ json: Any) -> ResponseType? {
        guard let dic = json as? [String: Any] else {return nil}
        return WeatherRequestResponse(JSON: dic)
    }
    
    var requestUrl: String { return NetworkUrlTool.weatherURL }
    var headers: [String : String] { return ["apikey" : kAPIStoreKey] }
    var parameters: [String : Any] { return ["area" : "101010100"] }
}
