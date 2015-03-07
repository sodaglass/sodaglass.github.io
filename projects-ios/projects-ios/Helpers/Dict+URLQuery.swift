//
//  Array+URLQuery.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 22/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import Foundation

func urlquery(parameters: [String: AnyObject]) -> String {
    var components: [(String, String)] = []
    for key in sorted(Array(parameters.keys), <) {
        let value: AnyObject! = parameters[key]
        components += queryComponents(key, value)
    }
    
    return join("&", components.map{"\($0)=\($1)"} as [String])
}

func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
    var components: [(String, String)] = []
    if let dictionary = value as? [String: AnyObject] {
        for (nestedKey, value) in dictionary {
            components += queryComponents("\(key)[\(nestedKey)]", value)
        }
    } else if let array = value as? [AnyObject] {
        for value in array {
            components += queryComponents("\(key)[]", value)
        }
    } else {
        components.extend([(escape(key), escape("\(value)"))])
    }
    
    return components
}

func escape(string: String) -> String {
    let legalURLCharactersToBeEscaped: CFStringRef = ":/?&=;+!@#$()',*"
    return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue)
}

func parseQuery(string: String) -> [String:String] {
    
    let args = string.componentsSeparatedByString("&") as [String]
    var ret = [String:String]()
    for a in args {
        
        var arg = a.componentsSeparatedByString("=") as [String]
        
        //Would be nicer changing it to something that checks if element in array exists
        var val = ""
        if arg.count > 1 {
            val = arg[1]
        }
        
        let key = arg[0].stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!.stringByReplacingOccurrencesOfString("+", withString: " ", options: .LiteralSearch, range: nil) as String
        let value = val.stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!.stringByReplacingOccurrencesOfString("+", withString: " ", options: .LiteralSearch, range: nil) as String
        
        ret[key] = value
    }
    
    return ret
}
