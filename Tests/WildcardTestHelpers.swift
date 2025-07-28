@testable import TestingWildcards

enum Mode: CaseIterable, Equatable, InvariantValues, CustomStringConvertible {
    case alpha, beta, gamma

    var description: String {
        switch self {
        case .alpha: return "Alpha"
        case .beta: return "Beta"
        case .gamma: return "Gamma"
        }
    }
}

struct FilePermission: OptionSet, Equatable, InvariantOptionSet {
    let rawValue: Int

    static let read    = FilePermission(rawValue: 1 << 0)
    static let write   = FilePermission(rawValue: 1 << 1)
    static let execute = FilePermission(rawValue: 1 << 2)

    static let all: FilePermission = [.read, .write, .execute]

    public static var allOptions: [Self] {
        [.read, .write, .execute]
    }
}

struct Example: WildcardPrototyping, CustomStringConvertible, Equatable {
    // recommended pattern -- set all properties values to default
    var name: String = "bob"
    var flag: Bool = false
    var mode: Mode = .alpha
    var count: Int = 0
    var a: Int = 0
    var b: Int = 0
    var c: Int = 0
    var filePermission: FilePermission = .all
    var error: SomeError? = nil
    var mutableResult: MutableResult<Bool, SomeError> = .init()
    // not easily doable -- hashability etc
//    var handler: (Int) -> Int = { _ in 0 }

    var description: String {
        "[Example name: \(name) flag: \(flag), mode: \(mode), count: \(count), abc: \(a) \(b) \(c) perm: \(filePermission) result: \(mutableResult) error: \(String(describing: error))])"
    }
}

enum SomeError: Error, Equatable, WildcardEnum {
    case catWokeUp
    case dogGotRainedOn
}
