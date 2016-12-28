//
//  Foundation+Johnny.swift
//  Johnny
//
//  Created by Zolo on 7/4/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGSize {
    
    func aspectFillSize(_ size: CGSize) -> CGSize {
        let scaleWidth = size.width / self.width
        let scaleHeight = size.height / self.height
        let scale = max(scaleWidth, scaleHeight)
        
        let resultSize = CGSize(width: self.width * scale, height: self.height * scale)
        return CGSize(width: ceil(resultSize.width), height: ceil(resultSize.height))
    }
    
    func aspectFitSize(_ size: CGSize) -> CGSize {
        let targetAspect = size.width / size.height
        let sourceAspect = self.width / self.height
        var resultSize = size
        
        if (targetAspect > sourceAspect) {
            resultSize.width = size.height * sourceAspect
        }
        else {
            resultSize.height = size.width / sourceAspect
        }
        return CGSize(width: ceil(resultSize.width), height: ceil(resultSize.height))
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


extension FileManager {
    
    func enumerateContentsOfDirectoryAtPath(_ path: String, orderedByProperty property: String, ascending: Bool, usingBlock block: (URL, Int, inout Bool) -> Void ) {
        
        let directoryURL = URL(fileURLWithPath: path)
        do {
            let contents = try self.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [URLResourceKey(rawValue: property)], options: FileManager.DirectoryEnumerationOptions())
            let sortedContents = contents.sorted(by: {(URL1: URL, URL2: URL) -> Bool in
                
                // Maybe there's a better way to do this. See: http://stackoverflow.com/questions/25502914/comparing-anyobject-in-swift
                
                var value1 : AnyObject?
                do {
                    try (URL1 as NSURL).getResourceValue(&value1, forKey: URLResourceKey(rawValue: property));
                } catch {
                    return true
                }
                var value2 : AnyObject?
                do {
                    try (URL2 as NSURL).getResourceValue(&value2, forKey: URLResourceKey(rawValue: property));
                } catch {
                    return false
                }
                
                if let string1 = value1 as? String, let string2 = value2 as? String {
                    return ascending ? string1 < string2 : string2 < string1
                }
                
                if let date1 = value1 as? Date, let date2 = value2 as? Date {
                    return ascending ? date1 < date2 : date2 < date1
                }
                
                if let number1 = value1 as? NSNumber, let number2 = value2 as? NSNumber {
                    return ascending ? number1 < number2 : number2 < number1
                }
                
                return false
            })
            
            for (i, v) in sortedContents.enumerated() {
                var stop : Bool = false
                block(v, i, &stop)
                if stop { break }
            }
            
        } catch {
            print("Failed to list directory", error as NSError)
        }
    }
    
}

func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == ComparisonResult.orderedAscending
}
