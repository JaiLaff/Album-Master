//
//  TableViewController.swift
//  TableView
//
//  Created by Jai Lafferty on 3/4/19.
//  Copyright © 2019 Jai Lafferty. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var currData: memAlbum? = nil
    var parser:DataParser? = nil
    var coreController: CoreDataController? = nil
    var useSavedData: Bool?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (useSavedData != true){
            parser = DataParser()
            parser?.begin(tv: tableView)
            deleteButton.isHidden = true
        } else {
            coreController = CoreDataController(context: appDelegate.persistentContainer.viewContext)
            memArtists = coreController?.getArtists() ?? []
        }
        
        tableView.reloadData()
        
        // Make Error Alert
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (useSavedData == true ? memArtists.count : 1)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (useSavedData == true ? memArtists[section].albums.count : currentArtist.albums.count)
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
        
        DispatchQueue.main.async {
            if (memArtists[indexPath.section].albums[indexPath.row].tracks.isEmpty) {
                //Need to load Data
                if (self.useSavedData  == true){
                    memArtists[indexPath.section].albums[indexPath.row].tracks = (self.coreController?.getTracks(collId: memArtists[indexPath.section].albums[indexPath.row].itunesID))!
                } else {
                    self.parser?.fetchTracks(collID: memArtists[indexPath.section].albums[indexPath.row].itunesID)
                }
            }
            self.currData = memArtists[indexPath.section].albums[indexPath.row]
            cell.spinner.stopAnimating()
            cell.spinner.isHidden = true
            self.performSegue(withIdentifier: "DetailsSegue", sender: nil)
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
            detailVC.album = currData
            detailVC.usingCoreData = useSavedData
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Confirm Deletion", message: "Delete saved albums? This action cannot be reversed", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.coreController?.deleteAll()
            self.deleteButton.isEnabled = false
            self.currData = nil
            memArtists.removeAll()
            self.tableView.reloadData()
            memArtists.append(currentArtist)
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
    }
}
