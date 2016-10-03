//
//  ColorPickerMarker.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/11/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

@IBDesignable
class ColorPickerMarker: UIView {
    
    @IBInspectable var borderSize:CGFloat = 3.0
    
    fileprivate var color: UIColor!;
    
    override var backgroundColor: UIColor?  {
        didSet {
            if (backgroundColor != UIColor.clear) {
                color = backgroundColor
                self.backgroundColor = UIColor.clear;
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        self.isOpaque = false
        
        context?.clear(rect)
        
        if let color = color {
            
            //STROKE LINES
//            var hue:CGFloat = 0
//            var intensity:CGFloat = 0
//            var saturation:CGFloat = 0
//            color.getHue(&hue, saturation: &saturation, brightness: &intensity, alpha: nil)
            
            context?.setFillColor(color.cgColor)
            context?.fillEllipse(in: rect)
            
            context?.setStrokeColor(self.tintColor.cgColor)
            context?.setLineWidth(borderSize);
            
            context?.strokeEllipse(in: CGRect(x: borderSize/2.0, y: borderSize/2.0, width: rect.width - borderSize, height: rect.height - borderSize))
            
        }
    }
}
