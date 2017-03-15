//
//  StockRequest.swift
//  Mara
//
//  Created by 周际航 on 2016/11/28.
//  Copyright © 2016年 com.maramara. All rights reserved.
//

import Foundation

class StockRequest: RequestProtocol {
    typealias ResponseType = StockRequestResponse
    
    func parse(_ json: Any) -> ResponseType? {
        guard let dic = json as? [String: Any] else {return nil}
        return StockRequestResponse(JSON: dic)
    }
    
    var requestUrl: String { return NetworkUrlTool.stockURL }
    var headers: [String : String] { return ["apikey" : kAPIStoreKey] }
    var parameters: [String : Any] { return ["stockid" : "bidu", "list" : "1"] }
}
