//
//  NetworkingTasks.swift
//  newsApp
//
//  Created by Anna Kulaieva on 25.11.2020.
//

import Foundation
import UIKit

struct NetworkingTasks {
    
    @discardableResult static func taskForRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    static func downloadImage(urlString: String?, completion: @escaping (UIImage?, Error?) -> Void) {
        if let urlString = urlString, let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    completion(image, nil)
                }
            }
            task.resume()
        }
        else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [ NSLocalizedDescriptionKey: "No image url provided"]))
        }
    }
}
