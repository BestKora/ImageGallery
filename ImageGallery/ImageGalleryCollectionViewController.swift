//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Tatiana Kornilova on 24/11/2018.
//  Copyright © 2018 BestKora. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewController: UICollectionViewController,
    UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate,
    UICollectionViewDropDelegate {
    
    // MARK: - Public API, Model
    
    var imageCollection = [ImageModel]()
    
   // MARK: - Live cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.dragDelegate = self
        collectionView!.dropDelegate = self
        
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        flowLayout?.invalidateLayout()
    }
    
    // MARK: Vars, Constants
    
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
    
    // MARK: UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        itemsForAddingTo session: UIDragSession,
                        at indexPath: IndexPath,
                        point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let itemCell = collectionView?.cellForItem(at: indexPath)
            as? ImageCollectionViewCell,
            let image = itemCell.imageView.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItem.localObject = imageCollection[indexPath.item]
            return [dragItem]
        } else {
            return []
        }
    }
    
    // MARK: UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView,
                        canHandle session: UIDropSession) -> Bool {
        let isSelf = (session.localDragSession?.localContext as?
            UICollectionView) == collectionView
        if isSelf {
            return session.canLoadObjects(ofClass: UIImage.self)
        } else {
            return session.canLoadObjects(ofClass: NSURL.self) &&
                session.canLoadObjects(ofClass: UIImage.self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?
        ) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as?
            UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy,
                                            intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ??
            IndexPath(item: 0, section: 0)
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath { // Drag locally
                
                collectionView.performBatchUpdates({
                    let imageInfo = imageCollection.remove(at: sourceIndexPath.item)
                    imageCollection.insert(imageInfo, at: destinationIndexPath.item)
                    
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else {  // Drag from other app
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(
                        insertionIndexPath: destinationIndexPath,
                        reuseIdentifier: "DropPlaceholderCell"
                    )
                )
                
                var imageURLLocal: URL?
                var aspectRatioLocal: Double?
                
                // Load UIImage
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) {
                    (provider, error) in
                    DispatchQueue.main.async {
                        if let image = provider as? UIImage {
                            aspectRatioLocal = Double(image.size.width) /
                                Double(image.size.height)
                        }
                    }
                }
                // Load URL
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) {
                    (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider as? URL {
                            imageURLLocal = url.imageURL
                        }
                        if imageURLLocal != nil, aspectRatioLocal != nil {
                            placeholderContext.commitInsertion(dataSourceUpdates:{
                                insertionIndexPath in
                                self.imageCollection.insert(
                                    ImageModel(url: imageURLLocal!,
                                               aspectRatio: aspectRatioLocal!),
                                    at: insertionIndexPath.item)
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Image":
                if let imageCell = sender as? ImageCollectionViewCell,
                    let indexPath = collectionView?.indexPath(for: imageCell),
                    let imgvc = segue.destination as? ImageViewController {
                    imgvc.imageURL = imageCollection[indexPath.item].url
                }
            default: break
            }
        }
    }
}
