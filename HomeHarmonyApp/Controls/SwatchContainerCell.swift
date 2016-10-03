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
    
    override var isSelected: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.clear(rect)
        
        if (color != nil) {
            context?.setFillColor(color.uiColor.cgColor)
            context?.fill(rect)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
}
