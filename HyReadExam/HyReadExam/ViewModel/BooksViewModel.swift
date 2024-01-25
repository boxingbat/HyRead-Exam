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
    private let booksService: BooksService
    private let errorSubject = PublishSubject<String>()

    private let booksSubject = PublishSubject<[Book]>()

    var books: Observable<[Book]> {
        return booksSubject.asObservable()
    }

    var errors: Observable<String> {
        return errorSubject.asObservable()
    }

    init(booksService: BooksService) {
            self.booksService = booksService
        }
    func fetchBooks() {
            booksService.fetchBooks()
                .observe(on: MainScheduler.instance)
                .catch { [weak self] error in
                    self?.errorSubject.onNext("Failed to fetch books: \(error.localizedDescription)")
                    return Observable.empty()
                }
                .subscribe(onNext: { [weak self] newBooks in
                    self?.booksSubject.onNext(newBooks)
                })
                .disposed(by: disposeBag)
        }

        private func loadBooksFromCoreData() {
            booksService.loadBooksFromCoreData()
                .subscribe(onNext: { [weak self] books in
                    self?.booksSubject.onNext(books)
                }, onError: { error in
                    print("Error loading books from Core Data: \(error)")
                })
                .disposed(by: disposeBag)
        }

    //toggle the favorite status of a book
    func toggleFavorite(uuid: Int) {
            var favorites = UserDefaultsManager.shared.favoriteBookUUIDs
            if favorites.contains(uuid) {
                favorites.removeAll { $0 == uuid }
            } else {
                favorites.append(uuid)
            }
            UserDefaultsManager.shared.favoriteBookUUIDs = favorites
        }
    //checks if a book is a favorite
    func isFavorite(uuid: Int) -> Bool {
            let favorites = UserDefaultsManager.shared.favoriteBookUUIDs
            return favorites.contains(uuid)
        }

}

