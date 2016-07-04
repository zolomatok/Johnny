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
extension UIImage : Storable {
    
    public typealias Result = UIImage
    
    public static func fromData(data: NSData) -> Result? {
        imgLock.lock()
        let img = UIImage(data: data)
        imgLock.unlock()
        return img
    }
    
    public func toData() -> NSData {
        return UIImageJPEGRepresentation(self, 1.0)!
    }
}


extension UIImage {
    
    func hasAlpha() -> Bool {
        let alpha = CGImageGetAlphaInfo(self.CGImage)
        switch alpha {
        case .First, .Last, .PremultipliedFirst, .PremultipliedLast, .Only:
            return true
        case .None, .NoneSkipFirst, .NoneSkipLast:
            return false
        }
    }
    
    
    func scaledToSize(toSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(toSize, !hasAlpha(), 0.0)
        drawInRect(CGRectMake(0, 0, toSize.width, toSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}