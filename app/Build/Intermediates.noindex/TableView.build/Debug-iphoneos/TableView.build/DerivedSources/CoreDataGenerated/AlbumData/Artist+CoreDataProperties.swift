//
//  Artist+CoreDataProperties.swift
//  
//
//  Created by Jai Lafferty on 14/6/19.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Artist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artist> {
        return NSFetchRequest<Artist>(entityName: "Artist")
    }

    @NSManaged public var itunesId: String?
    @NSManaged public var name: String?
    @NSManaged public var album: NSSet?

}

// MARK: Generated accessors for album
extension Artist {

    @objc(addAlbumObject:)
    @NSManaged public func addToAlbum(_ value: Album)

    @objc(removeAlbumObject:)
    @NSManaged public func removeFromAlbum(_ value: Album)

    @objc(addAlbum:)
    @NSManaged public func addToAlbum(_ values: NSSet)

    @objc(removeAlbum:)
    @NSManaged public func removeFromAlbum(_ values: NSSet)

}
