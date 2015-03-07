//
//  PopcornAPIService.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 21/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import Alamofire

class PopcornAPIService {
    
    let api_base = "http://api.popcorntime.io"
    
    private func request(path: String, callback: JSONCallback) {
        var r = Alamofire.request(.GET, "\(api_base)\(path)").responseSwiftyJSON { (_, _, json, error) -> Void in
            
            if error != nil {
                callback(.Error(error!))
            } else {
                callback(.Success(json))
            }
        }
        debugPrintln(r)
    }
    
    class func getShowTorrents(imdb_id: String, callback: (Response<PopcornAPIShow>) -> ()) {
        
        PopcornAPIService().request("/show/\(imdb_id)", callback: callback --> {
            json in
            return PopcornAPIShow(json: json)
        })
    }
}