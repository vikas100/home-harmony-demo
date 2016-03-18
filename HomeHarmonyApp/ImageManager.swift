//
//  ImageManager.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/10/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation
import Photos

class ImageManager:NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static var sharedInstance = ImageManager()
    
    var videoStatus = AVAuthorizationStatus.NotDetermined
    var photoStatus = PHAuthorizationStatus.NotDetermined
    
    override init() {
        super.init()
        self.videoStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        self.photoStatus = PHPhotoLibrary.authorizationStatus();
    }
    
    private var callback:((image: UIImage?) -> Void)!
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let cb = callback {
            cb(image: chosenImage)
        }
        self.callback = nil
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let cb = callback {
            cb(image: nil)
        }
        self.callback = nil
    }
    
    func proceedWithCameraAccess(controller: UIViewController, handler: ((Void) -> Void)) {
        
        if (self.videoStatus == .Authorized) {
            dispatch_async(dispatch_get_main_queue(), handler)
        } else {
            self.askForCameraAccess(controller, handler: { (status) -> Void in
                if status == .Authorized {
                    //continue
                    dispatch_async(dispatch_get_main_queue(), handler)
                } else {
                    self.noCameraAccessAlert(controller, showSettings: true)
                }
            })
        }
    }
    
    func askForCameraAccess(controller: UIViewController, handler: ((AVAuthorizationStatus) -> Void)!) {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
            granted in
            
            self.videoStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            
            if let handler = handler {
                dispatch_async(dispatch_get_main_queue(), {
                    handler(self.videoStatus)
                })
            }
        })
    }
    
    func proceedWithPhotoAccess(controller: UIViewController, handler: ((Void) -> Void)) {
        if (self.photoStatus == .Authorized) {
            dispatch_async(dispatch_get_main_queue(), handler)
        } else {
            self.askForPhotosAccess(controller, handler: { (status) -> Void in
                if status == .Authorized {
                    //continue
                    dispatch_async(dispatch_get_main_queue(), handler)
                } else {
                    self.noCameraAccessAlert(controller, showSettings: true)
                }
            })
        }
    }
    
    func askForPhotosAccess(controller: UIViewController, handler: ((PHAuthorizationStatus) -> Void)!) {
        
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            self.photoStatus = status
            
            if let handler = handler {
                dispatch_async(dispatch_get_main_queue(), {
                    handler(self.photoStatus)
                })
            }
        }
    }
    
    func hasCamera() -> Bool {
        return UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear)
    }
    
    func getImage(viewController:UIViewController, type:UIImagePickerControllerSourceType?=nil, callback:(image: UIImage?) -> Void) -> Bool {
        
        self.callback = callback
        
        if let type = type {
            if type == .Camera {
                if (hasCamera()) {
                    showCamera(viewController)
                    return true
                } else {
                    return false
                }
            } else {
                showPhotoLibrary(viewController, type:type)
                return true
            }
        }
        
        let hasCameraOption = hasCamera() && (self.videoStatus == .Authorized || self.videoStatus == .NotDetermined)
        let hasPhotoOption = self.photoStatus == .Authorized || self.photoStatus == .NotDetermined
        
        if (hasCameraOption && hasPhotoOption) {
            let optionMenu = UIAlertController(title: nil, message: "Choose Image Source", preferredStyle: .ActionSheet)
            
            let cameraAction = UIAlertAction(title: "Device Camera", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.showCamera(viewController)
            })
            let libraryAction = UIAlertAction(title: "Photo Library", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.showPhotoLibrary(viewController, type:.PhotoLibrary)
            })
            
            //
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
                callback(image: nil)
                self.callback = nil
            })
            
            optionMenu.addAction(cameraAction)
            optionMenu.addAction(libraryAction)
            optionMenu.addAction(cancelAction)
            
            presentActionSheet(optionMenu, viewController: viewController)

            return true
        } else if (hasCameraOption) {
            self.showCamera(viewController)
            return true
        } else if (hasPhotoOption) {
            self.showPhotoLibrary(viewController, type:.PhotoLibrary)
            return true
        }
        
        return false
    }
    
    func showCamera(viewController:UIViewController, hasPermission:Bool = false) {
        
        if (!hasPermission && self.videoStatus == .NotDetermined) {
            self.proceedWithCameraAccess(viewController, handler: {
                self.showCamera(viewController, hasPermission:true)
            })
        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = .Camera
            viewController.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func showPhotoLibrary(viewController:UIViewController, type:UIImagePickerControllerSourceType, hasPermission:Bool = false) {
        
        if (!hasPermission && self.photoStatus == .NotDetermined) {
            self.proceedWithPhotoAccess(viewController, handler: {
                self.showPhotoLibrary(viewController, type: type, hasPermission: true)
            })
        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = type
            viewController.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func noCameraAccessAlert(controller: UIViewController, showSettings:Bool) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let title = NSLocalizedString("no camera alert title", comment:"")
            let message = NSLocalizedString("no camera alert text", comment:"")
            
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: .Cancel, handler: nil))
            
            if (showSettings) {
                alert.addAction(UIAlertAction(title: NSLocalizedString("Go to Settings", comment:""), style: .Default, handler: { action in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }))
            }
            
            controller.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func noPhotosAccessAlert(controller: UIViewController, showSettings:Bool) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let title = NSLocalizedString("no photos alert title", comment:"")
            let message = NSLocalizedString("no photos alert text", comment:"")
            
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: .Cancel, handler: nil))
            
            if (showSettings) {
                alert.addAction(UIAlertAction(title: NSLocalizedString("Go to Settings", comment:""), style: .Default, handler: { action in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }))
            }
            
            controller.presentViewController(alert, animated: true, completion: nil)
        }
    }
}