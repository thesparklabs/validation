extension Validator where T: Equatable {
    /// Validates whether an item is contained in the supplied array.
    ///
    ///     try validations.add(\.name, .in("foo", "bar"))
    ///
    public static func `in`(_ array: T...) -> Validator<T> {
        return .in(array)
    }

    /// Validates whether an item is contained in the supplied array.
    ///
    ///     try validations.add(\.name, .in(["foo", "bar"]))
    ///
    public static func `in`(_ array: [T]) -> Validator<T> {
        return InValidator(array).validator()
    }
}

// MARK: Private

/// Validates whether an item is contained in the supplied array.
fileprivate struct InValidator<T>: ValidatorType where T: Equatable {
    /// See `ValidatorType`.
    public var validatorReadable: String {
        let all = array.map { "\($0)" }.joined(separator: ", ")
        return "in (\(all))"
    }

    /// Array to check against.
    let array: [T]

    /// Creates a new `InValidator`.
    public init(_ array: [T]) {
        self.array = array
    }

    /// See `Validator`.
    public func validate(_ item: T) throws {
        guard array.contains(item) else {
            throw ValidationError("is not \(validatorReadable)")
        }
    }
}
