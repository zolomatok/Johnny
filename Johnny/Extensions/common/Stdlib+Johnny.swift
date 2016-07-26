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
    static func fromData(_ data: Data) -> Result?
    func toData() -> Data
}


public protocol ProtocolConsumer {
    func consume<T: Storable>(_ value: T)
}


extension Int : Storable {
    
    public static func fromData(_ data: Data) -> Int? {
        var n = 0
        (data as NSData).getBytes(&n, length: sizeof(Int))
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: UnsafePointer<UInt8>(&n), count: sizeof(Int))
    }
}


extension Int64 : Storable {
    
    public static func fromData(_ data: Data) -> Int64? {
        var n: Int64 = 0
        (data as NSData).getBytes(&n, length: sizeof(Int64))
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: UnsafePointer<UInt8>(&n), count: sizeof(Int64))
    }
}


extension UInt : Storable {
    
    public static func fromData(_ data: Data) -> UInt? {
        var n: UInt = 0
        (data as NSData).getBytes(&n, length: sizeof(UInt))
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: UnsafePointer<UInt8>(&n), count: sizeof(UInt))
    }
}


extension UInt64 : Storable {
    
    public static func fromData(_ data: Data) -> UInt64? {
        var n: UInt64 = 0
        (data as NSData).getBytes(&n, length: sizeof(UInt64))
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: UnsafePointer<UInt8>(&n), count: sizeof(UInt64))
    }
}


extension Float : Storable {
    
    public static func fromData(_ data: Data) -> Float? {
        var n: Float = 0
        (data as NSData).getBytes(&n, length: sizeof(Float))
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: UnsafePointer<UInt8>(&n), count: sizeof(Float))
    }
}


extension Double : Storable {
    
    public static func fromData(_ data: Data) -> Double? {
        var n: Double = 0
        (data as NSData).getBytes(&n, length: sizeof(Double))
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: UnsafePointer<UInt8>(&n), count: sizeof(Double))
    }
}


extension String : Storable {
    
    public static func fromData(_ data: Data) -> String? {
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
    }
    
    public func toData() -> Data {
        return self.data(using: String.Encoding.utf8)!
    }
}


extension Data : Storable {
    
    public typealias Result = Data
    
    public static func fromData(_ data: Data) -> Result? {
        return data
    }
    
    public func toData() -> Data {
        return self
    }
}


extension Date : Storable {
    
    public typealias Result = Date
    
    public static func fromData(_ data: Data) -> Result? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? Date
    }
    
    public func toData() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}


extension Array where Element: Storable {
    func toData() -> Data! {
        let dataArray = self.map({ $0.toData() })
        return NSKeyedArchiver.archivedData(withRootObject: dataArray)
    }
}


extension Dictionary where Key: Hashable, Value: Storable {
    func toData() -> Data! {
        let dataDictionary = self.map { [String($0): $1.toData()] }
        return NSKeyedArchiver.archivedData(withRootObject: dataDictionary)
    }
}

extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
    func map<T>(@noescape _ transform: (Value) throws -> T) rethrows -> [Key: T] {
        return Dictionary<Key, T>(try map { (k, v) in (k, try transform(v)) })
    }
}


extension Set where Element: Storable {
    func toData() -> Data! {
        let dataArray = self.map({ $0.toData() })
        return NSKeyedArchiver.archivedData(withRootObject: dataArray)
    }
}

extension Set {
    init(_ array: [Element]) {
        self.init()
        for v in array {
            self.insert(v)
        }
    }
    
    public func map<T>(@noescape transform: (Set.Iterator.Element) throws -> T) rethrows -> Set<T> {
        return Set<T>(try map(transform))
    }
}

