//
//  Deposit.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum TransactionMedium : String, Codable {
    case Balance = "balance"
    case Rewards = "rewards"
    case Unknown
}

public enum TransactionType : String, Decodable {
    case P2P = "p2p"
    case Deposit = "deposit"
    case Withdrawal = "withdrawal"
    case Unknown
}

public enum TransactionStatus : String, Codable {
    case Pending = "pending"
    case Cancelled = "cancelled"
    case Completed = "completed"
    case Executed = "executed"
    case Unknown
}

public struct Deposit: Decodable {
    public var depositId: String
    public var status: TransactionStatus
    public var medium: TransactionMedium
    public var payeeId: String?
    public var amount: Int
    public var type: TransactionType
    public var transactionDate: String?
    public var description: String?
    
    public init(depositId: String, status: TransactionStatus, medium: TransactionMedium, payeeId: String?, amount: Int, type: TransactionType, transactionDate: String?, description: String?) {
        self.depositId = depositId
        self.status = status
        self.medium = medium
        self.payeeId = payeeId
        self.amount = amount
        self.type = type
        self.transactionDate = transactionDate
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case status, medium, amount, type, description

        case depositId = "_id"
        case payeeId = "payee_id"
        case transactionDate = "transaction_date"
    }
}

public struct DepositPostData: Encodable {
    public var medium: TransactionMedium
    public var transactionDate: String?
    public var status: TransactionStatus?
    public var amount: Int
    public var description: String?
    
    public init(medium: TransactionMedium, transactionDate: String? = nil, status: TransactionStatus? = nil, amount: Int, description: String? = nil) {
        self.medium = medium
        self.transactionDate = transactionDate
        self.status = status
        self.amount = amount
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case medium, status, amount, description

        case transactionDate = "transaction_date"
    }
}

public struct DepositPostResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
    public var objectCreated: Deposit?
}

public struct DepositPutData: Encodable {
    public var medium: TransactionMedium
    public var amount: Int
    public var description: String?
    
    public init(medium: TransactionMedium, amount: Int, description: String? = nil) {
        self.medium = medium
        self.amount = amount
        self.description = description
    }
}

public struct DepositPutResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
}

public struct DepositDeleteResponse: Decodable {
    public var code: Int?
    public var message: String?
}

open class DepositRequest {
    fileprivate var requestType: HTTPType!
    fileprivate var accountId: String?
    fileprivate var depositId: String?
    
    public init () {}
    
    fileprivate func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/deposits/"
        if let accountId = accountId {
            requestString = "\(baseString)/accounts/\(accountId)/deposits"
        }
        
        if let depositId = depositId {
            requestString += "\(depositId)"
        }
        
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    // APIs
    open func getDeposit(_ depositId: String) async throws -> Deposit? {
        requestType = HTTPType.GET
        self.depositId = depositId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let deposit = try JSONDecoder().decode(Deposit.self, from: data)
        return deposit
    }
    
    open func getDepositsFromAccountId(_ accountId: String) async throws -> [Deposit]? {
        requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let deposits = try JSONDecoder().decode([Deposit].self, from: data)
        return deposits
    }
    
    open func postDeposit(_ accountId: String, _ newDeposit: DepositPostData) async throws -> DepositPostResponse? {
        requestType = HTTPType.POST
        self.accountId = accountId
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        if let transactionDate = newDeposit.transactionDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            guard dateFormatter.date(from: transactionDate) != nil else {
                throw DateFormattingError.notADate
            }
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(newDeposit)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let depositPostResponse = try JSONDecoder().decode(DepositPostResponse.self, from: data)
        return depositPostResponse
    }
    
    open func putDeposit(_ depositId: String, _ updatedDeposit: DepositPutData) async throws -> DepositPutResponse? {
        requestType = HTTPType.PUT
        self.depositId = depositId
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedDeposit)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let depositPutResponse = try JSONDecoder().decode(DepositPutResponse.self, from: data)
        return depositPutResponse
    }
    
    open func deleteDeposit(_ depositId: String) async throws -> DepositDeleteResponse? {
        requestType = HTTPType.DELETE
        self.depositId = depositId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        guard !data.isEmpty else {
            return DepositDeleteResponse(code: 204, message: "Deposit Deleted")
        }
        let depositDeleteResponse = try JSONDecoder().decode(DepositDeleteResponse.self, from: data)
        return depositDeleteResponse
    }
}
