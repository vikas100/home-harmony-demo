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
    
    var videoStatus = AVAuthorizationStatus.notDetermined
    var photoStatus = PHAuthorizationStatus.notDetermined
    
    override init() {
        super.init()
        self.videoStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        self.photoStatus = PHPhotoLibrary.authorizationStatus();
    }
    
    fileprivate var callback:((_ image: UIImage?) -> Void)!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        picker.dismiss(animated: true, completion: nil)
        
        if let cb = callback {
            cb(chosenImage)
        }
        self.callback = nil
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
        if let cb = callback {
            cb(nil)
        }
        self.callback = nil
    }
    
    func proceedWithCameraAccess(_ controller: UIViewController, handler: @escaping ((Void) -> Void)) {
        
        if (self.videoStatus == .authorized) {
            DispatchQueue.main.async(execute: handler)
        } else {
            self.askForCameraAccess(controller, handler: { (status) -> Void in
                if status == .authorized {
                    //continue
                    DispatchQueue.main.async(execute: handler)
                } else {
                    self.noCameraAccessAlert(controller, showSettings: true)
                }
            })
        }
    }
    
    func askForCameraAccess(_ controller: UIViewController, handler: ((AVAuthorizationStatus) -> Void)!) {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {
            granted in
            
            self.videoStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            
            if let handler = handler {
                DispatchQueue.main.async(execute: {
                    handler(self.videoStatus)
                })
            }
        })
    }
    
    func proceedWithPhotoAccess(_ controller: UIViewController, handler: @escaping ((Void) -> Void)) {
        if (self.photoStatus == .authorized) {
            DispatchQueue.main.async(execute: handler)
        } else {
            self.askForPhotosAccess(controller, handler: { (status) -> Void in
                if status == .authorized {
                    //continue
                    DispatchQueue.main.async(execute: handler)
                } else {
                    self.noCameraAccessAlert(controller, showSettings: true)
                }
            })
        }
    }
    
    func askForPhotosAccess(_ controller: UIViewController, handler: ((PHAuthorizationStatus) -> Void)!) {
        
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            self.photoStatus = status
            
            if let handler = handler {
                DispatchQueue.main.async(execute: {
                    handler(self.photoStatus)
                })
            }
        }
    }
    
    func hasCamera() -> Bool {
        return UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear)
    }
    
    func getImage(_ viewController:UIViewController, type:UIImagePickerControllerSourceType?=nil, callback:@escaping (_ image: UIImage?) -> Void) -> Bool {
        
        self.callback = callback
        
        if let type = type {
            if type == .camera {
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
        
        let hasCameraOption = hasCamera() && (self.videoStatus == .authorized || self.videoStatus == .notDetermined)
        let hasPhotoOption = self.photoStatus == .authorized || self.photoStatus == .notDetermined
        
        if (hasCameraOption && hasPhotoOption) {
            let optionMenu = UIAlertController(title: nil, message: "Choose Image Source", preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Device Camera", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.showCamera(viewController)
            })
            let libraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.showPhotoLibrary(viewController, type:.photoLibrary)
            })
            
            //
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
                callback(nil)
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
            self.showPhotoLibrary(viewController, type:.photoLibrary)
            return true
        }
        
        return false
    }
    
    func showCamera(_ viewController:UIViewController, hasPermission:Bool = false) {
        
        if (!hasPermission && self.videoStatus == .notDetermined) {
            self.proceedWithCameraAccess(viewController, handler: {
                self.showCamera(viewController, hasPermission:true)
            })
        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = .camera
            viewController.present(picker, animated: true, completion: nil)
        }
    }
    
    func showPhotoLibrary(_ viewController:UIViewController, type:UIImagePickerControllerSourceType, hasPermission:Bool = false) {
        
        if (!hasPermission && self.photoStatus == .notDetermined) {
            self.proceedWithPhotoAccess(viewController, handler: {
                self.showPhotoLibrary(viewController, type: type, hasPermission: true)
            })
        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = type
            viewController.present(picker, animated: true, completion: nil)
        }
    }
    
    func noCameraAccessAlert(_ controller: UIViewController, showSettings:Bool) {
        
        DispatchQueue.main.async { () -> Void in
            let title = NSLocalizedString("no camera alert title", comment:"")
            let message = NSLocalizedString("no camera alert text", comment:"")
            
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: .cancel, handler: nil))
            
            if (showSettings) {
                alert.addAction(UIAlertAction(title: NSLocalizedString("Go to Settings", comment:""), style: .default, handler: { action in
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }))
            }
            
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    func noPhotosAccessAlert(_ controller: UIViewController, showSettings:Bool) {
        
        DispatchQueue.main.async { () -> Void in
            let title = NSLocalizedString("no photos alert title", comment:"")
            let message = NSLocalizedString("no photos alert text", comment:"")
            
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: .cancel, handler: nil))
            
            if (showSettings) {
                alert.addAction(UIAlertAction(title: NSLocalizedString("Go to Settings", comment:""), style: .default, handler: { action in
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }))
            }
            
            controller.present(alert, animated: true, completion: nil)
        }
    }
}
