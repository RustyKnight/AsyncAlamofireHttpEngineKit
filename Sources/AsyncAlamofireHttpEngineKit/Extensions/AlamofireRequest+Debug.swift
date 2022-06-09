//
//  AlamofireRequest+Debug.swift
//  
//
//  Created by Shane Whitehead on 9/6/2022.
//

import Foundation
import Alamofire
import Cadmus

extension Alamofire.Request {
    public func debugLog() -> Self {
        if AsyncAlamofireHttpEngineConfiguration.isDebugMode {
            debugPrint(self)
        }
        return self
    }
}
