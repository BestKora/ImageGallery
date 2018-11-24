//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Tatiana Kornilova on 24/11/2018.
//  Copyright © 2018 BestKora. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewController: UICollectionViewController {
    
    // MARK: - Public API, Model
    
    var imageCollection = [ImageModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let im1 = ImageModel(url: URL(string:
            "http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg")!,
                             aspectRatio: 0.67)
        let im2 = ImageModel(url: URL(string:
            "https://adriatic-lines.com/wp-content/uploads/2015/04/canal-of-Venice.jpg")!,
                             aspectRatio: 1.5)
       
        let im3 = ImageModel(url: URL(string:
            "http://www.picture-newsletter.com/arctic/arctic-12.jpg")!,
                             aspectRatio: 0.8)
        imageCollection += [im1,im2, im3]
      
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView,
                  numberOfItemsInSection section: Int) -> Int {
        return imageCollection.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "Image Cell",
            for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.imageURL = imageCollection[indexPath.item].url
        }
        return cell
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
}
