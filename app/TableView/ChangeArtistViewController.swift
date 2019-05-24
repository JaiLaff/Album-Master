//
//  ChangeArtistViewController.swift
//  TableView
//
//  Created by Jai Lafferty on 24/5/19.
//  Copyright © 2019 Jai Lafferty. All rights reserved.
//

import Foundation
import UIKit

class ChangeArtistViewController: UIViewController {
    
    @IBOutlet weak var tfArtistName: UITextField!
    @IBOutlet weak var lblFoundArtistName: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let dataParser = DataParser()

    var foundArtistName: String? = nil
    var foundArtistId: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.stopAnimating()
        lblFoundArtistName.isHidden = true
        
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        spinner.isHidden = false
        spinner.startAnimating()
        
        var result: (name: String?, id: String?)
        
        // COMPLETION HANDLER HERE
        
        let completeQuery: ((name: String?, id: String?)) -> Void = { result in
            DispatchQueue.main.async {
                if result != (nil,nil) {
                    self.lblFoundArtistName.isHidden = false
                    self.foundArtistName = result.name
                    self.foundArtistId = result.id
                    self.lblFoundArtistName.text = self.foundArtistName
                    self.spinner.stopAnimating()
                }
            }
            
        }
        
        func retrieveArtistDetails() {
            // Replicate Downloading/Uploading
            dataParser.findArtist(searchTerm: tfArtistName.text ?? "", callback: completeQuery)
        }
        
        retrieveArtistDetails()
    }
    
    @IBAction func changePressed(_ sender: Any) {
        if (foundArtistId == nil || foundArtistName == nil ) {
            let alert = UIAlertController(title: "Error Finding Artist", message: "Your Artist may not be on the iTunes Store!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            
            self.present(alert, animated: true)
        } else {
            let newArtist = memArtist(name: foundArtistName!, id: foundArtistId!, albums: [])
            currentArtist = newArtist
            memArtists.append(currentArtist)
            navigationController?.popViewController(animated: true)
        }
        
        
    }
    
}
