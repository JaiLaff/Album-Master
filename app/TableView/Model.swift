//
//  Data.swift
//  TableView
//
//  Created by Jai Lafferty on 3/4/19.
//  Copyright © 2019 Jai Lafferty. All rights reserved.
//

import Foundation

// memAlbum -> Album Stored in memory vs Album stored in Core Data
// names collide otherwise

// Need these all as reference types so i can throw around currentArtist and it affect the memArtists array

class memAlbum : Equatable{
    
    init(itunesID: String, title: String, tracks: [memTrack], url: String) {
        self.itunesID = itunesID
        self.title = title
        self.tracks = tracks
        self.imgUrl = url
    }
    
    
    var itunesID: String = ""
    var title: String = ""
    var tracks: [memTrack] = []
    var imgUrl: String = ""
    
    static func == (lhs: memAlbum, rhs: memAlbum) -> Bool {
        return lhs.itunesID == rhs.itunesID
    }
}

class memTrack {
    
    var title: String
    var trackNo: Int
    
    init(title: String, trackNo: Int) {
        self.title = title
        self.trackNo = trackNo
    }
}

class memArtist {
    var name: String
    var id: String
    var albums: [memAlbum]
    
    init(name: String, id: String, albums: [memAlbum]) {
        self.name = name
        self.id = id
        self.albums = albums
    }
}

struct Question {
    var trackName: String?
    var options: [String?]
    var correctAlbum: String?
}

var currentArtist: memArtist = memArtist(name: "No Current Artist", id: "", albums: [])

var memArtists:[memArtist] = []

