import FluentSQLite
import Vapor
import FCM
import Ferno

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    let fernoConfig = FernoConfig(basePath: Environment.get("FIREBASE_DATABASE_URL") ?? "", email: Environment.get("FIREBASE_CLIENT_EMAIL") ?? "", privateKey: Environment.get("FIREBASE_PRIVATE_KEY")?.base64Decoded ?? "")
    services.register(fernoConfig)
    try services.register(FernoProvider())
    
    let fcm = FCM(email: Environment.get("FIREBASE_CLIENT_EMAIL") ?? "",
                  projectId: Environment.get("FIREBASE_PROJECT_ID") ?? "",
                  key: Environment.get("FIREBASE_PRIVATE_KEY")?.base64Decoded ?? "")
    services.register(fcm, as: FCM.self)
    
    let slackConfig = SlackConfig(basePath: Environment.get("SLACK_WEBHOOK_URL") ?? "")
    services.register(slackConfig)
    try services.register(SlackProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
}
