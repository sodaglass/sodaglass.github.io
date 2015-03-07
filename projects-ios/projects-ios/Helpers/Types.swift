//
//  Types.swift
//  projects-ios
//
//  Created by Jorge Izquierdo on 20/12/14.
//  Copyright (c) 2014 izqui. All rights reserved.
//

import Foundation

enum Response<A> {
    case Error(NSError)
    case Success(@autoclosure () -> A)
    
    func unwrap() -> A? {
        switch self {
        case .Error(let err):
            println("Respose error: \(err)") // TODO: Better error handling
        case .Success(let a):
            return a()
        }
        return nil
    }
}

typealias JSONResponse = Response<JSON>
typealias JSONCallback = (JSONResponse) -> ()

infix operator >>> {}
func >>> <A, B> (input: Response<A>, transform: (A) -> (B)) -> Response<B> {
    
    switch input {
    case .Error(let err):
        return .Error(err)
    case .Success(let a):
        return .Success(transform(a()))
    }
}


func newCallback <A, B> (cba: (A) -> (), transform: (B) -> (A)) -> (B) -> () {
    
    return {
        cba(transform($0))
    }
}

infix operator --> {}
func --> <A, B> (cba: (Response<A>) -> (), transform: (B) -> (A)) -> (Response<B>) -> () {
    
    return newCallback(cba, { b in
        
       return b >>> transform
    })
}

func parallel <A> (tasks: [((A) -> ()) -> ()], callback:([A]) -> ()) {
    
    var arr = [A?](count: tasks.count, repeatedValue: nil)
    var add: (Int, A) -> () = {
        i, v in
        arr[i] = v
        
        var newArr = [A]()
        for a in arr {
            if a != nil {
                newArr.append(a!)
            } else {
                return
            }
        }
        callback(newArr)
    }
    
    for (i, t) in enumerate(tasks) {
        t({a in add(i, a)})
    }
}


func mapParallel <A, B> (values: [A], task: ( (A, (B) -> () ) -> () ), callback:([B]) -> ()) {
    
    let tasks: [((B) -> ()) -> ()] = values.map({
        v in
        return {
            cb in
            task(v, cb)
        }
    })
    
    return parallel(tasks, callback)
}
