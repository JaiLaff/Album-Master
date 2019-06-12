//
//  ViewController.swift
//  TableView
//
//  Created by Jai Lafferty on 3/4/19.
//  Copyright © 2019 Jai Lafferty. All rights reserved.
//

import UIKit
import CoreData

class AlbumDetailsViewController: UIViewController {

    var album: memAlbum? = nil
    var artist: memArtist? = nil
    let session:URLSession = URLSession(configuration: .default)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var usingCoreData:Bool? = nil
    
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumTitle.text = album?.title ?? ""
        
        updateImage()
        updateTracklist()
        
        if(usingCoreData == true){
            saveButton.isHidden = true
        }
        
    }
    
    func updateImage() {
        if (!isConnectedToNetwork) {
            let errorAlert = UIAlertController(title: "Failed to Load Image", message: "No Connection", preferredStyle: .alert)
            
            errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                return
            }))
            
            self.present(errorAlert, animated: true, completion: nil)
        }
        
        if let url = URL(string: album?.imgUrl ?? ""){
            if let data = try? Data(contentsOf: url){ //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
    
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    func updateTracklist() {
        textView.text = "Tracklist: \n\n"
        for t in (album?.tracks)! {
            textView.text += "\(t.trackNo): \(t.title)\n"
        }
    }
    
    func correctTitle() -> String{
        var result = album?.title.replacingOccurrences(of: " ", with: "+")
        let correctedArtistName = artist?.name.replacingOccurrences(of: " ", with: "+")
        result! += correctedArtistName ?? ""
        
        return result!
    }
    
    func fetchWikiUrl(completion: @escaping (String?) -> Void){
        print("Fetching Wikipedia Page Candidates")
        spinner.startAnimating()
        
        if (!isConnectedToNetwork){
            print("Cannot Call Wikipedia API - No connection")
            let errorAlert = UIAlertController(title: "No Connection", message: "Cannot go to Wikipedia without any internet!", preferredStyle: .alert)
            
            errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                self.spinner.stopAnimating()
                return
            }))
            
            self.present(errorAlert, animated: true, completion: nil)
        }
        var result: String?
        var dataTask: URLSessionDataTask?
        
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://en.wikipedia.org/w/api.php") {
            urlComponents.query = "action=query&generator=search&gsrsearch=\(correctTitle())&format=json&gsrprop=snippet&prop=info&inprop=url"
            
            guard let url = urlComponents.url else {return} // failed
            
            //Actual API Call
            dataTask = session.dataTask(with: url) {data, response, error in defer {dataTask = nil}
                
                if let error = error {
                    print("error: " + error.localizedDescription)
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    // If we have a 200 status (OK) then continue
                    result = self.parseBestUrl(data: data)
                    completion(result)
                }
            }
        }
        dataTask?.resume()
        

    }
    
    func parseBestUrl(data: Data) -> String? {
        var response:[String: Any]
        
        
        do {
            response = try (JSONSerialization.jsonObject(with: data, options: []) as? [String:Any])!
            
            

            // Make sure we actually have results
            guard let query = response["query"] as? [String:Any],
            let pages = query["pages"] as? [String:Any] else {
                print("wrong identifer")
                return nil
            }
            print("Parsing best URL out of \(pages.count) Candidates")
            
            for page in pages.values {
                if let pageData = page as? [String:Any] {
                    let index = pageData["index"] as? Int
                    
                    if index == 1 { //Best url has index 1
                        let result = pageData["fullurl"] as? String
                        print("Best URL found: \(result!)")
                        return result
                    }
                    
                }
            }
            
            print("Error finding best url")
            return nil
        } catch {
            print("Error Parsing URL")
            return nil
        }
    }
    
    func openWiki(stringUrl: String?) {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            UIApplication.shared.open(NSURL(string:stringUrl ?? "")! as URL)
        }
    }
    
    @IBAction func viewOnWikiPressed(_ sender: Any) {
        fetchWikiUrl(completion: openWiki)
    }
    
    
    @IBAction func SaveDataPressed(_ sender: Any) {
        
        let coreController = CoreDataController(context: appDelegate.persistentContainer.viewContext)
        coreController.writeAlbum(album:album!)
        
        print("Saving Tracks to Core Data")
        
        for t in (album?.tracks)! {
            coreController.writeTrack(album: album!, track: t)
        }
        
        saveButton.isEnabled = false
        
        
    }
    

}

