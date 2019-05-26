//
//  Album+CoreDataProperties.swift
//  
//
//  Created by Jai Lafferty on 26/5/19.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }

    @NSManaged public var imageUrl: String?
    @NSManaged public var itunesId: String?
    @NSManaged public var title: String?
    @NSManaged public var artist: Artist?
    @NSManaged public var tracks: NSSet?

}

// MARK: Generated accessors for tracks
extension Album {

    @objc(addTracksObject:)
    @NSManaged public func addToTracks(_ value: Track)

    @objc(removeTracksObject:)
    @NSManaged public func removeFromTracks(_ value: Track)

    @objc(addTracks:)
    @NSManaged public func addToTracks(_ values: NSSet)

    @objc(removeTracks:)
    @NSManaged public func removeFromTracks(_ values: NSSet)

}
