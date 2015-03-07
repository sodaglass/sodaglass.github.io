//
//  TraktModel.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 22/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import Foundation

class TraktAccessToken {
    let token, refreshToken: String
    let expires: Int
    
    init(json: JSON) {
        self.token = json["access_token"].stringValue ?? "wat"
        self.refreshToken = json["refresh_token"].stringValue ?? ""
        self.expires = json["expires_in"].intValue ?? 0
    }
    init(token: String){
        self.token = token
        self.refreshToken = ""
        self.expires = 0
    }
}

class TraktEpisode {
    
    let seasonNumber, episodeNumber: Int
    let name, description: String
    let tvdb_id, imdb_id: String
    let airdate: NSDate?
    
    init(json: JSON){
        
        self.imdb_id = json["ids"]["imdb"].stringValue ?? "id"
        self.tvdb_id = json["ids"]["tvdb"].stringValue ?? "id"
        self.name = json["title"].stringValue ?? "Show"
        self.description = json["overview"].stringValue ?? "Description"
        self.seasonNumber = json["season"].intValue ?? 0
        self.episodeNumber = json["number"].intValue ?? 0
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        self.airdate = formatter.dateFromString(json["first_aired"].stringValue)
    }
}

class TraktShow {
    
    //Data available on search
    let imdb_id, tvdb_id: String
    let name, description, releaseYear: String
    let posterURL, fanartURL: String
    
    //Remaining data
    let runtime: Int?
    let network: String?
    let status: String?
    
    var episodes: [TraktEpisode]?
    
    init(json: JSON) {
        
        self.imdb_id = json["ids"]["imdb"].stringValue ?? "id"
        self.tvdb_id = json["ids"]["tvdb"].stringValue ?? "id"
        self.name = json["title"].stringValue ?? "Show"
        self.description = json["overview"].stringValue ?? "Description"
        self.releaseYear = String(json["year"].intValue ?? 0)
        self.posterURL = json["images"]["poster"]["medium"].stringValue ?? "http://www.smashingmagazine.com/images/404-error-pages/simp.gif"
        self.fanartURL = json["images"]["fanart"]["medium"].stringValue ?? "http://www.smashingmagazine.com/images/404-error-pages/simp.gif"
        
        self.runtime = json["runtime"].int
        self.network = json["network"].string
        self.status = json["status"].string
    }
}