//
//  ArrayExtension.swift
//  Mara
//
//  Created by 周际航 on 2016/12/12.
//  Copyright © 2016年 com.maramara. All rights reserved.
//

import Foundation

extension Array {
    func ext_jsonString() -> String? {
        guard JSONSerialization.isValidJSONObject(self) else {return nil}
        var jsonString: String?
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            jsonString = String(data: data, encoding: String.Encoding.utf8)
        } catch let error {
            debugPrint("\(self): \(#function) \(#line) \(error)")
        }
        return jsonString
    }
}
