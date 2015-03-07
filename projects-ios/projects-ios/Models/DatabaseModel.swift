//
//  DatabaseModel.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 23/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import Realm

class Episode: RLMObject {
    
    dynamic var seasonNumber = 0
    dynamic var episodeNumber = 0
    dynamic var name = "Name"
    dynamic var episodeDescription = "Description"
    dynamic var tvdb_id = "id"
    dynamic var imdb_id = "id"
    
    dynamic var airdate: NSDate = NSDate(timeIntervalSinceNow: 0)
    
    dynamic var watched = false
    
    dynamic var show: Show = Show()
    
    override init(){
        super.init()
    }
    init(traktEpisode: TraktEpisode, show: Show){
        super.init()
        self.seasonNumber = traktEpisode.seasonNumber
        self.episodeNumber = traktEpisode.episodeNumber
        self.name = traktEpisode.name
        self.episodeDescription = traktEpisode.description
        self.tvdb_id = traktEpisode.tvdb_id
        self.imdb_id = traktEpisode.imdb_id
        self.airdate = traktEpisode.airdate? ?? NSDate(timeIntervalSinceNow: 0)
        self.show = show
    }
}

class Show: RLMObject {
    
    dynamic var imdb_id = "id"
    dynamic var tvdb_id = "id"
    dynamic var name = "Name"
    dynamic var showDescription = "Description"
    dynamic var releaseYear = "2013"
    dynamic var posterURL = ""
    dynamic var fanartURL = ""
    
    //Remaining data
    dynamic var runtime = 0
    dynamic var network: String = ""
    dynamic var status: String = ""
    
    dynamic var addedDate = NSDate(timeIntervalSince1970: 0)
    dynamic var episodes = RLMArray(objectClassName: Episode.className())

    override init(){
        super.init()
    }
    init(traktShow: TraktShow) {
        super.init()
        self.tvdb_id = traktShow.tvdb_id
        self.imdb_id = traktShow.imdb_id
        self.name = traktShow.name
        self.showDescription = traktShow.description
        self.releaseYear = traktShow.releaseYear
        self.posterURL = traktShow.posterURL
        self.fanartURL = traktShow.fanartURL
        self.runtime = traktShow.runtime? ?? 0
        self.network = traktShow.network? ?? ""
        self.status = traktShow.status? ?? ""
        self.addedDate = NSDate(timeIntervalSinceNow: 0)
        
        if let eps = traktShow.episodes {
            for ep in eps {
                self.episodes.addObject(Episode(traktEpisode: ep, show: self))
            }
        }
    }
}

class AccessToken: RLMObject {
    
    dynamic var token = ""
    dynamic var expires = 0
    dynamic var refreshToken = ""
    
    override init(){
        super.init()
    }
    
    init(trakt: TraktAccessToken) {
        super.init()
        self.token = trakt.token
        self.expires = trakt.expires
        self.refreshToken = trakt.refreshToken
    }
}

class PopcornConfig: RLMObject {
    
    dynamic var ip = ""
    dynamic var port = ""
    dynamic var username = ""
    dynamic var password = ""
    
    override init(){
        super.init()
    }
    init(ip: String, port: String, user: String, pass: String){
        
        super.init()
        self.ip = ip
        self.port = port
        self.username = user
        self.password = pass
    }
}