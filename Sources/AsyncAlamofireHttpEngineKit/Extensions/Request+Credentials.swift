//
//  Request+Credentials.swift
//  
//
//  Created by Shane Whitehead on 9/6/2022.
//

import Foundation
import AsyncHttpEngineKit
import Alamofire

extension Request {
    func authenticate(with credentials: AsyncHttpEngineKit.Credentials?) -> Self {
        guard let credentials = credentials else { return self }
        return authenticate(username: credentials.userName, password: credentials.password)
    }
}
