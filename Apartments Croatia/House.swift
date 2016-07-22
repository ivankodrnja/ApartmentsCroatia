//
//  House.swift
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


class House: NSManagedObject {

    @NSManaged var active: String
    @NSManaged var address: String
    @NSManaged var centerDistance: NSNumber
    @NSManaged var email: String
    @NSManaged var favorite: String
    @NSManaged var houseid: NSNumber
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var mainImagePath: String
    @NSManaged var name: String
    @NSManaged var parking: String
    @NSManaged var pets: String
    @NSManaged var phone: String
    @NSManaged var priceFrom: NSNumber
    @NSManaged var seaDistance: NSNumber
    @NSManaged var statusID: NSNumber
    @NSManaged var website: String
    @NSManaged var apartments: [Apartment]
    @NSManaged var destination: Destination?
    @NSManaged var photos: [Photo]
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(dictionary: [String : Any], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("House", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        active = dictionary[NetworkClient.XMLResponseKeys.HouseActive] as! String
        address = dictionary[NetworkClient.XMLResponseKeys.HouseAddress] as! String
        centerDistance = dictionary[NetworkClient.XMLResponseKeys.HouseCenterDistance] as! NSNumber
        email = dictionary[NetworkClient.XMLResponseKeys.HouseEmail] as! String
        favorite = dictionary[NetworkClient.XMLResponseKeys.HouseFavorite] as! String
        houseid = dictionary[NetworkClient.XMLResponseKeys.HouseID] as! NSNumber
        latitude = dictionary[NetworkClient.XMLResponseKeys.HouseLatitude] as! Double
        longitude = dictionary[NetworkClient.XMLResponseKeys.HouseLongitude] as! Double
        mainImagePath = dictionary[NetworkClient.XMLResponseKeys.HouseMainImage] as! String
        name = dictionary[NetworkClient.XMLResponseKeys.HouseName] as! String
        parking = dictionary[NetworkClient.XMLResponseKeys.HouseParking] as! String
        pets = dictionary[NetworkClient.XMLResponseKeys.HousePets] as! String
        phone = dictionary[NetworkClient.XMLResponseKeys.HousePhone] as! String
        priceFrom = dictionary[NetworkClient.XMLResponseKeys.HousePriceFrom] as! NSNumber
        seaDistance = dictionary[NetworkClient.XMLResponseKeys.HouseSeaDistance] as! NSNumber
        statusID = dictionary[NetworkClient.XMLResponseKeys.HouseStatusID] as! NSNumber
        website = dictionary[NetworkClient.XMLResponseKeys.HouseWebsite] as! String
        
        
    }

}
