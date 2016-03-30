//
//  Constants.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 29/03/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

extension NetworkClient {
    
    struct Constants {
        static let baseUrl: String = "http://www.2plus2.hr/Apartment/"
        static let reloadMethod: String = "xmlV3ios.php?lastmodified="
    }
    
    
    struct XMLResponseKeys {
        static let RegionName = "region"
        static let DestinationName = "destination"
        static let HouseName = "name"
        static let HouseAddress = "address"
        static let HousePhone = "phone"
        static let HouseEmail = "email"
        static let HouseWebsite = "website"
        static let HouseLatitude = "lat"
        static let HouseLongitude = "lng"
        static let HouseSeaDistance = "sea_distance"
        static let HouseCenterDistance = "center_distance"
        static let HouseParking = "parking"
        static let HousePets = "pets"
        static let HousePriceFrom = "price_from"
        static let HouseStatusID = "statusid"
        static let HouseActive = "active"
        static let Photos = "photos"
        static let PhotoName = "photoname"
        static let Apartments = "apartments"
        static let Apartment = "apartment"
        static let ApartmentType = "apartment_type"
        static let ApartmentPriceRange = "price_range"
        static let ApartmentNumberOfBeds = "number_of_beds"
        static let ApartmentSurface = "surface"
        static let ApartmentAircondition = "air_condition"
        static let ApartmentTV = "tv"
        static let ApartmentInternet = "internet"
    }
}