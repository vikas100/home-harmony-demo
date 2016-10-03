//
//  LaunchViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/28/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

class FadeSegue:UIStoryboardSegue  {
    override func perform() {
        
        let transition: CATransition = CATransition()
        
        transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
        transition.duration = 1.0
        source.view.window?.layer.add(transition, forKey: "kCATransition")
        //print("%@", sourceViewController);
        source.showDetailViewController(destination, sender: source)
        //sourceViewController.navigationController?.pushViewController(destinationViewController, animated: false)
    }
}

class LaunchViewController: UIViewController {

    var initialPosition:CGRect!
    
    @IBOutlet weak var appIconView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        //self.navigationController?.navigationBar.hidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        var endPoint = CGRect(x: -4, y: 90, width:300,  height:70)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            endPoint = CGRect(x: 0, y: 210, width:300,  height:70)
        }
        if (initialPosition == nil) {
            initialPosition = self.appIconView.frame
        }
        self.appIconView.frame = initialPosition
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                self.appIconView.frame = endPoint
            }, completion: { finished in
                self.performSegue(withIdentifier: "startApp", sender: self)
                
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
