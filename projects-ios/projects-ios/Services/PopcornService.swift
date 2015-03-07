//
//  PopcornService.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 20/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import Alamofire

class PopcornService {
    
    var config: PopcornConfig? {
        didSet {
            let authHeader = "\(self.config!.username):\(self.config!.password)"
            
            self.manager.session.configuration.HTTPAdditionalHeaders = ["Authorization":authHeader.base64Encoded()]
        }
    }
    
    private var manager = Alamofire.Manager()
    
    class func sharedService() -> PopcornService {
        return _popcorninstance
    }
    
    private func JSONRPCcall(method: String, parameters: AnyObject, callback: JSONCallback) {
        
        if self.config != nil {
            
            var params: [String: AnyObject] = ["method":method, "params": parameters, "id":1]
            let url = "http://\(self.config!.ip):\(self.config!.port)"
            
            var r = manager.request(.POST, url, parameters: params, encoding: .JSON)
                .responseSwiftyJSON({ (req, res, json, error) -> Void in
                    
                    if error != nil {
                        
                        callback(.Error(error!))
                    } else if let code = json["error"]["code"].int {
                        
                        var message = "error"
                        if let mes = json["error"]["message"].string {
                            message = mes
                        }
                        
                        callback(.Error(NSError(domain: message, code: code, userInfo: nil)))
                        
                    } else {
                    
                        callback(.Success(json["result"]))
                    }
            })
            
            debugPrintln(r)
            
        } else {
            
            callback(.Error(NSError(domain: "Popcorn config not existent", code: 202, userInfo: nil)))
        }
       
    }
    
    func ping(callback: JSONCallback) {
        return JSONRPCcall("ping", parameters: [], callback: callback)
    }
    
    func togglePlaying(callback: JSONCallback) {
        return JSONRPCcall("toggleplaying", parameters: [], callback: callback)
    }
    
    func getPlaying(callback: (Response<PopcornPlay>) -> ()) {
        return JSONRPCcall("getplaying", parameters: [], callback: callback --> {
            json in
            return PopcornPlay(json: json)
        })
    }
    
    //Name format: "Homeland - Season 1, Episode 05 - Blind Spot"
    func startStream(magnet: String, imdbid: String, name:String, callback: JSONCallback) {
        return JSONRPCcall("startstream", parameters: ["imdb_id":imdbid, "torrent_url": magnet, "backdrop":"http://zumodecaos.files.wordpress.com/2009/11/2wow-logo2800-med.jpg", "subtitle":"", "selected_subtitle":"","title":name,"quality":"720p", "type":"tvshow"], callback: callback)
    }
    
    func getPlayers(callback: JSONCallback) {
        return JSONRPCcall("getplayers", parameters: [], callback: callback)
    }

}

let _popcorninstance: PopcornService = {
    return PopcornService()
}()
