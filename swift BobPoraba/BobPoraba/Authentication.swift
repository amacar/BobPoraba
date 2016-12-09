//
//  Authentication.swift
//  BobPoraba
//
//  Created by Amadej Pevec on 12. 11. 16.
//  Copyright © 2016 Amadej Pevec. All rights reserved.
//
import Foundation

class Authentication: NSObject, NSCoding {
    
    private static let usernameKey = "username"
    private static let passwordKey = "password"
    static let classKey = "authentication"
    
    private var username: String = ""
    private var password: String = ""
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(username, forKey: Authentication.usernameKey)
        aCoder.encode(password, forKey: Authentication.passwordKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.username = aDecoder.decodeObject(forKey: Authentication.usernameKey) as! String
        self.password = aDecoder.decodeObject(forKey: Authentication.passwordKey) as! String
    }
    
    //getters
    func getUsername() -> String {
        return self.username
    }
    func getPassword() -> String {
        return self.password
    }
}
