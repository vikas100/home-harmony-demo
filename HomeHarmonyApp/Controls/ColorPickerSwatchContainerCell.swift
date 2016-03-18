//
//  ColorPickerSwatchContainerCell.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/9/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

class ColorPickerSwatchContainerCell: SwatchContainerCell {
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let circleRadius = CGFloat(round(rect.width / 5.0))
        
        CGContextClearRect(context, rect)
        
        if (color != nil) {
            
            let borderSize:CGFloat = self.selected ? 5 : 3
            
            //STROKE LINES
            var hue:CGFloat = 0
            var intensity:CGFloat = 0
            var saturation:CGFloat = 0
            self.color.uiColor.getHue(&hue, saturation: &saturation, brightness: &intensity, alpha: nil)
            
            let unselectedColor = UIColor(hue: hue, saturation: saturation, brightness: intensity, alpha: 0.5)
            
            CGContextSetStrokeColorWithColor(context, self.selected ? CAMBRIAN_COLOR.CGColor : unselectedColor.CGColor)
            CGContextSetLineWidth(context, borderSize);
            
            //top right circle
            CGContextStrokeEllipseInRect(context, CGRect(x: rect.width - 2 * circleRadius - borderSize, y: borderSize/2,
                width:2 * circleRadius - borderSize,height:2 * circleRadius - borderSize))
            
            //bottom left circle
            CGContextStrokeEllipseInRect(context, CGRect(x: borderSize/2, y: rect.height - 2 * circleRadius - borderSize,
                width:2 * circleRadius - borderSize,height:2 * circleRadius - borderSize))
            
            //top left rect
            CGContextClearRect(context, CGRect(x: 0, y: 0,
                width:rect.width - circleRadius - borderSize, height:rect.height - circleRadius - borderSize))
            CGContextStrokeRectWithWidth(context, CGRect(x: borderSize/2, y: borderSize/2,
                width:rect.width - circleRadius - 2 * borderSize, height:rect.height - circleRadius - 2 * borderSize), borderSize)
            
            //bottom right rect
            CGContextClearRect(context, CGRect(x: circleRadius - borderSize/2, y: circleRadius - borderSize/2,
                width:rect.width - circleRadius - borderSize, height:rect.height - circleRadius - borderSize))
            CGContextStrokeRectWithWidth(context, CGRect(x: circleRadius, y: circleRadius,
                width:rect.width - circleRadius - 2 * borderSize, height:rect.height - circleRadius - 2 * borderSize), borderSize)
            
            //FILL OBJECT
            CGContextSetFillColorWithColor(context, color.uiColor.CGColor)
            //top left rect
            CGContextFillRect(context, CGRect(x: borderSize, y: borderSize,
                width:rect.width - circleRadius - 3 * borderSize, height:rect.height - circleRadius - 3 * borderSize))
            
            //bottom right rect
            CGContextFillRect(context, CGRect(x: circleRadius + borderSize/2, y: circleRadius + borderSize/2,
                width:rect.width - circleRadius - 3 * borderSize, height:rect.height - circleRadius - 3 * borderSize))
            
            //top right circle
            CGContextFillEllipseInRect(context, CGRect(x: rect.width - 2 * circleRadius - borderSize/2, y: borderSize,
                width:2 * circleRadius - 2 * borderSize, height:2 * circleRadius - 2 * borderSize))
            
            //bottom left circle
            CGContextFillEllipseInRect(context, CGRect(x: borderSize, y: rect.height - 2 * circleRadius - borderSize/2,
                width:2 * circleRadius - 2 * borderSize, height:2 * circleRadius - 2 * borderSize))
        }
    }
}