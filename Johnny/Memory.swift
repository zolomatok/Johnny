//
//  Memory.swift
//  Johnny
//
//  Created by Zolo on 6/26/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import UIKit

class Memory: NSCache {
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Memory.removeAllObjects), name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    }
    
    subscript(key: String) -> AnyObject? {
        
        get {
            return self.objectForKey(key)
        }
        
        set(newValue) {
            self.setObject(newValue!, forKey: key)
        }
    }
}
