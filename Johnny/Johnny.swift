//
//  Johnny.swift
//  Johnny
//
//  Created by Zolo on 6/26/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation
import Async
  #if UIKIT_COMPATIBLE
import UIKit
  #endif


// Used to add T to NSCache
class Shell : NSObject {
    let value: Any
    init(value: Any) {
        self.value = value
    }
}


public class Johnny {
    
    static let memory = Memory()
    static let disk = Disk()

    init() {
        #if UIKIT_COMPATIBLE && !WATCHKIT
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Johnny.nuke), name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
        #endif
    }
    
    // MARK: - In
    /**
     Caches a Storable object
     
     - parameter value: The value to be cached
     - parameter key:   The key for pulling the object from the cache
     */
    public class func cache<T: Storable>(value: T?, key: String) {
        
        // Store in memory
        memory[key] = Shell(value: value)

        
        // Store in disk
        Async.background {
            let data = value?.toData()
            disk[key] = data
        }
    }
    
    /**
     Caches an array of Storable objects
     
     - parameter array: The array to be cached
     - parameter key:   The key for pulling the object from the cache
     */
    public class func cache<T: Storable>(array: [T]?, key: String) {
        
        // Store in memory
        memory[key] = Shell(value: array)
        
        // Store in disk
        Async.background {
            let data = array?.toData()
            disk[key] = data
        }
    }
    
    /**
     Caches a dictionary of Storable objects
     
     - parameter dictionary: The dictionary to be cached
     - parameter key:        The key for pulling the object from the cache
     */
    public class func cache<U: StringLiteralConvertible, T: Storable>(dictionary: [U:T]?, key: String) {
        
        // Store in memory
        memory[key] = Shell(value: dictionary)
        
        // Store in disk
        Async.background {
            let data = dictionary?.toData()
            disk[key] = data
        }
    }
    
    /**
     Caches a set of Storable objects
     
     - parameter dictionary: The set to be cached
     - parameter key:        The key for pulling the object from the cache
     */
    public class func cache<T: Storable>(array: Set<T>?, key: String) {
        
        // Store in memory
        memory[key] = Shell(value: array)
        
        // Store in disk
        Async.background {
            let data = array?.toData()
            disk[key] = data
        }
    }
    
    
    
    // MARK: - Out
    /**
     Retrieves a Storable object for a given key
     
     - parameter key: The key for pulling the object from the cache
     
     - returns: The stored object, nil if not found
     */
    public class func pull<T: Storable>(key: String) -> T? {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? T { return value }

        
        // Check disk
        if let data = disk[key] {
    
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
    public class func pull<T: Storable>(key: String) -> [T]? {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? [T] { return value }
        
        
        // Check disk
        if let data = disk[key] {
            
            let dataArray = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSData]
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
    public class func pull<T: Storable>(key: String) -> [String: T]? {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? [String: T] { return value }

        
        // Check disk
        if let data = disk[key] {
            
            let dataMap = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: NSData]
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
    public class func pull<T: Storable>(key: String) -> Set<T>? {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? Set<T> { return value }
        
        
        // Check disk
        if let data = disk[key] {

            let dataSet = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Set<NSData>
            let value = dataSet?.map{ T.fromData($0) as! T }
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
    public class func pull<T: Storable>(key: String, completion: ((value: T?)->Void)? = nil ) {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? T {
            completion?(value: value)
            return
        }
        
        
        // Check disk
        var value: T?
        Async.background {
            let data = disk[key]
            if data != nil {
                value = T.fromData(data!) as? T
            }
        }.main { 
            guard let value = value else { completion?(value: nil); return }
            
            memory[key] = Shell(value: value)
            completion?(value: value)
        }
    }
    
    /**
     Asyncronously retrieves an array of Storable objects for a given key
     
     - parameter key: The key for pulling the array from the cache
     
     - returns: The stored array, nil if not found
     */
    public class func pull<T: Storable>(key: String, completion: ((value: [T]?)->Void)? = nil ) {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? [T] {
            completion?(value: value)
            return
        }
    
        
        // Check disk
        var value: [T]?
        Async.background {
            let data = disk[key]
            if data != nil {
                let dataArray = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? [NSData]
                value = dataArray?.map{ T.fromData($0) as! T}
            }
        }.main {
            guard let value = value else { completion?(value: nil); return }
                
            memory[key] = Shell(value: value)
            completion?(value: value)
        }
    }
    
    /**
     Asyncronously retrieves a dictionary of Storable objects for a given key
     
     - parameter key: The key for pulling the dictionary from the cache
     
     - returns: The stored dictionary, nil if not found
     */
    public class func pull<T: Storable>(key: String, completion: ((value: [String: T]?)->Void)? = nil ) {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? [String: T] {
            completion?(value: value)
            return
        }
        
        
        // Check disk
        var value: [String: T]?
        Async.background {
            let data = disk[key]
            if let data = data {
                let dataMap = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: NSData]
                value = dataMap?.map{ T.fromData($0) as! T}
            }
        }.main {
            guard let value = value else { completion?(value: nil); return }
                
            memory[key] = Shell(value: value)
            completion?(value: value)
        }
    }
    
    /**
     Asyncronously retrieves a set of Storable objects for a given key
     
     - parameter key: The key for pulling the set from the cache
     
     - returns: The stored set, nil if not found
     */
    public class func pull<T: Storable>(key: String, completion: ((value: Set<T>?)->Void)? = nil ) {
        
        // Check memory
        if let value = (memory[key] as? Shell)?.value as? Set<T> {
            completion?(value: value)
            return
        }

        
        // Check disk
        var value: Set<T>?
        Async.background {
            let data = disk[key]
            if let data = data {
                let dataSet = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Set<NSData>
                value = dataSet?.map{ T.fromData($0) as! T }
            }
        }.main {
            guard let value = value else { completion?(value: nil); return }
            
            memory[key] = Shell(value: value)
            completion?(value: value)
        }
    }
    
    
    
    // MARK: - Clear
    /**
     Nukes the entire cache from memory & disk
     */
    @objc public class func nuke() {
        memory.removeAllObjects()
        disk.nuke(nil)
    }
}