//
//  Branch.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Branch: JsonParser {
    public let branchId: String
    public let name: String
    public let phoneNumber: String
    public let hours: Array<String>
    public let notes: Array<String>
    public let address: Address
    public let geocode: Geocode
    
    public required init(data: JSON) {
        self.branchId = data["_id"].string ?? ""
        self.name = data["name"].string ?? ""
        self.phoneNumber = data["phone_number"].string ?? ""
        self.hours = data["hours"].arrayValue.map({$0.string ?? ""})
        self.notes = data["notes"].arrayValue.map({$0.string ?? ""})
        self.address = Address(data: data["address"])
        self.geocode = Geocode(data: data["geocode"])
    }
}

open class BranchRequest {
    fileprivate var requestType: HTTPType = .GET
    fileprivate var branchId: String?

    public init () {}

    fileprivate func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/branches"
        if (branchId != nil) {
            requestString += "/\(branchId!)"
        }
        
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        return requestString
    }
    
    // APIs
    open func getBranches(_ completion:@escaping (_ branchesArray: Array<Branch>?, _ error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                guard let data = data else {
                    completion(nil, genericError)
                    return
                }
                
                do {
                    let json = try JSON(data: data)
                    let response = BaseResponse<Branch>(data: json)
                    completion(response.requestArray, nil)
                } catch let error as NSError {
                    completion(nil, error)
                }
            }
        })
    }
    
    open func getBranch(_ branchId: String, completion: @escaping (_ branch: Branch?, _ error: NSError?) -> Void) {
        self.branchId = branchId
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                do {
                    let json = try JSON(data: data ?? Data())
                    let response = BaseResponse<Branch>(data: json)
                    completion(response.object, nil)
                } catch let error as NSError {
                    completion(nil, error)
                }
            }
        })
    }
}
