//
//  ImageGallery.swift
//  Image Gallery
//
//  Created by Kyle Cross on 1/16/18.
//  Copyright © 2018 Kyle Cross. All rights reserved.
//

import Foundation
import UIKit

class ImageGallery {
    var images: [Image] = []
    var name: String = "Untitled 1"
    
    struct Image {
        var url: URL?
        var aspectRatio: CGFloat?
    }
    
    init(name: String) {
        self.name = name
    }
}
