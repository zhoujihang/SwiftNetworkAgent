//
//  RequestErrorModel.swift
//  Mara
//
//  Created by 周际航 on 2016/12/27.
//  Copyright © 2016年 com.maramara. All rights reserved.
//

import Foundation
import ObjectMapper

class RequestErrorModel: Mappable {
    
    var error: RequestErrorErrorModel?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        error           <- map["error"]
    }
}

extension RequestErrorModel: CustomStringConvertible {
    var description: String {
        let message = "\(type(of: self)) \(self.error))"
        return message
    }
}

class RequestErrorErrorModel: Mappable {
    
    var code: Int?
    var message: String?
    var type: String?
    var sub_code: String?
    var prompt_info: String?
    var prompt_type: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        code            <- map["code"]
        message         <- map["message"]
        type            <- map["type"]
        sub_code        <- map["sub_code"]
        prompt_info     <- map["prompt_info"]
        prompt_type     <- map["prompt_type"]
    }
}

extension RequestErrorErrorModel: CustomStringConvertible {
    var description: String {
        let message = "\(type(of: self)) \(self.code) \(self.message)  \(self.type) \(self.sub_code) \(self.prompt_info) \(self.prompt_type))"
        return message
    }
}
