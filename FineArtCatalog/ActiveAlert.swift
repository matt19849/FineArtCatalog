import Foundation

enum ActiveAlert: Identifiable {
    case success
    case error(String)
    
    var id: String {
        switch self {
        case .success:
            return "success"
        case .error(let message):
            return message
        }
    }
}
