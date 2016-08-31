//
//  JohnnyTests.swift
//  JohnnyTests
//
//  Created by Zolo on 7/27/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import XCTest
@testable import Johnny
import Async

class JohnnyMemoryTests: XCTestCase {
    
    var token: dispatch_once_t = 0
    var disk = Disk()
    
    override func setUp() {
        super.setUp()
        dispatch_once(&token) { 
            let cachesPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
            let johhny = "io.johhny"
            let path = (cachesPath as NSString).stringByAppendingPathComponent(johhny)
            let paths = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
            if let paths = paths {
                for p in paths {
                    let _ = try? NSFileManager.defaultManager().removeItemAtPath(p)
                }
            }
        }
    }
    
    override func tearDown() { super.tearDown() }
    
    
    func testDefaultTypes() {
        let string: String = "Heresy grows from idleness"
        let bool: Bool = true
        let int: Int = 1
        let int64: Int64 = 2
        let uint: UInt = 3
        let uint64: UInt64 = 4
        let float: Float = 10.2
        let double: Double = 20.6
        
        let ip = NSBundle(forClass: self.dynamicType).resourcePath!.stringByAppendingString("/johnny-logo.png")
        let image = UIImage(contentsOfFile: ip)!
        let data = image.toData()
        let date: NSDate = NSDate(timeIntervalSince1970: 1459355217)
        let color = UIColor.blueColor()
        
        
        Johnny.cache(string, key: "testString")
        Johnny.cache(bool, key: "testBool")
        Johnny.cache(int, key: "testInt")
        Johnny.cache(int64, key: "testInt64")
        Johnny.cache(uint, key: "testUInt")
        Johnny.cache(uint64, key: "testUInt64")
        Johnny.cache(float, key: "testFloat")
        Johnny.cache(double, key: "testDouble")
        Johnny.cache(image, key: "testImage")
        Johnny.cache(data, key: "testData")
        Johnny.cache(date, key: "testDate")
        Johnny.cache(color, key: "testColor")
        
        
        if let value: String = Johnny.pull("testString") {
            XCTAssert(value == "Heresy grows from idleness", "default string was incorrect")
        } else {
            XCTFail("no default string could be unpacked")
        }
        
        if let value: Bool = Johnny.pull("testBool") {
            XCTAssert(value == true, "default bool was incorrect")
        } else {
            XCTFail("no default bool could be unpacked")
        }
        
        if let value: Int = Johnny.pull("testInt") {
            XCTAssert(value == 1, "default int was incorrect")
        } else {
            XCTFail("no default int could be unpacked")
        }
        
        if let value: Int64 = Johnny.pull("testInt64") {
            XCTAssert(value == 2, "default int64 was incorrect")
        } else {
            XCTFail("no default int64 could be unpacked")
        }
        
        if let value: UInt = Johnny.pull("testUInt") {
            XCTAssert(value == 3, "default uint was incorrect")
        } else {
            XCTFail("no default uint could be unpacked")
        }
        
        if let value: UInt64 = Johnny.pull("testUInt64") {
            XCTAssert(value == 4, "default uint64 was incorrect")
        } else {
            XCTFail("no default uint64 could be unpacked")
        }
        
        if let value: Float = Johnny.pull("testFloat") {
            XCTAssert(value == 10.2, "default float was incorrect")
        } else {
            XCTFail("no default float could be unpacked")
        }
        
        if let value: Double = Johnny.pull("testDouble") {
            XCTAssert(value == 20.6, "default Double was incorrect")
        } else {
            XCTFail("no default Double could be unpacked")
        }
        
        if let value: UIImage = Johnny.pull("testImage") {
            XCTAssert(value.toData() == data, "default Image was incorrect")
        } else {
            XCTFail("no default Image could be unpacked")
        }
        
        if let value: NSData = Johnny.pull("testData") {
            XCTAssert(value == data, "default Data was incorrect")
        } else {
            XCTFail("no default Data could be unpacked")
        }
        
        if let value: NSDate = Johnny.pull("testDate") {
            XCTAssert(value.timeIntervalSince1970 == 1459355217 , "default Date was incorrect")
        } else {
            XCTFail("no default Date could be unpacked")
        }
        
        if let value: UIColor = Johnny.pull("testColor") {
            XCTAssert(value == UIColor.blueColor(), "default Color was incorrect")
        } else {
            XCTFail("no default Color could be unpacked")
        }
    }
    
    
    func testOptionalDefaultTypes() {
        let string: String? = "Heresy grows from idleness"
        let int: Int? = 1
        let int64: Int64? = 2
        let uint: UInt? = 3
        let uint64: UInt64? = 4
        let float: Float? = 10.2
        let double: Double? = 20.6
        
        let ip = NSBundle(forClass: self.dynamicType).resourcePath!.stringByAppendingString("/johnny-logo.png")
        let image = UIImage(contentsOfFile: ip)
        let data: NSData? = image?.toData()
        let date: NSDate? = NSDate(timeIntervalSince1970: 1459355217)
        let color: UIColor? = UIColor.blueColor()
        
        
        Johnny.cache(string, key: "testStringOptional")
        Johnny.cache(int, key: "testIntOptional")
        Johnny.cache(int64, key: "testInt64Optional")
        Johnny.cache(uint, key: "testUIntOptional")
        Johnny.cache(uint64, key: "testUInt64Optional")
        Johnny.cache(float, key: "testFloatOptional")
        Johnny.cache(double, key: "testDoubleOptional")
        Johnny.cache(image, key: "testImageOptional")
        Johnny.cache(data, key: "testDataOptional")
        Johnny.cache(date, key: "testDateOptional")
        Johnny.cache(color, key: "testColorOptional")
        
        
        if let value: String? = Johnny.pull("testStringOptional") {
            XCTAssert(value == "Heresy grows from idleness", "default optional string was incorrect")
        } else {
            XCTFail("no default optional string could be unpacked")
        }
        
        if let value: Int? = Johnny.pull("testIntOptional") {
            XCTAssert(value == 1, "default optional int was incorrect")
        } else {
            XCTFail("no default optional int could be unpacked")
        }
        
        if let value: Int64? = Johnny.pull("testInt64Optional") {
            XCTAssert(value == 2, "default optional int64 was incorrect")
        } else {
            XCTFail("no default optional int64 could be unpacked")
        }
        
        if let value: UInt? = Johnny.pull("testUIntOptional") {
            XCTAssert(value == 3, "default optional uint was incorrect")
        } else {
            XCTFail("no default optional uint could be unpacked")
        }
        
        if let value: UInt64? = Johnny.pull("testUInt64Optional") {
            XCTAssert(value == 4, "default optional uint64 was incorrect")
        } else {
            XCTFail("no default optional uint64 could be unpacked")
        }
        
        if let value: Float? = Johnny.pull("testFloatOptional") {
            XCTAssert(value == 10.2, "default optional float was incorrect")
        } else {
            XCTFail("no default optional float could be unpacked")
        }
        
        if let value: Double? = Johnny.pull("testDoubleOptional") {
            XCTAssert(value == 20.6, "default optional Double was incorrect")
        } else {
            XCTFail("no default optional Double could be unpacked")
        }
        
        if let value: UIImage? = Johnny.pull("testImageOptional") {
            XCTAssert(value!.toData() == data, "default optional Image was incorrect")
        } else {
            XCTFail("no default optional Image could be unpacked")
        }
        
        if let value: NSData? = Johnny.pull("testDataOptional") {
            XCTAssert(value == data, "default optional Data was incorrect")
        } else {
            XCTFail("no default optional Data could be unpacked")
        }
        
        if let value: NSDate? = Johnny.pull("testDateOptional") {
            XCTAssert(value!.timeIntervalSince1970 == 1459355217 , "default optional Date was incorrect")
        } else {
            XCTFail("no default optional Date could be unpacked")
        }
        
        if let value: UIColor? = Johnny.pull("testColorOptional") {
            XCTAssert(value == UIColor.blueColor(), "default optional Color was incorrect")
        } else {
            XCTFail("no default optional Color could be unpacked")
        }
    }
    
    
    func testCollections() {
        
        let ip = NSBundle(forClass: self.dynamicType).resourcePath!.stringByAppendingString("/johnny-logo.png")
        let image = UIImage(contentsOfFile: ip)!
        let data = image.toData()
        
        let stringArray: [String] = ["Heresy", "grows", "from", "idleness"]
        let intArray: [Int] = [1,2]
        let dataArray: [NSData] = [data]
        
        let stringMap: [String: String] = ["first": "Heresy", "second": "grows"]
        let intMap: [String: Int] = ["first": 1, "second": 2]
        let dataMap: [String: NSData] = ["first": data]
        
        let stringSet: Set<String> = ["Heresy", "grows", "from", "idleness"]
        let intSet: Set<Int> = [1,2]
        let dataSet: Set<NSData> = [data]
        
        
        Johnny.cache(stringArray, key: "testStringArray")
        Johnny.cache(intArray, key: "testIntArray")
        Johnny.cache(dataArray, key: "testDataArray")
        Johnny.cache(stringMap, key: "testStringMap")
        Johnny.cache(intMap, key: "testIntMap")
        Johnny.cache(dataMap, key: "testDataMap")
        Johnny.cache(stringSet, key: "testStringSet")
        Johnny.cache(intSet, key: "testIntSet")
        Johnny.cache(dataSet, key: "testDataSet")
        
        
        if let value: [String] = Johnny.pull("testStringArray") {
            XCTAssert(value == ["Heresy", "grows", "from", "idleness"], "default string array was incorrect")
        } else {
            XCTFail("no default string array could be unpacked")
        }
        
        if let value: [Int] = Johnny.pull("testIntArray") {
            XCTAssert(value == [1,2], "default int array was incorrect")
        } else {
            XCTFail("no default int array could be unpacked")
        }
        
        if let value: [NSData] = Johnny.pull("testDataArray") {
            XCTAssert(value == [data], "default int array was incorrect")
        } else {
            XCTFail("no default int array could be unpacked")
        }
        
        if let value: [String: String] = Johnny.pull("testStringMap") {
            XCTAssert(value == ["first": "Heresy", "second": "grows"], "default string map was incorrect")
        } else {
            XCTFail("no default string map could be unpacked")
        }
        
        if let value: [String: Int] = Johnny.pull("testIntMap") {
            XCTAssert(value == ["first": 1, "second": 2], "default int map was incorrect")
        } else {
            XCTFail("no default int map could be unpacked")
        }
        
        if let value: [String: NSData] = Johnny.pull("testDataMap") {
            XCTAssert(value == ["first": data], "default data map was incorrect")
        } else {
            XCTFail("no default data map could be unpacked")
        }
        
        if let value: Set<String> = Johnny.pull("testStringSet") {
            XCTAssert(value == ["Heresy", "grows", "from", "idleness"], "default string set was incorrect")
        } else {
            XCTFail("no default string set could be unpacked")
        }
        
        if let value: Set<Int> = Johnny.pull("testIntSet") {
            XCTAssert(value == [1,2], "default int set was incorrect")
        } else {
            XCTFail("no default int set could be unpacked")
        }
        
        if let value: Set<NSData> = Johnny.pull("testDataSet") {
            XCTAssert(value == [data], "default int set was incorrect")
        } else {
            XCTFail("no default int set could be unpacked")
        }
    }
    
    
    func testOptionalCollections() {
        let ip = NSBundle(forClass: self.dynamicType).resourcePath!.stringByAppendingString("/johnny-logo.png")
        let image = UIImage(contentsOfFile: ip)!
        let data = image.toData()
        
        let stringArray: [String]? = ["Heresy", "grows", "from", "idleness"]
        let intArray: [Int]? = [1,2]
        let dataArray: [NSData]? = [data]
        
        let stringMap: [String: String]? = ["first": "Heresy", "second": "grows"]
        let intMap: [String: Int]? = ["first": 1, "second": 2]
        let dataMap: [String: NSData]? = ["first": data]
        
        let stringSet: Set<String>? = ["Heresy", "grows", "from", "idleness"]
        let intSet: Set<Int>? = [1,2]
        let dataSet: Set<NSData>? = [data]
        
        
        Johnny.cache(stringArray, key: "testStringArrayOptional")
        Johnny.cache(intArray, key: "testIntArrayOptional")
        Johnny.cache(dataArray, key: "testDataArrayOptional")
        Johnny.cache(stringMap, key: "testStringMapOptional")
        Johnny.cache(intMap, key: "testIntMapOptional")
        Johnny.cache(dataMap, key: "testDataMapOptional")
        Johnny.cache(stringSet, key: "testStringSetOptional")
        Johnny.cache(intSet, key: "testIntSetOptional")
        Johnny.cache(dataSet, key: "testDataSetOptional")
        
        
        if let value: [String] = Johnny.pull("testStringArrayOptional") {
            XCTAssert(value == ["Heresy", "grows", "from", "idleness"], "default optional string array was incorrect")
        } else {
            XCTFail("no default optional string array could be unpacked")
        }
        
        if let value: [Int] = Johnny.pull("testIntArrayOptional") {
            XCTAssert(value == [1,2], "default optional int array was incorrect")
        } else {
            XCTFail("no default optional int array could be unpacked")
        }
        
        if let value: [NSData] = Johnny.pull("testDataArrayOptional") {
            XCTAssert(value == [data], "default optional int array was incorrect")
        } else {
            XCTFail("no default optional int array could be unpacked")
        }
        
        if let value: [String: String] = Johnny.pull("testStringMapOptional") {
            XCTAssert(value == ["first": "Heresy", "second": "grows"], "default optional string map was incorrect")
        } else {
            XCTFail("no default optional string map could be unpacked")
        }
        
        if let value: [String: Int] = Johnny.pull("testIntMapOptional") {
            XCTAssert(value == ["first": 1, "second": 2], "default optional int map was incorrect")
        } else {
            XCTFail("no default optional int map could be unpacked")
        }
        
        if let value: [String: NSData] = Johnny.pull("testDataMapOptional") {
            XCTAssert(value == ["first": data], "default optional data map was incorrect")
        } else {
            XCTFail("no default optional data map could be unpacked")
        }
        
        if let value: Set<String> = Johnny.pull("testStringSetOptional") {
            XCTAssert(value == ["Heresy", "grows", "from", "idleness"], "default optional string set was incorrect")
        } else {
            XCTFail("no default optional string set could be unpacked")
        }
        
        if let value: Set<Int> = Johnny.pull("testIntSetOptional") {
            XCTAssert(value == [1,2], "default optional int set was incorrect")
        } else {
            XCTFail("no default optional int set could be unpacked")
        }
        
        if let value: Set<NSData> = Johnny.pull("testDataSetOptional") {
            XCTAssert(value == [data], "default optional int set was incorrect")
        } else {
            XCTFail("no default optional int set could be unpacked")
        }
    }
    
    
    func testStorables() {
        let spacemarine: Ultramarine = Ultramarine()
        Johnny.cache(spacemarine, key: "spacemarine")
        
        if let spacemarine: Ultramarine = Johnny.pull("spacemarine") {
            XCTAssert(spacemarine.identification == 84823682 && spacemarine.badassery == Ultramarine.Badassery.Total, "storable object was incorrect")
        } else {
            XCTFail("no Storable object could be unpacked")
        }
        
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue()) { 
//            Johnny.memory.removeAllObjects()
//
//            
//        }
    }
    
    
    func testOptionalStorables() {
        let spacemarine: Ultramarine? = Ultramarine()
        Johnny.cache(spacemarine, key: "spacemarine")
        
        if let spacemarine: Ultramarine = Johnny.pull("spacemarine") {
            XCTAssert(spacemarine.identification == 84823682 && spacemarine.badassery == Ultramarine.Badassery.Total, "storable object was incorrect")
        } else {
            XCTFail("no Storable object could be unpacked")
        }
    }
}


class Ultramarine {
    
    enum Badassery: String {
        case Total
    }
    
    var identification: Int = 84823682
    var badassery = Badassery.Total
}


extension Ultramarine: Storable {
    typealias Result = Ultramarine
    
    static func fromData(data: NSData) -> Ultramarine.Result? {
        let dict = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! [NSObject: AnyObject]
        
        let spacemarine = Ultramarine()
        spacemarine.identification = dict["identification"] as! Int
        spacemarine.badassery = Badassery(rawValue: dict["badassery"] as! String)!
        return spacemarine
    }
    
    func toData() -> NSData {
        let json = ["identification": identification, "badasery": badassery.rawValue]
        return try! NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
    }
}
