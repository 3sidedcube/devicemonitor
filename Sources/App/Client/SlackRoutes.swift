//
//  SlackRoutes.swift
//  App
//
//  Created by Simon Mitchell on 19/02/2019.
//

import Vapor

public struct SlackRoutes {
    
    private let request: SlackRequest
    
    init(request: SlackRequest) {
        self.request = request
    }
    
    @discardableResult public func send<T: Content>(req: Request, payload: T, url: URL? = nil) throws -> Future<HTTPResponseStatus> {
        let sendReq = try self.request.send(req: req, method: .POST, body: payload, headers: [:], url: url)
        return sendReq
    }
}
