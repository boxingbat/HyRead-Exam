//
//  BooksViewModel.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/24.
//

import Foundation
import RxSwift

class BooksViewModel {

    private let disposeBag = DisposeBag()
    private var booksData: [Book] = []

    private let booksSubject = PublishSubject<[Book]>()

    var books: Observable<[Book]> {
        return booksSubject.asObservable()
    }

    func fetchBooks() {
        APIManager.shared.fetchBooks()
            .subscribe(onNext: { [weak self] newBooks in
                self?.printBooks(newBooks)

                self?.booksData = newBooks

                self?.booksSubject.onNext(newBooks)
            }, onError: { error in
                print("Error fetching books: \(error)")
            })
            .disposed(by: disposeBag)
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

