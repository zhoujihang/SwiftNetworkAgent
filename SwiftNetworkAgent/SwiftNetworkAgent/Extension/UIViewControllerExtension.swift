//
//  UIViewControllerExtension.swift
//  SwiftNetworkAgent
//
//  Created by 周际航 on 2017/3/15.
//  Copyright © 2017年 com.zjh. All rights reserved.
//

import UIKit

// MARK: - 扩展 hierarchy
extension UIViewController {
    // 该 vc 下，最后一个 presented 的vc
    func ext_lastPresentedViewController() -> UIViewController? {
        guard var vc = self.presentedViewController else {return nil}
        while vc.presentedViewController != nil {
            vc = vc.presentedViewController!
        }
        return vc
    }
    // 该 vc 下，显示在最上层的 vc
    func ext_topShowViewController() -> UIViewController {
        if let topPresentVC = self.ext_lastPresentedViewController() {
            return topPresentVC.ext_topShowViewController()
        }
        if let tabBarVC = self as? UITabBarController {
            guard let selectedVC = tabBarVC.selectedViewController else {return self}
            return selectedVC.ext_topShowViewController()
        }
        if let navVC = self as? UINavigationController {
            guard let topVC = navVC.topViewController else {return self}
            return topVC.ext_topShowViewController()
        }
        return self
    }
}
