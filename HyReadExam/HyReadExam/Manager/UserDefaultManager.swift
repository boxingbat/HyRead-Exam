//
//  UserDefaultManager.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/24.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard

    private init() {}

    private let favoritesKey = "favorites"

    var favoriteBookUUIDs: [Int] {
        get {
            return userDefaults.array(forKey: favoritesKey) as? [Int] ?? []
        }
        set {
            userDefaults.set(newValue, forKey: favoritesKey)
        }
    }
}

