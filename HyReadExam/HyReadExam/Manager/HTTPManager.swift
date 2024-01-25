//
//  HTTPManager.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/23.
//

import Foundation

class HTTPRequestManager {

    static let shared = HTTPRequestManager()

    private init() {}

    func request(url: URL, method: String, headers: [String: String]? = nil, body: Data? = nil, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        if let body = body {
            request.httpBody = body
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                completion(data, response, error)
            }
        }
        task.resume()
    }
}

