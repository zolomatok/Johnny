//
//  Extension-UIColor.swift
//  Johnny
//
//  Created by Zolo on 6/30/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import UIKit

extension UIColor : Storable {
    
    public typealias Result = UIColor
    
    public static func fromData(data: NSData) -> Result? {
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? UIColor
    }
    
    public func toData() -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
}