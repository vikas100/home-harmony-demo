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
    
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
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
    var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    var targetReceiver: NSObject!
    var targetSelector: Selector!
    
    override func draw(_ rect: CGRect) {
        if (self.hasPhotoLibrary) {
            super.draw(rect)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentMode = UIViewContentMode.scaleAspectFill
        self.imageView!.contentMode = UIViewContentMode.scaleAspectFill;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill;
        self.contentVerticalAlignment = UIControlContentVerticalAlignment.fill;
        
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.borderRadius;
        self.layer.borderWidth = self.borderWidth;
        self.layer.borderColor = self.tintColor.cgColor;
        self.clipsToBounds = true
        
        //transfer all actions
        if (self.targetReceiver == nil) {
            self.allTargets.forEach { (object) -> () in
                if let actions = self.actions(forTarget: object, forControlEvent: UIControlEvents.touchUpInside) {
                    actions.forEach({ (action) -> () in
                        self.targetReceiver = object as NSObject!
                        self.targetSelector = NSSelectorFromString(action)
                        self.removeTarget(object, action: NSSelectorFromString(action), for: UIControlEvents.touchUpInside)
                    })
                }
            }
            
            if let _ = self.targetSelector {
                self.addTarget(self, action: #selector(LibraryThumbnailButton.openLibrary), for: UIControlEvents.touchUpInside)
            }
        }
        
        if (authorizationStatus == .notDetermined) {
            authorizationStatus = PHPhotoLibrary.authorizationStatus()
            if (authorizationStatus == .authorized) {
                self.loadFirstPhotoImage()
            } else {
                self.setImage(UIImage(named: "LibraryButton"), for: UIControlState())
            }
        }
    }
    
    func openLibrary() {
        let previousStatus = authorizationStatus
        if let activeController = window?.visibleViewController {
            ImageManager.sharedInstance.getImage(activeController, type:.photoLibrary) { (image) -> Void in
                self.authorizationStatus = PHPhotoLibrary.authorizationStatus()
                if (previousStatus == .notDetermined && self.authorizationStatus == .authorized) {
                    self.loadFirstPhotoImage()
                }
                
                self.targetReceiver.performSelector(onMainThread: self.targetSelector, with: image, waitUntilDone: false)
            }
        }
    }
    
    func loadFirstPhotoImage() {
        
        let options = PHFetchOptions()
        //options.predicate = NSPredicate()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let results = PHAsset.fetchAssets(with: .image, options: options)
        
        if (results.count > 0) {
            let asset = results[0] as? PHAsset
            PHImageManager.default().requestImage(for: asset!,
                targetSize: CGSize(width: 2 * self.frame.size.width, height: 2 * self.frame.size.height),
                contentMode: .aspectFill,
                options: nil) { (finalResult, _) in
                    self.setImage(finalResult, for: UIControlState())
                    self.hasPhotoLibrary = true
            }
        } else {
            self.isHidden = true
            self.isEnabled = false
            self.isUserInteractionEnabled = false
        }
    }
}
