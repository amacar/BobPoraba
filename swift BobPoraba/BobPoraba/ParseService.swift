//
//  ParseService.swift
//  BobPoraba
//
//  Created by Amadej Pevec on 10. 11. 16.
//  Copyright © 2016 Amadej Pevec. All rights reserved.
//

import Foundation

class ParseService {
    
    public func parseUsage(data: Data?) throws -> [UsageProperty]{
        var usageList = [UsageProperty]()
		
		guard let data = data else { throw ParseErrors.NotFound }
		
		var json : Any?
		do {
			json = try JSONSerialization.jsonObject(with: data, options: [])
		} catch {
			throw ParseErrors.NotFound
		}
		
		guard let rootObject = json as? [String : Any],
			let quickUsageViewModel = rootObject["quickUsageViewModel"] as? [String : Any],
			let quickUsageModels = quickUsageViewModel["quickUsageModels"] as? [Any], quickUsageModels.count > 0,
			let quickUsageModel = quickUsageModels[0] as? [String : Any],
			let quickUsages = quickUsageModel["quickUsages"] as? [Dictionary<String, Any>],
			let overviewUsagesKeys = quickUsageModel["overviewUsagesKeys"] as? [String] else {
			throw ParseErrors.NotFound
		}
		
		for usageKey in overviewUsagesKeys {
			if let usageProperty = parseUsageProperty(key: usageKey, quickUsages: quickUsages) {
				usageList.append(usageProperty)
			}
		}
		
        return usageList
    }
    
	private func parseUsageProperty(key: String, quickUsages: [Dictionary<String, Any>]) -> UsageProperty? {
		var usageDict : Dictionary<String, Any>?
		var limitDict : Dictionary<String, Any>?
		
		for dict in quickUsages {
			if let dictKey = dict["key"] as? String {
				if dictKey == key {
					usageDict = dict
				} else if dictKey == "fu_\(key)" {
					limitDict = dict
				}
				if usageDict != nil && limitDict != nil {
					break
				}
			}
		}
		
		guard let usage = usageDict, let limit = limitDict else {
			return nil
		}
		
		guard let label = usage["characteristicDescription"] as? String,
			let usageValue = usage["value"] as? Double,
			let usageUnit = usage["unit"] as? String,
			let limitValue = limit["value"] as? Double,
			let limitUnit = limit["unit"] as? String else {
				return nil
		}
		
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = 2
		
		var usageValueString = String(format: "%.0f", usageValue)
		var usageUnitString = usageUnit
		
		var limitValueString = String(format: "%.0f", limitValue)
		var limitUnitString = limitUnit
		
		if usageUnit == "MB" && usageValue > 1024 {
			let usageValueGb = usageValue / 1024
			formatter.minimumFractionDigits = usageValueGb > 10 ? 0 : 2
			usageValueString = formatter.string(from: NSNumber(value: usageValueGb))!
			usageUnitString = "GB"
		}
		
		if limitUnit == "MB" && limitValue > 1024 {
			let limitValueGb = limitValue / 1024
			formatter.minimumFractionDigits = limitValueGb > 10 ? 0 : 2
			limitValueString = formatter.string(from: NSNumber(value: limitValueGb))!
			limitUnitString = "GB"
		}
		
		return UsageProperty(label: label, value: "\(usageValueString) \(usageUnitString) od \(limitValueString) \(limitUnitString)")
    }
}
