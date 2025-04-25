//
//  EnterpriseRequests.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 9/15/16.
//  Copyright (c) 2016 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol Enterprise {
    var id: String? { get }
    var urlName: String { get }
    func buildRequestUrl() -> String
}

extension Enterprise {
    func buildRequestUrl() -> String {
        var requestString = "\(baseEnterpriseString)\(urlName)"
        if let id = id {
            requestString += "/\(id)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        return requestString
    }
}

public struct EnterpriseAccountResponse: Decodable {
    public var results: [Account]
}

public struct EnterpriseAccountRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "accounts"
    
    public init () {}
    
    public func getAccounts() async throws -> EnterpriseAccountResponse? {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let enterpriseAccountResponse = try JSONDecoder().decode(EnterpriseAccountResponse.self, from: data)
        return enterpriseAccountResponse
    }
    
    public mutating func getAccount(_ accountId: String) async throws -> Account? {
        self.id = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let account = try JSONDecoder().decode(Account.self, from: data)
        return account
    }
}

public struct EnterpriseBillResponse: Decodable {
    public var results: [Bill]
}

public struct EnterpriseBillRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "bills"
    
    public init () {}
    
    public func getBills() async throws -> EnterpriseBillResponse? {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let enterpriseBillResponse = try JSONDecoder().decode(EnterpriseBillResponse.self, from: data)
        return enterpriseBillResponse
    }
    
    public mutating func getBill(_ bilId: String) async throws -> Bill? {
        self.id = bilId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        guard let data = try await nseClient.loadDataFromURL(request) else { return nil }
        let bill = try JSONDecoder().decode(Bill.self, from: data)
        return bill
    }
}

public struct EnterpriseCustomerRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "customers"
    
    public init () {}
    
    public func getCustomers(_ completion:@escaping (_ customersArray: Array<Customer>?, _ error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                guard let data = data else {
                    completion(nil, genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Customer>(data: json)
                completion(response.requestArray, nil)
            }
        })
    }
    
    public mutating func getCustomer(_ bilId: String, completion: @escaping (_ customer: Customer?, _ error: NSError?) -> Void) {
        self.id = bilId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Customer>(data: json)
                completion(response.object, nil)
            }
        })
    }
}

public struct EnterpriseDepositRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "deposits"
    
    public init () {}
    
    public func getDeposits(_ completion:@escaping (_ depositsArray: Array<Deposit>?, _ error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                guard let data = data else {
                    completion(nil, genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Deposit>(data: json)
                completion(response.requestArray, nil)
            }
        })
    }
    
    public mutating func getDeposit(_ bilId: String, completion: @escaping (_ customer: Deposit?, _ error: NSError?) -> Void) {
        self.id = bilId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Deposit>(data: json)
                completion(response.object, nil)
            }
        })
    }
}

public struct EnterpriseMerchantRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "merchants"
    
    public init () {}
    
    public func getMerchants(_ completion:@escaping (_ merchantsArray: Array<Merchant>?, _ error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                guard let data = data else {
                    completion(nil, genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Merchant>(data: json)
                completion(response.requestArray, nil)
            }
        })
    }
    
    public mutating func getMerchant(_ bilId: String, completion: @escaping (_ customer: Merchant?, _ error: NSError?) -> Void) {
        self.id = bilId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Merchant>(data: json)
                completion(response.object, nil)
            }
        })
    }
}

public struct EnterpriseTransferRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "transfers"
    
    public init () {}
    
    public func getTransfers(_ completion:@escaping (_ transfersArray: Array<Transfer>?, _ error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                guard let data = data else {
                    completion(nil, genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Transfer>(data: json)
                completion(response.requestArray, nil)
            }
        })
    }
    
    public mutating func getTransfer(_ bilId: String, completion: @escaping (_ customer: Transfer?, _ error: NSError?) -> Void) {
        self.id = bilId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Transfer>(data: json)
                completion(response.object, nil)
            }
        })
    }
}

public struct EnterpriseWithdrawalRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "withdrawals"
    
    public init () {}
    
    public func getWithdrawals(_ completion:@escaping (_ withdrawalsArray: Array<Withdrawal>?, _ error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                guard let data = data else {
                    completion(nil, genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Withdrawal>(data: json)
                completion(response.requestArray, nil)
            }
        })
    }
    
    public mutating func getWithdrawal(_ bilId: String, completion: @escaping (_ customer: Withdrawal?, _ error: NSError?) -> Void) {
        self.id = bilId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Withdrawal>(data: json)
                completion(response.object, nil)
            }
        })
    }
}
