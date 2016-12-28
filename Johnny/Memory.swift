//
//  Memory.swift
//  Johnny
//
//  Created by Zolo on 6/26/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation

class Memory: NSCache<AnyObject, AnyObject> {
    
    override init() {
        super.init()
        #if UIKIT_COMPATIBLE && !WATCHKIT
            NotificationCenter.default.addObserver(self, selector: #selector(removeAllObjects), name: .UIApplicationDidReceiveMemoryWarning, object: nil)
        #endif
    }
    
    subscript(key: String) -> AnyObject? {
        
        get {
            return self.object(forKey: key as AnyObject)
        }
        
        set(newValue) {
            if let newValue = newValue {
                self.setObject(newValue, forKey: key as AnyObject)
            } else {
                self.removeObject(forKey: key as AnyObject)
            }
        }
    }
}
