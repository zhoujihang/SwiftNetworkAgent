//
//  StringExtension.swift
//  SwiftNetworkAgent
//
//  Created by 周际航 on 2016/12/20.
//  Copyright © 2016年 com.zjh. All rights reserved.
//

import Foundation

// MARK: - 扩展 DEBUG 打印
extension String {
    func ext_debugPrint(function: String = #function, line: Int = #line) {
        #if DEBUG
            debugPrint("\(function) line:\(line) - \(self)")
        #endif
    }
}

