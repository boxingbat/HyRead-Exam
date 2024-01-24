//
//  BooksViewModel.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/24.
//

import Foundation
import CoreData
import RxSwift

class BooksViewModel {

    private let disposeBag = DisposeBag()
    private var booksData: [Book] = []

    private let booksSubject = PublishSubject<[Book]>()

    var books: Observable<[Book]> {
        return booksSubject.asObservable()
    }

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func fetchBooks() {
        APIManager.shared.fetchBooks()
            .subscribe(onNext: { [weak self] newBooks in
                self?.deleteAllBooksFromCoreData()
                self?.saveBooksToCoreData(books: newBooks)
                self?.booksData = newBooks
                self?.booksSubject.onNext(newBooks)
                self?.printBooks(newBooks)
            }, onError: { [weak self] error in
                print("Error fetching books: \(error)")
                self?.loadBooksFromCoreData()
            })
            .disposed(by: disposeBag)
    }

    private func loadBooksFromCoreData() {
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        do {
            let bookEntities = try context.fetch(fetchRequest)
            let books = bookEntities.map { Book(uuid: Int($0.uuid), title: $0.title ?? "", coverUrl: $0.coverUrl ?? "", publishDate: $0.publishDate ?? "", publisher: $0.publisher ?? "", author: $0.author ?? "") }
            self.booksData = books
            self.booksSubject.onNext(books)
        } catch {
            print("Error loading books from Core Data: \(error)")
        }
    }

    private func deleteAllBooksFromCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BookEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting books from Core Data: \(error)")
        }
    }

    private func saveBooksToCoreData(books: [Book]) {
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
        } catch {
            print("Error saving books to Core Data: \(error)")
        }
    }

    private func printBooks(_ books: [Book]) {
        books.forEach { book in
            print("""
                  UUID: \(book.uuid)
                  Title: \(book.title)
                  Cover URL: \(book.coverUrl)
                  Publish Date: \(book.publishDate)
                  Publisher: \(book.publisher)
                  Author: \(book.author)
                  """)
        }
    }
    
    func bookAt(_ index: Int) -> Book? {
        if index < booksData.count {
            return booksData[index]
        }
        return nil
    }
}

