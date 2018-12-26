//
//  ResultsTableViewController.swift
//  Vocalize
//
//  Created by Angella Qian on 12/2/18.
//  Copyright © 2018 Angella Qian. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // IBOutlets
    @IBOutlet weak var lastSpeechLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stopwatchLabel: UILabel!
    
    // Instance Variables
    var watchLabel: String?
    var speechText: String?
    var fillerCount: [String:Int] = [:]
    var strings: [String] = []
    var fills = Fillers.shared
    
    // Gradient
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    let gradientOne = UIColor(red: 108/255, green: 174/255, blue: 234/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 255/255, green: 151/255, blue: 145/255, alpha: 1).cgColor
    let gradientThree = UIColor(red: 245/255, green: 193/255, blue: 209/255, alpha: 1).cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopwatchLabel.text = watchLabel
        tableView.dataSource = self
        tableView.delegate = self
        checkFillers()
        addToHistory()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    }
    
    func checkFillers() {
        for word in (fills.words.keys) {
            if speechText!.lowercased().contains(word.lowercased()) {
                let s = speechText
                let tok = s!.components(separatedBy:word)
                fillerCount[word] = tok.count-1
            }
        }
        
        // Convert to string to display
        for results in fillerCount {
            strings.append("\(results.key): \(results.value)")
        }
        checkLastSpeech()
        self.tableView.reloadData()
    }

    // Comparing number of fillers to last speech's
    func checkLastSpeech() {
        var comment = "(Try your speech again to see your improvement)"
        if (fills.lastCount == 0) { }
        else if (fillerCount.count == 0) {
            comment = "Congrats! You didn't use any filler words."
        }
        else if (fillerCount.count > fills.lastCount) {
            comment = "You used \(fillerCount.count - fills.lastCount) more filler words than in your last speech."
        }
        else if (fillerCount.count < fills.lastCount) {
            comment = "Nice! You used \(fills.lastCount - fillerCount.count) less filler words than in your last speech."
        }
        else {
            comment = "You used the same number of filler words in your last speech."
        }
        fills.lastCount = fillerCount.count
        lastSpeechLabel.text = comment
    }
    
    func addToHistory() {
        for word in fillerCount.keys {
            fills.words[word] = fills.words[word]! + fillerCount[word]!
        }
        print(fills.words)
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
        return fillerCount.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsTableViewCell", for: indexPath) as! ResultsTableViewCell

        // Configure the cell...
        let word = strings[indexPath.row]
        cell.resultsLabel.text = word

        return cell
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(40)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
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

extension ResultsViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradient.colors = gradientSet[currentGradient]
            animateGradient()
        }
    }
}
