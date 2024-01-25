//
//  KeyChainManager.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/25.
//

import Foundation
import Security
import CryptoKit

class KeychainManager {

    static func saveKeyToKeychain(key: SymmetricKey, for keyName: String) -> OSStatus {
        let tag = keyName.data(using: .utf8)!
        let keyData = key.withUnsafeBytes {
            Data(Array($0))
        }
        let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag,
                                       kSecValueData as String: keyData,
                                       kSecAttrKeyClass as String: kSecAttrKeyClassSymmetric,
                                       kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked]
        return SecItemAdd(addquery as CFDictionary, nil)
    }

    static func getKeyFromKeychain(for keyName: String) -> SymmetricKey? {
        let tag = keyName.data(using: .utf8)!
        let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag,
                                       kSecReturnData as String: true,
                                       kSecAttrKeyClass as String: kSecAttrKeyClassSymmetric]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == noErr, let keyData = item as? Data else { return nil }
        return SymmetricKey(data: keyData)
    }
}

