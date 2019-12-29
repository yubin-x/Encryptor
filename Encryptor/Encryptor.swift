//
//  Encryptor.swift
//  Encryptor
//
//  Created by yubin on 2019/12/26.
//  Copyright © 2019 yubin. All rights reserved.
//

import Foundation
import CryptoSwift

enum EncryptorError: Error {
    case loadClearFileError(String)
    case encryptError(String)
    case loadCipherFileError(String)
    case decryptError(String)
}

extension EncryptorError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .loadClearFileError(let msg):
            return "加载明文文件出错: \(msg)"
        case .encryptError(let msg):
            return "加密文件出错: \(msg)"
        case .loadCipherFileError(let msg):
            return "加载密文文件出错: \(msg)"
        case .decryptError(let msg):
            return "解密文件出错: \(msg)"
        }
    }
}

public struct Encryptor {
    static func encrypt(file: URL, key: String, write: URL) throws {
        guard let data = try? Data(contentsOf: file) else {
            print("Encryptor 加载文件出错")
            return
        }
        
        guard let encryptedData = try encrypt(data: data, key: key) else {
            print("Encryptor 加密文件出错")
            return
        }
        
        try encryptedData.write(to: write,options: [.withoutOverwriting])
    }
    
    static func decrypt(file: URL, key: String, write: URL) throws {
        guard let data = try? Data(contentsOf: file) else {
            print("Encryptor 加载加密文件出错")
            return
        }
        
        guard let decryptedData = try decrypt(data: data, key: key) else {
            print("Encryptor 解密文件出错")
            return
        }
        
        try decryptedData.write(to: write)
    }
    
    static func encrypt(data: Data, key: String) throws -> Data? {
        let paddedKey = Padding.zeroPadding.add(to: key.bytes, blockSize: AES.blockSize)
        
        do {
            let aes = try AES(key: paddedKey, blockMode: ECB())
            let encryptedData = try aes.encrypt(data.bytes)
            let data = Data(bytes: encryptedData, count: encryptedData.count)
            return data
        } catch  {
            throw EncryptorError.encryptError(error.localizedDescription)
        }
    }
    
    static func decrypt(data: Data, key: String) throws -> Data? {
        let paddedKey = Padding.zeroPadding.add(to: key.bytes, blockSize: AES.blockSize)
        
        do {
            let aes = try AES(key: paddedKey, blockMode: ECB())
            let decryptedData = try aes.decrypt(data.bytes)
            let data = Data(bytes: decryptedData, count: decryptedData.count)
            return data
        } catch  {
            throw EncryptorError.decryptError(error.localizedDescription)
        }
    }
}
