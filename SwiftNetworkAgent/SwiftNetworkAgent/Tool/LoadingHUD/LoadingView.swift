//
//  LoadingView.swift
//  SwiftNetworkAgent
//
//  Created by 周际航 on 2016/12/29.
//  Copyright © 2016年 com.maramara. All rights reserved.
//

import UIKit
import SnapKit

class LoadingView: UIView {
    
    fileprivate lazy var indicatorView = UIActivityIndicatorView()
    fileprivate lazy var indicatorContentView = UIView()
    fileprivate lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        self.setupViews()
    }
    fileprivate func setupViews() {
        self.addSubview(self.indicatorContentView)
        self.indicatorContentView.addSubview(self.indicatorView)
        self.indicatorContentView.addSubview(self.titleLabel)
        
        self.isUserInteractionEnabled = true
        
        let width: CGFloat = 100
        let height: CGFloat = 100
        self.indicatorContentView.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        self.indicatorContentView.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        self.indicatorContentView.layer.cornerRadius = 8
        self.indicatorContentView.layer.masksToBounds = true
        
        self.indicatorView.activityIndicatorViewStyle = .whiteLarge
        self.indicatorView.startAnimating()
        self.indicatorView.center = CGPoint(x: ceil(width*0.5), y: ceil(height*0.5-10))
        
        self.titleLabel.text = "loading..."
        self.titleLabel.textColor = .white
        self.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.titleLabel.frame = CGRect(x: 0, y: width-40, width: width, height: 40)
        self.titleLabel.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.indicatorContentView.center = CGPoint(x: ceil(self.bounds.size.width*0.5), y: ceil(self.bounds.size.height*0.5))
    }
    
    // 拦截点击
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
extension LoadingView {
    @discardableResult
    static func addTo(_ superView: UIView) -> LoadingView {
        let loadingView = LoadingView()
        superView.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { (make) in
            make.edges.equalTo(superView)
        }
        return loadingView
    }
}









