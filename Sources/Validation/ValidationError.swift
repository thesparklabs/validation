import Debugging

/// A validation error that supports dynamic key paths. These key paths will be automatically
/// combined to support nested validations.
///

public struct ValidationError {
    public var path: [String]
    public let message:String
    public let errorType:ValidationErrorType

    public enum ValidationErrorType {
        case Basic
        //case Custom(name:String) //No use case for this yet but might later?
        indirect case And(left:ValidationError?, right:ValidationError?)
        indirect case Or(left:ValidationError, right:ValidationError)
        indirect case Multiple(errors:[ValidationError])
    }


    /// General
    public init(_ message: String, path:[String] = [], errorType:ValidationErrorType = .Basic) {
        self.message = message
        self.path = path
        self.errorType = errorType
    }

    // Multiple Errors
    public init(_ errors: [ValidationError], message:String = "") {
        self.message = message
        self.path = []
        self.errorType = .Multiple(errors:errors)
    }

    public var messages:[String] {
        var messages:[String] = []
        switch errorType {
        case .And(let left, let right):
            if let left = left {
                messages.append(contentsOf: left.messages)
            }
            if let right = right {
                messages.append(contentsOf: right.messages)
            }

        case .Or(let left, let right):
            messages.append(contentsOf: left.messages)
            messages.append(contentsOf: right.messages)

        case .Multiple(let errors):
            let list = errors.flatMap { error in
                return error.messages                
            }
            messages.append(contentsOf: list)

        default:
            messages.append(self.message)
        }

        return messages
    }
}
extension ValidationError: Debuggable {
    /// See `Debuggable`
    public var identifier: String {
        return "validationFailed"
    }
    /// See `Debuggable`
    public var reason: String {
        switch errorType {
        case .And(let left, let right):
            if let left = left, let right = right {
                var mutableLeft = left, mutableRight = right
                mutableLeft.path = path + left.path
                mutableRight.path = path + right.path
                return "\(mutableLeft.reason) and \(mutableRight.reason)"
            } else if let left = left {
                var mutableLeft = left
                mutableLeft.path = path + left.path
                return mutableLeft.reason
            } else if let right = right {
                var mutableRight = right
                mutableRight.path = path + right.path
                return mutableRight.reason
            } else {
                return ""
            }

        case .Or(let left, let right):
            var mutableLeft = left
            mutableLeft.path = self.path + left.path
            var mutableRight = right
            mutableRight.path = self.path + right.path
            return "\(mutableLeft.reason) and \(mutableRight.reason)"

        case .Multiple(let errors):
            return errors.map { error in
                var mutableError = error
                mutableError.path = path + error.path
                return mutableError.reason
            }.joined(separator: ", ")

        default:
            let path: String
            if self.path.count > 0 {
                path = "'" + self.path.joined(separator: ".") + "'"
            } else {
                path = "data"
            }
            return "\(path) \(message)"
        }
    }
}