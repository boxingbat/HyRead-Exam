//
//  UserDefaultManager.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/24.
//

import Foundation
import CryptoKit

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard

    private let favoritesKey = "favorites"

    private var symmetricKey: SymmetricKey? {
        return CoreDataManager.shared.getSymmetricKey()
    }

    var favoriteBookUUIDs: [Int] {
        get {
            guard let key = symmetricKey,
                  let encryptedData = userDefaults.data(forKey: favoritesKey),
                  let decryptedData = decrypt(encryptedData, using: key),
                  let decryptedArray = try? JSONDecoder().decode([Int].self, from: decryptedData) else {
                return []
            }
            return decryptedArray
        }
        set {
            guard let key = symmetricKey,
                  let data = try? JSONEncoder().encode(newValue),
                  let encryptedData = encrypt(data, using: key) else {
                return
            }
            userDefaults.set(encryptedData, forKey: favoritesKey)
        }
    }

    private func encrypt(_ data: Data, using key: SymmetricKey) -> Data? {
        try? AES.GCM.seal(data, using: key).combined
    }

    private func decrypt(_ data: Data, using key: SymmetricKey) -> Data? {
        guard let sealedBox = try? AES.GCM.SealedBox(combined: data),
              let decryptedData = try? AES.GCM.open(sealedBox, using: key) else {
            return nil
        }
        return decryptedData
    }
}


