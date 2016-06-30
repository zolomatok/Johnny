//
//  Memory.swift
//  Johnny
//
//  Created by Zolo on 6/26/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation

class Memory: NSCache {
    
    subscript(key: String) -> AnyObject? {
        
        get {
            return self.objectForKey(key)
        }
        
        set(newValue) {
            self.setObject(newValue!, forKey: key)
        }
    }
}
