//
//  NewsAPIClient.swift
//  newsApp
//
//  Created by Anna Kulaieva on 25.11.2020.
//

import Foundation
import UIKit

struct NewsAPIClient {
    
    let authToken: String = "b3dafdfbc58a4b36a27f1a5b066ec8d4"
    
    enum Endpoints {
        static let baseString = "https://newsapi.org/v2/"
        
        case topHeadlines
        case everything
        case sourceFilters
        
        var stringValue: String {
            switch self {
            case .topHeadlines: return Endpoints.baseString + "top-headlines"
            case .everything: return Endpoints.baseString + "everything"
            case .sourceFilters: return Endpoints.baseString + "sources"
            }
        }

        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    func getSourceFilters(completion: @escaping ([SourceFilter], Error?) -> Void) {
        guard var url: URLComponents = URLComponents(url: Endpoints.sourceFilters.url, resolvingAgainstBaseURL: true) else {
            print("An error with URL convertation has occured")
            return
        }
        url.queryItems = [URLQueryItem(name: "apiKey", value: authToken), URLQueryItem(name: "language", value: "en")]
        NetworkingTasks.taskForRequest(url: url.url!, responseType: SourceFiltersResponse.self) { (response, error) in
            guard let sourceFilters = response?.sources else {
                completion([], error)
                return
            }
            completion(sourceFilters, nil)
        }
    }
    
    func getNewsInfo(currentPage: Int, pageSize: Int, filters: [String : [String]], searchQuery: String, completion: @escaping (NewsInfo?, Error?) -> Void) {
        guard var url: URLComponents = URLComponents(url: Endpoints.topHeadlines.url, resolvingAgainstBaseURL: true) else {
            print("An error with URL convertation has occured")
            return
        }
        url.queryItems = [URLQueryItem(name: "apiKey", value: authToken), URLQueryItem(name: "page", value: "\(currentPage)"), URLQueryItem(name: "language", value: "en"), URLQueryItem(name: "pageSize", value: "\(pageSize)")]
        if searchQuery.isEmpty {
            for filterType in FilterType.asArray {
                if let chosenFilteroptions = filters[filterType.rawValue] {
                    let filterName = filterType.rawValue.lowercased() == "source" ? "sources" : filterType.rawValue.lowercased()
                    url.queryItems?.append(URLQueryItem(name: filterName, value: chosenFilteroptions.joined(separator: ",")))
                }
            }
        }
        else { url.queryItems?.append(URLQueryItem(name: "q", value: searchQuery)) }
        NetworkingTasks.taskForRequest(url: url.url!, responseType: NewsInfo.self) { (response, error) in
            completion(response, error)
        }
    }
    
}
