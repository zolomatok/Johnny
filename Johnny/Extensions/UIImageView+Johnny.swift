//
//  UIImageView+Johnny.swift
//  Johnny
//
//  Created by Zolo on 6/27/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import UIKit
import Async

extension UIImageView {
    
    public func imageWithURL(url: String?, placeholder: UIImage? = nil, completion: ((image: UIImage?)->Void)? = nil) {
        
        // Handle nil
        guard let url = url else {
            completion?(image: nil)
            return
        }
        
        
        // Set placeholder
        if let placeholder = placeholder {
            self.image = placeholder
        }
        
        
        // Get cache
        Johnny.pull(url) { (cached: UIImage?) in
            
            
            // Return cached value
            if let cached = cached {
                if completion == nil { self.image = cached }
                else { completion?(image: cached) }
                return
            }
            
            
            // Download from URL
            var img: UIImage?
            Async.background {
                let data = NSData(contentsOfURL: NSURL(string: url)!)
                if let data = data {
                    img = UIImage(data: data)
                    img = self.resizeImage(img)
                }
            }.main {
                
                // Save to cache & return
                if img != nil { Johnny.cache(img, key: url) }
                if completion == nil {
                    self.image = img
                }
                else { completion?(image: img) }
            }
        }
    }
    
    
    private func resizeImage(img: UIImage?) -> UIImage? {
        
        guard let img = img else { return nil }
        
        
        // Get target size
        var targetSize: CGSize
        switch self.contentMode {
        case .ScaleToFill:
            targetSize = bounds.size
        case .ScaleAspectFit:
            targetSize = img.size.aspectFitSize(bounds.size)
        case .ScaleAspectFill:
            targetSize = img.size.aspectFillSize(bounds.size)
        default:
            return img
        }
        assert(bounds.size.width > 0 && bounds.size.height > 0, "Expected non-zero size.")

        
        // Avoid unnecessary computations
        if (targetSize.width == img.size.width && targetSize.height == img.size.height) {
            return img
        }
        
        
        // Resize
        let resizedImage = img.scaledToSize(targetSize)
        return resizedImage
    }
}