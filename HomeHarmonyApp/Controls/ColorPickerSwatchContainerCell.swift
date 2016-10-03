//
//  ColorPickerSwatchContainerCell.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/9/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

class ColorPickerSwatchContainerCell: SwatchContainerCell {
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let circleRadius = CGFloat(round(rect.width / 5.0))
        
        context?.clear(rect)
        
        if (color != nil) {
            
            let borderSize:CGFloat = self.isSelected ? 5 : 3
            
            //STROKE LINES
            var hue:CGFloat = 0
            var intensity:CGFloat = 0
            var saturation:CGFloat = 0
            self.color.uiColor.getHue(&hue, saturation: &saturation, brightness: &intensity, alpha: nil)
            
            let unselectedColor = UIColor(hue: hue, saturation: saturation, brightness: intensity, alpha: 0.5)
            
            context?.setStrokeColor(self.isSelected ? CAMBRIAN_COLOR.cgColor : unselectedColor.cgColor)
            context?.setLineWidth(borderSize);
            
            //top right circle
            context?.strokeEllipse(in: CGRect(x: rect.width - 2 * circleRadius - borderSize, y: borderSize/2,
                width:2 * circleRadius - borderSize,height:2 * circleRadius - borderSize))
            
            //bottom left circle
            context?.strokeEllipse(in: CGRect(x: borderSize/2, y: rect.height - 2 * circleRadius - borderSize,
                width:2 * circleRadius - borderSize,height:2 * circleRadius - borderSize))
            
            //top left rect
            context?.clear(CGRect(x: 0, y: 0,
                width:rect.width - circleRadius - borderSize, height:rect.height - circleRadius - borderSize))
            context?.stroke(CGRect(x: borderSize/2, y: borderSize/2,
                width:rect.width - circleRadius - 2 * borderSize, height:rect.height - circleRadius - 2 * borderSize), width: borderSize)
            
            //bottom right rect
            context?.clear(CGRect(x: circleRadius - borderSize/2, y: circleRadius - borderSize/2,
                width:rect.width - circleRadius - borderSize, height:rect.height - circleRadius - borderSize))
            context?.stroke(CGRect(x: circleRadius, y: circleRadius,
                width:rect.width - circleRadius - 2 * borderSize, height:rect.height - circleRadius - 2 * borderSize), width: borderSize)
            
            //FILL OBJECT
            context?.setFillColor(color.uiColor.cgColor)
            //top left rect
            context?.fill(CGRect(x: borderSize, y: borderSize,
                width:rect.width - circleRadius - 3 * borderSize, height:rect.height - circleRadius - 3 * borderSize))
            
            //bottom right rect
            context?.fill(CGRect(x: circleRadius + borderSize/2, y: circleRadius + borderSize/2,
                width:rect.width - circleRadius - 3 * borderSize, height:rect.height - circleRadius - 3 * borderSize))
            
            //top right circle
            context?.fillEllipse(in: CGRect(x: rect.width - 2 * circleRadius - borderSize/2, y: borderSize,
                width:2 * circleRadius - 2 * borderSize, height:2 * circleRadius - 2 * borderSize))
            
            //bottom left circle
            context?.fillEllipse(in: CGRect(x: borderSize, y: rect.height - 2 * circleRadius - borderSize/2,
                width:2 * circleRadius - 2 * borderSize, height:2 * circleRadius - 2 * borderSize))
        }
    }
}
