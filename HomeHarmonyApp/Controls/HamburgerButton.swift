//
//  HamburgerButton.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/2/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

@IBDesignable
class HamburgerButton: UIButton {
    
    @IBInspectable var lineWidth: CGFloat = 3
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        
        let availableHeight = self.frame.size.height - self.contentEdgeInsets.top - self.contentEdgeInsets.bottom
        let lineSpacing = (availableHeight - lineWidth * 3) / 2
        let lineLength = self.frame.size.width - self.contentEdgeInsets.left - self.contentEdgeInsets.right
        
        CGContextSetFillColorWithColor(context, self.currentTitleColor.CGColor)
        
        CGContextFillRect(context, CGRectMake(self.contentEdgeInsets.left, self.contentEdgeInsets.top, lineLength, lineWidth))
        
        CGContextFillRect(context, CGRectMake(self.contentEdgeInsets.left, self.contentEdgeInsets.top + lineWidth + lineSpacing, lineLength, lineWidth))
        
        CGContextFillRect(context, CGRectMake(self.contentEdgeInsets.left, self.contentEdgeInsets.top + 2 * (lineWidth + lineSpacing), lineLength, lineWidth))
        
    }
}