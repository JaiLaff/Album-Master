//
//  QuizViewController.swift
//  TableView
//
//  Created by Jai Lafferty on 25/5/19.
//  Copyright © 2019 Jai Lafferty. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class QuizViewController: UIViewController {
    
    @IBOutlet weak var lblTrackName: UILabel!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblStreak: UILabel!
    @IBOutlet weak var lblLoading: UILabel!
    @IBOutlet weak var lblIsCorrect: UILabel!
    
    @IBOutlet weak var bt1: UIButton!
    @IBOutlet weak var bt2: UIButton!
    @IBOutlet weak var bt3: UIButton!
    @IBOutlet weak var bt4: UIButton!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var question: Question? = nil
    var coreController: CoreDataController? = nil
    var streak: Int = 0
    var albumCount: Int = 0
    let correctString = "👍"
    let incorrectString = "👎"

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        coreController = CoreDataController(context: appDelegate.persistentContainer.viewContext)
        
        if (coreController == nil) {
            print("Critical Error - Core Data Controller couldn't load")
            
            popViewController(errorTitle: "Critical Error", message: "Core Data Couldn't Load")
        }

        albumCount = coreController?.getTotalAlbumCount() ?? 0
        
        //set ui to loading
        updateUI(isLoading: true, updateButtons: true)
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Error Checking
        if albumCount < 4 {
            print("Error - Not enough albums to conduct quiz")
            popViewController(errorTitle: "Not Enough Albums", message: "Come back when you have 4 or more albums")
            return
        }
        
        let numOfOptions = availableButtons()
        loadQuestion(numberOfOptions: numOfOptions, callback: updateUI)
    }
    
    func availableButtons() -> Int {
        
        switch (albumCount) {
            case 4:
                return 2
            case 5:
                return 3
            default:
                return 4
        }
    }
    
    func popViewController(errorTitle: String, message: String) {
        let errorAlert = UIAlertController(title: errorTitle, message: message, preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
            print("Popping View Controller!")
        }))
        
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    func loadQuestion(numberOfOptions: Int, callback: (Int) -> Void) {
        
        if numberOfOptions < 2 {
            callback(0)
        }
        var newQuestion = Question(trackName: nil, options: [], correctAlbum: nil)
        
        let targetTrack:(track: String, album: String) = coreController!.getRandomTrack()
        
        newQuestion.trackName = targetTrack.track
        newQuestion.options.append(targetTrack.album)
        newQuestion.correctAlbum = targetTrack.album
        
        while newQuestion.options.count != numberOfOptions {
            let newOption = coreController!.getRandomAlbum()
            
            if !newQuestion.options.contains(newOption){
                newQuestion.options.append(newOption)
            }
        }
        
        newQuestion.options.shuffle()
        question = newQuestion
        
        callback(numberOfOptions)
    }
    
    func updateUI(isLoading: Bool, updateButtons: Bool) {
        // Only spinner & loading label are active
    
        lblStreak.text = "Streak: \(streak)"
        lblQuestion.isHidden = isLoading
        lblTrackName.isHidden = isLoading
        
        if (updateButtons) {
            bt1.isHidden = isLoading
            bt2.isHidden = isLoading
            bt3.isHidden = isLoading
            bt4.isHidden = isLoading
        }
        lblIsCorrect.isHidden = isLoading
        lblStreak.isHidden = isLoading
        
        lblLoading.isHidden = !isLoading
        
        if isLoading{
        spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
    }
    
    func updateUI(options: Int) {
        switch (options) {
            case 1:
                bt1.setTitle(question?.options[0], for: .normal)
                bt1.isHidden = false
                bt2.isHidden = true
                bt3.isHidden = true
                bt4.isHidden = true
                break
            case 2:
                bt1.setTitle(question?.options[0], for: .normal)
                bt2.setTitle(question?.options[1], for: .normal)
                bt1.isHidden = false
                bt2.isHidden = false
                bt3.isHidden = true
                bt4.isHidden = true
                break
            case 3:
                bt1.setTitle(question?.options[0], for: .normal)
                bt2.setTitle(question?.options[1], for: .normal)
                bt3.setTitle(question?.options[2], for: .normal)
                bt1.isHidden = false
                bt2.isHidden = false
                bt3.isHidden = false
                bt4.isHidden = true
                break
            case 4:
                bt1.setTitle(question?.options[0], for: .normal)
                bt2.setTitle(question?.options[1], for: .normal)
                bt3.setTitle(question?.options[2], for: .normal)
                bt4.setTitle(question?.options[3], for: .normal)
                bt1.isHidden = false
                bt2.isHidden = false
                bt3.isHidden = false
                bt4.isHidden = false
                break
            default:
                updateUI(isLoading: true, updateButtons: true)
                return
        }
        
        lblTrackName.text = question?.trackName
        
        updateUI(isLoading: false, updateButtons: false)
    }
    
    @IBAction func button1Pressed(_ sender: Any) {
        checkAnswer(guessed: 0)
    }
    
    @IBAction func button2Pressed(_ sender: Any) {
        checkAnswer(guessed: 1)
    }
    
    @IBAction func button3Pressed(_ sender: Any) {
        checkAnswer(guessed: 2)
    }
    
    @IBAction func button4Pressed(_ sender: Any) {
        checkAnswer(guessed: 3)
    }
    
    func checkAnswer(guessed: Int){
        question?.options[guessed] == question?.correctAlbum ? correct() : incorrect()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // delay text field disappearing (1.0 seconds)
            self.lblIsCorrect.text = ""
        }
        loadQuestion(numberOfOptions: availableButtons(), callback: updateUI)
    }
    
    func correct() {
        lblIsCorrect.text = correctString
        streak += 1
        
    }
    
    func incorrect() {
        lblIsCorrect.text = incorrectString
        streak = 0
        // Ability to save score here if time to add
    }
    

    
}
