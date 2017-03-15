//
//  AppUploadRequest.swift
//  Mara
//
//  Created by 周际航 on 2016/12/14.
//  Copyright © 2016年 com.maramara. All rights reserved.
//

import Foundation
import Alamofire

class AppUploadReqeust: UploadRequestProtocol {
    typealias ResponseType = Any
    
    func parse(_ json: Any) -> ResponseType? {
        "解析模型".ext_debugPrint()
        return json
    }
    
    var requestUrl: String { return NetworkUrlTool.pgyUploadURL }
    
    var multipartFormDataBlock: ((MultipartFormData) -> Void)? {
        let block: ((MultipartFormData) -> Void) = {
            multipartFormData in
            let userKey = kPGYerUserKey
            let apiKey = kPGYerAPIKey
            
            guard let bundlePath = Bundle.main.path(forResource: "WhatYouWant", ofType: "mp3") else {
                "WhatYouWant.mp3 不存在1".ext_debugPrint()
                return
            }
            
            let fileURL = URL(fileURLWithPath: bundlePath)
            guard let fileData: Data = try? Data(contentsOf: fileURL, options: .mappedIfSafe) else {
                "WhatYouWant.mp3 不存在2".ext_debugPrint()
                return
            }
            
            multipartFormData.append(fileData, withName: "file", fileName: bundlePath, mimeType: "")
            multipartFormData.append(userKey.data(using: .utf8)!, withName: "uKey")
            multipartFormData.append(apiKey.data(using: .utf8)!, withName: "_api_key")
        }
        return block
    }
    var uploadData: Data?
}


