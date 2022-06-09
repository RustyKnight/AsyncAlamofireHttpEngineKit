//
//  File.swift
//  
//
//  Created by Shane Whitehead on 10/6/2022.
//

import Foundation
import Alamofire

extension HTTPMethod {
    var debugDescription: String {
        if self == HTTPMethod.connect {
            return "CONNECT"
        } else if self == HTTPMethod.delete {
            return "DELETE"
        } else if self == HTTPMethod.get {
            return "GET"
        } else if self == HTTPMethod.head {
            return "HEAD"
        } else if self == HTTPMethod.options {
            return "OPTIONS"
        } else if self == HTTPMethod.patch {
            return "PATCH"
        } else if self == HTTPMethod.post {
            return "POST"
        } else if self == HTTPMethod.put {
            return "PUT"
        } else if self == HTTPMethod.query {
            return "QUERY"
        } else if self == HTTPMethod.trace {
            return "TRACE"
        }
        return "Unknown"
    }
}
