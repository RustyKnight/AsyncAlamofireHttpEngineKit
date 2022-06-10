//
//  MultipartFormData+Item.swift
//  
//
//  Created by Shane Whitehead on 9/6/2022.
//

import Foundation
import Alamofire
import AsyncHttpEngineKit
import Cadmus

extension MultipartFormData {
    func append(_ item: MultipartFormItem) {
        switch item {
        case .data(let data, let name, let mimeType, let fileName):
            if let fileName = fileName, let mimeType = mimeType {
                append(data, withName: name, fileName: fileName, mimeType: mimeType)
            } else if let mimeType = mimeType {
                append(data, withName: name, mimeType: mimeType)
            } else {
                append(data, withName: name)
            }
        case .file(let url, let name, let mimeType, let fileName):
            log(debug: """
                \n\tAppend file:
                \t\t\(url)
                \t\t\(name)
                """)
            if let fileName = fileName, let mimeType = mimeType {
                append(url, withName: name, fileName: fileName, mimeType: mimeType)
            } else {
                append(url, withName: name)
            }
        }
    }
}
