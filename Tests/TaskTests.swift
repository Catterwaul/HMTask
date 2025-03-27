import HMError
import HMTask
import Testing
import Thrappture

struct TaskTests {
  @Test func reduce() async {
    enum Failure: Error { case failure }
    var task = Task<Int, _> { throw Failure.failure }
    func reduce() async -> Int { await task.reduce(1, +) }
    #expect(await reduce() == 1)
    task = .init { 2 }
    #expect(await reduce() == 3)
  }

  struct Map {
    @Test func standard() async throws {
      typealias Task<Success> = _Concurrency.Task<Success, any Error>

      func test(_ map: (Task<String>) -> Task<Int>) async throws {
        successToSuccess: do {
          let task = map(.init { "1" })
          #expect(try await task.value == 1)
        }
        transformThrows: do {
          let task = map(.init { "🏅" })
          await #expect(throws: nil as Int?.Nil) { try await task.value }
        }
        failurePropagates: do {
          let task = map(Task { throw SomeError() })
          await #expect(throws: SomeError()) { try await task.value }
        }
      }

      func transform(_ string: String) throws(Int?.Nil) -> Int {
        try .init(string).get() ¿! Int?.Nil.self
      }

      try await test { task throws(_) in
        task.flatMap { string throws(Int?.Nil) in
            .init { try transform(string) }
        }
      }

      try await test { $0.map(transform) }
    }

    @Test func failureIsNotNever() async throws {
      typealias Task = _Concurrency.Task<String, any Error>

      func test(_ mapError: (Task) -> Task) async throws {
        successToSuccess: do {
          let task = mapError(.init { "1" })
          #expect(try await task.value == "1")
        }
        transform: do {
          let task = mapError(.init { throw nil as Int?.Nil })
          await #expect(throws: SomeError()) { try await task.value }
        }
      }

      func transform(_: some Error) -> SomeError { .init() }
      try await test { task in
        task.flatMapError { error throws(Int?.Nil) in
            .init { throw transform(error) }
        }
      }
      try await test { $0.mapError(transform) }
    }

    @Test func failureTransformsToNever() async {
      typealias Task<Failure: Error> = _Concurrency.Task<String, Failure>
      let original = "😵"
      let transformed = "🧟"
      func transform<Failure>(_ task: Task<Failure>) -> Task<Never> {
        task.flatMapError { _ in .init { transformed } }
      }

      successToSuccess: do {
        let task = transform(.init { () throws in original })
        #expect(await task.value == original)
      }
      transformErrorToSuccess: do {
        let task = transform(.init { throw SomeError() })
        #expect(await task.value == transformed)
      }
    }

    @Test func failureIsNever() async throws {
      typealias Task<Success> = _Concurrency.Task<Success, Never>

      func test(_ map: (Task<String>) -> Task<Int>) async {
        let task = map(.init { "1" })
        #expect(await task.value == 1)
      }

      func transform(_ string: String) -> Int {
        .init(string)!
      }

      await test { task in
        task.flatMap { string in
            .init { transform(string) }
        }
      }

      await test { $0.map(transform) }
    }
  }

  struct Duplicates {
    struct NeverFailure {
      @Test func zip() async {
        let jenies = (Task { "👖" }, Task { "🧞‍♂️" })
        #expect(
          await Task.zip(jenies).value == ("👖", "🧞‍♂️")
        )
      }
    }

    struct anyErrorFailure {
      @Test func zip() async throws {
        let jenies = (
          Task<_, any Error> { "👖" },
          Task { throw nil as String?.Nil }
        )
        await #expect(throws: String?.Nil.self) {
          try await Task.zip(jenies).value
        }
      }
    }
  }
}
