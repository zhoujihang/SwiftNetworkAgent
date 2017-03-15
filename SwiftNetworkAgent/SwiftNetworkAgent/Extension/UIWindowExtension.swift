//
//  UIWindowExtension.swift
//  SwiftNetworkAgent
//
//  Created by 周际航 on 2017/3/15.
//  Copyright © 2017年 com.zjh. All rights reserved.
//

import UIKit

extension UIWindow {
    // 找到 window 下显示在最上层的 vc
    func ext_currentViewController() -> UIViewController? {
        return self.rootViewController?.ext_topShowViewController()
    }
}
