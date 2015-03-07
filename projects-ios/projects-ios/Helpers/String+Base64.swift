//
//  String+Base64.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 20/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import Foundation

extension String {
    
    func base64Encoded() -> String {
        
        let utf8str = self.dataUsingEncoding(NSUTF8StringEncoding)
        return utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0)) as String
    }
    
    func decodeBase64() -> String {
        
        let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(0))
        return NSString(data: data!, encoding: NSUTF8StringEncoding) as String
    }
}