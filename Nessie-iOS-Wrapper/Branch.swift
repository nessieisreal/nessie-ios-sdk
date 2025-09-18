//
//  Branch.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Branch: Decodable {
    public let branchId: String
    public let name: String
    public let phoneNumber: String
    public let hours: Array<String>
    public let notes: Array<String>
    public let address: Address
    public let geocode: Geocode
    
    enum CodingKeys: String, CodingKey {
        case name, hours, notes, address, geocode

        case branchId = "_id"
        case phoneNumber = "phone_number"
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
    open func getBranches() async throws -> [Branch]? {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let branches = try JSONDecoder().decode([Branch].self, from: data)
        return branches
    }
    
    open func getBranch(_ branchId: String) async throws -> Branch? {
        self.branchId = branchId
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let branch = try JSONDecoder().decode(Branch.self, from: data)
        return branch
    }
}
