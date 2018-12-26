//
//  FillersTableViewController.swift
//  Vocalize
//
//  Created by Angella Qian on 12/2/18.
//  Copyright © 2018 Angella Qian. All rights reserved.
//

import UIKit

class FillersViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    // IBOutlets
    @IBOutlet weak var currentFillers: UITextView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    // Instance Variables
    var fills = Fillers.shared
    
    // Gradient
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    let gradientOne = UIColor(red: 24/255, green: 174/255, blue: 234/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 255/255, green: 151/255, blue: 145/255, alpha: 1).cgColor
    let gradientThree = UIColor(red: 245/255, green: 193/255, blue: 209/255, alpha: 1).cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var fill = ""
        for word in (fills.words.keys) {
            fill = "\(fill) \(word),"
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        gradientSet.append([gradientOne, gradientTwo])
        gradientSet.append([gradientTwo, gradientThree])
        gradientSet.append([gradientThree, gradientOne])
        
        gradient.frame = self.view.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        
        self.view.layer.addSublayer(gradient)
        
        animateGradient()
        
        addButton.isEnabled = false
        
        var fill = ""
        for word in (fills.words.keys) {
            fill = "\(fill) \(word),"
        }
        currentFillers.text = fill
        
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        // Grabbing user input and saving it to plist
        let userInput = textField.text
        let addList = userInput!.components(separatedBy:", ")
        for word in addList {
            fills.insert(newWord: word)
        }
        
        // Updating the textView that displays all of the fillers
        var fill = ""
        for word in (fills.words.keys) {
            fill = "\(fill) \(word),"
        }
        fill.removeFirst()
        fill.removeLast()
        currentFillers.text = fill
        
        // Reseting textField
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    @IBAction func backgroundPressed(_ sender: UITapGestureRecognizer) {
        if (textField.isFirstResponder) {
            self.textField.resignFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        enableAddButton(newFillers: updatedString)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // If textView return key is pressed close keyboard
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let updatedString = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        let newList = updatedString.components(separatedBy:", ")
        
        // If words removed from textview, remove from plist too
        for oldWord in (fills.words.keys) {
            if !newList.contains(oldWord) {
                fills.remove(word: oldWord)
            }
        }
        
        // If words added to textview, add to plist too
        for newWord in newList {
            if !(fills.words.keys).contains(newWord) {
                fills.insert(newWord: newWord)
            }
        }
        return true
    }
    
    func enableAddButton(newFillers: String) {
        if newFillers.isEmpty {
            addButton.isEnabled = false
            addButton.backgroundColor = UIColor.lightGray
        }
        else {
            addButton.isEnabled = true
            addButton.backgroundColor = UIColor(red: 229.0/250.0, green:36.0/250.0, blue: 81.0/250.0, alpha: 1)
        }
    }
    
    func animateGradient() {
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
            
        }
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 5.0
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = kCAFillModeForwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
        
        gradient.zPosition = -0.05
        
    }
}

extension FillersViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradient.colors = gradientSet[currentGradient]
            animateGradient()
        }
    }
}
