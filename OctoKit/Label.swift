import Foundation

open class Label: Codable {
    open var url: URL?
    open var name: String?
    open var color: String?

    public init(withName name: String) {
        self.name = name
    }
}
