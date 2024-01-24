//
//  CoreDataManager.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/24.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func loadBooksFromCoreData(completion: @escaping (Result<[Book], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        do {
            let bookEntities = try context.fetch(fetchRequest)
            let books = bookEntities.map { Book(uuid: Int($0.uuid), title: $0.title ?? "", coverUrl: $0.coverUrl ?? "", publishDate: $0.publishDate ?? "", publisher: $0.publisher ?? "", author: $0.author ?? "") }
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
        for book in books {
            let bookEntity = BookEntity(context: context)
            bookEntity.uuid = Int64(book.uuid)
            bookEntity.title = book.title
            bookEntity.coverUrl = book.coverUrl
            bookEntity.publishDate = book.publishDate
            bookEntity.publisher = book.publisher
            bookEntity.author = book.author
        }
        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

