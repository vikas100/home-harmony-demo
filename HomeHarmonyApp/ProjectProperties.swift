//
//  ProjectProperties.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/23/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

func getSampleBasePath() -> String! {
    return Bundle.main.path(forResource: "Rooms", ofType: nil)
}

func getSampleTypePath(_ roomType: String) -> String! {
    return "\(getSampleBasePath())/\(roomType)"
}

func getSampleProjectPath(_ roomType: String, projectID:String) -> String! {
    return "\(getSampleTypePath(roomType))/\(projectID)"
}

func applyPlainShadow(_ view: UIView, offset:CGSize) {
    let layer = view.layer
    
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = offset
    layer.shadowOpacity = 0.3
    layer.shadowRadius = max(fabs(offset.width), fabs(offset.height)/2.0)
}

let INITIAL_COLOR_CATEGORY = "ColorSmart Premium Plus"
let CAMBRIAN_COLOR = UIColor(red: 22/255.0, green: 167/255.0, blue: 231/255.0, alpha: 1.0)

func isLightColor(_ color:UIColor) -> Bool {
    var intensity:CGFloat = 0
    var saturation:CGFloat = 0
    color.getHue(nil, saturation: &saturation, brightness: &intensity, alpha: nil)
    let isLightColor = intensity > 0.8 && saturation < 0.3
    return isLightColor
}

func presentActionSheet(_ actionSheet:UIAlertController, viewController:UIViewController) {
    if let popoverController = actionSheet.popoverPresentationController {
        popoverController.sourceView = viewController.view
        popoverController.sourceRect = CGRect(x: viewController.view.bounds.width/2-25, y: viewController.view.bounds.height/2-25, width: 50, height: 50)
    }
    viewController.present(actionSheet, animated: true, completion: nil)
}
