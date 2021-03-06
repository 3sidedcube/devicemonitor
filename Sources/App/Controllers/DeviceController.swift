//
//  DeviceController.swift
//  App
//
//  Created by Simon Mitchell on 18/02/2019.
//

import Vapor
import FCM
import Ferno

/// Controls basic CRUD operations on Cube users.
final class DevicesController {
    
    static let shared = DevicesController()
    
    private init() {
        
        
    }
    
    @discardableResult func checkForNotSeenDevices(_ app: Application) throws -> Future<[Device]> {        
        let request = Request(using: app)
        return try check(request)
    }
    
    @discardableResult func sendOutSilentPushes(_ app: Application) throws -> Future<String> {
        let request = Request(using: app)
        return try push(request)
    }
    
    /// Marks the device as low on battery
    func lowBattery(_ req: Request) throws -> Future<Device> {
        
        let deviceId = try req.parameters.next(String.self)
        
        return try req.content.decode(Device.self).flatMap(to: Device.self, { (requestDevice) -> Future<Device> in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let seenString = dateFormatter.string(from: Date())
            
            let newDevice = Device(
                name: nil,
                seen: seenString,
                id: nil,
                currentUserId: requestDevice.userId,
                pluggedIn: nil,
                offsite: nil,
                batteryPercentage: requestDevice.batteryPercentage
            )
            
            let fernoClient = try req.make(FernoClient.self).ferno
            
            UsersController.fetchCubeWith(id: requestDevice.userId, using: req, callback: { (cube) in
                
                guard let _cube = cube else {
                    DevicesController.sendSlackMessage("\(deviceId.removingPercentEncoding ?? deviceId) is low on battery 🔋 (\(requestDevice.batteryPercentage != nil ? "\(requestDevice.batteryPercentage!)%" : ""))", using: req)
                    return
                }
                
                DevicesController.sendSlackMessage(
                    "\(_cube.name) (@\(_cube.slack)) let \(deviceId.removingPercentEncoding ?? deviceId) get low on battery 🔔 (\(requestDevice.batteryPercentage != nil ? "\(requestDevice.batteryPercentage!)%" : ""))",
                    using: req
                )
            })
            
            return try fernoClient.update(req: req, appendedPath: ["devices", deviceId], body: newDevice)
        })
    }
    
    /// Marks a device as unplugged
    func unplugged(_ req: Request) throws -> Future<Device> {
        return try setPluggedIn(req, pluggedIn: false)
    }
    
    /// Marks a device as plugged in!
    func pluggedIn(_ req: Request) throws -> Future<Device> {
        return try setPluggedIn(req, pluggedIn: true)
    }
    
    /// Marks a device as onsite
    func offsite(_ req: Request) throws -> Future<Device> {
        return try setOnsite(req, onsite: false)
    }
    
    /// Marks a device as offsite!
    func onsite(_ req: Request) throws -> Future<Device> {
        return try setOnsite(req, onsite: true)
    }
    
    private func setOnsite(_ req: Request, onsite: Bool) throws -> Future<Device> {
        
        let deviceId = try req.parameters.next(String.self)
        
        return try req.content.decode(Device.self).flatMap(to: Device.self, { (requestDevice) -> Future<Device> in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let seenString = dateFormatter.string(from: Date())
            
            let newDevice = Device(
                name: nil,
                seen: seenString,
                id: nil,
                currentUserId: requestDevice.userId,
                pluggedIn: nil,
                offsite: !onsite
            )
            
            let fernoClient = try req.make(FernoClient.self).ferno
            
            UsersController.fetchCubeWith(id: requestDevice.userId, using: req, callback: { (cube) in
                
                guard let _cube = cube else {
                    DevicesController.sendSlackMessage(onsite ? "\(deviceId.removingPercentEncoding ?? deviceId) was bought back to the office  👍🏻" : "\(deviceId.removingPercentEncoding ?? deviceId) was taken offsite! 👋🏻", using: req)
                    return
                }
                
                DevicesController.sendSlackMessage(
                    onsite ? "\(deviceId.removingPercentEncoding ?? deviceId) was bought back to the office by \(_cube.name) (@\(_cube.slack)) 👍🏻" : "\(_cube.name) (@\(_cube.slack)) has taken \(deviceId.removingPercentEncoding ?? deviceId) offsite 👋🏻",
                    using: req
                )
            })
            
            return try fernoClient.update(req: req, appendedPath: ["devices", deviceId], body: newDevice)
        })
    }
    
    private func setPluggedIn(_ req: Request, pluggedIn: Bool) throws -> Future<Device> {
        
        let deviceId = try req.parameters.next(String.self)
        
        return try req.content.decode(Device.self).flatMap(to: Device.self, { (requestDevice) -> Future<Device> in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let seenString = dateFormatter.string(from: Date())
            
            let newDevice = Device(
                name: nil,
                seen: seenString,
                id: nil,
                currentUserId: requestDevice.userId,
                pluggedIn: pluggedIn,
                offsite: nil
            )
            
            let fernoClient = try req.make(FernoClient.self).ferno
            
            UsersController.fetchCubeWith(id: requestDevice.userId, using: req, callback: { (cube) in
                
                guard let _cube = cube else {
                    DevicesController.sendSlackMessage(pluggedIn ? "\(deviceId.removingPercentEncoding ?? deviceId) was plugged back in ⚡️" : "\(deviceId.removingPercentEncoding ?? deviceId) was unplugged 🔌", using: req)
                    return
                }
                
                DevicesController.sendSlackMessage(
                    pluggedIn ? "\(deviceId.removingPercentEncoding ?? deviceId) was plugged back in by \(_cube.name) (@\(_cube.slack)) ⚡️" : "\(_cube.name) (@\(_cube.slack)) has unplugged \(deviceId.removingPercentEncoding ?? deviceId) 🔌",
                    using: req
                )
            })
            
            return try fernoClient.update(req: req, appendedPath: ["devices", deviceId], body: newDevice)
        })
    }
    
    /// Marks a device as "unplugged" at the current date and time.
    func update(_ req: Request) throws -> Future<Device> {
        
        return try req.content.decode(Device.self).flatMap(to: Device.self, { (requestDevice) -> Future<Device> in
            
            let deviceId = try req.parameters.next(String.self)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let seenString = dateFormatter.string(from: Date())
            
            let newDevice = Device(
                name: requestDevice.name,
                seen: seenString,
                id: nil,
                model: requestDevice.model,
                currentUserId: requestDevice.userId,
                pluggedIn: requestDevice.pluggedIn,
                offsite: requestDevice.offsite,
                batteryPercentage: requestDevice.batteryPercentage
            )
            return try req.make(FernoClient.self).ferno.update(req: req, appendedPath: ["devices", deviceId], body: newDevice)
            
        })
    }
    
    func check(_ req: Request) throws -> Future<[Device]> {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let manyFuture: Future<[String : Device]> = try req.make(FernoClient.self).ferno.retrieveMany(req: req, queryItems: [], appendedPath: ["devices"])
        return manyFuture.map(to: Array<Device>.self, { cubeDict -> [Device] in
            
            let devices = Array((cubeDict as [String: Device]).values).filter({ (device) -> Bool in
                
                guard let dateString = device.seen else {
                    return true
                }
                guard let date = dateFormatter.date(from: dateString) else {
                    return true
                }
                
                return date.timeIntervalSinceNow < -60*60*2
            })
            
            guard !devices.isEmpty else {
                return devices
            }
            
            DevicesController.sendSlackMessage("""
                Please make sure the below devices are running the "Battery Police" app:
                ```
                - \(devices.compactMap({ (device) -> String? in
                return device.statusString
                }).joined(separator: "\n- ")
                )
                ```
                """, using: req
            )
            
            //TODO: Send push notification to device to re-awaken!
            
            return devices
        })
    }
    
    func push(_ req: Request) throws -> Future<String> {
        
        let fcm = try req.make(FCM.self)
        let notification: FCMNotification? = nil
        let message = FCMMessage(topic: "status", notification: notification)
        message.apns = FCMApnsConfig(headers: [:], aps: FCMApnsApsObject(alert: nil, badge: nil, sound: nil, contentAvailable: true))
        message.data = ["x":"x"]
        return try fcm.sendMessage(req.client(), message: message)
    }
    
    func status(_ req: Request) throws -> Future<SlackResponse> {
        
        let ferno = try req.make(FernoClient.self).ferno
        
        return try req.content.decode(SlackCommand.self).map(to: SlackResponse.self, { (slackCommand) -> SlackResponse in
            
            guard let responseURLString = slackCommand.response_url, let responseURL = URL(string: responseURLString) else {
                return SlackResponse(text: "Invalid request!")
            }
            
            if let text = slackCommand.text, !text.isEmpty {
                
                do {
                    let futureDevice: Future<[String: Device]> = try ferno.retrieveMany(req: req, queryItems: [.orderBy("name"), .equalTo(text)], appendedPath: ["devices"])
                    futureDevice.do({ (device) in
                        
                        guard let matchedDevice = device.values.first else {
                            DevicesController.sendSlackResponse("Failed to find device named \(text)", response_type: "ephemeral", using: req, to: responseURL)
                            return
                        }
                        
                        guard let userId = matchedDevice.userId else {
                            DevicesController.sendSlackResponse(matchedDevice.statusString(lastUsedBy: nil), response_type: "in_channel", using: req, to: responseURL)
                            return
                        }
                        
                        UsersController.fetchCubeWith(id: userId, using: req, callback: { (cube) in
                            DevicesController.sendSlackResponse(matchedDevice.statusString(lastUsedBy: cube), response_type: "in_channel", using: req, to: responseURL)
                        })
                        
                    }).catch({ (error) in
                        DevicesController.sendSlackResponse("Failed to find device named \(text)", response_type: "ephemeral", using: req, to: responseURL)
                    })
                }
                
            } else {
                
                do {
                    try UsersController().index(req).do({ (cubes) in
                        
                        do {
                            try self.index(req).do({ devices in
                                DevicesController.sendSlackResponse(DevicesController.devicesString(devices, cubes: cubes), response_type: "in_channel", using: req, to: responseURL)
                            }).catch({ error in
                                DevicesController.sendSlackResponse("Failed to get devices", response_type: "ephemeral", using: req, to: responseURL)
                            })
                        } catch {
                            DevicesController.sendSlackResponse("Failed to get devices", response_type: "ephemeral", using: req, to: responseURL)
                        }
                        
                    })
                } catch {
                    
                    do {
                        try self.index(req).do({ devices in
                            DevicesController.sendSlackResponse(DevicesController.devicesString(devices, cubes: nil), response_type: "in_channel", using: req, to: responseURL)
                        }).catch({ error in
                            DevicesController.sendSlackResponse("Failed to get devices", response_type: "ephemeral", using: req, to: responseURL)
                        })
                    } catch {
                        DevicesController.sendSlackResponse("Failed to get devices", response_type: "ephemeral", using: req, to: responseURL)
                    }
                }
            }
            
            return SlackResponse(text: "Checking device status...", response_type: "in_channel")
        })
    }
    
    private static func devicesString(_ devices: [Device], cubes: [User]?) -> String {
        var baseString = """
                        All test devices! 📱
                        ```
                        """
        let deviceStrings = devices.map({ (device) -> String in
            device.statusString(lastUsedBy: cubes?.first(where: { $0.id == device.userId }))
        })
        baseString.append(contentsOf: deviceStrings.joined(separator: "\n"))
        baseString.append("```")
        return baseString
    }
    
    private static func sendSlackResponse(_ response: String, response_type: String, using request: Request, to url: URL) {
        
        let slackResponse = SlackResponse(text: response, response_type: response_type)
        do {
            try request.make(SlackClient.self).slack.send(req: request, payload: slackResponse, url: url)
        } catch {
            print("Failed to send slack response")
        }
    }

    private static func sendSlackMessage(_ message: String, using request: Request) {
        
        let slackMessage = SlackMessage(
            text: message,
            channel: Environment.get("SLACK_CHANNEL") ?? "@simon",
            icon_emoji: ":passport_control:",
            username: "Battery Police"
        )
        
        do {
            try request.make(SlackClient.self).slack.send(req: request, payload: slackMessage)
        } catch {
            print("Failed to send slack message")
        }
    }
    
    func index(_ req: Request) throws -> Future<[Device]> {
        let manyFuture: Future<[String : Device]> = try req.make(FernoClient.self).ferno.retrieveMany(req: req, queryItems: [], appendedPath: ["devices"])
        return manyFuture.map(to: Array<Device>.self, { cubeDict -> [Device] in
            return Array((cubeDict as [String: Device]).values)
        })
    }
}

