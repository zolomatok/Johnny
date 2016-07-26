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
    
    public static func fromData(_ data: Data) -> Result? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor
    }
    
    public func toData() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}
