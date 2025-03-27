# ``_Concurrency/Task``

An asynchronous get-only throwing property wrapper?

##

Although `Task` qualifies as being a "throwing property wrapper", and has a lot in common with `Result`, in particular, it has some key differences to its synchronous cousins.

First, unlike mutable `Optional`s and `Result`s, the value of a `Task` exclusively makes sense to be `get`-only. Although it's not currently possible in Swift, it might make sense for an asynchronous *property* to be settable—but not the `value` of a `Task`.

Other differences show up when taking mapping methods into account:

### flatMap / map

With a synchronous wrapper, like `Result`, mapping can throw a different type of error than the wrapper's own error type. You can still do that, with `Task`. But there's no way to preserve either of the error types, in the resulting `Task`, in doing so.

Mapping methods have to handle the possibility of the `Task` failing, or the transformation failing. This requires the transformed `Task`'s error type to be `any Error`.

**There is an exception:**

If the original `Task`'s error type is `Never`, the `Error` type of the transformation could, in theory, match the transformed `Task`'s. 

In practice, this is possible, but only when the transformation also *doesn't* throw. `Never` can be preserved in the transformed `Task`.

The reason for this is that, unfortunately, while `Task`s technically can use any type of error, there is no way to create a `Task` whose `Failure` is anything except `Never` or `any Error`. Hopefully this limitation will be lifted soon.

### flatMapAndMergeError / mapAndMergeError

In theory, these would also be exceptions. An error type should be able to be preserved, if only one is used across the transformation.

But for now, "merging error" overloads are not be possible.

### mapError

In the future, this may be able to provide a true mapping to new `Task` type, with a typed `Failure`. For now, it at least can still transform an error—the result just needs to be erased to `any Error`.

…That is, unless the `Success` type is `Void`, and the failure transformation is not throwing. This special case allows for returning a transformed `Task` whose `Failure` is `Never`, instead of `any Error`. The `Success` type 

There is one special overload of `flatMapError` which allows for a type transformation `mapError` cannot achieve. If the failure transformation is not throwing, you can return a transformed `Task` whose `Failure` is `Never`, instead of `any Error`.    

### flatMapError

There is one special overload of `flatMapError` which allows for a type transformation `mapError` cannot achieve. If the failure transformation is not throwing, you can return a transformed `Task` whose `Failure` is `Never`, instead of `any Error`.    

## Topics

- ``_Concurrency/Task/reduce(_:_:)``
- ``_Concurrency/Task/flatMap(_:)->Task<NewSuccess,Error>``
- ``_Concurrency/Task/map(_:)->Task<NewSuccess,Error>``

### Failure != Never

These compile when Failure == Never, but will generate warnings, and can't actually do anything there. 

- ``_Concurrency/Task/flatMapError(_:)->Task<Success,Error>``
- ``_Concurrency/Task/flatMapError(_:)->Task<Success,Never>``
- ``_Concurrency/Task/mapError(_:)``

### Failure == Never

Explicit specializations for more generic overloads.

- ``_Concurrency/Task/flatMap(_:)->Task<NewSuccess,Never>``
- ``_Concurrency/Task/map(_:)->Task<NewSuccess,Never>``

### Duplicates for `Never` and `any Error` 

For reasons detailed above, working with `Task`s often requires an overload for each of the two supported `Failure` types.

- ``_Concurrency/Task/zip(_:)-50liz``
- ``_Concurrency/Task/zip(_:)-7kroi``
