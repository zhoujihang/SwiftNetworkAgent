# SwiftNetworkAgent
swift 面向协议方式，封装网络层框架，目前封装Alamofire框架，支持自由转换JSON格式的结果为任意类型

限制：

* 只支持 Get、Post 请求
* 只支持 json 格式返回值

特点：

* 面向协议编程，侵入小，逻辑核心方便替换
* 支持网络请求的json结果自动转化为自定义的任何类型
* 支持 上传文件
* 轻量级，只包含必要的功能


###一般 Get Post 请求的用法
实现如下协议：

```
protocol RequestProtocol {
    associatedtype ResponseType
    
    var method: RequestMethod {get}
    
    var requestUrl: String {get}                // 必须主动实现，无默认值
    
    var parameters: [String: Any] {get}
    var headers: [String: String] {get}

    var timeoutForRequest: TimeInterval {get}
    
    func parse(_ json: Any) -> ResponseType?
}

extension RequestProtocol {
    
    var method: RequestMethod {return .Get}
    
    var parameters: [String: Any] {return [:]}
    var headers: [String: String] {return [:]}
    
    var timeoutForRequest: TimeInterval {return 30}
}
```

实现类，其中ResponseType可以任意指定请求结果的返回类型：

```
class StockRequest: RequestProtocol {
    typealias ResponseType = StockRequestResponse
    
    func parse(_ json: Any) -> ResponseType? {
        guard let dic = json as? [String: Any] else {return nil}
        return StockRequestResponse(JSON: dic)
    }
    
    var requestUrl: String { return "http://apis.baidu.com/apistore/stockservice/usastock" }
    var headers: [String : String] { return ["apikey" : kAPIStoreKey] }
    var parameters: [String : Any] { return ["stockid" : "bidu", "list" : "1"] }
}
```


使用:

```
self.stockRequestAgent = StockRequest().net_agent.requestParseResponse(success: { (parseResponse) in
    guard let parse = parseResponse else {
        debugPrint("\(self): \(#function) line:\(#line) parseResponse 为 nil")
        return
    }
    let shanghai = parse.retData?.market?.shanghai
    debugPrint("\(self): \(#function) line:\(#line) \(parse)  \(type(of: parse)) errMsg:\(parse.errMsg)  errNum:\(parse.errNum)")
    debugPrint("\(self): \(#function) line:\(#line) shanghai:\(shanghai)")
}, failture: { (error) in
    debugPrint("\(self): \(#function) line:\(#line) \(error)")
})
```

结果：

```
"<SwiftNetworkAgent.ViewController: 0x7fa26161c3b0>: test0_requestUSStock() line:100 SwiftNetworkAgent.StockRequestResponse  StockRequestResponse errMsg:success  errNum:0"
"<SwiftNetworkAgent.ViewController: 0x7fa26161c3b0>: test0_requestUSStock() line:101 shanghai:Optional(StockRequestResponseDataMarketCity: 上证指数 3117.677 -22.8538 -0.73 1899906 21286324)"
```

###文件上传请求

实现如下协议

```
protocol UploadRequestProtocol: RequestProtocol {
    var multipartFormDataBlock: ((MultipartFormData) -> Void) {get}         // 必须主动实现，无默认值
}
extension UploadRequestProtocol {
    var method: RequestMethod {return .Post}
    var timeoutForRequest: TimeInterval {return 60}
}

```

实现类，此处ResponseType未做任何处理，依然为json对象

```
class AppUploadReqeust: UploadRequestProtocol {
    typealias ResponseType = Any
    
    func parse(_ json: Any) -> ResponseType? {
        debugPrint("\(self): \(#function) line:\(#line) 调用了自己的解析模型")
        return json
    }
    
    var requestUrl: String { return "http://www.pgyer.com/apiv1/app/upload" }
    
    var multipartFormDataBlock: ((MultipartFormData) -> Void) {
        let block: ((MultipartFormData) -> Void) = {
            multipartFormData in
            let userKey = kPGYerUserKey
            let apiKey = kPGYerAPIKey
            
            guard let bundlePath = Bundle.main.path(forResource: "LittleApp", ofType: "ipa") else {
                debugPrint("\(self): \(#function) line:\(#line) LittleApp.ipa 不存在1")
                return
            }
            
            let fileURL = URL(fileURLWithPath: bundlePath)
            guard let fileData: Data = try? Data(contentsOf: fileURL, options: .mappedIfSafe) else {
                debugPrint("\(self): \(#function) line:\(#line) LittleApp.ipa 不存在2")
                return
            }
            
            multipartFormData.append(fileData, withName: "file", fileName: bundlePath, mimeType: "")
            multipartFormData.append(userKey.data(using: .utf8)!, withName: "uKey")
            multipartFormData.append(apiKey.data(using: .utf8)!, withName: "_api_key")
        }
        return block
    }
}
```
使用：

```
self.uploadRequestAgent = AppUploadReqeust().net_agent.upload(progress: { (progress) in
    debugPrint("\(self): \(#function) line:\(#line) \(progress.fractionCompleted)")
}, success: { (json) in
    debugPrint("\(self): \(#function) line:\(#line) 成功回调\(json)")
}, failure: { (error) in
    debugPrint("\(self): \(#function) line:\(#line) 失败回调\(error)")
})
```

参考学习：

* [OneV's Den-面向协议编程与 Cocoa 的邂逅 (下)](https://onevcat.com/2016/12/pop-cocoa-2/)
* [Git-APIKit](https://github.com/ishkawa/APIKit)
* [Git-Moya](https://github.com/Moya/Moya)
