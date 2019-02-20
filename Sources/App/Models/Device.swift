//
//  Device.swift
//  App
//
//  Created by Simon Mitchell on 18/02/2019.
//

import FluentSQLite
import Vapor

final class Device: Model {
    
    static var idKey: WritableKeyPath<Device, Int?> = \.id
    
    typealias ID = Int
    
    typealias Database = SQLiteDatabase
    
    var name: String?
    
    var seen: String?
    
    var id: Int?
    
    var userId: Int?
    
    var pluggedIn: Bool?
    
    var offsite: Bool?
    
    var batteryPercentage: Int?
    
    init(name: String?,
         seen: String?,
         id: Int?,
         currentUserId: Int? = nil,
         pluggedIn: Bool? = nil,
         offsite: Bool? = nil,
         batteryPercentage: Int? = nil
        ) {
        self.name = name
        self.seen = seen
        self.id = id
        self.userId = currentUserId
        self.pluggedIn = pluggedIn
        self.offsite = offsite
        self.batteryPercentage = batteryPercentage
    }
}

extension Device: Content { }

extension Device: Parameter { }

extension Device {
    var statusString: String? {
        guard let name = name else { return nil }
        switch (pluggedIn, offsite) {
        case (.some(let plugged), .some(let offsite)):
            return name + " (\(plugged ? "Charging ⚡️" : "Unplugged 🔌"), \(offsite ? "Offsite 👋🏻" : "In the Office 🏢"))"
        case (.some(let plugged), nil):
            return name + " (\(plugged ? "Charging ⚡️" : "Unplugged 🔌"))"
        case (nil, .some(let offsite)):
            return name + " \(offsite ? "Offsite 👋🏻" : "In the Office 🏢"))"
        default:
            return name
        }
    }
}
