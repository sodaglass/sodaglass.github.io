//
//  AppDelegate.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 20/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import UIKit
import Realm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        var popcorn = PopcornService.sharedService()
        popcorn.config = PopcornConfig(ip: "192.168.1.38", port: "8118", user: "popcorn", pass: "popcorn")
        
        let trakt = TraktService.sharedService()
        trakt.accessToken = TraktAccessToken(token: "54de40c6176753bc3ddaddbdffe5677b459e07f771cc7aa3c896a4a2a5ae82fd")
       
        trakt.search("homeland") {
            res in
            trakt.getShow(res.unwrap()![0].imdb_id) {
                r in
                /*let realm = RLMRealm.defaultRealm()
                realm.beginWriteTransaction()
                realm.addObject(Show(traktShow: r.unwrap()!))
                realm.commitWriteTransaction()
                
                println(Show.allObjects())
                println(realm.path)*/
            }
        }
        return true
    }
    
    func application(application: UIApplication!, openURL url: NSURL!, sourceApplication: String!, annotation: AnyObject!) -> Bool {
        
        let oauth_url = NSURL(string: TraktService.sharedService().oauth_callback)!
        
        if url.host == oauth_url.host && url.path?.hasPrefix(oauth_url.path!) != nil {
            
            TraktService.sharedService().handleOauthURL(url)
        }
        
        return true
    }
}

