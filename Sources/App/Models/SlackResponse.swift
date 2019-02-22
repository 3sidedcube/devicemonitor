//
//  SlackResponse.swift
//  App
//
//  Created by Simon Mitchell on 22/02/2019.
//

import Vapor

final class SlackResponse {
    
    var text: String
    
    var response_type: String = "ephemeral"
    
    var link_names: Int = 1
    
    init(text: String, response_type: String = "ephemeral") {
        self.text = text
        self.response_type = response_type
    }
}

extension SlackResponse: Content { }
