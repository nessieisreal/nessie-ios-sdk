//
//  Merchant.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. (CONT) on 9/1/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Merchant: Decodable {
    public let merchantId: String
    public var name: String
    public var creationDate: String
    public var category: String?
    public var address: Address?
    public var geocode: Geocode?
    
    public init(merchantId: String, name: String, creationDate: String, category: String?, address: Address?, geocode: Geocode?) {
        self.merchantId = merchantId
        self.name = name
        self.creationDate = creationDate
        self.category = category
        self.address = address
        self.geocode = geocode
    }
    
    enum CodingKeys: String, CodingKey {
        case name, category, address, geocode

        case merchantId = "_id"
        case creationDate = "creation_date"
    }
}

public struct MerchantPostData: Encodable {
    public var name: String
    public var category: String?
    public var address: Address?
    public var geocode: Geocode?
    
    public init(name: String, category: String? = nil, address: Address? = nil, geocode: Geocode? = nil) {
        self.name = name
        self.category = category
        self.address = address
        self.geocode = geocode
    }
}

public struct MerchantPostResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
    public var objectCreated: Merchant?
}

public struct MerchantPutData: Encodable {
    public var name: String
    public var category: String?
    public var address: Address?
    public var geocode: Geocode?
    
    public init(name: String, category: String? = nil, address: Address? = nil, geocode: Geocode? = nil) {
        self.name = name
        self.category = category
        self.address = address
        self.geocode = geocode
    }
}

public struct MerchantPutResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
}

open class MerchantRequest {
    fileprivate var requestType: HTTPType!
    fileprivate var merchantId: String?
    fileprivate var rad: String?
    fileprivate var geocode: Geocode?
    
    public init () {}
    
    fileprivate func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/merchants"
        if let merchantId = merchantId {
            requestString += "/\(merchantId)"
        }
        if let geocode = geocode, let rad = rad {
            requestString += "?lat=\(geocode.lat)&lng=\(geocode.lng)&rad=\(rad)&key=\(NSEClient.sharedInstance.getKey())"
            return requestString
        }
        
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    // APIs
    open func getMerchants(_ geocode: Geocode? = nil, rad: String? = nil) async throws -> [Merchant]? {
        requestType = HTTPType.GET
        self.geocode = geocode
        self.rad = rad
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let merchants = try JSONDecoder().decode([Merchant].self, from: data)
        return merchants
    }
    
    open func getMerchant(_ merchantId: String) async throws -> Merchant? {
        requestType = HTTPType.GET
        self.merchantId = merchantId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let merchant = try JSONDecoder().decode(Merchant.self, from: data)
        return merchant
    }
    
    open func postMerchant(_ newMerchant: MerchantPostData) async throws -> MerchantPostResponse? {
        self.requestType = HTTPType.POST
        
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        do {
            request.httpBody = try JSONEncoder().encode(newMerchant)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let merchantPostResponse = try JSONDecoder().decode(MerchantPostResponse.self, from: data)
        return merchantPostResponse
    }
    
    open func putMerchant(_ merchantId: String, _ updatedMerchant: MerchantPutData) async throws -> MerchantPutResponse? {
        requestType = HTTPType.PUT
        self.merchantId = merchantId
        
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedMerchant)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let merchantPutResponse = try JSONDecoder().decode(MerchantPutResponse.self, from: data)
        return merchantPutResponse
    }
}
