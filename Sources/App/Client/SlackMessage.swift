//
//  SlackMessage.swift
//  App
//
//  Created by Simon Mitchell on 19/02/2019.
//

import Vapor

public final class SlackMessage: Content {
    
    let text: String
    
    let channel: String
    
    let icon_emoji: String
    
    let username: String
    
    init(text: String, channel: String, icon_emoji: String, username: String) {
        self.text = text
        self.channel = channel
        self.icon_emoji = icon_emoji
        self.username = username
    }
}
