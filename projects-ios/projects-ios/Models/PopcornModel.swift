//
//  PopcornConfig.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 20/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import Foundation

class PopcornPlay {
    
    let isShow: Bool
    let isPlaying: Bool
    let streamURL: String?
    let duration: Double
    
    let season, episode: Int?
    let id, name: String?
    
    var progress: Double
    var volume: Double

    init(json: JSON){
        
        self.isShow = !json["movie"].boolValue ?? true
        self.isPlaying = json["playing"].boolValue ?? false
        self.streamURL = json["streamUrl"].string
        self.duration = json["duration"].doubleValue ?? 0
        self.progress = json["currentTime"].doubleValue ?? 0
        self.volume = json["volume"].doubleValue ?? 0
        self.id = json["tvdb_id"].string
        self.name = json["title"].string
        self.season = (json["season"].string as NSString?)?.integerValue
        self.episode = (json["episode"].string as NSString?)?.integerValue
    }
}