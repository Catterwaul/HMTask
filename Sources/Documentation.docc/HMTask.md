# ``HMTask``

Extended functionality for [Task](https://developer.apple.com/documentation/swift/task).

## An asynchronous get-only throwing property wrapper?

Although `Task` qualifies as being a "[throwing property wrapper](https://github.com/Catterwaul/Thrappture)", and has a lot in common with `Result`, in particular, it has some key differences to its synchronous cousins.

First, unlike mutable `Optional`s and `Result`s, the value of a `Task` exclusively makes sense to be `get`-only. Although it's not currently possible in Swift, it might make sense for an asynchronous *property* to be settable—but not the `value` of a `Task`.

### Usage Examples

You've got the source code, so aside from reading this documentation, see the **Tests** folder for example usage! 😺

## Topics

- ``_Concurrency/Task``
