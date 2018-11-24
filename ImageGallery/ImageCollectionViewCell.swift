//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Tatiana Kornilova on 20/06/2018.
//  Copyright © 2018 Stanford University. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Public API
    var imageURL: URL? {
        didSet { updateUI()}
    }
    
    private func updateUI() {
        if let url = imageURL{
            imageView.image = nil
            spinner?.startAnimating()
            
            DispatchQueue.global(qos: .userInitiated).async {
                    let urlContents = try? Data(contentsOf: url)
                    DispatchQueue.main.async {
                        if let imageData = urlContents,
                            url == self.imageURL,
                            let image = UIImage(data: imageData) {
                            self.imageView?.image =  image
                        }
                        self.spinner?.stopAnimating()
                    }
            }
        }
    }
}
