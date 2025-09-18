//
//  Purchase.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Purchase: Decodable {
    public var merchantId: String
    public let status: BillStatus
    public var medium: TransactionMedium
    public let payerId: String?
    public var amount: Double
    public let type: String?
    public var purchaseDate: String?
    public var description: String?
    public let purchaseId: String
    
    public init(merchantId: String, status: BillStatus, medium: TransactionMedium, payerId: String?, amount: Double, type: String, purchaseDate: String?, description: String?, purchaseId: String) {
        self.merchantId = merchantId
        self.status = status
        self.medium = medium
        self.payerId = payerId
        self.amount = amount
        self.type = type
        self.purchaseDate = purchaseDate
        self.description = description
        self.purchaseId = purchaseId
    }
    
    enum CodingKeys: String, CodingKey {
        case status, medium, amount, type, description

        case purchaseId = "_id"
        case merchantId = "merchant_id"
        case payerId = "payer_id"
        case purchaseDate = "purchase_date"
    }
}

public struct PurchasePostData: Encodable {
    public var merchantId: String
    public var medium: TransactionMedium
    public var purchaseDate: String?
    public var amount: Double
    public let status: BillStatus?
    public var description: String?
    
    public init(merchantId: String, medium: TransactionMedium, purchaseDate: String? = nil, amount: Double, status: BillStatus? = nil, description: String? = nil) {
        self.merchantId = merchantId
        self.medium = medium
        self.purchaseDate = purchaseDate
        self.amount = amount
        self.status = status
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case status, medium, amount, description

        case merchantId = "merchant_id"
        case purchaseDate = "purchase_date"
    }
}

public struct PurchasePostResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
    public var objectCreated: Purchase?
}

public struct PurchasePutData: Encodable {
    public var payerId: String
    public var medium: TransactionMedium
    public var amount: Double
    public var description: String?
    
    public init(payerId: String, medium: TransactionMedium, amount: Double, description: String? = nil) {
        self.payerId = payerId
        self.medium = medium
        self.amount = amount
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case medium, amount, description

        case payerId = "payer_id"
    }
}

public struct PurchasePutResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
}

public struct PurchaseDeleteResponse: Decodable {
    public var code: Int?
    public var message: String?
}

open class PurchaseRequest {
    fileprivate var requestType: HTTPType!
    fileprivate var accountId: String?
    fileprivate var purchaseId: String?
    fileprivate var merchantId: String?
    
    public init () {}
    
    fileprivate func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/purchases/"
        
        if let merchantId = merchantId, let accountId = accountId {
            requestString = "\(baseString)/merchants/\(merchantId)/accounts/\(accountId)/purchases"
        }
        
        if let merchantId = merchantId {
            requestString = "\(baseString)/merchants/\(merchantId)/purchases"
        }

        if let accountId = accountId {
            requestString = "\(baseString)/accounts/\(accountId)/purchases"
        }
        
        if let purchaseId = purchaseId {
            requestString += "\(purchaseId)"
        }
        
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    // APIs
    open func getPurchase(_ purchaseId: String) async throws -> Purchase? {
        requestType = HTTPType.GET
        self.purchaseId = purchaseId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let purchase = try JSONDecoder().decode(Purchase.self, from: data)
        return purchase
    }
    
    open func getPurchasesFromMerchantId(_ merchantId: String) async throws -> [Purchase]? {
        requestType = HTTPType.GET
        self.merchantId = merchantId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let purchases = try JSONDecoder().decode([Purchase].self, from: data)
        return purchases
    }
    
    open func getPurchasesFromAccountId(_ accountId: String) async throws -> [Purchase]? {
        requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let purchases = try JSONDecoder().decode([Purchase].self, from: data)
        return purchases
    }
    
    open func getPurchasesFromMerchantAndAccountIds(_ merchantId: String, accountId: String) async throws -> [Purchase]? {
        requestType = HTTPType.GET
        self.merchantId = merchantId
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let purchases = try JSONDecoder().decode([Purchase].self, from: data)
        return purchases
    }
    
    open func postPurchase(accountId: String, _ newPurchase: PurchasePostData) async throws -> PurchasePostResponse? {
        requestType = HTTPType.POST
        self.accountId = accountId
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        if let purchaseDate = newPurchase.purchaseDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            guard dateFormatter.date(from: purchaseDate) != nil else {
                throw DateFormattingError.notADate
            }
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(newPurchase)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let purchasePostResponse = try JSONDecoder().decode(PurchasePostResponse.self, from: data)
        return purchasePostResponse
    }
    
    open func putPurchase(_ purchaseId: String, _ updatedPurchase: PurchasePutData) async throws -> PurchasePutResponse? {
        requestType = HTTPType.PUT
        self.purchaseId = purchaseId
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedPurchase)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let purchasePutResponse = try JSONDecoder().decode(PurchasePutResponse.self, from: data)
        return purchasePutResponse
    }
    
    open func deletePurchase(_ purchaseId: String) async throws -> PurchaseDeleteResponse? {
        requestType = HTTPType.DELETE
        self.purchaseId = purchaseId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        guard !data.isEmpty else {
            return PurchaseDeleteResponse(code: 204, message: "Purchase Deleted")
        }
        let purchaseDeleteResponse = try JSONDecoder().decode(PurchaseDeleteResponse.self, from: data)
        return purchaseDeleteResponse
    }
}
