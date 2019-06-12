//
//  MenuViewController.swift
//  TableView
//
//  Created by Jai Lafferty on 22/5/19.
//  Copyright © 2019 Jai Lafferty. All rights reserved.
//

import Foundation
import UIKit
import Network


class MenuViewController: UIViewController {
    
    var useSaved: Bool? = nil
    
    var networkHandler: NetworkHandler? = nil
    
    
    @IBOutlet weak var lblArtistName: UILabel!
    
    override func viewDidLoad() {
        networkHandler = NetworkHandler()
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(true)
        lblArtistName.text = currentArtist.name
        
        if (!isConnectedToNetwork) {
            let errorAlert = UIAlertController(title: "No Network Connection Detected", message: "Many features are not available without a present network connection", preferredStyle: .alert)
            
            errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                return
            }))
            
            self.present(errorAlert, animated: true, completion: nil)
        }
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
