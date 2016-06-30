//
//  Extensions.swift
//  Johnny
//
//  Created by Zolo on 6/26/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation


public protocol Storable {
    associatedtype Result
    static func fromData(data: NSData) -> Result?
    func toData() -> NSData
}


public protocol ProtocolConsumer {
    func consume<T: Storable>(value: T)
}


extension Int : Storable {
    
    public static func fromData(data: NSData) -> Int? {
        var n = 0
        data.getBytes(&n, length: sizeof(Int))
        return n
    }
    
    public func toData() -> NSData {
        var n = self
        return NSData(bytes: &n, length: sizeof(Int))
    }
}


extension Int64 : Storable {
    
    public static func fromData(data: NSData) -> Int64? {
        var n: Int64 = 0
        data.getBytes(&n, length: sizeof(Int64))
        return n
    }
    
    public func toData() -> NSData {
        var n = self
        return NSData(bytes: &n, length: sizeof(Int64))
    }
}


extension UInt : Storable {
    
    public static func fromData(data: NSData) -> UInt? {
        var n: UInt = 0
        data.getBytes(&n, length: sizeof(UInt))
        return n
    }
    
    public func toData() -> NSData {
        var n = self
        return NSData(bytes: &n, length: sizeof(UInt))
    }
}


extension UInt64 : Storable {
    
    public static func fromData(data: NSData) -> UInt64? {
        var n: UInt64 = 0
        data.getBytes(&n, length: sizeof(UInt64))
        return n
    }
    
    public func toData() -> NSData {
        var n = self
        return NSData(bytes: &n, length: sizeof(UInt64))
    }
}


extension Float : Storable {
    
    public static func fromData(data: NSData) -> Float? {
        var n: Float = 0
        data.getBytes(&n, length: sizeof(Float))
        return n
    }
    
    public func toData() -> NSData {
        var n = self
        return NSData(bytes: &n, length: sizeof(Float))
    }
}


extension Double : Storable {
    
    public static func fromData(data: NSData) -> Double? {
        var n: Double = 0
        data.getBytes(&n, length: sizeof(Double))
        return n
    }
    
    public func toData() -> NSData {
        var n = self
        return NSData(bytes: &n, length: sizeof(Double))
    }
}


extension String : Storable {
    
    public static func fromData(data: NSData) -> String? {
        return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
    }
    
    public func toData() -> NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}


extension NSData : Storable {
   
    public typealias Result = NSData

    public static func fromData(data: NSData) -> Result? {
        return data
    }
    
    public func toData() -> NSData {
        return self
    }
}


extension NSDate : Storable {
    
    public typealias Result = NSDate
    
    public static func fromData(data: NSData) -> Result? {
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDate
    }
    
    public func toData() -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
}


extension Array where Element: Storable {
    func toData() -> NSData! {
        let dataArray = self.map({ $0.toData() })
        return NSKeyedArchiver.archivedDataWithRootObject(dataArray)
    }
}


extension Dictionary where Key: Hashable, Value: Storable {
    func toData() -> NSData! {
        let dataDictionary = self.map { [String($0): $1.toData()] }
        return NSKeyedArchiver.archivedDataWithRootObject(dataDictionary)
    }
}

extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
    func map<T>(@noescape transform: Value throws -> T) rethrows -> [Key: T] {
        return Dictionary<Key, T>(try map { (k, v) in (k, try transform(v)) })
    }
}


extension Set where Element: Storable {
    func toData() -> NSData! {
        let dataArray = self.map({ $0.toData() })
        return NSKeyedArchiver.archivedDataWithRootObject(dataArray)
    }
}

extension Set {
    init(_ array: [Element]) {
        self.init()
        for v in array {
            self.insert(v)
        }
    }
    
    public func map<T>(@noescape transform: (Set.Generator.Element) throws -> T) rethrows -> Set<T> {
        return Set<T>(try map(transform))
    }
}

