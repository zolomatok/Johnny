//
//  Extension-UIColor.swift
//  Johnny
//
//  Created by Zolo on 6/30/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import UIKit

open class Color: Codable {
    let colorString: String
    public init?(color: UIColor?) {
        guard let color = color else { return nil }
        guard let components = color.cgColor.components else { return nil }
        colorString = "\(components[0]), \(components[1]), \(components[2]), \(components[3])"
    }
    
    open func uiColor() -> UIColor {
        let components = colorString.components(separatedBy: ", ")
        return UIColor(red: CGFloat((components[0] as NSString).floatValue),
                       green: CGFloat((components[1] as NSString).floatValue),
                       blue: CGFloat((components[2] as NSString).floatValue),
                       alpha: CGFloat((components[3] as NSString).floatValue))
    }
}
