import Vapor
import Ferno

/// Controls basic CRUD operations on Cube users.
final class UsersController {
    
    /// Returns a list of all `Cube`s.
    func index(_ req: Request) throws -> Future<[User]> {
        return try req.make(FernoClient.self).ferno.retrieve(req: req, queryItems: [], appendedPath: ["users"])
    }
    
    static func fetchCubeWith(id: Int?, using req: Request, callback: @escaping (_ user: User?) -> Void) {
        
        guard let fernoClient = try? req.make(FernoClient.self).ferno, let userId = id else {
            callback(nil)
            return
        }
        
        do {
            let futureCube: Future<[String: User]> = try fernoClient.retrieveMany(req: req, queryItems: [.orderBy("id"), .equalTo(userId)], appendedPath: ["users"])
            futureCube.do({ (cubeDictionary) in
                callback(cubeDictionary.values.first(where: { $0.id == userId }))
            }).catch({ (error) in
                callback(nil)
            })
        } catch {
            callback(nil)
        }
    }
}
