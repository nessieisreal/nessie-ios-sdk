//
//  ATM.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

open class ATMRequest {
    fileprivate var requestType: HTTPType?
    fileprivate var atmId: String?
    fileprivate var radius: String?
    fileprivate var latitude: Float?
    fileprivate var longitude: Float?
    fileprivate var nextPage: String?
    fileprivate var previousPage: String?
    
    public init () {
        self.requestType = HTTPType.GET
    }
    
    fileprivate func buildRequestUrl() -> String {
        if let nextPage = self.nextPage {
            return "\(baseString)\(nextPage)"
        }

        if let previousPage = self.previousPage {
            return "\(baseString)\(previousPage)"
        }
        
        var requestString = "\(baseString)/atms"

        if let atmId = self.atmId {
            requestString += "/\(atmId)?"
        } else {
            requestString += validateLocationSearchParameters()
        }
        
        requestString += "key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    fileprivate func validateLocationSearchParameters() -> String {
        if (self.latitude != nil && self.longitude != nil && self.radius != nil) {
            let locationSearchParameters = "lat=\(self.latitude!)&lng=\(self.longitude!)&rad=\(self.radius!)"
            return "?"+locationSearchParameters+"&"
        }
        else if !(self.latitude == nil && self.longitude == nil && self.radius == nil) {
            print("Latitude, longitude, and radius are optionals. But if one is used, all are required.")
            print("You provided lat:\(String(describing: self.latitude)) long:\(String(describing: self.longitude)) radius:\(String(describing: self.radius))")
            return ""
        }
        
        return "?"
    }
    
    open func getAtms(_ latitude: Float?, longitude: Float?, radius: String?) async throws -> AtmResponse? {

        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius

        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let atmResponse = try JSONDecoder().decode(AtmResponse.self, from: data)
        return atmResponse
    }
    
    open func getNextAtms(_ nextPage: String) async throws -> AtmResponse? {
            
        self.nextPage = nextPage

        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let atmResponse = try JSONDecoder().decode(AtmResponse.self, from: data)
        return atmResponse
    }

    open func getPreviousAtms(_ previousPage: String) async throws -> AtmResponse? {

        self.previousPage = previousPage
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let atmResponse = try JSONDecoder().decode(AtmResponse.self, from: data)
        return atmResponse
    }
    
    open func getAtm(_ atmId: String) async throws -> Atm? {

        self.atmId = atmId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let atm = try JSONDecoder().decode(Atm.self, from: data)
        return atm
    }

}

public struct Paging: Decodable {
    public let previous: String
    public let next: String
}

open class AtmResponse: Decodable {
    
    public let data: [Atm]
    public let paging: Paging

    public init(data: [Atm], paging: Paging) {
        self.data = data
        self.paging = paging
    }

}

public struct Atm: Decodable {
    
    public let atmId: String
    public let name: String
    public let languageList: Array<String>
    public let address: Address
    public let geocode: Geocode
    public let amountLeft: Int
    public let accessibility: Bool
    public let hours: Array<String>
    
    public init(atmId: String, name: String, languageList: Array<String>, address: Address, geocode: Geocode, amountLeft: Int, accessibility: Bool, hours: Array<String>) {
        self.atmId = atmId
        self.name = name
        self.languageList = languageList
        self.address = address
        self.geocode = geocode
        self.amountLeft = amountLeft
        self.accessibility = accessibility
        self.hours = hours
    }

    
    enum CodingKeys: String, CodingKey {
        case name, address, accessibility, hours

        case atmId = "_id"
        case languageList = "language_list"
        case amountLeft = "amount_left"
        case geocode = "geocode"
    }

}
