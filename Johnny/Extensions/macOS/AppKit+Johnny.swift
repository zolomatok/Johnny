//
//  AppKit+Johnny.swift
//  Johnny
//
//  Created by Zolo on 7/4/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation
import AppKit


// See: https://github.com/AFNetworking/AFNetworking/issues/2572#issuecomment-115854482
private let imgLock = NSLock()
class Image: Codable {
    let data: Data
    init?(image: NSImage?) {
        guard let image = image else { return nil }
        guard let d = image.tiffRepresentation else { return nil }
        data = d
    }
    
    func nsImage() -> NSImage {
        imgLock.lock()
        let img = NSImage(data: data)!
        imgLock.unlock()
        return img
    }
}


extension NSImageView {
    
    open func imageWithURL(_ url: String?, placeholder: NSImage? = nil, completion: ((_ image: NSImage?)->Void)? = nil) {
        
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
                if completion == nil { self.image = cached.nsImage() }
                else { completion?(cached.nsImage()) }
                return
            }
            
            
            // Download from URL
            var img: NSImage?
            DispatchQueue.global(qos: .background).async {
                let data = try? Data(contentsOf: URL(string: url)!)
                if let data = data {
                    img = NSImage(data: data)
                }
                
                DispatchQueue.main.async {
                    // Save to cache & return
                    if img != nil { Johnny.cache(Image(image: img), key: url) }
                    if completion == nil {
                        self.image = img
                    }
                    else { completion?(img) }

                }
            }
        }
    }
}
