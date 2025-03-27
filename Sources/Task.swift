// MARK: - public
public extension Task {
  /// Modify a success value.
  /// - Parameters:
  ///   - errorResult: An unmodified value, when `value` `throw`s.
  ///   - combine: Use `value` to create another value of the same type as `defaultValue`.
  @inlinable func reduce<Transformed, Error: Swift.Error>(
    _ errorResult: Transformed,
    _ combine: (_ errorValue: Transformed, _ value: Success) async throws(Error) -> Transformed
  ) async throws(Error) -> Transformed {
    do { return try await combine(errorResult, value) }
    catch { return errorResult }
  }
}

// MARK: - Duplicates for `Never` and `any Error`
// An overload is currently needed below for each of
// the only two error types that `Task` currently supports:
// `Never`, and `any Error`.
// The only difference between the overloads is `try`,
// which would generate a warning if used in the `Never` overloads.
// They are written in such a way as to be able to delete the `Never` overloads,
// and the `where Failure == any Error` constraint,
// when all `Error`s are supported.

public extension Task where Failure == Never {
  /// Exchange a tuple of `Task`s for a single `Task` whose `Success` is a tuple.
  /// - Throws: The first failure that might occur in a tuple.
  @inlinable static func zip<each Element>(_ task: (repeat Task<each Element, Failure>)) -> Self
  where Success == (repeat each Element) {
    .init { () throws(_) in (repeat await (each task).value) }
  }
}

public extension Task where Failure == any Error {
  /// Exchange a tuple of `Task`s for a single `Task` whose `Success` is a tuple.
  /// - Throws: The first failure that might occur in a tuple.
  @inlinable static func zip<each Element>(
    _ task: (repeat Task<each Element, Failure>)
  ) -> Self where Success == (repeat each Element) {
    .init { () throws(_) in (repeat try await (each task).value) }
  }
}
