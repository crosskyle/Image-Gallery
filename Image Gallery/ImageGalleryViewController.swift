//
//  ImageGalleryViewController.swift
//  Image Gallery
//
//  Created by Kyle Cross on 1/20/18.
//  Copyright © 2018 Kyle Cross. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout {
    
    var imageGallery: ImageGallery?
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
            collectionView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(scaleCollectionViewCells(with:))))
        }
    }
    
    private var scaleForCollectionViewCell: CGFloat = 1.0
    
    @objc func scaleCollectionViewCells(with recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            scaleForCollectionViewCell *= recognizer.scale
            recognizer.scale = 1
            collectionView.collectionViewLayout.invalidateLayout()
        default:
            break
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let aspectRatio = imageGallery?.images[indexPath.item].aspectRatio ?? 1
        let cellHeight: CGFloat = 200 * scaleForCollectionViewCell / aspectRatio
        return CGSize(width: 200 * scaleForCollectionViewCell, height: cellHeight)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let imageGallery = imageGallery {
            return imageGallery.images.count
        } else {
            return 0
        }
        
    }
    
    private let reuseIdentifier = "ImageCell"
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        if let imageCell = cell as? ImageGalleryCollectionViewCell {
            if let imageUrl = imageGallery?.images[indexPath.item].url {
                fetchImage(imageCell: imageCell, url: imageUrl)
                
            }
        }
        return cell
    }
    
    private func fetchImage(imageCell: ImageGalleryCollectionViewCell, url: URL)  {
        DispatchQueue.global(qos: .userInitiated).async {
            let urlContents = try? Data(contentsOf: url)
            DispatchQueue.main.async {
                if let imageData = urlContents {
                    imageCell.imageView.image = UIImage(data: imageData)

                }
            }
        }
    }
    
    // MARK: - UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let image = (collectionView.cellForItem(at: indexPath) as? ImageGalleryCollectionViewCell)?.imageView?.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItem.localObject = image
            return[dragItem]
        } else {
            return []
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    // MARK: - UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                collectionView.performBatchUpdates({
                    if let draggedImage = imageGallery?.images.remove(at: sourceIndexPath.item) {
                        imageGallery?.images.insert(draggedImage, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    }
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else {
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell")
                )
                
                var image = ImageGallery.Image()
                
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    if let loadedImage = provider as? UIImage {
                        image.aspectRatio = loadedImage.size.width/loadedImage.size.height
                    }
                }
                
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { [weak self] (provider, error) in
                    if let url = provider as? URL {
                        image.url = url.imageURL
                    }
                    DispatchQueue.main.async {
                        placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                            self?.imageGallery?.images.insert(image, at: insertionIndexPath.item)
                        })
                    }
                }
            }
        }
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination.contents as? ImageViewController else { return }
        if let cell = sender as? ImageGalleryCollectionViewCell {
            vc.image = cell.imageView.image
        }
    }
    
}
