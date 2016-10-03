//
//  SwatchContainerCell.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/1/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation
import UIKit

class ExpandingSwatchContainerCell: SwatchContainerCell {
    
    var scale:CGFloat = 1.5
    
    override var isSelected: Bool {
        didSet {
            if self.expands {
                if self.isSelected {
                    // animate selection
                    changeZDepth(true)
                } else {
                    changeZDepth(false)
                }
            }
        }
    }
    
    var expands = true
    
    func changeZDepth(_ bringForward:Bool) {
        
        let layer = self.layer
        
        scale = 1 + 20.0 / self.bounds.width;
        
        if bringForward {
            if (self.superview != nil) {
                self.superview?.bringSubview(toFront: self)
            }
            let offset = CGSize(width: 1, height: 5)
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = offset
            layer.shadowOpacity = 0.5
            layer.shadowRadius = max(fabs(offset.width), fabs(offset.height)/2.0)
            
            //self.superview!.bringSubviewToFront(self)
            UIView.animate(withDuration: 0.125, animations: { () -> Void in
                //self.frame = self.startFrame
                self.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1);
                }, completion: { (Bool) -> Void in
                    
                    UIView.animate(withDuration: 0.125, animations: { () -> Void in
                        self.layer.transform = CATransform3DMakeScale(self.scale, self.scale, 1);
                    }) 
            })
        } else {
            layer.shadowColor = UIColor.clear.cgColor
            
            UIView.animate(withDuration: 0.125, animations: { () -> Void in
                self.layer.transform = CATransform3DMakeScale(self.scale, self.scale, 1);
                }, completion: { (Bool) -> Void in
                    
                    UIView.animate(withDuration: 0.125, animations: { () -> Void in
                        self.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1);
                    }) 
            })
        }
    }
}
