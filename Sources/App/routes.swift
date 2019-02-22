import Vapor
import Jobs

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let usersController = UsersController()
    router.get("users", use: usersController.index)
    
    let devicesController = DevicesController.shared
    
    router.put("devices", String.parameter, use: devicesController.update)
    router.post("devices", "check", use: devicesController.check)
    router.post("devices", String.parameter, "unplugged", use: devicesController.unplugged)
    router.post("devices", String.parameter, "pluggedIn", use: devicesController.pluggedIn)
    router.post("devices", String.parameter, "onsite", use: devicesController.onsite)
    router.post("devices", String.parameter, "offsite", use: devicesController.offsite)
    router.post("devices", String.parameter, "low_battery", use: devicesController.lowBattery)
    router.get("devices", use: devicesController.index)
    router.post("status", use: devicesController.status)
}
