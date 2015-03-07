//
//  TraktService.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 22/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import Alamofire
import UIKit

class TraktService {
    
    private let api_base = "https://api.v2.trakt.tv"
    private let oauth_client_id = "05a3bfb8b06a315486b748ef461650c507f2e7bf80bac25108b29e42a06a76fa"
    private let oauth_client_secret = "c58b44fa302c3ed0ec8c0dc7ea27c3c2e22a33b5d8dceac97b9dd21274b908f6"
    internal let oauth_callback = "project-s://oauth/trakt"
    private var oauth_cb: ((Response<TraktAccessToken>) -> ())?
    internal var accessToken: TraktAccessToken? {
        didSet {
            self.manager.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Bearer \(self.accessToken!.token)"] + (self.manager.session.configuration.HTTPAdditionalHeaders? ?? [:])
        }
    }
    
    private var manager = Alamofire.Manager()
    
    init() {
        
        self.manager.session.configuration.HTTPAdditionalHeaders = ["trakt-api-version":"2", "trakt-api-key":self.oauth_client_id, "Content-type":"application/json"] + (self.manager.session.configuration.HTTPAdditionalHeaders? ?? [:])
    }
    
    class func sharedService() -> TraktService {
        return _traktinstance
    }
    
    
    private func getAccessToken(code: String, grantType: String = "authorization_code", callback: (Response<TraktAccessToken>) -> ()) {
        
        var r = Alamofire.request(.POST, "\(self.api_base)/oauth/token", parameters: ["code":code, "client_id": self.oauth_client_id, "client_secret": self.oauth_client_secret, "redirect_uri":self.oauth_callback, "grant_type": grantType], encoding: .JSON).responseSwiftyJSON { (_, _, json, err) -> Void in

            if err != nil {
                callback(.Error(err!))
            } else if json["error"] != nil {
                callback(.Error(NSError(domain: json["error"].stringValue, code: 401, userInfo: ["description": json["error_description"].stringValue ?? "Code error"])))
            } else {
                
                callback(.Success(TraktAccessToken(json: json)))
            }
        }
        
        debugPrintln(r)
    }
    
    func authenticatedRequest(method: Alamofire.Method, path: String, params: [String:AnyObject]?, callback: JSONCallback) {
        
        if let token = self.accessToken?.token {
            
            var encoding = Alamofire.ParameterEncoding.JSON
            if method == .GET {
                encoding = .URL
            }
            var r = self.manager.request(method, "\(self.api_base)\(path)", parameters: params, encoding: encoding).responseSwiftyJSON({ (_, _, json, err) -> Void in
               
                if err != nil {
                    callback(.Error(err!))
                } else if json["error"] != nil {
                    callback(.Error(NSError(domain: json["error"].stringValue, code: 401, userInfo: ["description":json["error_description"].stringValue ?? "Code error"])))
                } else {
                    
                    callback(.Success(json))
                }

            })
            debugPrintln(r)
        } else {
            callback(.Error(NSError(domain: "Unauthorized request", code: 403, userInfo: nil)))
        }
    }
    
    func oauth(callback: (Response<TraktAccessToken>) -> ()) {
        self.oauth_cb = callback
        
        let params = ["response_type":"code", "client_id": self.oauth_client_id, "redirect_uri":self.oauth_callback]
        UIApplication.sharedApplication().openURL(NSURL(string: "\(self.api_base)/oauth/authorize?\(urlquery(params))")!)
    }
    
    func handleOauthURL(url: NSURL) {
        
        if let q = url.query {
            if let code = parseQuery(q)["code"] {
                return self.getAccessToken(code, callback: self.oauth_cb! --> {
                    token in
                    
                    self.accessToken = token
                    return token
                })
            }
        }
        
        oauth_cb?(.Error(NSError(domain: "Didn't get auth code", code: 202, userInfo: nil)))
    }
    
    func search(query: String, callback:(Response<[TraktShow]>) -> ()){
        
        return self.authenticatedRequest(.GET, path: "/search", params: ["query":query, "type":"show"], callback: callback --> {
            json in
            
            var array = [TraktShow]()
            for js in json.arrayValue {
                array.append(TraktShow(json: js["show"]))
            }
            return array
        })
    }
    
    func getSeason(showid: String, seasonNumber: String, callback: (Response<[TraktEpisode]>) -> ()) {
        
        return self.authenticatedRequest(.GET, path: "/shows/\(showid)/seasons/\(seasonNumber)", params: ["extended":"full"], callback: callback --> {
            
            json in
            
            var array = [TraktEpisode]()
            for js in json.arrayValue {
                array.append(TraktEpisode(json: js))
            }
            return array
            
            })
    }
    func getShow(id: String, callback:(Response<TraktShow>) -> ()) {
        
        return self.authenticatedRequest(.GET, path: "/shows/\(id)", params: ["extended":"full,images"]) { (js) -> () in
            
            switch js {
                
            case .Error(let e):
                callback(.Error(e))
                return
            case .Success(let show):
                self.authenticatedRequest(.GET, path: "/shows/\(id)/seasons", params: ["extended":"full"]) {
                    json in
                    
                    switch json {
                        
                    case .Success(let j):
                        
                        var seasons: [String] = j().arrayValue.map({j in return String(j["number"].intValue)})
                        mapParallel(seasons, {v, cb in self.getSeason(id, seasonNumber: v, callback: cb)}) {
                            bs in
                            
                            var arr = [TraktEpisode]()
                            for b in bs {
                                switch b {
                                case .Error(let e):
                                    callback(.Error(e))
                                    return
                                    
                                case .Success(let eps):
                                    arr += eps()
                                }
                            }
                            
                            let s = TraktShow(json: show())
                            s.episodes = arr
                            callback(.Success(s))
                        }
                        
                    case .Error(let error):
                        callback(.Error(error))
                        
                    }
                }
            }
        }
    }
}

let _traktinstance: TraktService = {
    return TraktService()
}()