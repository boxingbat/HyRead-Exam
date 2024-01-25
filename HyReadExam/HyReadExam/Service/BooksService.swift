//
//  BooksService.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/25.
//

import Foundation
import RxSwift

import Foundation
import RxSwift

class BooksService {

    func fetchBooks() -> Observable<[Book]> {
        return APIManager.shared.fetchBooks().flatMap { books -> Observable<[Book]> in
            DispatchQueue.main.async {
                let saveCompletion: (Error?) -> Void = { error in
                    if let error = error {
                        print("Error saving books to Core Data: \(error)")
                    }
                }
                CoreDataManager.shared.saveBooksToCoreData(books: books, completion: saveCompletion)
            }
            return .just(books)
        }
    }

    func loadBooksFromCoreData() -> Observable<[Book]> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                CoreDataManager.shared.loadBooksFromCoreData { result in
                    switch result {
                    case .success(let books):
                        observer.onNext(books)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            }
            return Disposables.create()
        }
    }
}

