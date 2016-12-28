//
//  Log.swift
//  Johnny
//
//  Created by Zolo on 6/27/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation

struct Log {
    
    fileprivate static let Tag = "[JOHNNY]"
    static func log(_ message: String, _ error: Error) {
        #if DEBUG
            NSLog(Tag + " " + message + ":" + (error as NSError).description)
        #endif
    }
}
