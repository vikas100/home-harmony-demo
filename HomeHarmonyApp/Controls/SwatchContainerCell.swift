//
//  SwatchContainerCell.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/1/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation
import UIKit

class SwatchContainerCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SwatchCell"
    
    weak var color: Color! {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var selected: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextClearRect(context, rect)
        
        if (color != nil) {
            CGContextSetFillColorWithColor(context, color.uiColor.CGColor)
            CGContextFillRect(context, rect)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
}
