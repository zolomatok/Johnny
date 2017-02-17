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
    open class func cache<T: Storable>(_ value: T?, key: String, library: Bool = false) {
        
        guard let value = value else {
            print("")
            return
        }
        
        // Store in memory
        memory[key] = Shell(value: value)
        
        // Store in disk
        DispatchQueue.global(qos: .background).async {
            let data = value.toData()
            disk[key, library] = data
        }
    }

    /**
     Caches an array of Storable objects
     
     - parameter array: The array to be cached
     - parameter key:   The key for pulling the object from the cache
     */
    open class func cache<T: Storable>(_ array: [T]?, key: String, library: Bool = false) {
        
        guard let array = array else {
            return
        }
        
        // Store in memory
        memory[key] = Shell(value: array)
        
        // Store in disk
        DispatchQueue.global(qos: .background).async {
            let data = array.toData()
            disk[key, library] = data
        }
    }
    
    /**
     Caches a dictionary of Storable objects
     
     - parameter dictionary: The dictionary to be cached
     - parameter key:        The key for pulling the object from the cache
     */
    open class func cache<U: ExpressibleByStringLiteral, T: Storable>(_ dictionary: [U:T]?, key: String, library: Bool = false) {
        
        guard let dictionary = dictionary else {
            return
        }
        
        // Store in memory
        memory[key] = Shell(value: dictionary)
        
        // Store in disk
        DispatchQueue.global(qos: .background).async {
            let data = dictionary.toData()
            disk[key, library] = data
        }
    }
    
    /**
     Caches a set of Storable objects
     
     - parameter dictionary: The set to be cached
     - parameter key:        The key for pulling the object from the cache
     */
    open class func cache<T: Storable>(_ set: Set<T>?, key: String, library: Bool = false) {
        
        guard let set = set else {
            return
        }
        
        // Store in memory
        memory[key] = Shell(value: set)
        
        // Store in disk
        DispatchQueue.global(qos: .background).async {
            let data = set.toData()
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
    open class func pull<T: Storable>(_ key: String, library: Bool = false) -> T? {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? T { return value }

        
        // Check disk
        if let data = disk[key, library] {
    
            let value = T.fromData(data)
            if let value = value { memory[key] = Shell(value: value) }
            return value as? T
        }
        
        return nil
    }
    
    /**
     Retrieves an array of Storable objects for a given key
     
     - parameter key: The key for pulling the array from the cache
     
     - returns: The stored array, nil if not found
     */
    open class func pull<T: Storable>(_ key: String, library: Bool = false) -> [T]? {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? [T] { return value }
        
        
        // Check disk
        if let data = disk[key, library] {
            
            let dataArray = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [Data]
            let value = dataArray?.map{ T.fromData($0) as! T}
            if let value = value { memory[key] = Shell(value: value) }
            return value
        }
        
        return nil
    }
    
    /**
     Retrieves a dictionary of Storable objects for a given key
     
     - parameter key: The key for pulling the dictionary from the cache
     
     - returns: The stored dictionary, nil if not found
     */
    open class func pull<T: Storable>(_ key: String, library: Bool = false) -> [String: T]? {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? [String: T] { return value }

        
        // Check disk
        if let data = disk[key, library] {
            
            let dataMap = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String: Data]
            let value = dataMap?.map{ T.fromData($0) as! T }
            if let value = value { memory[key] = Shell(value: value) }
            return value
        }
        
        return nil
    }
    
    /**
     Retrieves a set of Storable objects for a given key
     
     - parameter key: The key for pulling the set from the cache
     
     - returns: The stored set, nil if not found
     */
    open class func pull<T: Storable>(_ key: String, library: Bool = false) -> Set<T>? {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? Set<T> { return value }
        
        
        // Check disk
        if let data = disk[key, library] {

            var value: Set<T>?
            let dataSet = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? Set<Data>
            let array = dataSet?.map{ T.fromData($0) as! T }
            if let array = array {
                value = Set(array)
            }
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
    open class func pull<T: Storable>(_ key: String, library: Bool = false, completion: ((_ value: T?)->Void)? = nil ) {
        
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
                value = T.fromData(data!) as? T
            }
            
            DispatchQueue.main.async {
                guard let value = value else { completion?(nil); return }
                
                memory[key] = Shell(value: value)
                completion?(value)
            }
        }
    }
    
    /**
     Asyncronously retrieves an array of Storable objects for a given key
     
     - parameter key: The key for pulling the array from the cache
     
     - returns: The stored array, nil if not found
     */
    open class func pull<T: Storable>(_ key: String, library: Bool = false, completion: ((_ value: [T]?)->Void)? = nil ) {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? [T] {
            completion?(value)
            return
        }
    
        
        // Check disk
        var value: [T]?
        DispatchQueue.global(qos: .background).async {
            let data = disk[key, library]
            if data != nil {
                let dataArray = NSKeyedUnarchiver.unarchiveObject(with: data!) as? [Data]
                value = dataArray?.map{ T.fromData($0 as Data) as! T}
            }
            
            DispatchQueue.main.async {
                guard let value = value else { completion?(nil); return }
                
                memory[key] = Shell(value: value)
                completion?(value)
            }
        }
    }
    
    /**
     Asyncronously retrieves a dictionary of Storable objects for a given key
     
     - parameter key: The key for pulling the dictionary from the cache
     
     - returns: The stored dictionary, nil if not found
     */
    open class func pull<T: Storable>(_ key: String, library: Bool = false, completion: ((_ value: [String: T]?)->Void)? = nil ) {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? [String: T] {
            completion?(value)
            return
        }
        
        
        // Check disk
        var value: [String: T]?
        DispatchQueue.global(qos: .background).async {
            let data = disk[key, library]
            if let data = data {
                let dataMap = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Data]
                value = dataMap?.map{ T.fromData($0) as! T}
            }
            
            DispatchQueue.main.async {
                guard let value = value else { completion?(nil); return }
                
                memory[key] = Shell(value: value)
                completion?(value)
            }
        }
    }
    
    /**
     Asyncronously retrieves a set of Storable objects for a given key
     
     - parameter key: The key for pulling the set from the cache
     
     - returns: The stored set, nil if not found
     */
    open class func pull<T: Storable>(_ key: String, library: Bool = false, completion: ((_ value: Set<T>?)->Void)? = nil ) {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? Set<T> {
            completion?(value)
            return
        }

        
        // Check disk
        var value: Set<T>?
        DispatchQueue.global(qos: .background).async {
            let data = disk[key, library]
            if let data = data {
                let dataSet = NSKeyedUnarchiver.unarchiveObject(with: data) as? Set<Data>
                let array = dataSet?.map{ T.fromData($0) as! T }
                if let array = array {
                    value = Set(array)
                }
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
