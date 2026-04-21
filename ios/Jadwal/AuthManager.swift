import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    var token: String = ""
    var role: String = ""
    var userId: String = ""
    
    func isLoggedIn() -> Bool {
        return !token.isEmpty
    }
    
    func logout() {
        token = ""
        role = ""
        userId = ""
    }
}
