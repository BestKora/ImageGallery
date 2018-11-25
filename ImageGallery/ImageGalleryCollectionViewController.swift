//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Tatiana Kornilova on 24/11/2018.
//  Copyright © 2018 BestKora. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewController: UICollectionViewController,
    UICollectionViewDelegateFlowLayout {
    
    // MARK: - Public API, Model
    
    var imageCollection = [ImageModel]()
    
   // MARK: - Live cycle methods
    
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
        
        collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(
            target: self,
            action: #selector(ImageGalleryCollectionViewController.zoom(_:)))
        )
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    private struct Constants {
        static let columnCount = 3.0
        static let minWidthRation = CGFloat(0.03)
    }
    
      // MARK: Pinch GestureR ecognizer
    
    private var boundsCollectionWidth: CGFloat  {return (collectionView?.bounds.width)!}
    private var gapItems: CGFloat  {return (flowLayout?.minimumInteritemSpacing)! *
        CGFloat((Constants.columnCount - 1.0))}
    private var gapSections: CGFloat  {return (flowLayout?.sectionInset.right)! * 2.0}
    
    // MARK: Pinch Gesture Recognizer
    
    var scale: CGFloat = 1  {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    @objc func zoom(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    var predefinedWidth:CGFloat {
        let width = floor((boundsCollectionWidth - gapItems - gapSections)
            / CGFloat(Constants.columnCount)) * scale
        return  min (max (width , boundsCollectionWidth * Constants.minWidthRation),
                     boundsCollectionWidth)}
    
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
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = predefinedWidth
        let aspectRatio = CGFloat(imageCollection[indexPath.item].aspectRatio)
        return CGSize(width: width, height: width / aspectRatio)
        
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
