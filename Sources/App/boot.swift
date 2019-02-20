import Vapor
import Jobs

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    
    Jobs.delay(by: 10.seconds, interval: (60*30).seconds) { [weak app] in
        do {
            guard let _app = app else { return }
            try DevicesController.shared.checkForNotSeenDevices(_app)
        } catch let error {
            print("Errored trying to check seen devices", error.localizedDescription)
        }
    }
    
    Jobs.delay(by: 10.seconds, interval: (10*60).seconds) { [weak app] in
        guard let _app = app else { return }
        do {
            try DevicesController.shared.sendOutSilentPushes(_app)
        } catch let error {
            print("Errored trying to send out silent pushes", error.localizedDescription)
        }
    }
}
