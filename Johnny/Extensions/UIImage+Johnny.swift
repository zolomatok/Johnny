//
//  UIImage+Johhny.swift
//  Johnny
//
//  Created by Zolo on 6/30/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import UIKit
#if WATCHKIT
    import WatchKit
#endif

// See: https://github.com/AFNetworking/AFNetworking/issues/2572#issuecomment-115854482
private let imgLock = NSLock()

class Image: Codable {
    let data: Data
    init(image: UIImage) {
        data = UIImageJPEGRepresentation(image, 1.0)!
    }
    
    func uiImage() -> UIImage {
        imgLock.lock()
        let img = UIImage(data: data)!
        imgLock.unlock()
        return img
    }
}


extension UIImage {
    
    func hasAlpha() -> Bool {
        
        guard let alpha = self.cgImage?.alphaInfo else {
            return false
        }
        
        switch alpha {
        case .first, .last, .premultipliedFirst, .premultipliedLast, .alphaOnly:
            return true
        case .none, .noneSkipFirst, .noneSkipLast:
            return false
        }
    }
    
    
    func scaledToSize(_ toSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(toSize, !hasAlpha(), 0.0)
        draw(in: CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}
