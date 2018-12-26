//
//  HistoryTableViewController.swift
//  Vocalize
//
//  Created by Angella Qian on 12/2/18.
//  Copyright © 2018 Angella Qian. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // IBOutlets
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // Instance Variables
    var fills = Fillers.shared
    var words: [String] = []
    var counts: [Int] = []
    var totalCount = 0
    
    // Gradient setup
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    let gradientOne = UIColor(red: 108/255, green: 174/255, blue: 234/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 255/255, green: 151/255, blue: 145/255, alpha: 1).cgColor
    let gradientThree = UIColor(red: 245/255, green: 193/255, blue: 209/255, alpha: 1).cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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

        var i = 0
        for word in fills.words {
            if (word.value > 0 && !words.contains(word.key)) {
                words.append(word.key)
                counts.append(word.value)
                totalCount += word.value
            }
            i += 1
        }
        totalCountLabel.text = "\(totalCount)"
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return counts.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell

        // Configure the cell...
        let word = "\(words[indexPath.row]): \(counts[indexPath.row])"
        cell.historyLabel.text = word

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(60)
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

extension HistoryViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradient.colors = gradientSet[currentGradient]
            animateGradient()
        }
    }
}
