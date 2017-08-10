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
        let message = "\(type(of: self)) \(String(describing: self.error)))"
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
        let message = "\(type(of: self)) \(String(describing: self.code)) \(String(describing: self.message))  \(String(describing: self.type)) \(String(describing: self.sub_code)) \(String(describing: self.prompt_info)) \(String(describing: self.prompt_type)))"
        return message
    }
}
