//
//  NewsDataModel.swift
//  newsApp
//
//  Created by Anna Kulaieva on 25.11.2020.
//

import Foundation
import UIKit

struct NewsFilters: Codable {
    let categoryOptions: [String]
    let countryOptions: [CountryOptions]
    var sourceOptions: [SourceFilter] = []
}

struct CountryOptions: Codable {
    let code, name: String
}

enum FilterType: String, CaseIterable {
    
    case country = "Country", source = "Source", category = "Category"

        static var asArray: [FilterType] { return self.allCases }

        func asInt() -> Int {
            return FilterType.asArray.firstIndex(of: self)!
        }
}

protocol NewsViewModelDelegate: class {

    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
}

class NewsDataModel {
    
    var delegate: NewsViewModelDelegate?
    var isFetchInProgress = false
    let apiClient = NewsAPIClient()
    let pageSize = 30
    var totalArticlesCount = 0
    var currentPage = 0
    
    var fetchedArticles: [Article] = []
    var fetchedArticleImages: [UIImage] = []
    var filterOptions: [String : [String]] = [:]
    var chosenFilters: [String : [String]] = [:]
    private var filters: NewsFilters!
    
    init(delegate: NewsViewModelDelegate) {
        self.delegate = delegate
        guard let filters = HelperMethods.readFiltersInfoJSON() else {
            print("An error with filters fetch from JSON has occured")
            return
        }
        self.filters = filters
        apiClient.getSourceFilters { (sourceOptions, error) in
            DispatchQueue.main.async {
                if sourceOptions.count > 0 {
                    self.filters.sourceOptions = sourceOptions
                    self.filterOptions["Country"] = self.filters.countryOptions.map({$0.name})
                    self.filterOptions["Source"] = sourceOptions.map({$0.name})
                    self.filterOptions["Category"] = self.filters.categoryOptions
                    let newsListVc = self.delegate as! NewsListViewController
                    newsListVc.filterButton.isEnabled = true
                }
                else {
                    print(error?.localizedDescription ?? "An error with sources fetch has occured")
                }
            }
        }
    }
    
    func fetchNewsData(searchQuery: String) {
        convertCountryFilterNames()
        guard !isFetchInProgress else {return}
        isFetchInProgress = true
        apiClient.getNewsInfo(currentPage: currentPage, pageSize: pageSize, filters: chosenFilters, searchQuery: searchQuery) { (response, error) in
            DispatchQueue.main.async {
                self.isFetchInProgress = false
                guard let response = response else {
                    self.delegate?.onFetchFailed(with: error?.localizedDescription ?? "An error has occured")
                    return
                }
                self.currentPage += 1
                self.fetchedArticles.append(contentsOf: response.articles)
                self.totalArticlesCount = response.totalResults < 100 ? response.totalResults : 100
                if self.currentPage > 1 {
                    let indexPathsToReload = self.calculateIndexPathsToReload(from: response.articles, total: response.totalResults)
                    self.delegate?.onFetchCompleted(with: indexPathsToReload)
                }
                else {
                    self.delegate?.onFetchCompleted(with: .none)
                }
            }
        }
    }
    
    func calculateIndexPathsToReload(from newArticles: [Article], total: Int) -> [IndexPath] {
        let startIndex = total - newArticles.count
        let endIndex = startIndex + newArticles.count
        var indexPaths: [IndexPath] = []
        for i in startIndex..<endIndex {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        return indexPaths
    }
    
    private func convertCountryFilterNames() {
        guard chosenFilters.count > 0 else {
            return
        }
        for filterType in FilterType.asArray {
            if let optionsForFilterType = chosenFilters[filterType.rawValue] {
                var formattedOption = ""
                for (i, fetchedOption) in optionsForFilterType.enumerated() {
                    if filterType == .source {
                        for source in filters.sourceOptions {
                            if source.name == fetchedOption {
                                formattedOption = source.id}
                        }
                    }
                    else {
                        formattedOption = fetchedOption.lowercased().replacingOccurrences(of: " ", with: "-")
                        if filterType == .country {
                            for country in filters.countryOptions {
                                if country.name == fetchedOption {formattedOption = country.code}
                            }
                        }
                    }
                    chosenFilters[filterType.rawValue]![i] = formattedOption
                }
            }
        }
    }
}
