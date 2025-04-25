//
//  Customer.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Customer: Decodable {
    public var customerId: String
    public var firstName: String
    public var lastName: String
    public var address: Address
    
    public init(firstName: String, lastName: String, address: Address, customerId: String) {
        self.customerId = customerId
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
    }
    
    enum CodingKeys: String, CodingKey {
        case address

        case customerId = "_id"
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

public struct CustomerPostData: Encodable {
    public var firstName: String
    public var lastName: String
    public var address: Address
    
    enum CodingKeys: String, CodingKey {
        case address

        case firstName = "first_name"
        case lastName = "last_name"
    }
}

public struct CustomerPostResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
    public var objectCreated: Customer?
}

public struct CustomerPutData: Encodable {
    public var address: Address

    public init(address: Address) {
        self.address = address
    }
}

public struct CustomerPutResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
}

open class CustomerRequest {
    fileprivate var requestType: HTTPType!
    fileprivate var accountId: String?
    fileprivate var customerId: String?
    
    public init () {}
    
    fileprivate func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/customers/"
        if let accountId = accountId {
            requestString = "\(baseString)/accounts/\(accountId)/customer"
        }
        
        if let customerId = customerId {
            requestString += "\(customerId)"
        }

        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }

    // APIs
    open func getCustomers() async throws -> [Customer]? {
        requestType = HTTPType.GET
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let customers = try JSONDecoder().decode([Customer].self, from: data)
        return customers
    }
    
    open func getCustomer(_ customerId: String) async throws -> Customer? {
        requestType = HTTPType.GET
        self.customerId = customerId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let customer = try JSONDecoder().decode(Customer.self, from: data)
        return customer
    }
    
    open func getCustomerFromAccountId(_ accountId: String) async throws -> Customer? {
        requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let customer = try JSONDecoder().decode(Customer.self, from: data)
        return customer
    }
    
    open func postCustomer(_ newCustomer: Customer) async throws -> CustomerPostResponse? {
        self.requestType = HTTPType.POST
        
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        let customerPostData = CustomerPostData(firstName: newCustomer.firstName, lastName: newCustomer.lastName, address: newCustomer.address)
        
        do {
            request.httpBody = try JSONEncoder().encode(customerPostData)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let customerPostResponse = try JSONDecoder().decode(CustomerPostResponse.self, from: data)
        return customerPostResponse
    }
    
    open func putCustomer(_ customerId: String, _ updatedCustomer: CustomerPutData) async throws -> CustomerPutResponse? {
        requestType = HTTPType.PUT
        self.customerId = customerId
        
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedCustomer)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let customerPutResponse = try JSONDecoder().decode(CustomerPutResponse.self, from: data)
        return customerPutResponse
    }
}
