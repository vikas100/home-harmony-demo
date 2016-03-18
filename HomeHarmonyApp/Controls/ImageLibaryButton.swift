//
//  ImageLibaryButton.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/3/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation
import Photos

public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

@IBDesignable
class LibraryThumbnailButton: UIButton {
    
    @IBInspectable var borderRadius: CGFloat = 10.0
    @IBInspectable var borderWidth: CGFloat = 1.0
    
    var hasPhotoLibrary = false
    var authorizationStatus: PHAuthorizationStatus = .NotDetermined
    
    var targetReceiver: NSObject!
    var targetSelector: Selector!
    
    override func drawRect(rect: CGRect) {
        if (self.hasPhotoLibrary) {
            super.drawRect(rect)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageView!.contentMode = UIViewContentMode.ScaleAspectFill;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill;
        self.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill;
        
        self.opaque = false
        self.backgroundColor = UIColor.clearColor()
        self.layer.cornerRadius = self.borderRadius;
        self.layer.borderWidth = self.borderWidth;
        self.layer.borderColor = self.tintColor.CGColor;
        self.clipsToBounds = true
        
        //transfer all actions
        if (self.targetReceiver == nil) {
            self.allTargets().forEach { (object) -> () in
                if let actions = self.actionsForTarget(object, forControlEvent: UIControlEvents.TouchUpInside) {
                    actions.forEach({ (action) -> () in
                        self.targetReceiver = object
                        self.targetSelector = NSSelectorFromString(action)
                        self.removeTarget(object, action: NSSelectorFromString(action), forControlEvents: UIControlEvents.TouchUpInside)
                    })
                }
            }
            
            if let _ = self.targetSelector {
                self.addTarget(self, action: "openLibrary", forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        
        if (authorizationStatus == .NotDetermined) {
            authorizationStatus = PHPhotoLibrary.authorizationStatus()
            if (authorizationStatus == .Authorized) {
                self.loadFirstPhotoImage()
            } else {
                self.setImage(UIImage(named: "LibraryButton"), forState: .Normal)
            }
        }
    }
    
    func openLibrary() {
        let previousStatus = authorizationStatus
        if let activeController = window?.visibleViewController {
            ImageManager.sharedInstance.getImage(activeController, type:.PhotoLibrary) { (image) -> Void in
                self.authorizationStatus = PHPhotoLibrary.authorizationStatus()
                if (previousStatus == .NotDetermined && self.authorizationStatus == .Authorized) {
                    self.loadFirstPhotoImage()
                }
                
                self.targetReceiver.performSelectorOnMainThread(self.targetSelector, withObject: image, waitUntilDone: false)
            }
        }
    }
    
    func loadFirstPhotoImage() {
        
        let options = PHFetchOptions()
        //options.predicate = NSPredicate()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let results = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        
        if (results.count > 0) {
            let asset = results[0] as? PHAsset
            PHImageManager.defaultManager().requestImageForAsset(asset!,
                targetSize: CGSize(width: 2 * self.frame.size.width, height: 2 * self.frame.size.height),
                contentMode: .AspectFill,
                options: nil) { (finalResult, _) in
                    self.setImage(finalResult, forState: .Normal)
                    self.hasPhotoLibrary = true
            }
        } else {
            self.hidden = true
            self.enabled = false
            self.userInteractionEnabled = false
        }
    }
}