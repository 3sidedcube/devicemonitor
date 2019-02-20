import FluentSQLite
import Vapor

final class Cube: Model {
    
    static var idKey: WritableKeyPath<Cube, Int?> = \.id
    
    typealias ID = Int
    
    typealias Database = SQLiteDatabase
    
    var name: String
    
    var slack: String
    
    var id: Int?
}

extension Cube: Content { }

extension Cube: Parameter { }
