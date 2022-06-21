//
//  AlamofireHttpRequestBuilder.swift
//  
//
//  Created by Shane Whitehead on 9/6/2022.
//

import Foundation
import Alamofire
import Cadmus
import AsyncHttpEngineKit

open class AlamofireHttpRequestBuilder: BaseHttpRequestBuilder {
    
    override open func build() throws -> AsyncHttpEngine {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        return AlamofireHttpEngine(url: try components.asURL(),
                                   //parameters: par,
                                   headers: headers,
                                   credentials: credentials,
                                   timeout: timeout,
                                   progressMonitor: progressMonitor)
    }
    
    @discardableResult
    public func with(_ header: HTTPHeader) -> Self {
        with(header: header.name, value: header.value)
        return self
    }
}
