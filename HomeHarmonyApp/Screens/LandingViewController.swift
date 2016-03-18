//
//  LandingViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/16/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit
import Photos

struct TutorialStep {
    var text:String
    var duration:NSTimeInterval
    var view:UIView! = nil
}

class LandingViewController: UIViewController, SampleCellDelegate, ProjectCellDelegate, MainActionDelegate {

    @IBOutlet weak var mainAction: UIView!
    @IBOutlet weak var mainActionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var projectsView: UIView!
    @IBOutlet weak var projectsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var samplesView: UIView!
    @IBOutlet weak var samplesHeight: NSLayoutConstraint!
    @IBOutlet weak var tutorialView: UIView!
    @IBOutlet weak var tutorialLabel: UILabel!
    
    @IBOutlet weak var tutorialOpeningX: NSLayoutConstraint!
    @IBOutlet weak var tutorialOpeningY: NSLayoutConstraint!
    @IBOutlet weak var tutorialOpeningWidth: NSLayoutConstraint!
    @IBOutlet weak var tutorialOpeningHeight: NSLayoutConstraint!
    @IBOutlet weak var tutorialSkipButton: UIButton!
    
    private var selectedProjectPath: String!
    private var isSample = false
    private var colorFinderImage:UIImage!
    
    private var mainActionsVC:MainActionsViewController!
    
    private var tutorialSteps: [TutorialStep] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tutorialView.hidden = true
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        projectsView.hidden = ProjectDatabase.sharedDatabase().count == 0
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        let availableHeight = self.view.frame.height - CGRectGetMinY(mainAction.frame)
        
        let eachHeight = availableHeight / 3
        
        mainActionHeight.constant = eachHeight
        projectsHeight.constant = projectsView.hidden ? 0 : eachHeight
        samplesHeight.constant = eachHeight
        
        mainAction.layoutIfNeeded()
        projectsView.layoutIfNeeded()
        samplesView.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (!UserPreferences.sharedPreferences().hasSeenLandingInstructions) {
            //setup tutorial
            tutorialSteps.append(TutorialStep(text: NSLocalizedString("TutorialStep1", comment: ""), duration:5, view:nil))
            tutorialSteps.append(TutorialStep(text: NSLocalizedString("TutorialStep2", comment: ""), duration:5, view:nil))
            tutorialSteps.append(TutorialStep(text: NSLocalizedString("TutorialStep3", comment: ""), duration:5, view:nil))
            
            for var i = 0; i < mainActionsVC.collectionView!.numberOfItemsInSection(0) && i < tutorialSteps.count; i++
            {
                if let cell = mainActionsVC.collectionView!.cellForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) {
                    tutorialSteps[i].view = cell
                }
            }
            showTutorial()
        }
    }

    @IBAction func skipStep(sender: AnyObject) {
        showTutorialStep(currentStep + 1)
    }
    
    var currentStep = -1
    func showTutorial() {
        currentStep = -1
        self.tutorialSkipButton.hidden = true
        self.tutorialView.alpha = 0.0
        self.tutorialLabel.hidden = true
        self.tutorialView.hidden = false
        self.tutorialOpeningWidth.constant = 0
        self.tutorialOpeningHeight.constant = 0
        
        UIView.animateWithDuration(1.0, delay: 1.0, options: .CurveEaseOut, animations: {
            self.tutorialView.alpha = 1.0
            }, completion: { finished in
                self.showTutorialStep(0)
        })
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.tutorialView.hidden = false
        }
    }
    
    func showTutorialStep(index:Int) {
        
        if (index <= currentStep) {
            return;//was skipped by user
        }
        currentStep = index;
        
        if (index < tutorialSteps.count) {
            let step = tutorialSteps[index]
            
            if (index < tutorialSteps.count - 1) {
                self.tutorialSkipButton.setTitle(NSLocalizedString("TutorialSkipAny", comment: ""), forState: UIControlState.Normal)
            } else {
                self.tutorialSkipButton.setTitle(NSLocalizedString("TutorialSkipLast", comment: ""), forState: UIControlState.Normal)
            }
            
            var opening = CGRect()
            if let view = step.view {
                let point = view.superview!.convertPoint(view.frame.origin, toView: self.tutorialView)
                opening.origin = point
                opening.size.width = view.bounds.size.width
                opening.size.height = view.bounds.size.height
            }
            
            self.tutorialSkipButton.hidden = false
            tutorialLabel.hidden = true
            UIView.animateWithDuration(index == 0 ? 0.2 : 0.5, delay: 0.0, options: .CurveEaseOut, animations: {
                self.tutorialOpeningX.constant = opening.origin.x
                self.tutorialOpeningY.constant = opening.origin.y
                self.tutorialOpeningWidth.constant = opening.width
                self.tutorialOpeningHeight.constant = opening.height
                self.tutorialView.layoutIfNeeded()
                }, completion: { finished in
                    self.tutorialLabel.text = step.text
                    self.tutorialLabel.alpha = 0
                    self.tutorialLabel.hidden = false
                    
                    //Fade in text
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.tutorialLabel.alpha = 1.0
                        }, completion: { finished in
                            //Wait specified time, then continue recursively
                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(step.duration * Double(NSEC_PER_SEC)))
                            dispatch_after(delayTime, dispatch_get_main_queue()) {
                                self.showTutorialStep(index+1)
                            }
                    })
            })
        }
        else {
            //ALL DONE
            UserPreferences.sharedPreferences().hasSeenLandingInstructions = true
            
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
                self.tutorialView.alpha = 0.0
                }, completion: { finished in
                    self.tutorialView.hidden = true
            })
        }
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? AugmentedViewController {
            if (nil != self.selectedProjectPath) {
                vc.projectPath = self.selectedProjectPath
                vc.isSample = self.isSample
            }
        }
        else if let vc = segue.destinationViewController as? SampleTypeViewController {
            vc.delegate = self
        } else if let vc = segue.destinationViewController as? SampleCollectionViewController {
            vc.delegate = self
        } else if let vc = segue.destinationViewController as? ProjectCollectionViewController {
            vc.delegate = self
        } else if let vc = segue.destinationViewController as? ProjectListingViewController {
            vc.delegate = self
        } else if let vc = segue.destinationViewController as? MainActionsViewController {
            vc.delegate = self
            self.mainActionsVC = vc
        } else if let vc = segue.destinationViewController as? ColorFinderViewController {
            vc.image = self.colorFinderImage
            self.colorFinderImage = nil
        }
        
        self.selectedProjectPath = nil
        self.isSample = false
    }
    
    func sampleSelected(samplePath:String) {
        print("Selected \(samplePath)")
        self.selectedProjectPath = samplePath
        self.isSample = true
        self.performSegueWithIdentifier("showPainter", sender: self)
    }
    
    func projectSelected(samplePath:String) {
        print("Selected \(samplePath)")
        self.selectedProjectPath = samplePath
        self.performSegueWithIdentifier("showPainter", sender: self)
    }
    
    func visualizerAction() {
        if (ImageManager.sharedInstance.hasCamera()) {
            ImageManager.sharedInstance.proceedWithCameraAccess(self) {
                self.performSegueWithIdentifier("showPainter", sender: self)
            }
        } else {
            self.performSegueWithIdentifier("showPainter", sender: self)
        }
    }
    
    func samplesAction() {
        self.performSegueWithIdentifier("showSamples", sender: self)
    }
    
    func colorsAction() {
        ImageManager.sharedInstance.getImage(self) { (image) -> Void in
            if let _ = image {
                self.colorFinderImage = image
                self.performSegueWithIdentifier("showColorFinder", sender: self)
            }
        }
    }
}
