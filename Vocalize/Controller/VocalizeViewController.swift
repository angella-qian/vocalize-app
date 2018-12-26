//
//  ViewController.swift
//  Vocalize
//
//  Created by Angella Qian on 11/26/18.
//  Copyright © 2018 Angella Qian. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

var recordingSession: AVAudioSession!
var audioRecorder: AVAudioRecorder!
var soundPlayer: AVAudioPlayer?
var counter = 0.0
var stopwatch = Timer()
var isRunning = false

class VocalizeViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    // IBOutlets
    @IBOutlet weak var stopwatchLabel: UILabel!
    @IBOutlet weak var transcriptTextView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var resultsButton: UIButton!
    
    // Audio Engine, Speech Recognizer, Recognition Task setup
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var watchTime: String?
    
    // Gradient setup
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    let gradientOne = UIColor(red: 159/255, green: 208/255, blue: 255/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 255/255, green: 151/255, blue: 145/255, alpha: 1).cgColor
    let gradientThree = UIColor(red: 108/255, green: 174/255, blue: 234/255, alpha: 1).cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopwatchLabel.text = String("\(Int(counter/10)) m \(Int(counter.truncatingRemainder(dividingBy: 10))) s")
        
        resultsButton.isEnabled = false
        resultsButton.backgroundColor = UIColor.lightGray
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
        
        transcriptTextView.isEditable = false
        transcriptTextView.text = "Select record to start..."
        speechRecognizer.delegate = self
        
        // Requesting authorization of speech recognizer and handling user's response
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            OperationQueue.main.addOperation {
                switch authStatus {
                    case .authorized:
                        self.recordButton.isEnabled = true
                    case .denied:
                        self.recordButton.isEnabled = false
                        self.recordButton.setTitle("User denied speech recognition access", for: .disabled)
                    case .restricted:
                        self.recordButton.isEnabled = false
                        self.recordButton.setTitle("Speech recognition is restricted on the device", for: .disabled)
                    case .notDetermined:
                        self.recordButton.isEnabled = false
                        self.recordButton.setTitle("Speech recognition has not been authorized yet", for: .disabled)
                }
            }
        }
    }
    
    private func startRecording() throws {
        
        // Cancel old task
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // AudioSession and AudioEngine input node setup
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else
        {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
        }
        
        
        // Configure request to return results before audio recording finishes
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task = a speech recognition session (keep reference to task so it can be cancelled)
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let r = result {
                self.transcriptTextView.text = r.bestTranscription.formattedString
                isFinal = r.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("RECORD", for: [])
                self.recordButton.backgroundColor = UIColor(red: 229.0/250.0, green:36.0/250.0, blue: 81.0/250.0, alpha: 1)
            }
        }
        
        // Setting audio recording format
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("RECORD", for: [])
        }
        else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition unavailable", for: .disabled)
        }
    }
    
    
    // MARK: IBActions
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        
        // Check for old recording task
        if audioEngine.isRunning {
            resetTimer()
            resultsButton.isEnabled = true
            resultsButton.backgroundColor = UIColor.white
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
        }
        else {
            // Start recording task
            try! startRecording()
            transcriptTextView.text = ""
            startTimer()
            recordButton.setTitle("STOP", for: [])
            recordButton.backgroundColor = UIColor(red: 229.0/250.0, green:36.0/250.0, blue: 81.0/250.0, alpha: 1)
            resultsButton.isEnabled = false
            resultsButton.backgroundColor = UIColor.lightGray
        }
    }
    
    
    // MARK: Stopwatch functions
    func startTimer() {
        if (isRunning) {
            return
        }
        stopwatch = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func UpdateTimer() {
        counter = counter + 0.01
        stopwatchLabel.text = String("\(Int(counter/60)) m \(Int(counter.truncatingRemainder(dividingBy: 60))) s")
    }
    
    func pauseTimer() {
        recordButton.isEnabled = true
        stopwatch.invalidate()
        isRunning = false
    }
    
    func resetTimer() {
        watchTime = stopwatchLabel.text
        stopwatch.invalidate()
        isRunning = false
        counter = 0.00
        stopwatchLabel.text = String("\(Int(counter/10)) m \(Int(counter.truncatingRemainder(dividingBy: 10))) s")
    }
    
    override func prepare( for segue: UIStoryboardSegue, sender: Any?) {
        let speech = transcriptTextView.text
        let resultsViewController = segue.destination as! ResultsViewController
        resultsViewController.speechText = speech
        resultsViewController.watchLabel = watchTime
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension VocalizeViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradient.colors = gradientSet[currentGradient]
            animateGradient()
        }
    }
}

