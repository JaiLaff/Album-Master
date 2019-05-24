//
//  MenuViewController.swift
//  TableView
//
//  Created by Jai Lafferty on 22/5/19.
//  Copyright © 2019 Jai Lafferty. All rights reserved.
//

import Foundation
import UIKit


class MenuViewController: UIViewController {
    
    var useSaved: Bool? = nil
    
    @IBOutlet weak var lblArtistName: UILabel!
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(true)
        lblArtistName.text = currentArtist.name
    }
    
   
    @IBAction func savedPressed(_ sender: Any) {
        useSaved = true
        goToTable()
    }
    
    @IBAction func itunesPressed(_ sender: Any) {
        useSaved = false
        goToTable()
    }
    
    @IBAction func quizPressed(_ sender: Any) {
        performSegue(withIdentifier: "quizSegue", sender: nil)
    }
    
    @IBAction func changeArtistPressed(_ sender: Any) {
        performSegue(withIdentifier: "changeArtistSegue", sender: nil)
    }
    
    
    func goToTable() {
        performSegue(withIdentifier: "tableSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let tableVC = segue.destination as? TableViewController {
            memArtists.removeAll()
            memArtists.append(currentArtist)
            tableVC.useSavedData = useSaved
        }
    }
    
}
