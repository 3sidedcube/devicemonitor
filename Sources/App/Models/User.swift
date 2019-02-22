import FluentSQLite
import Vapor

final class User: Model {
    
    static var idKey: WritableKeyPath<User, Int?> = \.id
    
    typealias ID = Int
    
    typealias Database = SQLiteDatabase
    
    var name: String
    
    var slack: String
    
    var id: Int?
}

extension User: Content { }

extension User: Parameter { }
