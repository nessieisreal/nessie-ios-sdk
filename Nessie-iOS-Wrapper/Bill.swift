//
//  Bill.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum BillStatus : String, Codable {
    case Pending = "pending"
    case Recurring = "recurring"
    case Cancelled = "cancelled"
    case Completed = "completed"
    case Unknown
}

public struct Bill: Decodable, JsonParser {
    
    public let billId: String
    public let status: BillStatus
    public var payee: String
    public var nickname: String?
    public var creationDate: String
    public var paymentDate: String?
    public var recurringDate: Int?
    public var upcomingPaymentDate: String?
    public let paymentAmount: Double
    public var accountId: String
    
    public init (status: BillStatus, payee: String, nickname: String?, paymentDate: String?, recurringDate: Int?, upcomingPaymentDate: String?, paymentAmount: Double, accountId: String) {
        self.billId = ""
        self.status = status
        self.payee = payee
        self.nickname = nickname
        self.creationDate = ""
        self.paymentDate = paymentDate
        self.recurringDate = recurringDate
        self.upcomingPaymentDate = upcomingPaymentDate
        self.paymentAmount = paymentAmount
        self.accountId = accountId
    }
    
    public init (data: JSON) {
        self.billId = data["_id"].string ?? ""
        self.status = BillStatus(rawValue: data["status"].string ?? "") ?? .Unknown
        self.payee = data["_payee"].string ?? ""
        self.nickname = data["nickname"].string ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        self.creationDate = data["creation_date"].string ?? ""
        self.paymentDate = data["payment_date"].string ?? ""
        self.recurringDate = data["recurring_date"].int ?? 0
        self.upcomingPaymentDate = data["upcoming_payment_date"].string ?? ""
        self.paymentAmount = data["payment_amount"].double ?? 0
        self.accountId = data["account_id"].string ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case status, payee, nickname

        case billId = "_id"
        case creationDate = "creation_date"
        case paymentDate = "payment_date"
        case recurringDate = "recurring_date"
        case upcomingPaymentDate = "upcoming_payment_date"
        case paymentAmount = "payment_amount"
        case accountId = "account_id"
    }
}

public struct BillPostData: Codable {
    public let status: BillStatus
    public var payee: String
    public var nickname: String?
    public var paymentDate: String?
    public var recurringDate: Int?
    public let paymentAmount: Double
    
    public init(status: BillStatus, payee: String, nickname: String? = nil, paymentDate: String? = nil, recurringDate: Int? = nil, paymentAmount: Double) {
        self.status = status
        self.payee = payee
        self.nickname = nickname
        self.paymentDate = paymentDate
        self.recurringDate = recurringDate
        self.paymentAmount = paymentAmount
    }

    
    enum CodingKeys: String, CodingKey {
        case status, payee, nickname
        case paymentDate = "payment_date"
        case recurringDate = "recurring_date"
        case paymentAmount = "payment_amount"
    }
}

public struct BillPostResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
    public var objectCreated: Bill?
}

public struct BillPutData: Encodable {
    public var status: BillStatus?
    public var payee: String?
    public var nickname: String?
    public var paymentDate: String?
    public var recurringDate: Int?
    public var paymentAmount: Double?
    
    public init(status: BillStatus? = nil, payee: String? = nil, nickname: String? = nil, paymentDate: String? = nil, recurringDate: Int? = nil, paymentAmount: Double? = nil) {
        self.status = status
        self.payee = payee
        self.nickname = nickname
        self.paymentDate = paymentDate
        self.recurringDate = recurringDate
        self.paymentAmount = paymentAmount
    }
    
    enum CodingKeys: String, CodingKey {
        case status, payee, nickname
        case paymentDate = "payment_date"
        case recurringDate = "recurring_date"
        case paymentAmount = "payment_amount"
    }
}

public struct BillPutResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
}

public struct BillDeleteResponse: Decodable {
    public var code: Int?
    public var message: String?
}

open class BillRequest {
    fileprivate var requestType: HTTPType!
    fileprivate var billId: String?
    fileprivate var accountId: String?
    fileprivate var accountType: AccountType?
    fileprivate var customerId: String?

    public init () {}
    
    fileprivate func buildRequestUrl() -> String {

        var requestString = "\(baseString)"
        if (self.accountId != nil) {
            requestString += "/accounts/\(self.accountId!)/bills"
        }

        if (self.billId != nil) {
            requestString += "/bills/\(self.billId!)"
        }
        
        if (self.customerId != nil) {
            requestString = "\(baseString)/customers/\(self.customerId!)/bills"
        }
        
        if (self.requestType == HTTPType.POST) {
            requestString = "\(baseString)/accounts/\(self.accountId!)/bills"
        }
        
        if (self.requestType == HTTPType.GET && self.accountId == nil && self.accountType != nil) {
            var typeParam = self.accountType!.rawValue
            typeParam = typeParam.replacingOccurrences(of: " ", with: "%20")
            requestString += "?type=\(typeParam)&key=\(NSEClient.sharedInstance.getKey())"
            return requestString
        }
        
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    // APIs
    open func getAccountBills(_ accountId: String) async throws -> [Bill]? {
        self.requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let bills = try JSONDecoder().decode([Bill].self, from: data)
        return bills
    }
    
    open func getBill(_ billId: String) async throws -> Bill? {
        self.requestType = HTTPType.GET
        self.billId = billId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let bill = try JSONDecoder().decode(Bill.self, from: data)
        return bill
    }
    
    open func getCustomerBills(_ customerId: String) async throws -> [Bill]? {
        self.requestType = HTTPType.GET
        self.customerId = customerId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let customerBills = try JSONDecoder().decode([Bill].self, from: data)
        return customerBills
    }
    
    open func postBill(_ accountId: String, _ newBill: BillPostData) async throws -> BillPostResponse? {
        
        self.requestType = HTTPType.POST
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        
        if let paymentDate = newBill.paymentDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            guard dateFormatter.date(from: paymentDate) != nil else {
                throw DateFormattingError.notADate
            }
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(newBill)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let billPostResponse = try JSONDecoder().decode(BillPostResponse.self, from: data)
        return billPostResponse
    }
    
    open func putBill(_ billId: String, _ updatedBill: BillPutData) async throws -> BillPutResponse? {
        self.requestType = HTTPType.PUT
        self.billId = billId

        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        
        if let paymentDate = updatedBill.paymentDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            guard dateFormatter.date(from: paymentDate) != nil else {
                throw DateFormattingError.notADate
            }
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedBill)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let billPutResponse = try JSONDecoder().decode(BillPutResponse.self, from: data)
        return billPutResponse
    }
    
    open func deleteBill(_ billId: String) async throws -> BillDeleteResponse? {
        self.requestType = HTTPType.DELETE
        self.billId = billId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        guard !data.isEmpty else {
            return BillDeleteResponse(code: 204, message: "Bill Deleted")
        }
        let billDeleteResponse = try JSONDecoder().decode(BillDeleteResponse.self, from: data)
        return billDeleteResponse
    }
}

enum DateFormattingError: Error {
    case notADate
}
