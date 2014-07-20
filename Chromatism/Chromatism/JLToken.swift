//
//  JLToken.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit
class JLToken: JLScope {
    
    var regularExpression: NSRegularExpression
    var captureGroup = 0
    var contentCaptureGroup: Int?
    var tokenType: JLTokenType
    
    init(regularExpression: NSRegularExpression, tokenType: JLTokenType) {
        self.regularExpression = regularExpression
        self.tokenType = tokenType
        super.init()
    }
    
    convenience init(pattern: String, tokenType: JLTokenType) {
        self.init(pattern: pattern, options: .AnchorsMatchLines, tokenType: tokenType)
    }
    
    convenience init(pattern: String, options: NSRegularExpressionOptions, tokenType: JLTokenType) {
        let expression = NSRegularExpression(pattern: pattern, options: options, error: nil)
        self.init(regularExpression: expression, tokenType: tokenType)
    }
    
    convenience init(pattern: String, tokenType: JLTokenType, scope: JLScope, contentCaptureGroup: Int) {
        self.init(pattern: pattern, tokenType: tokenType)
        self.contentCaptureGroup = contentCaptureGroup
    }
    
    convenience init(keywords: [String], tokenType: JLTokenType) {
        let pattern = "\\b(%" + join("|", keywords) + ")\\b"
        self.init(pattern: pattern, tokenType: tokenType)
    }
    
    override func perform(attributedString: NSMutableAttributedString, parentIndexSet: NSIndexSet) {
        let indexSet = NSMutableIndexSet()
        let contentIndexSet = NSMutableIndexSet()
        parentIndexSet.enumerateRangesUsingBlock({ (range, stop) in
            self.regularExpression.enumerateMatchesInString(attributedString.string, options: nil, range: range, usingBlock: {(result, flags, stop) in
                let range = result.rangeAtIndex(self.captureGroup)
                
                if let color = self.colorDictionary?[self.tokenType] {
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                }
                
                indexSet.addIndexesInRange(range)
                if let captureGroup = self.contentCaptureGroup {
                    contentIndexSet.addIndexesInRange(result.rangeAtIndex(captureGroup))
                }
                })
            })
        
        if contentCaptureGroup {
            performSubscopes(attributedString, indexSet: contentIndexSet)
        }
        
        self.indexSet = indexSet
    }
    
    override var description: String {
        return "JLToken"
    }
}
