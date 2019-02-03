import Foundation
import RequestKit

// MARK: model

open class Comment: Codable {
    open private(set) var id: Int = -1
    open var url: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case url
    }
}

// MARK: request

public extension Octokit {

    /**
     Fetches the comments for an issue in a repository
     - parameter session: RequestKitURLSession, defaults to URLSession.sharedSession()
     - parameter owner: The user or organization that owns the repository.
     - parameter repository: The name of the repository.
     - parameter number: The number of the issue.
     - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    public func comments(_ session: RequestKitURLSession = URLSession.shared, owner: String, repository: String, number: Int, page: String = "1", perPage: String = "100", completion: @escaping (_ response: Response<[Comment]>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = CommentRouter.readComments(configuration, owner, repository, number, page, perPage)
        return router.load(session, dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter), expectedResultType: [Comment].self) { comments, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let comments = comments {
                    completion(Response.success(comments))
                }
            }
        }
    }
}

// MARK: Router

enum CommentRouter: JSONPostRouter {
    case readComments(Configuration, String, String, Int, String, String)
    
    var method: HTTPMethod {
        switch self {
        default:
            return .GET
        }
    }
    
    var encoding: HTTPEncoding {
        switch self {
        default:
            return .url
        }
    }
    
    var configuration: Configuration {
        switch self {
        case .readComments(let config, _, _, _, _, _): return config
        }
    }
    
    var params: [String: Any] {
        switch self {
        case .readComments(_, _, _, _, let page, let perPage):
            return ["per_page": perPage, "page": page]
        }
    }
    
    var path: String {
        switch self {
        case .readComments(_, let owner, let repository, let number, _, _):
            return "repos/\(owner)/\(repository)/issues/\(number)/comments"
        }
    }
}
