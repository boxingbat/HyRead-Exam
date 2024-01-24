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

    var books: Observable<[Book]> {
        return booksSubject.asObservable()
    }

    private let booksSubject = PublishSubject<[Book]>()

    func fetchBooks() {
            APIManager.shared.fetchBooks()
                .subscribe(onNext: { [weak self] newBooks in
                    newBooks.forEach { book in
                        print("""
                              UUID: \(book.uuid)
                              Title: \(book.title)
                              Cover URL: \(book.coverUrl)
                              Publish Date: \(book.publishDate)
                              Publisher: \(book.publisher)
                              Author: \(book.author)
                              """)
                    }
                    self?.booksSubject.onNext(newBooks)
                }, onError: { error in
                    print("Error fetching books: \(error)")
                })
                .disposed(by: disposeBag)
        }

}
