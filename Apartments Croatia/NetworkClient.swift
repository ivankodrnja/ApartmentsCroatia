//
//  NetworkClient.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 29/03/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import Foundation

class NetworkClient: NSObject {
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    /* Shared Session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // dictionary that will temporarily hold request parameters
    var tempRequestParameters = [String : AnyObject]()
    
    
    // MARK: - Shared Instance
    class func sharedInstance() -> NetworkClient {
        
        struct Singleton {
            static var sharedInstance = NetworkClient()
        }
        
        return Singleton.sharedInstance
    }
    
}