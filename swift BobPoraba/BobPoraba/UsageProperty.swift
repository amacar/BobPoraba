//
//  UsageProperty.swift
//  BobPoraba
//
//  Created by Amadej Pevec on 10. 11. 16.
//  Copyright © 2016 Amadej Pevec. All rights reserved.
//
import Foundation

class UsageProperty: NSObject, NSCoding {
    
    private static let labelKey = "label"
    private static let valueKey = "value"
    static let classKey = "usageProperty"
    
    private var label: String = ""
    private var value: String = ""

    init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(label, forKey: UsageProperty.labelKey)
        aCoder.encode(value, forKey: UsageProperty.valueKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.label = aDecoder.decodeObject(forKey: UsageProperty.labelKey) as! String
        self.value = aDecoder.decodeObject(forKey: UsageProperty.valueKey) as! String
    }
    
    //getters
    func getLabel() -> String {
        return self.label
    }
    func getValue() -> String {
        return self.value
    }
}
