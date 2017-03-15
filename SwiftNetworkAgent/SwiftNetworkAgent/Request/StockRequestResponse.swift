//
//  StockRequestResponse.swift
//  Mara
//
//  Created by 周际航 on 2016/12/15.
//  Copyright © 2016年 com.maramara. All rights reserved.
//

import Foundation
import ObjectMapper
class StockRequestResponse: Mappable {
    var errMsg: String = ""
    var errNum: Int = 0
    var retData: StockRequestResponseData?
    
    required init?(map: Map) {
        guard map.JSON["errNum"] != nil else {return nil}
        guard map.JSON["errMsg"] != nil else {return nil}
    }
    
    func mapping(map: Map) {
        errMsg <- map["errMsg"]
        errNum <- map["errNum"]
        retData <- map["retData"]
    }
}
class StockRequestResponseData: Mappable {
    var market: StockRequestResponseDataMarket?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        market <- map["market"]
    }
}
class StockRequestResponseDataMarket: Mappable {
    var shanghai: StockRequestResponseDataMarketCity?
    var shenzhen: StockRequestResponseDataMarketCity?
    var DJI: StockRequestResponseDataMarketCity?
    var IXIC: StockRequestResponseDataMarketCity?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        shanghai <- map["shanghai"]
        shenzhen <- map["shenzhen"]
        DJI <- map["DJI"]
        IXIC <- map["IXIC"]
    }
}
class StockRequestResponseDataMarketCity: Mappable, CustomStringConvertible {
    var name: String = ""
    var curdot: Double = 0.0
    var curprice: Double = 0.0
    var rate: Double = 0.0
    var dealnumber: Int = 0
    var turnover: Int = 0
    
    required init?(map: Map) {
        guard map.JSON["name"] != nil else {return nil}
        guard map.JSON["rate"] != nil else {return nil}
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        curdot <- map["curdot"]
        curprice <- map["curprice"]
        rate <- map["rate"]
        dealnumber <- map["dealnumber"]
        turnover <- map["turnover"]
    }
    
    var description: String {
        let message = "\(type(of: self)): \(name) \(curdot) \(curprice) \(rate) \(dealnumber) \(turnover)"
        return message
    }
}
