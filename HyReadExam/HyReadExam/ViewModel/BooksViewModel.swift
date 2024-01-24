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
            .observe(on: MainScheduler.instance) // switch to main thread
            .subscribe(onNext: { [weak self] newBooks in
                // update core data on main thread
                DispatchQueue.main.async {
                    CoreDataManager.shared.deleteAllBooksFromCoreData { error in
                        if let error = error {
                            print("Error deleting books from Core Data: \(error)")
                        } else {
                            CoreDataManager.shared.saveBooksToCoreData(books: newBooks) { error in
                                if let error = error {
                                    print("Error saving books to Core Data: \(error)")
                                }
                            }
                        }
                    }
                    self?.booksData = newBooks
                    self?.booksSubject.onNext(newBooks)
                }
            }, onError: { [weak self] error in
                print("Error fetching books: \(error)")
                // update core data on main thread
                DispatchQueue.main.async {
                    CoreDataManager.shared.loadBooksFromCoreData { result in
                        switch result {
                        case .success(let books):
                            self?.booksData = books
                            self?.booksSubject.onNext(books)
                        case .failure(let error):
                            print("Error loading books from Core Data: \(error)")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    func bookAt(_ index: Int) -> Book? {
        if index < booksData.count {
            return booksData[index]
        }
        return nil
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

