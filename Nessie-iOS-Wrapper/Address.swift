//
//  Address.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 5/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Geocode: Codable {
    let lng: Float
    let lat: Float

    public init(lng: Float, lat: Float) {
        self.lng = lng
        self.lat = lat
    }
}

public struct Address: Codable {
    public let streetNumber:String
    public let streetName:String
    public let city:String
    public let state:String
    public let zipCode:String
    
    public init(streetName:String, streetNumber:String, city:String, state:String, zipCode:String) {
        self.streetName = streetName
        self.streetNumber = streetNumber
        self.city = city
        self.state = state
        self.zipCode = zipCode
    }
    
    enum CodingKeys: String, CodingKey {
        case city, state

        case streetName = "street_name"
        case streetNumber = "street_number"
        case zipCode = "zip"
    }
    
    internal func toDict() -> Dictionary<String,AnyObject> {
        let dict = ["street_name":streetName,"street_number":streetNumber,"state":state, "city":city, "zip":zipCode]
        return dict as Dictionary<String, AnyObject>
    }
}
