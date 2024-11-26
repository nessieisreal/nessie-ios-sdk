//
//  NSEClient.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 4/3/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum HTTPType: String {
    case GET
    case POST
    case PUT
    case DELETE
}

internal let baseString = "http://api.reimaginebanking.com"
internal let baseEnterpriseString = "\(baseString)/enterprise/"
internal var dateFormatter = DateFormatter()
internal let genericError = NSError(domain:"com.nessie", code:0, userInfo:[NSLocalizedDescriptionKey : "Error", NSLocalizedFailureReasonErrorKey : "No description"])

open class NSEClient {
    
    public static var sharedInstance = NSEClient()
    
    fileprivate var key = ""
    
    open func getKey() -> String {
        if key == "" {
            print("Attempting to get unset key. Don't forget to set the key before sending requests!")
        }
        return key;
    }
    
    open func setKey(_ key:String) {
        self.key = key
    }
    
    fileprivate init() {
        dateFormatter.dateFormat = "yyyy-dd-MM"
    }
    
    open func buildRequest(_ requestType: HTTPType, url: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = requestType.rawValue
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request
    }
    
    open func makeRequest(_ requestUrl: String, requestType: HTTPType) -> NSMutableURLRequest {
        let requestString = requestUrl
        let nseClient = NSEClient.sharedInstance
        
        let request = nseClient.buildRequest(requestType, url: requestString)
        return request
    }
    
    open func loadDataFromURL(_ request: NSMutableURLRequest, completion:@escaping (_ data: Data?, _ error: NSError?) -> Void) {
        let session = URLSession.shared
        
        // Use NSURLSession to get data from an NSURL
        let loadDataTask = session.dataTask(with: request as URLRequest) { data, response, error in
            if let responseError = error as NSError? {
                completion(nil, responseError)
            } else if let httpResponse = response as? HTTPURLResponse {
                if (200 ... 299 ~= httpResponse.statusCode) {
                    completion(data, nil)
                } else {
                    do {
                        let json = try JSON(data: data ?? Data())
                        let errorMessage = json["message"].string ?? "Something went wrong. Check your connection."
                        let culprit = json["culprit"].array
                        let culpritMessage: String = culprit?.first?.rawString() ?? "Unknown reason"
                        let statusError = NSError(domain:"com.nessie", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : errorMessage, NSLocalizedFailureReasonErrorKey : culpritMessage])
                        completion(nil, statusError)
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                }
            }
        }
        
        loadDataTask.resume()
    }
    
    
//**********//
    // In progress
    class func invokeService<T:Initable> (_ service: String, withParams params: Dictionary<String, String>, returningClass: T.Type, completionHandler handler: @escaping ((Initable) -> ())) {
        
        let request = NSMutableURLRequest(url: URL(string: "asd")!)
        NSEClient.sharedInstance.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                return
            } else {
                do {
                    let json = try JSON(data: data ?? Data())
                    handler(BaseClass(data: json))
                } catch let error as NSError {
                    print(error)
                }
            }
        })
    }
}

protocol Initable {
    init(data:JSON)
}

open class BaseClass: Initable {
    
    public let previuosPage: String
    public let nextPage: String
    public let requestArray: Array<AnyObject>
    
    required public init(data:JSON) {
        self.requestArray = data["data"].arrayValue.map({Atm(data:$0)})
        self.previuosPage = data["paging"]["previous"].string ?? ""
        self.nextPage = data["paging"]["next"].string ?? ""
    }
}
//**********//

open class BaseResponse<T:JsonParser> {
    
    public var requestArray: Array<T>?
    public var object: T?
    public var message: String?
    
    internal init(data: JSON) {
        if (data["data"].null == nil) {
            self.requestArray = data["data"].arrayValue.map({T(data:$0)})
        } else if (data["results"].null == nil) {
            self.requestArray = data["results"].arrayValue.map({T(data:$0)})
        } else {
            self.requestArray = data.arrayValue.map({T(data:$0)})
        }
        if (data["objectCreated"].null == nil) {
            self.object = T(data: data["objectCreated"])
        } else {
            self.object = T(data: data)
        }
        self.message = data["message"].string ?? ""
    }
    
    internal init(requestArray: Array<T>?, object: T?, message: String?) {
        self.requestArray = requestArray
        self.object = object
        self.message = message
    }
}

public protocol JsonParser {
    init (data: JSON)
}

extension String {
    func stringToDate() -> Date? {
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return Date()
        }
    }
}
