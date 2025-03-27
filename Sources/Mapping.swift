// MARK: - public
public extension Task {
  /// Transform success values.
  /// - Throws: The new `Failure` is a combination of the original  `Failure`, and the new `Error`.
  @inlinable func flatMap<NewSuccess, Error>(
    _ transform: sending @escaping @isolated(any) (Success) async throws(Error) -> Task<NewSuccess, Failure>
  ) -> Task<NewSuccess, any Swift.Error> {
    .init { try await transform(value).value }
  }

  /// Transform success values.
  /// - Throws: The new `Failure` is a combination of the original  `Failure`, and the new `Error`.
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

  func mapFailureToSuccess(
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
