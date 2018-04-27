//
//  FetchService.swift
//  BobPoraba
//
//  Created by Amadej Pevec on 10. 11. 16.
//  Copyright © 2016 Amadej Pevec. All rights reserved.
//

import Alamofire

class FetchService {
    
    public func getUsage(username: String, password: String, completionHandler : @escaping ((_ usage : Data?) -> Void)) {
        
        Alamofire.request("https://moj.bob.si/").validate(statusCode: 200..<303).responseString{ response in
            
            if response.result.isFailure {
                completionHandler(nil)
                return
            }
            
            let content = response.result.value
            //already logged in
            if content?.index(of: "moje razmerje") != nil {
                Alamofire.request("https://moj.bob.si/Home/GetUsageData").validate(statusCode: 200..<303).responseString{ response in
                    
                    if response.result.isFailure {
                        completionHandler(nil)
                        return
                    }

                    completionHandler(response.data)
                }
            } else if content?.index(of: "seja je potekla") != nil { //session expired
                Alamofire.request("https://moj.bob.si/").validate(statusCode: 200..<303).responseString{ response in
                    
                    if response.result.isFailure {
                        completionHandler(nil)
                        return
                    }
                    
                    let content = response.result.value
                    self.login(username: username, password: password, content: content!)  {(usage) -> Void in
                        completionHandler(usage)
                    }
                }
            } else { //normal login
                self.login(username: username, password: password, content: content!)  {(usage) -> Void in
                    completionHandler(usage)
                }
            }
        }
    }
    
    private func login(username: String, password: String, content: String, completionHandler : @escaping ((_ content : Data?) -> Void)) {
        
        var parameters: Parameters = [
            "UserName": username,
            "Password": password,
            "IsSamlLogin": "False",
            "InternalBackUrl": "",
            "IsPopUp": "True",
        ]
        
        do {
            let token = try self.getHiddenInput(content: content, inputName: "__RequestVerificationToken")
            parameters["__RequestVerificationToken"] = token
        } catch {
            completionHandler(nil)
            return
        }
        
        Alamofire.request("https://prijava.bob.si/SSO/Login/Login", method: .post, parameters: parameters).validate(statusCode: 200..<303).responseString{ response in
            
            if response.result.isFailure {
                completionHandler(nil)
                return
            }
            
            Alamofire.request("https://moj.bob.si/").validate(statusCode: 200..<303).responseString{ response in
                
                if response.result.isFailure {
                    completionHandler(nil)
                    return
                }
                
                let content = response.result.value
                
                var parameters: Parameters = [:]
                
                do {
                    let authTicket = try self.getHiddenInput(content: content!, inputName: "authTicket")
                    let subscriberService = try self.getHiddenInput(content: content!, inputName: "subscriberService")
                    parameters["authTicket"] = authTicket
                    parameters["subscriberService"] = subscriberService
                } catch {
                    completionHandler(nil)
                    return
                }
                
                Alamofire.request("https://moj.bob.si/ssologin?returnUrl=/", method: .post, parameters: parameters).validate(statusCode: 200..<303).responseString{ response in
                    
                    if response.result.isFailure {
                        completionHandler(nil)
                        return
                    }
					
					Alamofire.request("https://moj.bob.si/Home/GetUsageData", method: .get, parameters: nil).validate(statusCode: 200..<303).responseString{ response in
						
						if response.result.isFailure {
							completionHandler(nil)
							return
						}
						
						completionHandler(response.data)
					}
                }
            }
            
        }
    }
    
    private func getHiddenInput(content: String, inputName: String) throws -> String {
        guard var index = content.index(of: inputName) else { throw ParseErrors.NotFound}
        var input = content.substring(from: index)
        index = input.index(input.index(of: "value")!, offsetBy: 7)
        input = input.substring(from: index)
        input = input.substring(to: input.index(of: "\"")!)
        
        return input
    }
}
