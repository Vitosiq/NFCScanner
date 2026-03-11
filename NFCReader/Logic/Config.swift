import Foundation

class Config: Codable {
    
    static let shared = Config()
    
    var apiKey = String()
    
    private init() {}
    
}
