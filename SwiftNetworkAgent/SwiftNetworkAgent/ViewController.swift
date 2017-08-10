//
//  ViewController.swift
//  SwiftNetworkAgent
//
//  Created by 周际航 on 2016/12/15.
//  Copyright © 2016年 com.zjh. All rights reserved.
//

import UIKit
import SnapKit


let kAPIStoreKey = "842538bada1ca2d61d697fb65dc9deb3"               // 普通查询的key

let kPGYerUserKey = "your userkey in http://www.pgyer.com/"         // 上传文件用的userkey
let kPGYerAPIKey = "your apikey in http://www.pgyer.com/"           // 上传文件用的apikey

class ViewController: UIViewController {
    lazy var tableView = UITableView()
    
    fileprivate var uploadRequestAgent: NetworkUploadAgent<AppUploadReqeust>?
    fileprivate var weatherAgent: NetworkAgent<WeatherRequest>?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.setupConstraints()
    }
}

private extension ViewController {
    func setupViews() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
    }
    func setupConstraints() {
        self.tableView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(self.view)
        }
    }
}

// MARK: - 扩展 UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .default, reuseIdentifier: cellID)
        cell.selectionStyle = .none
        
        var title = "\(indexPath.section) - \(indexPath.row)"
        if indexPath.row == 0 {
            title = "天气查询"
        } else if indexPath.row == 1 {
            title = "上传文件请求"
        }
        
        cell.textLabel?.text = title
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        debugPrint("did click \(String(describing: cell?.textLabel?.text))")
        
        if indexPath.row == 0 {
            self.test0()
        } else if indexPath.row == 1 {
            self.test1()
        }
    }
}
// MARK: - 扩展 tableview 点击事件
private extension ViewController {
    func test0() {
        self.weatherAgent = WeatherRequest().net_agent.requestParseResponse(success: { (response) in
            "air:-------------------\(response.air)".ext_debugPrint()
            "alarm:-----------------\(response.alarm)".ext_debugPrint()
            "forecast:--------------\(response.forecast)".ext_debugPrint()
            "observe:---------------\(response.observe)".ext_debugPrint()
        }, failure: {_ in}).needLoading(self)
    }
    
    func test1() {
        self.uploadRequestAgent = AppUploadReqeust().net_agent.uploadMultipartFormData(progress: { (progress) in
            "\(progress.fractionCompleted)".ext_debugPrint()
        }, success: { (response) in
            "成功回调\(response)".ext_debugPrint()
        }, failure: { (error) in
            "失败回调\(error)".ext_debugPrint()
        }).needLoading(self).hintErrorInfo(false)
        
        // 取消上传
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
//            [weak self] in
//            self?.uploadRequestAgent?.cancel()
//        }
    }
    
    
}

