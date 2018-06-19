/// Combines two `Validator`s using AND logic, succeeding if both `Validator`s succeed without error.
///
///     try validations.add(\.name, .range(5...) && .alphanumeric)
///
public func &&<T> (lhs: Validator<T>, rhs: Validator<T>) -> Validator<T> {
    return AndValidator(lhs, rhs).validator()
}

/// Combines two validators, if either both succeed the validation will succeed.
fileprivate struct AndValidator<T>: ValidatorType {
    /// See `ValidatorType`.
    public var validatorReadable: String {
        return "\(lhs.readable) and is \(rhs.readable)"
    }

    /// left validator
    let lhs: Validator<T>

    /// right validator
    let rhs: Validator<T>

    /// create a new and validator
    init(_ lhs: Validator<T>, _ rhs: Validator<T>) {
        self.lhs = lhs
        self.rhs = rhs
    }

    /// See `ValidatorType`.
    func validate(_ data: T) throws {
        var left: ValidationError?
        do {
            try lhs.validate(data)
        } catch let l as ValidationError {
            left = l
        }

        var right: ValidationError?
        do {
            try rhs.validate(data)
        } catch let r as ValidationError {
            right = r
        }

        if left != nil || right != nil {
            throw ValidationError("", errorType: .And(left:left, right:right))
        }
    }
}
