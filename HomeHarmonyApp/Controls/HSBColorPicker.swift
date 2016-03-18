//
//  HSLColorPicker.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/7/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

    internal protocol HSBColorPickerDelegate : NSObjectProtocol {
        func HSBColorColorPickerTouched(sender:HSBColorPicker, color:UIColor, point:CGPoint, state:UIGestureRecognizerState)
    }

    @IBDesignable
    class HSBColorPicker : UIView {
        
        weak internal var delegate: HSBColorPickerDelegate?
        let saturationExponentTop:Float = 2.0
        let saturationExponentBottom:Float = 1.3
        
        @IBInspectable var elementSize: CGFloat = 1.0 {
            didSet {
                setNeedsDisplay()
            }
        }
        
        private func initialize() {
            self.clipsToBounds = true
            let touchGesture = UILongPressGestureRecognizer(target: self, action: "touchedColor:")
            touchGesture.minimumPressDuration = 0
            touchGesture.allowableMovement = CGFloat.max
            self.addGestureRecognizer(touchGesture)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            initialize()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            initialize()
        }
        
        override func drawRect(rect: CGRect) {
            let context = UIGraphicsGetCurrentContext()
            
            for var y = CGFloat(0.0); y < rect.height; y=y+elementSize {
                var saturation = y < rect.height / 2.0 ? CGFloat(2 * y) / rect.height : 2.0 * CGFloat(rect.height - y) / rect.height
                saturation = CGFloat(powf(Float(saturation), y < rect.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
                let brightness = y < rect.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(rect.height - y) / rect.height
                
                for var x = CGFloat(0.0); x < rect.width; x=x+elementSize {
                    let hue = x / rect.width
                    let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                    CGContextSetFillColorWithColor(context, color.CGColor)
                    CGContextFillRect(context, CGRect(x:x, y:y, width:elementSize,height:elementSize))
                }
            }
        }
        
        func getColorAtPoint(point:CGPoint) -> UIColor {
            let roundedPoint = CGPoint(x:elementSize * CGFloat(Int(point.x / elementSize)),
                                       y:elementSize * CGFloat(Int(point.y / elementSize)))
            var saturation = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(2 * roundedPoint.y) / self.bounds.height
                : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
            saturation = CGFloat(powf(Float(saturation), roundedPoint.y < self.bounds.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
            let brightness = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
            let hue = roundedPoint.x / self.bounds.width
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        }
        
        func getPointForColor(color:UIColor) -> CGPoint {
            var hue:CGFloat=0;
            var saturation:CGFloat=0;
            var brightness:CGFloat=0;
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil);
            
            var yPos:CGFloat = 0
            let halfHeight = (self.bounds.height / 2)
            
            if (brightness >= 0.99) {
                let percentageY = powf(Float(saturation), 1.0 / saturationExponentTop)
                yPos = CGFloat(percentageY) * halfHeight
            } else {
                //use brightness to get Y
                yPos = halfHeight + halfHeight * (1.0 - brightness)
            }
            
            let xPos = hue * self.bounds.width
            
            return CGPoint(x: xPos, y: yPos)
        }
        
        func touchedColor(gestureRecognizer: UILongPressGestureRecognizer){
            let point = gestureRecognizer.locationInView(self)
            let color = getColorAtPoint(point)
            
            self.delegate?.HSBColorColorPickerTouched(self, color: color, point: point, state:gestureRecognizer.state)
        }
    }
