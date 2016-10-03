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
    var duration:TimeInterval
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
    
    fileprivate var selectedProjectPath: String!
    fileprivate var isSample = false
    fileprivate var colorFinderImage:UIImage!
    
    fileprivate var mainActionsVC:MainActionsViewController!
    
    fileprivate var tutorialSteps: [TutorialStep] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tutorialView.isHidden = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        projectsView.isHidden = ProjectDatabase.sharedDatabase().count == 0
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        let availableHeight = self.view.frame.height - mainAction.frame.minY
        
        let eachHeight = availableHeight / 3
        
        mainActionHeight.constant = eachHeight
        projectsHeight.constant = projectsView.isHidden ? 0 : eachHeight
        samplesHeight.constant = eachHeight
        
        mainAction.layoutIfNeeded()
        projectsView.layoutIfNeeded()
        samplesView.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (!UserPreferences.sharedPreferences().hasSeenLandingInstructions) {
            //setup tutorial
            tutorialSteps.append(TutorialStep(text: NSLocalizedString("TutorialStep1", comment: ""), duration:5, view:nil))
            tutorialSteps.append(TutorialStep(text: NSLocalizedString("TutorialStep2", comment: ""), duration:5, view:nil))
            tutorialSteps.append(TutorialStep(text: NSLocalizedString("TutorialStep3", comment: ""), duration:5, view:nil))
            
            let limit = min(mainActionsVC.collectionView!.numberOfItems(inSection: 0), tutorialSteps.count)
            
            for i in 0..<limit
            {
                if let cell = mainActionsVC.collectionView!.cellForItem(at: IndexPath(row: i, section: 0)) {
                    tutorialSteps[i].view = cell
                }
            }
            showTutorial()
        }
    }

    @IBAction func skipStep(_ sender: AnyObject) {
        showTutorialStep(currentStep + 1)
    }
    
    var currentStep = -1
    func showTutorial() {
        currentStep = -1
        self.tutorialSkipButton.isHidden = true
        self.tutorialView.alpha = 0.0
        self.tutorialLabel.isHidden = true
        self.tutorialView.isHidden = false
        self.tutorialOpeningWidth.constant = 0
        self.tutorialOpeningHeight.constant = 0
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            self.tutorialView.alpha = 1.0
            }, completion: { finished in
                self.showTutorialStep(0)
        })
        
        let delayTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.tutorialView.isHidden = false
        }
    }
    
    func showTutorialStep(_ index:Int) {
        
        if (index <= currentStep) {
            return;//was skipped by user
        }
        currentStep = index;
        
        if (index < tutorialSteps.count) {
            let step = tutorialSteps[index]
            
            if (index < tutorialSteps.count - 1) {
                self.tutorialSkipButton.setTitle(NSLocalizedString("TutorialSkipAny", comment: ""), for: UIControlState())
            } else {
                self.tutorialSkipButton.setTitle(NSLocalizedString("TutorialSkipLast", comment: ""), for: UIControlState())
            }
            
            var opening = CGRect()
            if let view = step.view {
                let point = view.superview!.convert(view.frame.origin, to: self.tutorialView)
                opening.origin = point
                opening.size.width = view.bounds.size.width
                opening.size.height = view.bounds.size.height
            }
            
            self.tutorialSkipButton.isHidden = false
            tutorialLabel.isHidden = true
            UIView.animate(withDuration: index == 0 ? 0.2 : 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                self.tutorialOpeningX.constant = opening.origin.x
                self.tutorialOpeningY.constant = opening.origin.y
                self.tutorialOpeningWidth.constant = opening.width
                self.tutorialOpeningHeight.constant = opening.height
                self.tutorialView.layoutIfNeeded()
                }, completion: { finished in
                    self.tutorialLabel.text = step.text
                    self.tutorialLabel.alpha = 0
                    self.tutorialLabel.isHidden = false
                    
                    //Fade in text
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.tutorialLabel.alpha = 1.0
                        }, completion: { finished in
                            //Wait specified time, then continue recursively
                            let delayTime = DispatchTime.now() + Double(Int64(step.duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                                self.showTutorialStep(index+1)
                            }
                    })
            })
        }
        else {
            //ALL DONE
            UserPreferences.sharedPreferences().hasSeenLandingInstructions = true
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.tutorialView.alpha = 0.0
                }, completion: { finished in
                    self.tutorialView.isHidden = true
            })
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AugmentedViewController {
            if (nil != self.selectedProjectPath) {
                vc.projectPath = self.selectedProjectPath
                vc.isSample = self.isSample
            }
        }
        else if let vc = segue.destination as? SampleTypeViewController {
            vc.delegate = self
        } else if let vc = segue.destination as? SampleCollectionViewController {
            vc.delegate = self
        } else if let vc = segue.destination as? ProjectCollectionViewController {
            vc.delegate = self
        } else if let vc = segue.destination as? ProjectListingViewController {
            vc.delegate = self
        } else if let vc = segue.destination as? MainActionsViewController {
            vc.delegate = self
            self.mainActionsVC = vc
        } else if let vc = segue.destination as? ColorFinderViewController {
            vc.image = self.colorFinderImage
            self.colorFinderImage = nil
        }
        
        self.selectedProjectPath = nil
        self.isSample = false
    }
    
    func sampleSelected(_ samplePath:String) {
        print("Selected \(samplePath)")
        self.selectedProjectPath = samplePath
        self.isSample = true
        self.performSegue(withIdentifier: "showPainter", sender: self)
    }
    
    func projectSelected(_ samplePath:String) {
        print("Selected \(samplePath)")
        self.selectedProjectPath = samplePath
        self.performSegue(withIdentifier: "showPainter", sender: self)
    }
    
    func visualizerAction() {
        if (ImageManager.sharedInstance.hasCamera()) {
            ImageManager.sharedInstance.proceedWithCameraAccess(self) {
                self.performSegue(withIdentifier: "showPainter", sender: self)
            }
        } else {
            self.performSegue(withIdentifier: "showPainter", sender: self)
        }
    }
    
    func samplesAction() {
        self.performSegue(withIdentifier: "showSamples", sender: self)
    }
    
    func colorsAction() {
        ImageManager.sharedInstance.getImage(self) { (image) -> Void in
            if let _ = image {
                self.colorFinderImage = image
                self.performSegue(withIdentifier: "showColorFinder", sender: self)
            }
        }
    }
}
