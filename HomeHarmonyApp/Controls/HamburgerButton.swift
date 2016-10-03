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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        
        let availableHeight = self.frame.size.height - self.contentEdgeInsets.top - self.contentEdgeInsets.bottom
        let lineSpacing = (availableHeight - lineWidth * 3) / 2
        let lineLength = self.frame.size.width - self.contentEdgeInsets.left - self.contentEdgeInsets.right
        
        context?.setFillColor(self.currentTitleColor.cgColor)
        
        context?.fill(CGRect(x: self.contentEdgeInsets.left, y: self.contentEdgeInsets.top, width: lineLength, height: lineWidth))
        
        context?.fill(CGRect(x: self.contentEdgeInsets.left, y: self.contentEdgeInsets.top + lineWidth + lineSpacing, width: lineLength, height: lineWidth))
        
        context?.fill(CGRect(x: self.contentEdgeInsets.left, y: self.contentEdgeInsets.top + 2 * (lineWidth + lineSpacing), width: lineLength, height: lineWidth))
        
    }
}
