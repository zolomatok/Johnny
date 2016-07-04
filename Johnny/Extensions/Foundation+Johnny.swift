//
//  Foundation+Johnny.swift
//  Johnny
//
//  Created by Zolo on 7/4/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation

extension CGSize {
    
    func aspectFillSize(size: CGSize) -> CGSize {
        let scaleWidth = size.width / self.width
        let scaleHeight = size.height / self.height
        let scale = max(scaleWidth, scaleHeight)
        
        let resultSize = CGSizeMake(self.width * scale, self.height * scale)
        return CGSizeMake(ceil(resultSize.width), ceil(resultSize.height))
    }
    
    func aspectFitSize(size: CGSize) -> CGSize {
        let targetAspect = size.width / size.height
        let sourceAspect = self.width / self.height
        var resultSize = size
        
        if (targetAspect > sourceAspect) {
            resultSize.width = size.height * sourceAspect
        }
        else {
            resultSize.height = size.width / sourceAspect
        }
        return CGSizeMake(ceil(resultSize.width), ceil(resultSize.height))
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


extension NSFileManager {
    
    func enumerateContentsOfDirectoryAtPath(path: String, orderedByProperty property: String, ascending: Bool, usingBlock block: (NSURL, Int, inout Bool) -> Void ) {
        
        let directoryURL = NSURL(fileURLWithPath: path)
        do {
            let contents = try self.contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: [property], options: NSDirectoryEnumerationOptions())
            let sortedContents = contents.sort({(URL1: NSURL, URL2: NSURL) -> Bool in
                
                // Maybe there's a better way to do this. See: http://stackoverflow.com/questions/25502914/comparing-anyobject-in-swift
                
                var value1 : AnyObject?
                do {
                    try URL1.getResourceValue(&value1, forKey: property);
                } catch {
                    return true
                }
                var value2 : AnyObject?
                do {
                    try URL2.getResourceValue(&value2, forKey: property);
                } catch {
                    return false
                }
                
                if let string1 = value1 as? String, let string2 = value2 as? String {
                    return ascending ? string1 < string2 : string2 < string1
                }
                
                if let date1 = value1 as? NSDate, let date2 = value2 as? NSDate {
                    return ascending ? date1 < date2 : date2 < date1
                }
                
                if let number1 = value1 as? NSNumber, let number2 = value2 as? NSNumber {
                    return ascending ? number1 < number2 : number2 < number1
                }
                
                return false
            })
            
            for (i, v) in sortedContents.enumerate() {
                var stop : Bool = false
                block(v, i, &stop)
                if stop { break }
            }
            
        } catch {
            print("Failed to list directory", error as NSError)
        }
    }
    
}

func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}