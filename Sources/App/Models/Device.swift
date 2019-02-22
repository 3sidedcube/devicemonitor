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
    
    var model: String?
    
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
         model: String? = nil,
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
        self.model = model
    }
}

extension Device: Content { }

extension Device: Parameter { }

extension Device {
    
    var statusString: String {
        return statusString(lastUsedBy: nil)
    }
    
    func statusString(name overrideName: String = "", lastUsedBy: User?) -> String {
        
        let name = self.name ?? overrideName
        var lastUsedString = ""
        if let cube = lastUsedBy {
            lastUsedString = " was last used by \(cube.name)"
        }
        
        switch (pluggedIn, offsite) {
        case (.some(let plugged), .some(let offsite)):
            return name + lastUsedString + " (\(plugged ? "Charging ⚡️" : "Unplugged 🔌"), \(offsite ? "Offsite 👋🏻" : "In the Office 🏢"))"
        case (.some(let plugged), nil):
            return name + lastUsedString + " (\(plugged ? "Charging ⚡️" : "Unplugged 🔌"))"
        case (nil, .some(let offsite)):
            return name + lastUsedString + " \(offsite ? "Offsite 👋🏻" : "In the Office 🏢"))"
        default:
            return name + lastUsedString
        }
    }
}
