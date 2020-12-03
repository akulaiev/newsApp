//
//  NewsListViewController.swift
//  newsApp
//
//  Created by Anna Kulaieva on 25.11.2020.
//

import UIKit

class NewsListViewController: UIViewController {

    @IBOutlet weak var newsListTableView: UITableView!
    @IBOutlet weak var newsSearchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var refreshControl: UIRefreshControl!
    var networkingManager: NewsAPIClient = NewsAPIClient()
    var newsModel: NewsDataModel!
    var newsUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsSearchBar.delegate = self
        newsListTableView.delegate = self
        newsListTableView.dataSource = self
        newsListTableView.prefetchDataSource = self
        newsListTableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "newsCell")
        newsListTableView.estimatedRowHeight = 200
        newsListTableView.rowHeight = UITableView.automaticDimension
        newsListTableView.separatorColor = .black
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        newsListTableView.addSubview(refreshControl)
        newsModel = NewsDataModel(delegate: self)
        newsModel.fetchNewsData(searchQuery: "")
        if newsModel.filterOptions.isEmpty {
            filterButton.isEnabled = false
        }
    }
    
    @objc func refresh(sender: AnyObject) {
        newsModel.fetchedArticles.removeAll()
        newsModel.currentPage = 0
        self.newsListTableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFilter" {
            let filterVC = segue.destination as! FilterViewController
            filterVC.allFilters = newsModel.filterOptions
            filterVC.delegate = self
        }
        else if segue.identifier == "toWebView" {
            let webViewVC = segue.destination as! OpenLinkViewController
            webViewVC.urlToOpen = newsUrl
        }
    }
}

extension NewsListViewController: NewsViewModelDelegate {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            newsListTableView.reloadData()
            return
        }
        let indexPathsToReload = visibleIndexPathsToReload(indexPaths: newIndexPathsToReload)
        newsListTableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
    func onFetchFailed(with reason: String) {
        HelperMethods.showFailureAlert(title: "Warning", message: reason, controller: self)
    }
}

extension NewsListViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsModel.totalArticlesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell") as! NewsTableViewCell
        var currentArticle = isLoadingCell(for: indexPath) ? nil : newsModel.fetchedArticles[indexPath.row]
        cell.configure(with: &currentArticle, targetVC: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            newsModel.fetchNewsData(searchQuery: "")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if newsModel.fetchedArticles.count > indexPath.row {
            newsUrl = newsModel.fetchedArticles[indexPath.row].url ?? ""
            performSegue(withIdentifier: "toWebView", sender: self)
        }
    }
}

private extension NewsListViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= newsModel.fetchedArticles.count
    }

    func visibleIndexPathsToReload(indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = newsListTableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}

extension NewsListViewController: PopupDelegate {
    func popupValueSelected(value: [String : [String]]) {
        newsModel.chosenFilters = value
        refresh(sender: self)
    }
}

extension NewsListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        refresh(sender: self)
        newsModel.fetchNewsData(searchQuery: searchBar.text ?? "")
        searchBar.text = ""
    }
}

extension UIImage {
    func getImageRatio() -> CGFloat {
        return CGFloat(self.size.width / self.size.height)
    }
}
