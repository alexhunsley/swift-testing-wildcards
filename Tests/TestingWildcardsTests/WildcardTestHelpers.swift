import TestingWildcards

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

struct FilePermission: OptionSet, InvariantOptionSet {
    let rawValue: Int

    static let read    = FilePermission(rawValue: 1 << 0)
    static let write   = FilePermission(rawValue: 1 << 1)
    static let execute = FilePermission(rawValue: 1 << 2)

    static let all: FilePermission = [.read, .write, .execute]

    public static var allOptions: [Self] {
        [.read, .write, .execute]
    }
}

struct Example: WildcardPrototyping, CustomStringConvertible {
    // recommended pattern -- set all properties values to default values
    // and get no-param init for free
    var name: String = "bob"
    var flag: Bool = false
    var mode: Mode = .alpha
    var count: Int = 0
    var a: Int = 0
    var b: Int = 0
    var c: Int = 0
    var filePermission: FilePermission = .all
    var error: SomeError? = nil

    var result: Result<Bool, SomeError> = .success(false)
    var resultOptionalSuccess: Result<Bool?, SomeError> = .success(false)
    var resultNeverError: Result<Bool, Never> = .success(false)
    var resultNeverSuccess: Result<Never, SomeError> = .failure(.catWokeUp)
    // results for side-effect things without any return value.
    // we define and use `Empty` as a stand-in for the non-nominal `Void`
    var resultEmptySuccess: Result<Empty, SomeError> = .success(empty)
    var resultOptionalSuccessNeverError: Result<Bool?, Never> = .success(false)
    var resultEmptyNeverError: Result<Empty, Never> = .success(empty)

    var description: String {
        "[Example name: \(name) flag: \(flag), mode: \(mode), count: \(count), abc: \(a) \(b) \(c) perm: \(filePermission) " +
        " result: \(result) error: \(String(describing: error))])"
    }
}

enum SomeError: Error, Equatable, WildcardEnum {
    case catWokeUp
    case dogGotRainedOn
}
