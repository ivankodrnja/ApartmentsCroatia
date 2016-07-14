//
//  NetworkClient.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 29/03/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit
import CoreData

class NetworkClient: NSObject {
    //TODO:
    var destination: Destination!
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    /* Shared Session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK: - Shared Instance
    class func sharedInstance() -> NetworkClient {
        
        struct Singleton {
            static var sharedInstance = NetworkClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    //TODO: get all regions and destinations
    func getRegionByName(name: String) -> [Region] {
        
        let regionByNameFetchRequest = NSFetchRequest(entityName: "Region")
        regionByNameFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        regionByNameFetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        
        let regionByName = (try! sharedContext.executeFetchRequest(regionByNameFetchRequest)) as! [Region]
        
        return regionByName
    }
    
    func getDestinations(){
        
       // return Destiations
    }
    
    func getRentals(modifiedDate: NSDate, completionHandler: (result: [String:AnyObject]?, error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let stringFromDate = dateFormatter.stringFromDate(modifiedDate)
        
        /* 2. Build the URL */
        let urlString = NetworkClient.Constants.baseUrl + NetworkClient.Constants.reloadMethod + stringFromDate
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                
                completionHandler(result: nil, error: error)
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let xml = SWXMLHash.parse(data)
            
            var regions = [String]()
            var destinations = [String]()
            
            do {
                // get the <root><house> elements from the xml file
                let houseElement = try xml.byKey("root").byKey("house")
                
                // will store an array of house dictionaries i.e. house objects
                var housesArray = [[String:AnyObject]]()
                // will store house object in each iteration of the loop
                var houseDict = [String:AnyObject]()
                
                for elem in houseElement.children {
                    
                    // here will be stored photos and apartments data in each iteration of the loop
                    var tempDict = [String : AnyObject]()
                    // store apartment objects
                    var tempApartmentDict = [String:AnyObject]()
                    
                    switch (elem.element!.name){
                    case "region":
                        // we filter region names to append only unique ones
                        if !regions.contains(elem.element!.text!){
                            regions.append(elem.element!.text!)
                        }
                        
                    case "destination":
                        // we filter destination names to append only unique ones
                        if !destinations.contains(elem.element!.text!){
                            destinations.append(elem.element!.text!)
                        }
                        
                    case "photos":
                        let countOfPhotoElements = elem["photo"].children.count
                        var numberOfPhotoElements = 1
                        
                        for photoelem in elem["photo"].children {
                           // each xml entry goes to temporary dictionary which eventually goes to house object
                            tempDict["\(numberOfPhotoElements)"] = photoelem.element!.text!
                            
                            // tempDict of photo objects will be added to house object after all photo elements have been added to tempDict
                            if(numberOfPhotoElements == countOfPhotoElements){
                                houseDict["photos"] = tempDict
                            }
                            
                            numberOfPhotoElements += 1
                        }
                        
                    case "apartments":
                        let countOfApartmentElements = elem["apartment"].children.count
                        var numberOfApartmentElements = 1
                        var numberOfApartmentObjects = 1
                        
                        for apartelem in elem["apartment"].children {
                            tempDict["\(apartelem.element!.name)"] = apartelem.element!.text!
                            
                            // each new apartmeent object finishes with <internet> xml element, when it occurs, add tempDict to tempApartmentDict and clear tempDict content
                            if(apartelem.element!.name == NetworkClient.XMLResponseKeys.ApartmentInternet){
                                // before clearing the houseDict, add it to the tempApartmentDict which eventually goes to house object
                                tempApartmentDict["\(numberOfApartmentObjects)"] = tempDict
                                tempDict.removeAll()
                                
                                numberOfApartmentObjects += 1
                            }
                            
                            // tempApartmentDict of apartment objects will be added to house object after all apartment objects have been added to tempApartmentDict
                            if(numberOfApartmentElements == countOfApartmentElements){
                               houseDict["apartments"] = tempApartmentDict
                            }
                            
                            numberOfApartmentElements += 1
                        }
                  
                    case "deleted":
                        //TODO: delete the house by ID from database
                        for deletedelem in elem["deleted"].children {
                           // print("\(deletedelem.element!.name) : \(deletedelem.element!.text!)")
                        }
                        
                    default:
                        // check if xml element should be an int or a Duble and typecast it from string
                        if (NetworkClient.Constants.toInt.contains(elem.element!.name)){
                           houseDict["\(elem.element!.name)"] = Int(elem.element!.text!)
                        } else if (elem.element!.name == NetworkClient.XMLResponseKeys.HouseLatitude || elem.element!.name == NetworkClient.XMLResponseKeys.HouseLongitude){
                            houseDict["\(elem.element!.name)"] = Double(elem.element!.text!)
                            // leave as deafult type which is String
                        } else {
                            houseDict["\(elem.element!.name)"] = elem.element!.text!
                        }
                    }
                    
                    // each new house object finishes with <active> xml element, when it occurs, add houseDict to houseArray and clear houseDict content
                    if(elem.element!.name == NetworkClient.XMLResponseKeys.HouseActive){
                        
                        // before clearing the houseDict, append it to the houseArray
                        housesArray.append(houseDict)
                        
                        houseDict.removeAll()
                    }
                    
                }
                //print(regions)
                //print(destinations)
                
               // print(housesArray)
                
                housesArray.map(){ (dictionary: [String : AnyObject]) -> House in
                    let house = House(dictionary: dictionary, context: self.sharedContext)
                    
                    
                    
                    house.destination = self.destination
                    
                    print(house)
                    CoreDataStackManager.sharedInstance().saveContext()
                    return house
                }
            } catch {
                print("Could not parse the data as XML: '\(XMLIndexer.Error.self)'")
                return
            }
            
            /* 6. Use the data! */
            /*
            if let apartmentDictionary = parsedResult.valueForKey(ZilyoClient.JSONResponseKeys.Result) as? [[String:AnyObject]] {
                
                let apartments = ApartmentInformation.apartmentsFromResults(apartmentDictionary)
                completionHandler(result: apartments, error: nil)
                
            } else {
                completionHandler(result: nil, error: NSError(domain: "Results from Server", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download (server) error occured. Please retry."]))
            }
            */
        }
        /* 7. Start the request */
        task.resume()
    }
 

    
}