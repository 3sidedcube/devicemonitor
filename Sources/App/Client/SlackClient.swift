//
//  SlackClient.swift
//  App
//
//  Created by Simon Mitchell on 19/02/2019.
//

import Vapor

public struct SlackClient: Service {
    
    public var slack: SlackRoutes
    
    internal init(client: Client, basePath: String) {
        let apiRequest = SlackAPIRequest(httpClient: client, basePath: basePath)
        slack = SlackRoutes(request: apiRequest)
    }
}
