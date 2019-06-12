//
//  TableViewController.swift
//  TableView
//
//  Created by Jai Lafferty on 3/4/19.
//  Copyright © 2019 Jai Lafferty. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var currAlbum: memAlbum? = nil
    var currArtist: memArtist? = nil
    var parser:DataParser? = nil
    var coreController: CoreDataController? = nil
    var useSavedData: Bool?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (useSavedData == true){
            
            coreController = CoreDataController(context: appDelegate.persistentContainer.viewContext)
            memArtists = coreController?.getArtists() ?? []
            
            checkAlbumCount()
            
        } else {
            
            if (!isConnectedToNetwork) {
                let errorAlert = UIAlertController(title: "Cannot Browse iTunes", message: "No Connection", preferredStyle: .alert)
                
                errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                    return
                }))
                
                self.present(errorAlert, animated: true, completion: nil)
            }
            
            parser = DataParser()
            deleteButton.isHidden = true
            currentArtist.albums.removeAll()
            parser?.begin(callback: checkAlbumCount)
        }
    }
    
    func checkAlbumCount() {
        print("Checking Album Count")
        if (useSavedData == true) {
            let count = coreController?.getTotalAlbumCount()
            if ( count == 0) {
                displayNoAlbumAlert(savedData: true)
                print("No Albums count in Core Data")
            } else {
                print ("There are \(String(describing: count)) albums in Core Data")
            }
            
        } else {
            let count = currentArtist.albums.count
            if ( count == 0) {
                displayNoAlbumAlert(savedData: false)
                print("No Albums found in memory")
            } else {
                print("There are \(String(describing: count)) albums in memory")
            }
            
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (useSavedData == true ? memArtists.count : 1)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = useSavedData == true ? memArtists[section].albums.count : currentArtist.albums.count
        
        return count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! customCell
        
        cell.spinner.isHidden = true
        
        if (useSavedData == true) {
        cell.textLabel?.text = memArtists[indexPath.section].albums[indexPath.row].title
        } else {
            cell.textLabel?.text = currentArtist.albums[indexPath.row].title
        }

        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        let cell = tableView.cellForRow(at: indexPath) as! customCell
        
        cell.spinner.isHidden = false
        cell.spinner.startAnimating()
        
        func seguePrep() { // Needs access to variables within scope
            DispatchQueue.main.async {
                self.currAlbum = memArtists[indexPath.section].albums[indexPath.row]
                self.currArtist = memArtists[indexPath.section]
                cell.spinner.stopAnimating()
                cell.spinner.isHidden = true
                self.performSegue(withIdentifier: "DetailsSegue", sender: nil)
            }
        }
        
        
        if (memArtists[indexPath.section].albums[indexPath.row].tracks.isEmpty) {
            //Need to load Data
            if (self.useSavedData  == true){
                memArtists[indexPath.section].albums[indexPath.row].tracks = (self.coreController?.getTracks(collId: memArtists[indexPath.section].albums[indexPath.row].itunesID))!
                print("Loaded Core Data Tracks into Memory")
                seguePrep()
            } else {
                self.parser?.fetchTracks(collID: memArtists[indexPath.section].albums[indexPath.row].itunesID, callback: seguePrep)
            }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let count = memArtists.count
        if (section < count ) {
            return memArtists[section].name
        }
        
        return nil
    }
        
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? AlbumDetailsViewController {
            detailVC.album = currAlbum
            detailVC.artist = currArtist
            detailVC.usingCoreData = useSavedData
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Confirm Deletion", message: "Delete saved albums? This action cannot be reversed", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.coreController?.deleteAll()
            self.deleteButton.isEnabled = false
            self.currAlbum = nil
            self.currArtist = nil
            memArtists.removeAll()
            self.tableView.reloadData()
            memArtists.append(currentArtist)
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
    }
    
    func displayNoAlbumAlert(savedData: Bool) {
        var alert: UIAlertController
        
        if savedData{
            alert = UIAlertController(title: "No Albums Found", message: "Go and save some albums!", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "No Albums Found", message: "Select an Artist!", preferredStyle: .alert)
        }

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))

        self.present(alert, animated: true)
    }
}
