//
//  Employee.swift
//  RaiseMan
//
//  Created by Sebastian on 3/26/16.
//  Copyright © 2016 Sebastian. All rights reserved.
//

import Foundation

class Employee: NSObject, NSCoding {
    var name: String? = "New Employee"
    var raise: Float = 0.05
    
    //MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String?
        raise = aDecoder.decodeFloatForKey("raise")
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        if let name = name {
            aCoder.encodeObject(name, forKey: "name")
        }
        
        aCoder.encodeFloat(raise, forKey: "raise")
    }
}