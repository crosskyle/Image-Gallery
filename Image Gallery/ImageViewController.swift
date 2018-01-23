//
//  ImageViewController.swift
//  Image Gallery
//
//  Created by Kyle Cross on 1/23/18.
//  Copyright © 2018 Kyle Cross. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageView = UIImageView()
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            scrollView?.zoomScale = 1
            imageView.image = newValue
            let size = newValue?.size ?? CGSize.zero
            imageView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            scrollViewHeight?.constant = size.height
            scrollViewWidth?.constant = size.width
            let safeZoneBounds = UIEdgeInsetsInsetRect(view.bounds, view.safeAreaInsets)
            if size.width >= 0, size.width >= 0 {
                scrollView?.zoomScale = max(safeZoneBounds.width/size.width, safeZoneBounds.height/size.height)
            }
        }
    }
    
    
    // MARK: - Scroll view outlets
    
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(imageView)
        }
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewHeight.constant = scrollView.contentSize.height
        scrollViewWidth.constant = scrollView.contentSize.width
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
