//
//  Transfer.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum TransferType: String, Codable {
    case P2P = "p2p"
    case Deposit = "deposit"
    case Withdrawal = "withdrawal"
    case Unknown
}

public enum TransferStatus: String, Codable {
    case Pending = "pending"
    case Cancelled = "cancelled"
    case Completed = "completed"
    case Executed = "executed"
    case Unknown
}

public struct TransferPostData: Encodable {
    public var medium: TransactionMedium
    public var payeeId: String
    public var amount: Double
    public var transactionDate: String?
    public var status: TransferStatus?
    public var description: String?
    
    public init(medium: TransactionMedium, payeeId: String, amount: Double, transactionDate: String? = nil, status: TransferStatus? = nil, description: String? = nil) {
        self.medium = medium
        self.payeeId = payeeId
        self.amount = amount
        self.transactionDate = transactionDate
        self.status = status
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case medium, amount, status, description

        case transactionDate = "transaction_date"
        case payeeId = "payee_id"
    }
}

public struct TransferPostResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
    public var objectCreated: Transfer?
}

public struct TransferPutData: Encodable {
    public var medium: TransactionMedium?
    public var payeeId: String?
    public var amount: Double?
    public var description: String?
    
    public init(medium: TransactionMedium? = nil, payeeId: String? = nil, amount: Double? = nil, description: String? = nil) {
        self.medium = medium
        self.payeeId = payeeId
        self.amount = amount
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case medium, amount, description

        case payeeId = "payee_id"
    }
}

public struct TransferPutResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
}

public struct TransferDeleteResponse: Decodable {
    public var code: Int?
    public var message: String?
}

public struct Transfer: Decodable {
    public var transferId: String
    public var type: TransferType
    public var transactionDate: String?
    public var status: TransferStatus
    public var medium: TransactionMedium
    public var payerId: String
    public var payeeId: String
    public var amount: Double
    public var description: String?
    
    public init(transferId: String, type: TransferType, transactionDate: String?, status: TransferStatus, medium: TransactionMedium, payerId: String, payeeId: String, amount: Double, description: String?) {
        self.transferId = transferId
        self.type = type
        self.transactionDate = transactionDate
        self.status = status
        self.medium = medium
        self.payerId = payerId
        self.payeeId = payeeId
        self.amount = amount
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case type, status, medium, amount, description

        case transferId = "_id"
        case transactionDate = "transaction_date"
        case payerId = "payer_id"
        case payeeId = "payee_id"
    }
}

open class TransferRequest {
    fileprivate var requestType: HTTPType!
    fileprivate var accountId: String?
    fileprivate var transferId: String?
    
    public init () {
        // not implemented
    }
    
    fileprivate func buildRequestUrl() -> String {
        // base URL
        var requestString = "\(baseString)/transfers/"
        
        // if a call uses accountId
        if let accountId = accountId {
            requestString = "\(baseString)/accounts/\(accountId)/transfers"
        }
        
        // if a call uses transferId
        if let transferId = transferId {
            requestString += "\(transferId)"
        }
        
        // append apiKey
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    fileprivate func setUp(_ reqType: HTTPType, accountId: String?, transferId: String?) {
        self.requestType = reqType
        self.accountId = accountId
        self.transferId = transferId
    }
    
    // MARK: API Requests
    
    // GET /accounts/{id}/transfers
    open func getTransfersFromAccountId(_ accountId: String) async throws -> [Transfer]? {
        requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let transfers = try JSONDecoder().decode([Transfer].self, from: data)
        return transfers
    }
    
    // GET /transfers/{transferId}
    open func getTransfer(_ transferId: String) async throws -> Transfer? {
        requestType = HTTPType.GET
        self.transferId = transferId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let transfer = try JSONDecoder().decode(Transfer.self, from: data)
        return transfer
    }
    
    // POST /accounts/{id}/transfers
    open func postTransfer(_ accountId: String, _ newTransfer: TransferPostData) async throws -> TransferPostResponse? {
        requestType = HTTPType.POST
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        if let transactionDate = newTransfer.transactionDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            guard dateFormatter.date(from: transactionDate) != nil else {
                throw DateFormattingError.notADate
            }
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(newTransfer)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let transferPostResponse = try JSONDecoder().decode(TransferPostResponse.self, from: data)
        return transferPostResponse
    }
    
    // PUT /transfers/{transferId}
    open func putTransfer(_ transferId: String, _ updatedTransfer: TransferPutData) async throws -> TransferPutResponse? {
        requestType = HTTPType.PUT
        self.transferId = transferId
        
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedTransfer)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let transferPutResponse = try JSONDecoder().decode(TransferPutResponse.self, from: data)
        return transferPutResponse
    }
    
    // DELETE /transfers/{transferId}
    open func deleteTransfer(_ transferId: String) async throws -> TransferDeleteResponse? {
        requestType = HTTPType.DELETE
        self.transferId = transferId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        guard !data.isEmpty else {
            return TransferDeleteResponse(code: 204, message: "Transfer Deleted")
        }
        let purchaseDeleteResponse = try JSONDecoder().decode(TransferDeleteResponse.self, from: data)
        return purchaseDeleteResponse
    }
    
}
