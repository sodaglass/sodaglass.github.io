//
//  PopcornAPIModel.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 21/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import Foundation

class PopcornAPITorrent {
    let quality, magnet: String
    
    init(quality: String, magnet: String) {
        self.quality = quality
        self.magnet = magnet
    }
}

class PopcornAPIEpisode {
    let tvdbid: String
    let season, episode: Int
    let torrents: [PopcornAPITorrent]
    
    init(json: JSON) {
        self.tvdbid = json["tvdb_id"].stringValue ?? ""
        self.season = json["season"].intValue ?? 0
        self.episode = json["episode"].intValue ?? 0
        
        let jts = json["torrents"]
        var ts: [PopcornAPITorrent] = []
       
        for (k: String, v:JSON) in jts {
            let quality = k
            let magnet = v["url"].stringValue ?? ""
            ts.append(PopcornAPITorrent(quality: quality, magnet: magnet))
        }
        
        self.torrents = ts
    }
}

class PopcornAPIShow {
    let episodes: [PopcornAPIEpisode]
    
    init(json: JSON) {
        
        let jps = json["episodes"].arrayValue ?? []
        var eps: [PopcornAPIEpisode] = []
        for ep in jps {
            eps.append(PopcornAPIEpisode(json: ep))
        }
        
        self.episodes = eps
    }
    
    func getEpisode(#season: Int, episode: Int) -> PopcornAPIEpisode? {
        
        return self.episodes.filter {
            ep in
            return ep.episode == episode && ep.season == season
        }[0]
    }
    
    func getEpisode(#tvdbid: String) -> PopcornAPIEpisode? {
        
        return self.episodes.filter {
            ep in
            return ep.tvdbid == tvdbid
        }[0]
    }
}