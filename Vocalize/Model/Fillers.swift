//
//  Fillers.swift
//  Vocalize
//
//  Created by Angella Qian on 12/2/18.
//  Copyright © 2018 Angella Qian. All rights reserved.
//

import UIKit

class Fillers: NSObject {
    
    static private let kFillersPlist = "Fillers.plist"
    static public var shared = Fillers()
    
    private var filepath: String
    public var words = [String: Int]()
    public var lastCount = 0
    
    override init(){

        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        filepath = url!.appendingPathComponent(Fillers.kFillersPlist).path
        
        print("filepath=\(filepath)")

        // Read file into NSDictionary from user defaults
        // If it exists, use it
        if manager.fileExists(atPath: filepath) {
            if let fillersDictionary = NSDictionary(contentsOfFile: filepath) {
                for (key, value) in fillersDictionary {
                    let valueInt = (value as! NSNumber).intValue
                    words[key as! String] = valueInt
                }
            }
        }
        // Else pre-populate the fillers dictionary
        else {
            words["like"] = 0
            words["and yeah"] = 0
            words["but yeah"] = 0
            words["literally"] = 0
            words["you know"] = 0
            words["basically"] = 0
            words["I think"] = 0
            words["I feel"] = 0
        }
    }
    
     func insert(newWord: String) {
        if (!words.keys.contains(newWord)) {
            words[newWord] = 0
            save()
        }
    }
    
    func remove(word: String) {
        if (words.keys.contains(word)) {
            words.removeValue(forKey: word)
            save()
        }
    }
   
    func save() {
        var wordsDict = [NSString: NSNumber]()
        for (key, num) in words {
            wordsDict[key as NSString] = NSNumber(value: num)
        }
        (wordsDict as NSDictionary).write(toFile: filepath, atomically: true)
    }
}
