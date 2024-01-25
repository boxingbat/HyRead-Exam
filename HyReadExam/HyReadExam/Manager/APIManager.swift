//
//  APIManager.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/23.
//

import Foundation
import RxSwift

class APIManager {

    static let shared = APIManager()

    func fetchBooks() -> Observable<[Book]> {
        return Observable.create { observer in
            guard let url = URL(string: "https://mservice.ebook.hyread.com.tw/exam/user-list") else {
                observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(error)
                } else if let data = data {
                    do {
                        let books = try JSONDecoder().decode([Book].self, from: data)
                        observer.onNext(books)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                }
            }
            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
}

