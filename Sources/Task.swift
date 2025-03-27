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

  /// Transform success values.
  @inlinable func flatMap<NewSuccess, Error>(
    _ transform: sending @escaping @isolated(any) (Success) async throws(Error) -> Task<NewSuccess, Failure>
  ) -> Task<NewSuccess, any Swift.Error> {
    .init { try await transform(value).value }
  }

  /// Transform success values.
  @inlinable func map<NewSuccess, Error>(
    _ transform: sending @escaping @isolated(any) (Success) async throws(Error) -> NewSuccess
  ) -> Task<NewSuccess, any Swift.Error> {
    .init { try await transform(value) }
  }

  // MARK: - Failure != Never
  // These compile when Failure == Never, but will generate warnings, and can't actually do anything.

  /// Transform failures.
  func flatMapError<NewFailure: Swift.Error, Error>(
    _ transform: sending @escaping @isolated(any) (Failure) async throws(Error) -> Task<Success, NewFailure>
  ) -> Task<Success, any Swift.Error> {
    .init {
      do throws(Failure) { return try await result.get() }
      catch { return try await transform(error).value }
    }
  }

  /// Transform failures.
  func flatMapError(
    _ transform: sending @escaping @isolated(any) (Failure) async -> Task<Success, Never>
  ) -> Task<Success, Never> {
    .init {
      do throws(Failure) { return try await result.get() }
      catch { return await transform(error).value }
    }
  }

  /// Transform failures.
  func mapError<NewFailure: Swift.Error, Error>(
    _ transform: sending @escaping @isolated(any) (Failure) async throws(Error) -> NewFailure
  ) -> Task<Success, any Swift.Error> {
    .init {
      do throws(Failure) { return try await result.get() }
      catch { throw try await transform(error) }
    }
  }

  /// Transform failures.
  @discardableResult func mapFailureToSuccess(
    _ transform: sending @escaping @isolated(any) (Failure) async -> Success
  ) -> Task<Success, Never> {
    .init {
      do throws(Failure) { return try await result.get() }
      catch { return await transform(error) }
    }
  }

  @discardableResult func mapFailureToSuccess(
    _ transform: sending @escaping @isolated(any) (Failure) async throws(Error) -> Success
  ) -> Task<Success, any Error> {
    .init {
      do throws(Failure) { return try await result.get() }
      catch { return try await transform(error) }
    }
  }
}

// MARK: - Failure == Never
/// Explicit specializations for more generic overloads.
public extension Task where Failure == Never {
  /// Transform values.
  @inlinable func flatMap<NewSuccess>(
    _ transform: sending @escaping @isolated(any) (Success) async -> Task<NewSuccess, Failure>
  ) -> Task<NewSuccess, Never> {
    .init { await transform(value).value }
  }

  /// Transform values.
  @inlinable func map<NewSuccess>(
    _ transform: sending @escaping @isolated(any) (Success) async -> NewSuccess
  ) -> Task<NewSuccess, Never> {
    .init { await transform(value) }
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
