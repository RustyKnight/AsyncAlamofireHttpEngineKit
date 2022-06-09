//
//  AsyncAlamofireHttpEngine.swift
//  
//
//  Created by Shane Whitehead on 9/6/2022.
//

import Foundation
import Alamofire
import Cadmus
import AsyncHttpEngineKit

public struct AlamofireHttpEngineConfiguration {
    public static var isDebugMode = false
}

public enum HTTPEngineError: Error {
    case invalidURL(url: String)
    case unsuccessful(code: Int, description: String)
    case missingExpectedPayload
}

struct DefaultRequestResponse: RequestResponse {
    var statusCode: Int
    var statusDescription: String
    var data: Data?
    var responseHeaders: [AnyHashable : Any]?
}

public extension RequestResponse {
    // Checks the Http response for the request and fails if it's not 200
    func requestSuccessOrFail() throws {
        guard statusCode == 200 else {
            throw HTTPEngineError.unsuccessful(code: statusCode, description: statusDescription)
        }
    }
    
    // Checks the Http response for the request and fails if it's not 200 or if there
    // is no data associated with the response
    func requestSuccessWithDataOrFail() throws -> Data {
        guard statusCode == 200 else {
            throw HTTPEngineError.unsuccessful(code: statusCode, description: statusDescription)
        }
        guard let data = data else {
            throw HTTPEngineError.missingExpectedPayload
        }
        return data
    }
}

public class AlamofireHttpEngine: AsyncHttpEngine {
    
    let url: URL
    //    let parameters: [String: String]?
    let headers: HTTPHeaders?
    let credentials: AsyncHttpEngineKit.Credentials?
    let progressMonitor: ProgressMonitor?
    private(set) var timeout: TimeInterval = 30
    
    internal lazy var session: Session = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = timeout
        sessionConfig.timeoutIntervalForResource = timeout * 10
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData
        if #available(iOS 11.0, *) {
            sessionConfig.waitsForConnectivity = true
        }
        sessionConfig.networkServiceType = .responsiveData
        sessionConfig.shouldUseExtendedBackgroundIdleMode = true
        if #available(iOS 13, *) {
            sessionConfig.allowsConstrainedNetworkAccess = true
            sessionConfig.allowsExpensiveNetworkAccess = true
        }
        sessionConfig.httpMaximumConnectionsPerHost = 24
        
        let sessionManager = Session(configuration: sessionConfig)
        return sessionManager
    }()
    
    public init(
        url: URL,
        headers: [String: String]? = nil,
        credentials: AsyncHttpEngineKit.Credentials? = nil,
        timeout: TimeInterval? = nil,
        progressMonitor: ProgressMonitor?
    ) {
        self.url = url
        self.credentials = credentials
        if let requestTimeout = timeout {
            self.timeout = requestTimeout
        }
        self.progressMonitor = progressMonitor
        
        if let headers = headers {
            self.headers = HTTPHeaders(headers)
        } else {
            self.headers = nil
        }
    }
    
    public func get() async throws -> RequestResponse {
        return try await execute(.get)
    }
    
    public func put() async throws -> RequestResponse {
        return try await execute(.put)
    }
    
    public func put(_ data: Data) async throws -> RequestResponse {
        return try await execute(.put, data: data)
    }
    
    public func post() async throws -> RequestResponse {
        return try await execute(.post)
    }
    
    public func post(_ data: Data) async throws -> RequestResponse {
        return try await execute(.post, data: data)
    }
    
    public func post(_ formData: [MultipartFormItem]) async throws -> RequestResponse {
        return try await execute(.post, formData: formData)
    }
    
    public func delete() async throws -> RequestResponse {
        return try await execute(.delete)
    }
    
    public func delete(_ data: Data) async throws -> RequestResponse {
        return try await execute(.delete, data: data)
    }
    
    func debug(_ response: DataResponse<Data, AFError>) {
        guard AlamofireHttpEngineConfiguration.isDebugMode else { return }
        guard let httpResponse = response.response else {
            log(warning: "Unable to determine server response to request made to \(url)")
            return
        }
        let statusCode = httpResponse.statusCode
        let description = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
        log(debug: """
                    
                \tServer responded to request made to \(url)
                \t\twith: \(statusCode)
                \(description)
                """)
    }

    func process(_ response: DataResponse<Data, AFError>) throws -> RequestResponse {
        debug(response)
        switch response.result {
        case .success(let data):
            var statusCode = -1
            var description = "Unknown"
            if let httpResponse = response.response {
                statusCode = httpResponse.statusCode
                description = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            }
            let headers = response.response?.allHeaderFields
            return DefaultRequestResponse(
                statusCode: statusCode,
                statusDescription: description,
                data: data,
                responseHeaders: headers
            )
        case .failure(let error):
            throw error
        }
    }
    
    func execute(_ method: HTTPMethod) async throws -> RequestResponse {
        let request = session.request(
            url,
            method: method,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers
        )
        .authenticate(with: credentials)
        .debugLog()
        .downloadProgress { progress in
            self.progressMonitor?(progress.fractionCompleted)
        }
        
        let response = await request.serializingData().response
        return try process(response)
    }
    
    func execute(_ method: HTTPMethod, data: Data) async throws -> RequestResponse {
        let request = session.upload(
            data,
            to: url,
            method: method,
            headers: headers
        )
        .authenticate(with: credentials)
        .debugLog()
        .uploadProgress { progress in
            self.progressMonitor?(progress.fractionCompleted)
        }
        .downloadProgress { progress in
            self.progressMonitor?(progress.fractionCompleted)
        }
        
        let response = await request.serializingData().response
        return try process(response)
    }
    
    func execute(_ method: HTTPMethod, formData: [MultipartFormItem]) async throws -> RequestResponse {
        let request = session.upload(
            multipartFormData: { mfd in
                for item in formData {
                    mfd.append(item)
                }
            },
            to: url,
            method: method,
            headers: headers)
            .debugLog()
            .uploadProgress { progress in
                self.progressMonitor?(progress.fractionCompleted)
            }
            .downloadProgress { progress in
                self.progressMonitor?(progress.fractionCompleted)
            }
        let response = await request.serializingData().response
        return try process(response)
    }
}
