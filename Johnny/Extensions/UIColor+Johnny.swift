//
//  Extension-UIColor.swift
//  Johnny
//
//  Created by Zolo on 6/30/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import UIKit

class Color: Codable {
    let colorString: String
    init(color: UIColor) {
        colorString = CIColor(cgColor: color.cgColor).stringRepresentation
    }
    
    func uiColor() -> UIColor {
        let ciColor = CIColor(string: colorString)
        return UIColor(ciColor: ciColor)
    }
}
