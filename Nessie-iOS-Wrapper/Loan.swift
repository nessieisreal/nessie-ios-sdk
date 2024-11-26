//
//  Loan.swift
//  Nessie-iOS-Wrapper
//
//  Created by Ji,Jason on 1/30/17.
//  Copyright © 2017 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum LoanType: String {
    case auto, home, smallBusiness="small business", unknown
}

public enum LoanStatus: String {
    case pending, approved, declined, unknown
}

open class Loan: JsonParser {
    open var loanId: String
    open var type: LoanType
    open var status: LoanStatus
    open var creditScore: Int
    open var monthlyPayment: Double
    open var amount: Int
    open var creationDate: Date?
    open var description: String?
    
    public init(loanId: String, type: LoanType, status: LoanStatus, creditScore: Int, monthlyPayment: Double, amount: Int, creationDate: Date?, description: String?) {
        self.loanId = loanId
        self.type = type
        self.status = status
        self.creditScore = creditScore
        self.monthlyPayment = monthlyPayment
        self.amount = amount
        self.creationDate = creationDate
        self.description = description
    }
    
    public required init(data: JSON) {
        self.loanId = data["_id"].string ?? ""
        self.type = LoanType(rawValue: data["type"].string ?? "") ?? .unknown
        self.status = LoanStatus(rawValue: data["status"].string ?? "") ?? .unknown
        self.creditScore = data["credit_score"].int ?? 0
        self.monthlyPayment = data["monthly_payment"].double ?? 0
        self.amount = data["amount"].int ?? 0
        self.creationDate = data["creation_date"].string?.stringToDate()
        self.description = data["description"].string
    }
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
    open func getLoan(_ loanId: String, completion: @escaping (_ loan: Loan?, _ error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.loanId = loanId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                do {
                    let json = try JSON(data: data ?? Data())
                    let response = BaseResponse<Loan>(data: json)
                    completion(response.object, nil)
                } catch let error as NSError {
                    completion(nil, error)
                }
            }
        })
    }
    
    open func getLoansFromAccountId(_ accountId: String, completion: @escaping (_ loanArrays: Array<Loan>?, _ error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                do {
                    let json = try JSON(data: data ?? Data())
                    let response = BaseResponse<Loan>(data: json)
                    completion(response.requestArray, nil)
                } catch let error as NSError {
                    completion(nil, error)
                }
            }
        })
    }
    
    open func postLoan(_ newLoan: Loan, accountId: String, completion: @escaping (_ loanResponse: BaseResponse<Loan>?, _ error: NSError?) -> Void) {
        requestType = HTTPType.POST
        self.accountId = accountId
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        var params: Dictionary<String, Any> = ["type": newLoan.type.rawValue,
                                               "status": newLoan.status.rawValue,
                                               "credit_score": newLoan.creditScore,
                                               "monthly_payment": newLoan.monthlyPayment,
                                               "amount": newLoan.amount]

        if let description = newLoan.description {
            params["description"] = description
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch let error as NSError {
            request.httpBody = nil
            completion(nil, error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                do {
                    let json = try JSON(data: data ?? Data())
                    let response = BaseResponse<Loan>(data: json)
                    completion(response, nil)
                } catch let error as NSError {
                    completion(nil, error)
                }
            }
        })
    }
    
    open func putLoan(_ updatedLoan: Loan, completion: @escaping (_ loanResponse: BaseResponse<Loan>?, _ error: NSError?) -> Void) {
        requestType = HTTPType.PUT
        loanId = updatedLoan.loanId
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        var params: Dictionary<String, Any> = ["type": updatedLoan.type.rawValue,
                                               "status": updatedLoan.status.rawValue,
                                               "credit_score": updatedLoan.creditScore,
                                               "monthly_payment": updatedLoan.monthlyPayment,
                                               "amount": updatedLoan.amount]
        
        if let description = updatedLoan.description {
            params["description"] = description
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch let error as NSError {
            request.httpBody = nil
            completion(nil, error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                do {
                    let json = try JSON(data: data ?? Data())
                    let response = BaseResponse<Loan>(data: json)
                    completion(response, nil)
                } catch let error as NSError {
                    completion(nil, error)
                }
            }
        })
    }
    
    open func deleteLoan(_ loanId: String, completion: @escaping (_ loanResponse: BaseResponse<Loan>?, _ error: NSError?) -> Void) {
        requestType = HTTPType.DELETE
        self.loanId = loanId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                let response = BaseResponse<Loan>(requestArray: nil, object: nil, message: "Loan deleted")
                completion(response, nil)
            }
        })
    }
}
