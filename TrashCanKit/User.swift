import Foundation
import RequestKit

@objc public class User: NSObject {
    public let id: String
    public var login: String?
    public var name: String?

    public init(_ json: [String: AnyObject]) {
        if let id = json["uuid"] as? String {
            self.id = id
            login = json["username"] as? String
            name = json["display_name"] as? String
        } else {
            id = "-1"
        }
    }
}

@objc public class Email: NSObject {
    public let isPrimary: Bool
    public let isConfirmed: Bool
    public var type: String?
    public var email: String?

    public init(json: [String: AnyObject]) {
        if let _ = json["email"] as? String {
            isPrimary = json["is_primary"] as? Bool ?? false
            isConfirmed = json["is_confirmed"] as? Bool ?? false
            type = json["type"] as? String
            email = json["email"] as? String
        } else {
            isPrimary = false
            isConfirmed = false
        }
        super.init()
    }
}

public extension TrashCanKit {
    public func me(session: RequestKitURLSession = NSURLSession.sharedSession(), completion: (response: Response<User>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = UserRouter.ReadAuthenticatedUser(configuration)
        return router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(response: Response.Failure(error))
            } else {
                if let json = json {
                    let parsedUser = User(json)
                    completion(response: Response.Success(parsedUser))
                }
            }
        }
    }

    public func emails(session: RequestKitURLSession = NSURLSession.sharedSession(), completion: (response: Response<[Email]>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = UserRouter.ReadEmails(configuration)
        return router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(response: Response.Failure(error))
            } else {
                if let json = json, values = json["values"] as? [[String: AnyObject]] {
                    let emails = values.map({ Email(json: $0) })
                    completion(response: Response.Success(emails))
                }
            }
        }
    }
}

// MARK: Router

public enum UserRouter: Router {
    case ReadAuthenticatedUser(Configuration)
    case ReadEmails(Configuration)

    public var configuration: Configuration {
        switch self {
        case .ReadAuthenticatedUser(let config): return config
        case .ReadEmails(let config): return config
        }
    }

    public var method: HTTPMethod {
        return .GET
    }

    public var encoding: HTTPEncoding {
        return .URL
    }

    public var path: String {
        switch self {
        case .ReadAuthenticatedUser:
            return "user"
        case .ReadEmails:
            return "user/emails"
        }
    }

    public var params: [String: AnyObject] {
        return [:]
    }
}
