//
//  NewsAPIResponse.swift
//  newsApp
//
//  Created by Anna Kulaieva on 25.11.2020.
//

import Foundation
import UIKit

class NewsInfo: Codable {
    let status: String
    let totalResults: Int
    var articles: [Article]
}

class Article: Codable {
    let source: Source?
    let author: String?
    let title: String?
    let articleDescription: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    var image: UIImage? = nil

    enum CodingKeys: String, CodingKey {
        case source, author, title
        case articleDescription = "description"
        case url, urlToImage, publishedAt, content
    }
}

struct Source: Codable {
    let id: String?
    let name: String?
}

struct SourceFiltersResponse: Codable {
    let status: String
    let sources: [SourceFilter]
}

struct SourceFilter: Codable {
    let id, name, sourceDescription: String
    let url: String
    let category: Category
    let language: Language
    let country: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case sourceDescription = "description"
        case url, category, language, country
    }
}

enum Category: String, Codable {
    case business = "business"
    case entertainment = "entertainment"
    case general = "general"
    case health = "health"
    case science = "science"
    case sports = "sports"
    case technology = "technology"
}

enum Language: String, Codable {
    case en = "en"
}
