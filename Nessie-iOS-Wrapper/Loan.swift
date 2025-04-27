//
//  Loan.swift
//  Nessie-iOS-Wrapper
//
//  Created by Ji,Jason on 1/30/17.
//  Copyright © 2017 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum LoanType: String, Codable {
    case auto, home, unknown
    case smallBusiness="small business"
}

public enum LoanStatus: String, Codable {
    case pending, approved, declined, unknown
}

public struct Loan: Decodable {
    public var loanId: String
    public var type: LoanType
    public var status: LoanStatus
    public var creditScore: Int
    public var monthlyPayment: Double
    public var amount: Int
    public var creationDate: String?
    public var description: String?
    
    public init(loanId: String, type: LoanType, status: LoanStatus, creditScore: Int, monthlyPayment: Double, amount: Int, creationDate: String?, description: String?) {
        self.loanId = loanId
        self.type = type
        self.status = status
        self.creditScore = creditScore
        self.monthlyPayment = monthlyPayment
        self.amount = amount
        self.creationDate = creationDate
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case type, status, amount, description

        case loanId = "_id"
        case creditScore = "credit_score"
        case monthlyPayment = "monthly_payment"
        case creationDate = "creation_date"
    }
}

public struct LoanPostData: Encodable {
    public var type: LoanType
    public var status: LoanStatus
    public var creditScore: Int
    public var monthlyPayment: Double
    public var amount: Int
    public var description: String?
    
    public init(type: LoanType, status: LoanStatus, creditScore: Int, monthlyPayment: Double, amount: Int, description: String?) {
        self.type = type
        self.status = status
        self.creditScore = creditScore
        self.monthlyPayment = monthlyPayment
        self.amount = amount
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case type, status, amount, description

        case creditScore = "credit_score"
        case monthlyPayment = "monthly_payment"
    }
}

public struct LoanPostResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
    public var objectCreated: Loan?
}

public struct LoanPutData: Encodable {
    public var type: LoanType?
    public var status: LoanStatus?
    public var creditScore: Int?
    public var monthlyPayment: Double?
    public var amount: Int?
    
    public init(type: LoanType? = nil, status: LoanStatus? = nil, creditScore: Int? = nil, monthlyPayment: Double? = nil, amount: Int? = nil) {
        self.type = type
        self.status = status
        self.creditScore = creditScore
        self.monthlyPayment = monthlyPayment
        self.amount = amount
    }
    
    enum CodingKeys: String, CodingKey {
        case type, status, amount

        case creditScore = "credit_score"
        case monthlyPayment = "monthly_payment"
    }
}

public struct LoanPutResponse: Decodable {
    public var code: Int?
    public var message: String?
    public var culprit: [String]?
}

public struct LoanDeleteResponse: Decodable {
    public var code: Int?
    public var message: String?
}

open class LoanRequest {
    fileprivate var requestType: HTTPType!
    fileprivate var accountId: String?
    fileprivate var loanId: String?
    
    public init () {}
    
    fileprivate func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/loans/"
        if let accountId = accountId {
            requestString = "\(baseString)/accounts/\(accountId)/loans"
        }
        
        if let loanId = loanId {
            requestString += "\(loanId)"
        }
        
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    // APIs
    open func getLoan(_ loanId: String) async throws -> Loan? {
        requestType = HTTPType.GET
        self.loanId = loanId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let loan = try JSONDecoder().decode(Loan.self, from: data)
        return loan
    }
    
    open func getLoansFromAccountId(_ accountId: String) async throws -> [Loan]? {
        requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let loans = try JSONDecoder().decode([Loan].self, from: data)
        return loans
    }
    
    open func postLoan(_ accountId: String, _ newLoan: LoanPostData) async throws -> LoanPostResponse? {
        requestType = HTTPType.POST
        self.accountId = accountId
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        do {
            request.httpBody = try JSONEncoder().encode(newLoan)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let loanPostResponse = try JSONDecoder().decode(LoanPostResponse.self, from: data)
        return loanPostResponse
    }
    
    open func putLoan(_ loanId: String, _ updatedLoan: LoanPutData) async throws -> LoanPutResponse? {
        requestType = HTTPType.PUT
        self.loanId = loanId
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedLoan)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let loanPutResponse = try JSONDecoder().decode(LoanPutResponse.self, from: data)
        return loanPutResponse
    }
    
    open func deleteLoan(_ loanId: String) async throws -> LoanDeleteResponse? {
        requestType = HTTPType.DELETE
        self.loanId = loanId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        guard !data.isEmpty else {
            return LoanDeleteResponse(code: 204, message: "Loan Deleted")
        }
        let loanDeleteResponse = try JSONDecoder().decode(LoanDeleteResponse.self, from: data)
        return loanDeleteResponse
    }
}
