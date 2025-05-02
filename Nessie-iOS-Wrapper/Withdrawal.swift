//
//  Withdrawal.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Withdrawal: Decodable {
    public var withdrawalId: String
    public var type: TransferType
    public var transactionDate: String?
    public var status: TransferStatus
    public var payerId: String
    public var medium: TransactionMedium
    public var amount: Double
    public var description: String?
    
    enum CodingKeys: String, CodingKey {
        case type, medium, status, amount, description

        case withdrawalId = "_id"
        case transactionDate = "transaction_date"
        case payerId = "payer_id"
    }
}

public struct WithdrawalPostData: Encodable {
    public var medium: TransactionMedium
    public var transactionDate: String?
    public var status: TransferStatus?
    public var amount: Double
    public var description: String?
    
    public init(medium: TransactionMedium, transactionDate: String? = nil, amount: Double, status: TransferStatus? = nil, description: String? = nil) {
        self.medium = medium
        self.transactionDate = transactionDate
        self.amount = amount
        self.status = status
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case medium, status, amount, description

        case transactionDate = "transaction_date"
    }
}

public struct WithdrawalPostResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
    public var objectCreated: Withdrawal?
}

public struct WithdrawalPutData: Encodable {
    public var medium: TransactionMedium?
    public var amount: Double?
    public var description: String?
    
    public init(medium: TransactionMedium? = nil, amount: Double? = nil, description: String? = nil) {
        self.medium = medium
        self.amount = amount
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case medium, amount, description
    }
}

public struct WithdrawalPutResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
}

public struct WithdrawalDeleteResponse: Decodable {
    public var code: Int?
    public var message: String?
}

open class WithdrawalRequest {
    fileprivate var requestType: HTTPType!
    fileprivate var accountId: String?
    fileprivate var withdrawalId: String?
    
    public init() {
        // not implemented
    }
    
    fileprivate func buildRequestUrl() -> String {
        // base URL
        var requestString = "\(baseString)/withdrawals/"
        
        // if a call uses accountId
        if let accountId = accountId {
            requestString = "\(baseString)/accounts/\(accountId)/withdrawals"
        }
        
        // if a call uses transferId
        if let withdrawalId = withdrawalId {
            requestString += "\(withdrawalId)"
        }
        
        // append apiKey
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    
    // MARK: API Requests
    
    // GET /accounts/{id}/withdrawals
    open func getWithdrawalsFromAccountId(_ accountId: String) async throws -> [Withdrawal]? {
        requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let withdrawals = try JSONDecoder().decode([Withdrawal].self, from: data)
        return withdrawals
    }
    
    // GET /withdrawals/{id}
    open func getWithdrawal(_ withdrawalId: String) async throws -> Withdrawal? {
        requestType = HTTPType.GET
        self.withdrawalId = withdrawalId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let withdrawal = try JSONDecoder().decode(Withdrawal.self, from: data)
        return withdrawal
    }
    
    // POST /accounts/{id}/withdrawals
    open func postWithdrawal(_ accountId: String, _ newWithdrawal: WithdrawalPostData) async throws -> WithdrawalPostResponse? {
        requestType = HTTPType.POST
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        if let transactionDate = newWithdrawal.transactionDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            guard dateFormatter.date(from: transactionDate) != nil else {
                throw DateFormattingError.notADate
            }
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(newWithdrawal)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let withdrawalPostResponse = try JSONDecoder().decode(WithdrawalPostResponse.self, from: data)
        return withdrawalPostResponse
    }
    
    // PUT /withdrawals/{id}
    open func putWithdrawal(_ withdrawalId: String, _ updatedWithdrawal: WithdrawalPutData) async throws -> WithdrawalPutResponse? {
        requestType = HTTPType.PUT
        self.withdrawalId = withdrawalId
        
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedWithdrawal)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let withdrawalPutResponse = try JSONDecoder().decode(WithdrawalPutResponse.self, from: data)
        return withdrawalPutResponse
    }
    
    // DELETE /withdrawals/{id}
    open func deleteWithdrawal(_ withdrawalId: String) async throws -> WithdrawalDeleteResponse? {
        requestType = HTTPType.DELETE
        self.withdrawalId = withdrawalId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        guard !data.isEmpty else {
            return WithdrawalDeleteResponse(code: 204, message: "Withdrawal Deleted")
        }
        let withdrawalDeleteResponse = try JSONDecoder().decode(WithdrawalDeleteResponse.self, from: data)
        return withdrawalDeleteResponse
    }
}
