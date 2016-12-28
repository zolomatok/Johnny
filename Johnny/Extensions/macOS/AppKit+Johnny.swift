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
extension NSImage : Storable {
    
    public typealias Result = NSImage
    
    public static func fromData(_ data: Data) -> Result? {
        imgLock.lock()
        let img = NSImage(data: data)
        imgLock.unlock()
        return img
    }
    
    // See: http://stackoverflow.com/questions/3698400/how-to-convert-data-to-jpeg-format
    public func toData() -> Data {
        let data = self.tiffRepresentation
        let rep = NSBitmapImageRep(data: data!)
        let compression = 1.0
        let properties = [NSImageCompressionFactor: compression]
        return rep!.representation(using: .JPEG, properties: properties)!
    }
}


extension NSImageView {
    
    public func imageWithURL(_ url: String?, placeholder: NSImage? = nil, completion: ((_ image: NSImage?)->Void)? = nil) {
        
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
        Johnny.pull(url) { (cached: NSImage?) in
            
            
            // Return cached value
            if let cached = cached {
                if completion == nil { self.image = cached }
                else { completion?(cached) }
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
                    if img != nil { Johnny.cache(img, key: url) }
                    if completion == nil {
                        self.image = img
                    }
                    else { completion?(img) }

                }
            }
        }
    }
}
