//
//  Apartment.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 04/04/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//
/** There are 5 changes to be made. They are listed below, and called out in comments in the
 * code.
 * 1. Import Core Data
 * 2. Make Person a subclass of NSManagedObject
 * 3. Add @NSManaged in front of each of the properties/attributes
 * 4. Include the standard Core Data init method, which inserts the object into a context
 * 5. Write an init method that takes a dictionary and a context. This is the biggest change to the class
 */

import UIKit
import CoreData

class Apartment: NSManagedObject {
    @NSManaged var aircondition: String
    @NSManaged var internet: String
    @NSManaged var numberOfBeds: String
    @NSManaged var priceRange: String
    @NSManaged var surface: String
    @NSManaged var tv: String
    @NSManaged var type: String
    @NSManaged var house: House?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(dictionary: [String : Any], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Apartment", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        aircondition = dictionary[NetworkClient.XMLResponseKeys.ApartmentAircondition] as! String
        internet = dictionary[NetworkClient.XMLResponseKeys.ApartmentInternet] as! String
        numberOfBeds = dictionary[NetworkClient.XMLResponseKeys.ApartmentNumberOfBeds] as! String
        priceRange = dictionary[NetworkClient.XMLResponseKeys.ApartmentPriceRange] as! String
        surface = dictionary[NetworkClient.XMLResponseKeys.ApartmentSurface] as! String
        tv = dictionary[NetworkClient.XMLResponseKeys.ApartmentTV] as! String
        type = dictionary[NetworkClient.XMLResponseKeys.ApartmentType] as! String
        
    }

}