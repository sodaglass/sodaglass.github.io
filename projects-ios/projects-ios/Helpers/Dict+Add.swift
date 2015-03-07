//
//  Dict+Add.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 22/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import Foundation

infix operator + {}
func + <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>)
    -> Dictionary<K,V> {
    
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}