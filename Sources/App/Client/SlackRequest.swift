//
//  SlackRequest.swift
//  App
//
//  Created by Simon Mitchell on 19/02/2019.
//

import Vapor

public protocol SlackRequest {
    func send<T: Content>(req: Request, method: HTTPMethod, body: T, headers: HTTPHeaders) throws -> Future<HTTPResponseStatus>
}

public class SlackAPIRequest: SlackRequest {
    
    public func send<T>(req: Request, method: HTTPMethod, body: T, headers: HTTPHeaders) throws -> EventLoopFuture<HTTPResponseStatus> where T : Content {
        let request = try self.createRequest(method: method, body: body, headers: headers)
        return self.httpClient.send(request).map(to: HTTPResponseStatus.self, { (response) -> HTTPResponseStatus in
            guard response.http.status == .ok else { throw SlackError.requestFailed }
            return response.http.status
        })
    }
    
    private let httpClient: Client
    private let basePath: String
    
    public init(httpClient: Client, basePath: String) {
        self.httpClient = httpClient
        self.basePath = basePath
    }
}

extension SlackAPIRequest {
    private func createRequest<T: Content>(method: HTTPMethod, body: T, headers: HTTPHeaders) throws -> Request {
        let completePath = self.basePath
        let request = Request(using: self.httpClient.container)
        try request.content.encode(body)
        request.http.method = method
        request.http.headers = headers
        request.http.url = URL(string: completePath)!
        return request
    }
}
