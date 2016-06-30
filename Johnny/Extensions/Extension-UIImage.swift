//
//  Extension-UIKit.swift
//  Johnny
//
//  Created by Zolo on 6/30/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation

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