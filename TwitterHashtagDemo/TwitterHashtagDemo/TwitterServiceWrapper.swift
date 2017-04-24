//
//  Authenticator.swift
//  TwitterHashtagDemo
//
//  Created by Mac on 4/24/17.
//  Copyright © 2017 AtulPrakash. All rights reserved.
//

import Foundation

protocol TwitterImagesDelegate{
    func finishedDownloading(_ twitterImages:TwitterImages)
    func dataNotFound()
}

open class TwitterServiceWrapper:NSObject {
    
    var delegate:TwitterImagesDelegate?
    
    // MARK:- Get Bearer Token
    func getBearerToken(_ completion:@escaping (_ bearerToken: String) ->Void) {
        
        let url = URL(string: kTwitterHostAPI);
        
        var request = URLRequest(url:url!)
        
        request.httpMethod = "POST"
        request.addValue("Basic " + getBase64EncodeString(), forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let grantType =  "grant_type=client_credentials"
        
        request.httpBody = grantType.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        URLSession.shared.dataTask(with:request) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    if let results: NSDictionary = try JSONSerialization .jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments  ) as? NSDictionary {
                        print("bearerToken = \(results)")
                        if let token = results["access_token"] as? String {
                            completion(token)
                        } else {
                            print(results["errors"] ?? "")
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            }.resume()
    }
    
    
    // MARK:- base64Encode String
    
    func getBase64EncodeString() -> String {
        
        let consumerKey = kConsumerKey.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let consumerSecretKey = kConsumerSecretKey.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let concatenateKeyAndSecret = consumerKey! + ":" + consumerSecretKey!
        
        let secretAndKeyData = concatenateKeyAndSecret.data(using: String.Encoding.ascii, allowLossyConversion: true)
        
        let base64EncodeKeyAndSecret = secretAndKeyData?.base64EncodedString(options: NSData.Base64EncodingOptions())
        
        return base64EncodeKeyAndSecret!
    }
    
    // MARK:- Service Call
    
    func getResponseForRequest(_ url:String) {
        
        getBearerToken({ (bearerToken) -> Void in
            print("Twitter URL: \(url)")
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "GET"
            
            let token = "Bearer " + bearerToken
            
            request.addValue(token, forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with:request) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    self.processResult(data!, response: response!, error: error as NSError?)
                }
            }.resume()
        })
    }
    
    // MARK:- Process results

    func processResult(_ data: Data, response:URLResponse, error: NSError?) {
        
        do {
            
            if let results: NSDictionary = try JSONSerialization .jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments  ) as? NSDictionary {
                print ("searchResult : \(results)")
                if let users = results["statuses"] as? [[String:Any]] {
                    if users.count == 0{
                        self.delegate?.dataNotFound()
                    }else{
                        for user in users {
                            if let media:NSDictionary = user["entities"] as! NSDictionary?{
                                if let imageString = media.value(forKeyPath: "media.media_url") as? NSArray {
                                    print(imageString[0])
                                    let twitterImage = TwitterImages(imageUrl: imageString[0] as! String)
                                    
                                    self.delegate?.finishedDownloading(twitterImage)
                                }
                            }
                        }
                    }
                } else {
                    print(results["errors"] ?? "")
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
 
}
