//
//  WeatherRequestResponse.swift
//  SwiftNetworkAgent
//
//  Created by 周际航 on 2017/8/9.
//  Copyright © 2017年 com.zjh. All rights reserved.
//

import Foundation
import ObjectMapper

class WeatherRequestResponse: Mappable {
    var air: [String: Any] = [:]
    var alarm: [String: Any] = [:]
    var forecast: [String: Any] = [:]
    var observe: [String: Any] = [:]
    
    required init?(map: Map) {
        guard map.JSON["air"] != nil else {return nil}
        guard map.JSON["alarm"] != nil else {return nil}
        guard map.JSON["forecast"] != nil else {return nil}
        guard map.JSON["observe"] != nil else {return nil}
    }
    
    func mapping(map: Map) {
        air <- map["air"]
        alarm <- map["alarm"]
        forecast <- map["forecast"]
        observe <- map["observe"]
    }
}
