//
//  PersistService.swift
//  BobPoraba
//
//  Created by Amadej Pevec on 12. 11. 16.
//  Copyright © 2016 Amadej Pevec. All rights reserved.
//
import Foundation

class PersistService {
    
    public func saveObject<T>(object: T, saveKey: String) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: object)
        UserDefaults.standard.set(encodedData, forKey: saveKey)
    }
    
    public func getObject<T>(key: String) -> T? {
        if let data = UserDefaults.standard.data(forKey: key), let object = NSKeyedUnarchiver.unarchiveObject(with: data) {
            return object as? T
        }
        
        return nil
    }
}
