//
//  CGSize+Johnny.swift
//  Johnny
//
//  Created by Zolo on 6/30/16.
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