//
//  UIImageView+Johnny.swift
//  Johnny
//
//  Created by Zolo on 6/27/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import UIKit

extension UIImageView {
    
    open func imageWithURL(_ url: String?, placeholder: UIImage? = nil, completion: ((_ image: UIImage?)->Void)? = nil) {
        
        // Handle nil
        guard let url = url else {
            completion?(nil)
            return
        }
        
        
        // Set placeholder
        if let placeholder = placeholder {
            self.image = placeholder
        }
        
        
        // Get cache
        Johnny.pull(url) { (cached: Image?) in
            
            
            // Return cached value
            if let cached = cached {
                if completion == nil { self.image = cached.uiImage() }
                else { completion?(cached.uiImage()) }
                return
            }
            
            
            // Download from URL
            var img: UIImage?
            DispatchQueue.global(qos: .background).async {
                let data = try? Data(contentsOf: URL(string: url)!)
                if let data = data {
                    img = UIImage(data: data)
//                    img = self.resizeImage(img)
                }
                
                DispatchQueue.main.async {
                    // Save to cache & return
                    if let img = img { Johnny.cache(Image(image: img), key: url) }
                    if completion == nil {
                        self.image = img
                    }
                    else { completion?(img) }
                }
            }
        }
    }
    
    
    fileprivate func resizeImage(_ img: UIImage?) -> UIImage? {
        
        guard let img = img else { return nil }
        
        
        // Get target size
        var targetSize: CGSize
        switch self.contentMode {
        case .scaleToFill:
            targetSize = bounds.size
        case .scaleAspectFit:
            targetSize = img.size.aspectFitSize(bounds.size)
        case .scaleAspectFill:
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
