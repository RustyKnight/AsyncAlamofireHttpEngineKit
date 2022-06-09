//
//  AlamofireHttpRequestBuilder.swift
//  
//
//  Created by Shane Whitehead on 9/6/2022.
//

import Foundation
import Asy
import Alamofire
import Cadmus

open class AlamofireHttpRequestBuilder: BaseHttpRequestBuilder {
    
    override open func build() throws -> HttpEngine {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        let target = try components.asURL()
        log(debug: "target = \(target)")
        return AlamofireHttpEngine(url: try components.asURL(),
                                   //parameters: par,
                                   headers: headers,
                                   credentials: credentials,
                                   timeout: timeout,
                                   progressMonitor: progressMonitor)
    }
}
