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

    
    typealias CompletionHander = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    /* Shared Session */
    var session: URLSession
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    // will serve to store last db sync date
    let defaults = UserDefaults.standard
    
    
    // will serve for storing current user's location
    var userLocationLatitude: Double = 0
    var userLocationLongitude: Double = 0
    
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
    
    func getRegionByName(_ name: String) -> [Region] {
        
        let regionByNameFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Region")
        regionByNameFetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        
        let regionByName = (try! sharedContext.fetch(regionByNameFetchRequest)) as! [Region]
        
        return regionByName
        
    }
    
    func getDestinationByName(_ name: String) -> [Destination] {
        
        let destinationByNameFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Destination")
        destinationByNameFetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        
        let destinationByName = (try! sharedContext.fetch(destinationByNameFetchRequest)) as! [Destination]
        
        return destinationByName
    }
    
    
    func getHouseById(_ houseid: Int) -> [House] {
        
        let houseByIdFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "House")
        houseByIdFetchRequest.predicate = NSPredicate(format: "houseid == \(houseid)")
        
        
        let houseById = (try! sharedContext.fetch(houseByIdFetchRequest)) as! [House]
        
        return houseById
    }
    
    func getRentals(_ modifiedDate: Date, completionHandlerForGetRentals: @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let stringFromDate = dateFormatter.string(from: modifiedDate)
        
        /* 2. Build the URL */
        let urlString = NetworkClient.Constants.baseUrl + NetworkClient.Constants.reloadMethod + stringFromDate
        let url = URL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(url: url)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGetRentals(nil, NSError(domain: "getRentals", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let xml = SWXMLHash.parse(data)
            
            // will store an array of house dictionaries i.e. house objects
            var housesArray = [[String:Any]]()
            // will store house object in each iteration of the loop
            var houseDict = [String:Any]()
            
            do {
                // get the <root><house> elements from the xml file
                let houseElement = try xml.byKey("root").byKey("house")

                
                for elem in houseElement.children {
                    
                    // here will be stored photos and apartments data in each iteration of the loop
                    var tempDict = [String : Any]()
                    // here will be stored photos and apartments data in each iteration of the loop
                    var tempArray = [Any]()
                    // store apartment objects
                    var tempApartmentArray = [Any]()
                    
                    switch (elem.element!.name){
                    case "photos":
                        let countOfPhotoElements = elem["photo"].children.count
                        var numberOfPhotoElements = 1
                        
                        for photoelem in elem["photo"].children {
                            // each xml entry goes to temporary array which eventually goes to house object
                            tempArray.append(photoelem.element!.text)
                            
                            // tempArray of photo objects will be added to house object after all photo elements have been added to tempDict
                            if(numberOfPhotoElements == countOfPhotoElements){
                                houseDict["photos"] = tempArray 
                            }
                            
                            numberOfPhotoElements += 1

                        }
                        
                    case "apartments":
                        let countOfApartmentElements = elem["apartment"].children.count
                        var numberOfApartmentElements = 1
                        var numberOfApartmentObjects = 1
                        
                        for apartelem in elem["apartment"].children {
                            tempDict["\(apartelem.element!.name)"] = apartelem.element!.text
                            
                            // each new apartment object finishes with <internet> xml element, when it occurs, add tempDict to tempApartmentArray and clear tempDict content
                            if(apartelem.element!.name == NetworkClient.XMLResponseKeys.ApartmentInternet){
                                // before clearing the houseDict, add it to the tempApartmentDict which eventually goes to house object
                                tempApartmentArray.append(tempDict)
                                tempDict.removeAll()
                                
                                numberOfApartmentObjects += 1
                            }
                            
                            // tempApartmentArray of apartment objects will be added to house object after all apartment objects have been added to tempApartmentDict
                            if(numberOfApartmentElements == countOfApartmentElements){
                                houseDict["apartments"] = tempApartmentArray
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
                           houseDict["\(elem.element!.name)"] = Int(elem.element!.text)
                        } else if (elem.element!.name == NetworkClient.XMLResponseKeys.HouseLatitude || elem.element!.name == NetworkClient.XMLResponseKeys.HouseLongitude){
                            houseDict["\(elem.element!.name)"] = Double(elem.element!.text)
                            // leave as deafult type which is String
                        } else {
                            houseDict["\(elem.element!.name)"] = elem.element!.text
                        }
                    }
                    
                    // each new house object finishes with <active> xml element, when it occurs, add houseDict to houseArray and clear houseDict content
                    if(elem.element!.name == NetworkClient.XMLResponseKeys.HouseActive){
                        
                        // we add default entry for favorite attribute to "N", it will be used later when data is inserted into Core Data a
                        houseDict[NetworkClient.XMLResponseKeys.HouseFavorite] = "N"
                        // before clearing the houseDict, append it to the houseArray
                        housesArray.append(houseDict)
                        
                        houseDict.removeAll()
                    }
                    
                }

            } catch {
                print("Could not parse the data as XML: '\(XMLIndexer.xmlError.self)'")
                return
            }
            
            /* 6. Use the data! */
            // parse the newly created array and insert records into Core Data
            DispatchQueue.main.async {
                for house in housesArray{
                    
                    // check the current database if region, destination or house exists, array's first function is used to return the corresponding object
                    var region = self.getRegionByName(house[NetworkClient.XMLResponseKeys.RegionName] as! String).first
                    var destination = self.getDestinationByName(house[NetworkClient.XMLResponseKeys.DestinationName] as! String).first
                    var aHouse = self.getHouseById(house[NetworkClient.XMLResponseKeys.HouseID] as! Int).first
                    
                    // if region doesn't already exist, add it to the database
                    if region == nil {
                       // create dictionary which will be used for Core Data entry
                        let regionDict = [NetworkClient.XMLResponseKeys.RegionName : house[NetworkClient.XMLResponseKeys.RegionName]!, NetworkClient.XMLResponseKeys.SortOrder : house[NetworkClient.XMLResponseKeys.RegionSortOrder] as! Int]
                       region = Region(dictionary: regionDict, context: self.sharedContext)
                        
                    }
                    // if destination doesn't already exist, add it to the database
                    if  destination == nil {
                        // create dictionary which will be used for Core Data entry
                        let destinationDict = [NetworkClient.XMLResponseKeys.DestinationName : house[NetworkClient.XMLResponseKeys.DestinationName]!, NetworkClient.XMLResponseKeys.DestinationPhotoPath : house[NetworkClient.XMLResponseKeys.DestinationImage]]
                        destination = Destination(dictionary: destinationDict, context: self.sharedContext)
                        // destination belongs to a certain region
                        destination?.region = region
                    }

                    
                    // if house doesn't already exist in CD and it has Payment Successful status (id = 3), add it to the database
                    if (aHouse == nil && house[NetworkClient.XMLResponseKeys.HouseStatusID] as! Int == 3) {
                        aHouse = House(dictionary: house, context: self.sharedContext)
                        // house belongs to certain destination
                        aHouse?.destination = destination
                        
                        // add photos of the house
                        if let photos = house[NetworkClient.XMLResponseKeys.Photos] as? [Any]{
                            for photo in photos{
                                let photoDict = [NetworkClient.Constants.Path : photo]
                                let newPhoto = Photo(dictionary: photoDict, context: self.sharedContext)
                                // photo belongs to a certain house
                                newPhoto.house = aHouse
                            }
                        }
                        
                        if let apartments = house[NetworkClient.XMLResponseKeys.Apartments] as? [Any]{
                            for apartment in apartments{
                                let newApartment = Apartment(dictionary: apartment as! [String:Any], context: self.sharedContext)
                                newApartment.house = aHouse
                            }
                        }
                      // check if house needs to be deleted, i.e. house is already in CD and has status id !3 in the paresed xml file
                    } else if (aHouse != nil && house[NetworkClient.XMLResponseKeys.HouseStatusID] as! Int != 3) {
                            self.sharedContext.delete(aHouse!)
                        
                    }

                   // save data
                    CoreDataStackManager.sharedInstance().saveContext()
                }
            }
            let lastUpdate = ["lastUpdate" : Date()]
            completionHandlerForGetRentals(lastUpdate as [String : AnyObject], nil)
            
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
