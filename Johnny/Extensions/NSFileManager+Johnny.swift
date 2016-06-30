//
//  NSFileManager+Johnny.swift
//  Johnny
//
//  Created by Zolo on 6/26/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation

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