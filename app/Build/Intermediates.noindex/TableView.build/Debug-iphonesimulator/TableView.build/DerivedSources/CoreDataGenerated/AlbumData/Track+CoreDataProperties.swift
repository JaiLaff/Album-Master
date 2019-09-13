//
//  Track+CoreDataProperties.swift
//  
//
//  Created by Jai Lafferty on 30/5/19.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var title: String?
    @NSManaged public var trackNo: Int16
    @NSManaged public var album: Album?

}
