//
//  CoreDataController.swift
//  TableView
//
//  Created by Jai Lafferty on 22/5/19.
//  Copyright © 2019 Jai Lafferty. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController {
    
    let context: NSManagedObjectContext
    let albumEntity: NSEntityDescription?
    let trackEntity: NSEntityDescription?
    
    
    init(context: NSManagedObjectContext){
        self.context = context
        albumEntity = NSEntityDescription.entity(forEntityName: "Album", in: context)
        trackEntity = NSEntityDescription.entity(forEntityName: "Track", in: context)
    }
    
    func findArtist() -> Artist? {
        let request = NSFetchRequest<Artist>(entityName: "Artist")
        // iTunes ID is unique, best search term
        request.predicate = NSPredicate(format: "itunesId == %@", currentArtist.id)
        
        var artist:Artist? = nil
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0 {
                artist = result[0]
                print("Artist found: \(String(describing: artist!.name))")
            } else {
                print("Failed to find Artist \"\(currentArtist.name)\" in Core Data - Creating New Artist Entity")
                artist = nil
                artist = Artist(context: context)
                artist!.name = currentArtist.name
                artist!.itunesId = currentArtist.id
                
                do {
                    try context.save()
                    print("New artist saved successfully")
                } catch {
                    print("Could not save new artist - \(error)")
                    return nil
                }
            }
            
        } catch {
            print("Fetch Artist Failed")
        }
        return artist
    }
    
    func writeAlbum(album: memAlbum) {
        
        let artist = findArtist()
        
        let newAlbum = Album(context: context)
        
        newAlbum.title = album.title
        newAlbum.itunesId = album.itunesID
        newAlbum.imageUrl = album.imgUrl
        
        if artist != nil {
            artist?.addToAlbum(newAlbum)
        } // not the worst thing if an album doesn't have an artist - better to keep it anyway
        
        do {
            try context.save()
        }catch {
            print("Failed to save album to core data - \(error)")
        }
    }
    
    func readAlbum(collId: String) -> memAlbum?{
        let album = findAlbum(collId: collId)
        
        if let album = album {
            return convertCoreAlbumToMemAlbum(album: album)
        }
        
        return nil
        
    }
    
    func writeTrack(album: memAlbum, track: memTrack){
        let newTrack = Track(context: context)
        
        newTrack.title = track.title
        newTrack.trackNo = Int16(track.trackNo)
        
        let album = findAlbum(collId: album.itunesID)
        
        album?.addToTracks(newTrack)
        do {
            try context.save()
            print("\"\(newTrack.title!)\" saved to \"\(album!.title!)\"")

        }catch {
            print("Failed to save Track \"\(newTrack.title ?? "")\" to Core Data - \(error)")
        }
    }
    
    func getTracks(collId: String) -> [memTrack] {
        let album = findAlbum(collId: collId)
        let request = NSFetchRequest<Track>(entityName: "Track")
        request.predicate = NSPredicate(format: "album == %@", album!)
        var memTracks: [memTrack] = []
        
        do {
            let result = try context.fetch(request)
            let tracks = result
            
            
            for t in tracks {
                memTracks.append(convertCoreTrackToMemTrack(track: t)!)
            }
            
            memTracks.sort(by: {$0.trackNo < $1.trackNo})
        } catch {
            
            print("Failed to find Track from Core Data")
        }
        return memTracks
        
    }
    
    func findAlbum(collId: String) -> Album? {
        let request = NSFetchRequest<Album>(entityName: "Album")
        request.predicate = NSPredicate(format: "itunesId == %@", collId)
        do {
            let result = try context.fetch(request)
            let album = result[0]
            
            return album
        } catch {
            
            print("Failed to find Album from Core Data")
        }
        return nil
    }
    
    func getArtists() -> [memArtist] {
        let request = NSFetchRequest<Artist>(entityName: "Artist")
        var memArtists: [memArtist] = []

        do {
            let result = try context.fetch(request)
            let artists = result
            
            
            for a in artists {
                memArtists.append(convertCoreArtistToMemArtist(artist: a))
                
            }
        } catch {
            
            print("Failed to find Artists from Core Data")
        }
        return memArtists
    }
    
    func getAlbumsByArtist(artist: Artist) -> [memAlbum] {
        let request = NSFetchRequest<Album>(entityName: "Album")
        request.predicate = NSPredicate(format: "artist.itunesId == %@", artist.itunesId!)
        
        var albumsArr: [memAlbum] = []
        
        do {
            let result = try context.fetch(request)
            let albums = result
            
            
            for a in albums {
                albumsArr.append(convertCoreAlbumToMemAlbum(album: a)!)
                
            }
        } catch {
            
            print("Failed to find Albums by Artist from Core Data")
        }
        return albumsArr
    }
    
    func deleteAll() {
        let fetchTracks = NSFetchRequest<NSFetchRequestResult>(entityName: "Track")
        let fetchAlbums = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        let fetchArtists = NSFetchRequest<NSFetchRequestResult>(entityName: "Artist")

        let deleteTracks = NSBatchDeleteRequest(fetchRequest: fetchTracks)
        let deleteAlbums = NSBatchDeleteRequest(fetchRequest: fetchAlbums)
        let deleteArtists = NSBatchDeleteRequest(fetchRequest: fetchArtists)

        
        do{
            try context.execute(deleteTracks)
            try context.execute(deleteAlbums)
            try context.execute(deleteArtists)
            memArtists.removeAll()
            memArtists.append(currentArtist)
        } catch {
            print("error deleting records - \(error)")
        }

    }
    
    func getArtistCount() -> Int{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Artist")
        let count = try! context.count(for: fetchRequest)
        
        return count
    }
    
    func getAlbumCount(artist: memArtist) -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        fetchRequest.predicate = NSPredicate(format: "artist.itunesId == %@", currentArtist.id)
        let count = try! context.count(for: fetchRequest)
        
        return count
    }
    
    func getTotalAlbumCount() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        let count = try! context.count(for: fetchRequest)
        
        return count
    }
    
    func getRandomTrack() -> (track: String, album: String) {
        var result:(track: String, album: String) = ("","")
        
        let request = NSFetchRequest<Track>(entityName: "Track")
        
        do {
            let fetchRequest = try context.fetch(request)
            
            let randomTrack = fetchRequest.randomElement()
            let randomAlbum = randomTrack?.album
            
            result.track = randomTrack?.title ?? ""
            result.album = randomAlbum?.title ?? ""
            
        } catch {
            print("Error getting Tracks")
        }
        
        return result
    }
    
    func getRandomAlbum() -> String {
        var result: String = ""
        
        let request = NSFetchRequest<Album>(entityName: "Album")
        
        do {
            let fetchRequest = try context.fetch(request)
            
            let randomAlbum = fetchRequest.randomElement()
            
            result =  randomAlbum?.title ?? ""
            
        } catch {
            print("Error getting Tracks")
        }
        
        return result
    }
    
    func convertCoreArtistToMemArtist(artist: Artist) -> memArtist {
        return memArtist(name: artist.name!, id: artist.itunesId!, albums: getAlbumsByArtist(artist: artist))
    }
    
    func convertCoreAlbumToMemAlbum(album: Album) -> memAlbum? {
        return memAlbum(itunesID: album.itunesId!, title: album.title!, tracks: [], url: album.imageUrl!)
    }
    
    func convertCoreTrackToMemTrack(track: Track) -> memTrack? {
        return memTrack(title: track.title!, trackNo: Int(track.trackNo))
    }
}
