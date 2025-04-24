//
//  Account.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum AccountType: String, Decodable, Encodable {
    case CreditCard = "Credit Card"
    case Savings
    case Checking
    case Unknown = ""
}

public struct Account: Decodable, JsonParser {
    public init(data: SwiftyJSON.JSON) {
        self.accountId = ""
        self.accountType = .Checking
        self.nickname = ""
        self.rewards = 1
        self.balance = 1
        self.accountNumber = ""
        self.customerId = ""
    }
    
    public var accountId: String
    public var accountType: AccountType
    public var nickname: String
    public var rewards: Int
    public var balance: Int
    public var accountNumber: String
    public var customerId: String
    
    public init(accountId: String, accountType: AccountType, nickname: String, rewards: Int, balance: Int, accountNumber: String, customerId: String) {
        self.accountId = accountId
        self.accountType = accountType
        self.nickname = nickname
        self.rewards = rewards
        self.balance = balance
        self.accountNumber = accountNumber
        self.customerId = customerId
    }
    
    enum CodingKeys: String, CodingKey {
        case nickname, rewards, balance

        case accountId = "_id"
        case accountType = "type"
        case accountNumber = "account_number"
        case customerId = "customer_id"
    }
}

public struct AccountPostData: Codable {
    public var accountType: AccountType
    public var nickname: String
    public var rewards: Int
    public var balance: Int
    public var accountNumber: String
    
    enum CodingKeys: String, CodingKey {
        case nickname, rewards, balance
        case accountType = "type"
        case accountNumber = "account_number"
    }
}

public struct AccountPostResponse: Decodable {
    public var code: Int
    public var message: String
    public var culprit: [String]?
    public var objectCreated: Account?
}

public struct AccountPutData: Codable {
    public var nickname: String
    public var accountNumber: String
    
    enum CodingKeys: String, CodingKey {
        case nickname
        case accountNumber = "account_number"
    }
}

public struct AccountPutResponse: Decodable {
    public var code: Int
    public var message: String
    public var culprit: [String]?
}

public struct AccountDeleteResponse: Decodable {
    public var code: Int
    public var message: String
}

open class AccountRequest {
    fileprivate var requestType: HTTPType!
    fileprivate var accountId: String?
    fileprivate var accountType: AccountType?
    fileprivate var customerId: String?
    
    public init () {}

    fileprivate func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/accounts"
        if let accountId = accountId {
            requestString += "/\(accountId)"
        }
        
        if let customerId = customerId {
            requestString = "\(baseString)/customers/\(customerId)/accounts"
        }
        
        if (self.requestType == HTTPType.POST) {
            requestString = "\(baseString)/customers/\(self.customerId!)/accounts"
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
    open func getAccounts(_ accountType: AccountType?) async throws -> [Account]? {
        requestType = HTTPType.GET
        self.accountType = accountType
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let accounts = try JSONDecoder().decode([Account].self, from: data)
        return accounts
    }

    open func getAccount(_ accountId: String) async throws -> Account? {
        self.requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let account = try JSONDecoder().decode(Account.self, from: data)
        return account
    }

    open func getCustomerAccounts(_ customerId: String) async throws -> [Account]? {
        self.requestType = HTTPType.GET
        self.customerId = customerId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let customerAccounts = try JSONDecoder().decode([Account].self, from: data)
        return customerAccounts
    }

    open func postAccount(_ newAccount: Account) async throws -> AccountPostResponse? {
        self.requestType = HTTPType.POST
        self.customerId = newAccount.customerId
        
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        var accountPostData = AccountPostData(accountType: newAccount.accountType, nickname: newAccount.nickname, rewards: newAccount.rewards, balance: newAccount.balance, accountNumber: newAccount.accountNumber)
        
        do {
            request.httpBody = try JSONEncoder().encode(accountPostData)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let accountPostResponse = try JSONDecoder().decode(AccountPostResponse.self, from: data)
        return accountPostResponse
    }

    open func putAccount(_ accountId: String, nickname: String, accountNumber: String) async throws -> AccountPutResponse? {
        self.requestType = HTTPType.PUT
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        var request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        var accountPutData = AccountPutData(nickname: nickname, accountNumber: accountNumber)
        
        do {
            request.httpBody = try JSONEncoder().encode(accountPutData)
        } catch let error as NSError {
            throw error
        }
        
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let accountPutResponse = try JSONDecoder().decode(AccountPutResponse.self, from: data)
        return accountPutResponse
    }
    
    open func deleteAccount(_ accountId: String) async throws -> AccountDeleteResponse? {
        self.requestType = HTTPType.DELETE
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        guard !data.isEmpty else {
            return AccountDeleteResponse(code: 204, message: "Account Deleted")
        }
        let accountDeleteResponse = try JSONDecoder().decode(AccountDeleteResponse.self, from: data)
        return accountDeleteResponse
    }
}
