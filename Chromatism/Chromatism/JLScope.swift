//
//  JLScope.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLScope: NSObject, Printable, Equatable {
    
    init() {
        super.init()
    }
    
    init(scope: JLScope) {
        super.init()
        scope.addSubscope(self)
    }
    
    subscript(scopes: JLScope...) -> JLScope {
        self.subscopes = scopes
            return self
    }
    
    var multiline = false
    var theme: JLColorTheme?
    var editedIndexSet: NSIndexSet?
    
    // Will set the color to .Text in this scope's parentIndexSet before performing.
    var clearWithTextColorBeforePerform = false
    
    var indexSet = NSMutableIndexSet()
    var subscopes = [JLScope]()
    
    func addSubscope(subscope: JLScope) {
        self.subscopes += subscope
    }
    
    func perform(attributedString: NSMutableAttributedString) {
        perform(attributedString, parentIndexSet: NSIndexSet(indexesInRange: NSMakeRange(0, attributedString.length)))
    }
    
    func perform(attributedString: NSMutableAttributedString, parentIndexSet: NSIndexSet) {
        
        if clearWithTextColorBeforePerform {
            
            parentIndexSet.enumerateRangesUsingBlock({(range, stop) in
                if let color = self.theme?[.Text] {
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                }
                })
            
            invalidateAttributesInIndexes(parentIndexSet, attributedString: attributedString)
        }
        // Create a copy of the indexSet and call perform to subscopes
        // The results of the subscope is removed from the indexSet copy before the next subscope is performed
        let indexSetCopy = parentIndexSet.mutableCopy() as NSMutableIndexSet
        performSubscopes(attributedString, indexSet: indexSetCopy)
        
        self.indexSet = parentIndexSet.mutableCopy() as NSMutableIndexSet
    }
    
    // Will change indexSet
    func performSubscopes(attributedString: NSMutableAttributedString, indexSet: NSMutableIndexSet) {
        
        for (index, scope) in enumerate(subscopes) {
            scope.theme = theme
            
            var oldSet = scope.indexSet
            scope.perform(attributedString, parentIndexSet: indexSet)
            var newSet = scope.indexSet
            
            indexSet -= newSet
            if scope.multiline {
                indexSet += NSIndexSetDelta(oldSet, newSet).deletions
            }
        }
    }
    
    func invalidateAttributesInIndexes(indexSet: NSIndexSet, attributedString: NSMutableAttributedString) {
        for scope in subscopes { scope.invalidateAttributesInIndexes(indexSet, attributedString: attributedString) }
    }
    
    // Printable
    override public var description: String {
        return "JLScope"
    }
    
    func attributedStringDidChange(range: NSRange, delta: Int) {
        self.indexSet.removeIndexesInRange(range)
        self.indexSet.shiftIndexesStartingAtIndex(range.location, by: delta)
    }
    
}

public func ==(lhs: JLScope, rhs: JLScope) -> Bool {
    return lhs.subscopes == rhs.subscopes && lhs.indexSet == rhs.indexSet
}
