//
//  DatabaseService.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 24/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import Foundation
import Realm

class DatabaseService {
    
    class func sharedService() -> DatabaseService {
        return _instacedb
    }
    
    func write(block: (RLMRealm) -> (Bool)) {
        
        let realm = RLMRealm.defaultRealm()
        realm.beginWriteTransaction()
        if block(realm) {
            realm.commitWriteTransaction()
        } else {
            realm.cancelWriteTransaction()
        }
    }
}

// Show helpers
extension DatabaseService {
    
    func setLastSeen(#episode:Episode, show:Show) -> Bool {
        self.write { (r) -> (Bool) in
            
            for epi in show.episodes {
                
                let ep = epi as Episode
                if ep.seasonNumber <= episode.episodeNumber {
                    ep.watched = true
                }
            }
            
            return true
        }
        return true
    }
    
    func getNextToWatch(show: Show) -> Episode? {
        
        var next: Episode? = nil
        var watched = true
        
        for epi in show.episodes {
            let ep = epi as Episode
            
            if watched {
                next = ep
            }
            watched = ep.watched
        }
        
        return next
    }
}

// Popcorn config helpers
extension DatabaseService {
    
    func setPopcornConfig(config: PopcornConfig) -> Bool {
        
        var confis = PopcornConfig.allObjects()
        self.write { (r) -> (Bool) in
            r.deleteObjects(confis)
            r.addObject(config)
            return true
        }
        
        return true
    }
    func getPopcornConfig() -> PopcornConfig? {
        
        var confis = PopcornConfig.allObjects()
        if confis.count > 0 {
            return confis[0] as? PopcornConfig
        }
        
        return nil
    }
}

// Trakt access token
extension DatabaseService {
    
    func setAccessToken(config: AccessToken) -> Bool {
        
        var confis = AccessToken.allObjects()
        self.write { (r) -> (Bool) in
            r.deleteObjects(confis)
            r.addObject(config)
            return true
        }
        
        return true
    }
    func getAccessToken() -> AccessToken? {
        
        var confis = AccessToken.allObjects()
        if confis.count > 0 {
            return confis[0] as? AccessToken
        }
        
        return nil
    }

}

let _instacedb: DatabaseService = {
   return DatabaseService()
}()