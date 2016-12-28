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
        (data as NSData).getBytes(&n, length: MemoryLayout<Int>.size)
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: &n, count: MemoryLayout<Int>.size)
    }
}


extension Int64 : Storable {
    
    public static func fromData(_ data: Data) -> Int64? {
        var n: Int64 = 0
        (data as NSData).getBytes(&n, length: MemoryLayout<Int64>.size)
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: &n, count: MemoryLayout<Int64>.size)
    }
}


extension UInt : Storable {
    
    public static func fromData(_ data: Data) -> UInt? {
        var n: UInt = 0
        (data as NSData).getBytes(&n, length: MemoryLayout<UInt>.size)
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: &n, count: MemoryLayout<UInt>.size)
    }
}


extension UInt64 : Storable {
    
    public static func fromData(_ data: Data) -> UInt64? {
        var n: UInt64 = 0
        (data as NSData).getBytes(&n, length: MemoryLayout<UInt64>.size)
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: &n, count: MemoryLayout<UInt64>.size)
    }
}


extension Float : Storable {
    
    public static func fromData(_ data: Data) -> Float? {
        var n: Float = 0
        (data as NSData).getBytes(&n, length: MemoryLayout<Float>.size)
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: &n, count: MemoryLayout<Float>.size)
    }
}


extension Double : Storable {
    
    public static func fromData(_ data: Data) -> Double? {
        var n: Double = 0
        (data as NSData).getBytes(&n, length: MemoryLayout<Double>.size)
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: &n, count: MemoryLayout<Double>.size)
    }
}

extension Bool : Storable {
    
    public static func fromData(_ data: Data) -> Bool? {
        var n: Bool = false
        (data as NSData).getBytes(&n, length: MemoryLayout<Bool>.size)
        return n
    }
    
    public func toData() -> Data {
        var n = self
        return Data(bytes: &n, count: MemoryLayout<Bool>.size)
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


extension Array where Element: Storable {
    func toData() -> Data! {
        let dataArray = self.map({ $0.toData() })
        return NSKeyedArchiver.archivedData(withRootObject: dataArray)
    }
}


extension Dictionary where Key: Hashable, Value: Storable {
    func toData() -> Data! {
        let dataDictionary = self.map { [String(describing: $0): $1.toData()] }
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
    
    func map<T>(_ transform: (Value) throws -> T) rethrows -> [Key: T] {
        return Dictionary<Key, T>(try map { (k, v) in (k, try transform(v)) })
    }
}


extension Set where Element: Storable {
    func toData() -> Data! {
        let dataArray = self.map({ $0.toData() })
        return NSKeyedArchiver.archivedData(withRootObject: dataArray)
    }
}

