//
//  Johnny.swift
//  Johnny
//
//  Created by Zolo on 6/26/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation
#if UIKIT_COMPATIBLE
    import UIKit
#endif


// Used to add T to NSCache
class Shell : NSObject {
    let value: Any?
    init(value: Any?) {
        self.value = value
    }
}



open class Johnny {
    
    static let memory = Memory()
    static let disk = Disk()
    
    
    // MARK: - In
    /**
     Caches a Storable object
     
     - parameter value: The value to be cached
     - parameter key:   The key for pulling the object from the cache
     */
    open class func cache<T: Codable>(_ value: T?, key: String, library: Bool = false) {
        guard let value = value else { return }
        
        // Store in memory
        memory[key] = Shell(value: value)

        // Store in disk
        DispatchQueue.global(qos: .background).async {
            let d = try? JSONEncoder().encode(value)
            guard let data = d else { return }
            disk[key, library] = data
        }
    }
    
    
    // MARK: - Delete
    /**
     Delete a Storable object
     
     - parameter key:   The key for deleting the object from the cache
     */
    open class func delete(_ key: String, library: Bool = false) {
        memory[key] = nil
        disk[key, library] = nil
    }
    
    
    
    // MARK: - Out
    /**
     Retrieves a Storable object for a given key
     
     - parameter key: The key for pulling the object from the cache
     
     - returns: The stored object, nil if not found
     */
    open class func pull<T: Codable>(_ key: String, library: Bool = false) -> T? {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? T { return value }

        
        // Check disk
        if let data = disk[key, library] {
    
            let value = try? JSONDecoder().decode(T.self, from: data)
            if let value = value { memory[key] = Shell(value: value) }
            return value
        }
        
        return nil
    }
    
    
    // MARK: - Async Out  
    /**
     Asyncronously retrieves a Storable object for a given key
     
     - parameter key: The key for pulling the object from the cache
     
     - returns: The stored object, nil if not found
     */
    open class func pull<T: Codable>(_ key: String, library: Bool = false, completion: ((_ value: T?)->Void)? = nil ) {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? T {
            completion?(value)
            return
        }
        
        
        // Check disk
        var value: T?
        DispatchQueue.global(qos: .background).async {
            let data = disk[key, library]
            if data != nil {
                value = try? JSONDecoder().decode(T.self, from: data!)
            }
            
            DispatchQueue.main.async {
                guard let value = value else { completion?(nil); return }
                
                memory[key] = Shell(value: value)
                completion?(value)
            }
        }
    }

    
    
    // MARK: - Clear
    /**
     Nukes the entire cache from memory & disk
     */
    @objc open class func nuke() {
        memory.removeAllObjects()
        disk.nuke(nil)
    }
}
