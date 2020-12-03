//
//  HelperMethods.swift
//  newsApp
//
//  Created by Anna Kulaieva on 25.11.2020.
//

import Foundation
import UIKit

struct HelperMethods {
    
    static func showFailureAlert(title: String, message: String, controller: UIViewController?) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            if let controller = controller {
                controller.present(alertVC, animated: true)
            }
            else {
                let viewController = UIApplication.shared.windows.first!.rootViewController as! NewsListViewController
                viewController.present(alertVC, animated: true)
            }
        }
    }
    
    static func resizeImage(originalImage: UIImage, targetHeight: CGFloat) -> UIImage? {
        let size = originalImage.size
        var newSize: CGSize
        let resizeRatio = targetHeight / originalImage.size.height
        newSize = CGSize.init(width: size.width * resizeRatio, height: size.height * resizeRatio)
        let rect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        originalImage.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func readFiltersInfoJSON() -> NewsFilters? {
        if let url = Bundle.main.url(forResource: "NewsFilters", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(NewsFilters.self, from: data)
                return jsonData
            }
            catch {
                print("error:\(error)")
                return nil
            }
        }
        return nil
    }
}
