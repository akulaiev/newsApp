//
//  NewsTableViewCell.swift
//  newsApp
//
//  Created by Anna Kulaieva on 25.11.2020.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var newsPicture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
        
    func configure(with articleInfo: inout Article?, targetVC: UIViewController) {
        if let article = articleInfo {
            titleLabel.text = article.title ?? ""
            descriptionLabel.text = article.articleDescription ?? ""
            sourceLabel.text = article.source?.name ?? ""
            if let author = article.author {
                authorLabel.text = author.contains("{") || author.contains("/") ? "by \(article.source?.name ?? "unknown author")" : "by \(author)"
            }
            else {
                authorLabel.text = "by \(article.source?.name ?? "unknown author")"
            }
            if let articleImage = article.image {
                self.newsPicture.image = articleImage
            }
            else {
                NetworkingTasks.downloadImage(urlString: article.urlToImage) { (image, error) in
                    DispatchQueue.main.async { [self] in
                        if let image = image {
                            self.newsPicture.image = HelperMethods.resizeImage(originalImage: image, targetHeight: newsPicture.bounds.height)
                        }
                        else {
                            print(error?.localizedDescription ?? "An error with image loading has occured")
                            self.newsPicture.image = UIImage(named: "imagePlaceholder")
                        }
                        article.image = self.newsPicture.image
                    }
                }
            }
        }
        else {
            titleLabel.text = ""
            newsPicture.image = nil
            descriptionLabel.text = ""
            authorLabel.text! = ""
            sourceLabel.text! = ""
        }
    }
    
}
