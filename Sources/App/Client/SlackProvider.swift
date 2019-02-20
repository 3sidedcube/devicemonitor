//
//  SlackProvider.swift
//  App
//
//  Created by Simon Mitchell on 19/02/2019.
//

import Vapor

public struct SlackConfig: Service {
    
    public let basePath: String
    
    public init(basePath: String) {
        self.basePath = basePath
    }
}

public final class SlackProvider: Provider {
    
    public init() { }
    
    public func register(_ services: inout Services) throws {
        services.register { container -> SlackClient in
            let httpClient = try container.make(Client.self)
            let config = try container.make(SlackConfig.self)
            return SlackClient(client: httpClient, basePath: config.basePath)
        }
    }
    
    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return EventLoopFuture.done(on: container)
    }
}
