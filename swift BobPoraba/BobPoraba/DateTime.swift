//
//  DateStamp.swift
//  BobPoraba
//
//  Created by Amadej Pevec on 12. 11. 16.
//  Copyright © 2016 Amadej Pevec. All rights reserved.
//

import Foundation

class DateTime: NSObject, NSCoding {
    
    private static let dateTimeKey = "dateTime"
    static let classKey = "datetime"
    
    private var datetime: Date
    
    init(datetime: Date) {
        self.datetime = datetime
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(datetime, forKey: DateTime.dateTimeKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.datetime = aDecoder.decodeObject(forKey: DateTime.dateTimeKey) as! Date
    }
    
    //getters
    func getDateTime() -> Date {
        return self.datetime
    }
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "sl_SI")
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return "osveženo: " + dateFormatter.string(from: self.datetime)
    }
}
