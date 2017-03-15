//
//  StringExtension.swift
//  SwiftNetworkAgent
//
//  Created by 周际航 on 2016/12/20.
//  Copyright © 2016年 com.zjh. All rights reserved.
//

import UIKit

// MARK: - 扩展 常用常量扩展
extension String {
    static let ext_documentDirectory: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    static let ext_cachesDirectory: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
}

// MARK: - 扩展 计算内容大小
extension String {
    func ext_size(withBoundingSize boundingSize: CGSize, font: UIFont) -> CGSize {
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let attributes = [NSFontAttributeName : font]
        let contentSize = self.boundingRect(with: boundingSize, options: option, attributes: attributes, context: nil).size
        return contentSize
    }
}
// MARK: - 扩展 文件读写删除
extension String {
    func ext_readFileContent() -> String? {
        do {
            return try String(contentsOfFile: self, encoding: String.Encoding.utf8)
        } catch _ {
            //            "\(error)".ext_debugPrint()
            return nil
        }
    }
    
    @discardableResult
    func ext_write(toFile file: String, automically: Bool = true, encoding: String.Encoding = .utf8) -> Bool {
        do {
            try self.write(toFile: file, atomically: automically, encoding: encoding)
        } catch _ {
            //            "\(error)".ext_debugPrint()
            return false;
        }
        return true
    }
    
    func ext_createDirectory() throws {
        if !FileManager.default.fileExists(atPath: self, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(atPath: self, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                throw error
            }
        }
    }
    
    @discardableResult
    func ext_removeItem() -> Bool {
        do {
            try FileManager.default.removeItem(atPath: self)
        } catch _ {
            return false
        }
        return true
    }
}
// MARK: - 扩展 JSON
extension String {
    func ext_jsonObject() -> Any? {
        guard let data = self.data(using: String.Encoding.utf8) else {return nil}
        var jsonObj: Any?
        do {
            jsonObj = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        } catch let error {
            "\(error)".ext_debugPrint()
        }
        return jsonObj
    }
}
// MARK: - 扩展 文本替换
extension String {
    func ext_appendingPathComponent(_ path: String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }
    func ext_fileNameWithoutDirectory() -> String {
        let pathArray: [String] = self.components(separatedBy: "/")
        let fileName = pathArray.last ?? self
        return fileName
    }
    func ext_dirPathWithoutFileName() -> String {
        let string = self as NSString
        let dir = string.deletingLastPathComponent
        return dir
    }
    // Document 目录操作
    func ext_appendToDocumentPath() -> String {
        let documentPath = String.ext_documentDirectory
        if !self.hasPrefix(documentPath) {
            return documentPath.ext_appendingPathComponent(self)
        }
        return self
    }
    func ext_removeDocumentPath() -> String {
        let documentPath = String.ext_documentDirectory + "/"
        if self.hasPrefix(documentPath) {
            let relativePath = (self as NSString).replacingOccurrences(of: documentPath, with: "")
            return relativePath
        }
        return self
    }
    
    // Caches 目录操作
    func ext_appendToCachesPath() -> String {
        let cachesPath = String.ext_cachesDirectory
        if !self.hasPrefix(cachesPath) {
            return cachesPath.ext_appendingPathComponent(self)
        }
        return self
    }
    func ext_removeCachesPath() -> String {
        let cachesPath = String.ext_documentDirectory + "/"
        if self.hasPrefix(cachesPath) {
            let relativePath = (self as NSString).replacingOccurrences(of: cachesPath, with: "")
            return relativePath
        }
        return self
    }
}

// MARK: - 扩展 DEBUG 打印
extension String {
    @discardableResult
    func ext_debugPrint(file: String = #file, function: String = #function, line: Int = #line) -> String{
        #if DEBUG
            let fileName = file.ext_fileNameWithoutDirectory()
            debugPrint("***\(fileName)*** \(function) [line:\(line)] - \(self)")
        #endif
        return self
    }
}
