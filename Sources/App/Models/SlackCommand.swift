//
//  Device.swift
//  App
//
//  Created by Simon Mitchell on 18/02/2019.
//

import Vapor

final class SlackCommand {
    
    var text: String?
    
    var response_url: String?
}

extension SlackCommand: Content { }
