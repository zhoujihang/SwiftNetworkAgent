//
//  NetworkHeaderTool.swift
//  SwiftNetworkAgent
//
//  Created by 周际航 on 2017/3/15.
//  Copyright © 2017年 com.zjh. All rights reserved.
//

import Foundation

class NetworkHeaderTool {
    
    static func commonRequestHeader() -> [String: String]{
        var headers: [String: String] = [:]
        headers["User-Agent"] = self.commonUserAgent()
        return headers
    }
    
    static func commonUserAgent() -> String {
        var dic: [String: String] = [:]
        let kUnknownString = "Unknown"
        let infoDic = Bundle.main.infoDictionary ?? [:]
        
        dic["type"] = "iOS"
        dic["appID"] = Bundle.main.bundleIdentifier
        dic["app-version"] = infoDic["CFBundleShortVersionString"] as? String ?? kUnknownString
        dic["channel"] = "AppStore"
        
        let jsonString = dic.ext_jsonString() ?? ""
        return jsonString
    }
}
