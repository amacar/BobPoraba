//
//  ParseService.swift
//  BobPoraba
//
//  Created by Amadej Pevec on 10. 11. 16.
//  Copyright © 2016 Amadej Pevec. All rights reserved.
//

class ParseService {
    
    public func parseUsage(content: String) throws -> [UsageProperty]{
        var usageList = [UsageProperty]()
        
        guard let index = content.index(of: "<table id=\"usageCounter") else { throw ParseErrors.NotFound}
        //get table
        var table = content.substring(from: index)
        table = table.substring(to: (table.index(of: "</table")!))
        
        //get tbody
        var tbody = table[table.index(of: "<tbody")!...table.index(of: "</tbody")!]
        
        //get tr and td
        var counter = 0
        while let startIndex = tbody.index(of: "<tr") {
            let endIndex = tbody.index(of: "</tr")
            let tr = tbody[startIndex...endIndex!]
            tbody = tbody.substring(from: tbody.index(endIndex!, offsetBy: 3))
            
            usageList.append(parseUsageProperty(trElement: tr, counter: counter))
            counter += 1
        }
        
        return usageList
    }
    
    private func parseUsageProperty(trElement: String, counter: Int) -> UsageProperty {
        var parsableTrELement = trElement
        var startIndex = parsableTrELement.index(of: "<td")
        var endIndex = parsableTrELement.index(of: "</td")
        let label = parsableTrELement[parsableTrELement.index(startIndex!, offsetBy: 4)...parsableTrELement.index(endIndex!, offsetBy: -1)]
        
        parsableTrELement = parsableTrELement.substring(from: parsableTrELement.index(endIndex!, offsetBy: 3))
        startIndex = parsableTrELement.index(of: "<td")
        endIndex = parsableTrELement.index(of: "</td")
        let value = parsableTrELement[parsableTrELement.index(startIndex!, offsetBy: 4)...parsableTrELement.index(endIndex!, offsetBy: -1)]
        
        var suffix = ""
        switch counter {
        case 0, 1, 2:
            suffix = "min"
            break
        case 3:
            suffix = "sms"
            break
        case 4:
            suffix = "MB"
            break
        default:
            break
        }
        
        return UsageProperty(label: label, value: value + suffix)
    }
}
