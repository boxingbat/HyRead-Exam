//
//  CoreDataManager.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/24.
//

import CoreData
import UIKit
import CryptoKit

class CoreDataManager {
    static let shared = CoreDataManager()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let keychainKeyName = "com.HYReadExam.symmetrickey"

    func getSymmetricKey() -> SymmetricKey? {
           // make sure if there is any exsiting key
           if let key = KeychainManager.getKeyFromKeychain(for: keychainKeyName) {
               return key
           } else {
               let newKey = SymmetricKey(size: .bits256) // create a key
               let status = KeychainManager.saveKeyToKeychain(key: newKey, for: keychainKeyName)
               if status == errSecSuccess {
                   return newKey
               } else {
                   // simple error handleing
                   print("Error saving key to Keychain: \(status)")
                   return nil
               }
           }
       }
    func encrypt(_ text: String, using key: SymmetricKey) -> String? {
            guard let data = text.data(using: .utf8) else { return nil }
            let sealedBox = try? AES.GCM.seal(data, using: key)
            return sealedBox?.combined?.base64EncodedString()
        }

    func decrypt(_ encryptedText: String, using key: SymmetricKey) -> String? {
            guard let data = Data(base64Encoded: encryptedText),
                  let sealedBox = try? AES.GCM.SealedBox(combined: data),
                  let decryptedData = try? AES.GCM.open(sealedBox, using: key),
                  let decryptedString = String(data: decryptedData, encoding: .utf8) else { return nil }
            return decryptedString
        }

    func loadBooksFromCoreData(completion: @escaping (Result<[Book], Error>) -> Void) {
            guard let key = getSymmetricKey() else {
                completion(.failure(NSError(domain: "CoreDataManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve encryption key."])))
                return
            }

            let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
            do {
                let bookEntities = try context.fetch(fetchRequest)
                let books = bookEntities.compactMap { entity -> Book? in
                    guard let title = decrypt(entity.title ?? "", using: key),
                          let coverUrl = decrypt(entity.coverUrl ?? "", using: key),
                          let publishDate = decrypt(entity.publishDate ?? "", using: key),
                          let publisher = decrypt(entity.publisher ?? "", using: key),
                          let author = decrypt(entity.author ?? "", using: key) else {
                        return nil
                    }
                    return Book(uuid: Int(entity.uuid), title: title, coverUrl: coverUrl, publishDate: publishDate, publisher: publisher, author: author)
                }
                completion(.success(books))
            } catch {
                completion(.failure(error))
            }
        }

    func deleteAllBooksFromCoreData(completion: @escaping (Error?) -> Void) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BookEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func saveBooksToCoreData(books: [Book], completion: @escaping (Error?) -> Void) {
            guard let key = getSymmetricKey() else {
                completion(NSError(domain: "CoreDataManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve encryption key."]))
                return
            }

            for book in books {
                let bookEntity = BookEntity(context: context)
                bookEntity.uuid = Int64(book.uuid)
                bookEntity.title = encrypt(book.title, using: key)
                bookEntity.coverUrl = encrypt(book.coverUrl, using: key)
                bookEntity.publishDate = encrypt(book.publishDate, using: key)
                bookEntity.publisher = encrypt(book.publisher, using: key)
                bookEntity.author = encrypt(book.author, using: key)
            }
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
}

