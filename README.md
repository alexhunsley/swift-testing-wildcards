
# Swift Testing: a wildcard helper for testing invariants

This is an experimental tool for writing exhaustive tests in the Testing framework.

The idea is to make tests easier to write, and easier to read, by making the intentions around invariant testing easy to state and quite explicit.

If the word 'invariants' doesn't mean much to you, just think of wildcards and see the example below.

## Example

Suppose you've writing tests for an `HTTPRetrier` type. In Swift Testing you might write the following:

```swift
    @Test("if retry is disabled then shouldRetry always returns false", arguments: [
        (false, 0, 401, .offline),
        (false, 1, 401, .offline),
        (false, 2, 401, .offline),
        (true, 0, 401, .offline),
        (true, 1, 401, .offline),
        (true, 2, 401, .offline),
        (false, 0, 403, .offline),
        (false, 1, 403, .offline),
        (false, 2, 403, .offline),
        (true, 0, 403, .offline),
        (true, 1, 403, .offline),
        (true, 2, 403, .offline),
        (false, 0, 401, .online),
        (false, 1, 401, .online),
        (false, 2, 401, .online),
        (true, 0, 401, .online),
        (true, 1, 401, .online),
        (true, 2, 401, .online),
        (false, 0, 403, .online),
        (false, 1, 403, .online),
        (false, 2, 403, .online),
        (true, 0, 403, .online),
        (true, 1, 403, .online),
        (true, 2, 403, .online),
    ])
    func ifRetryDisabledThenShouldRetryAlwaysReturnFalse(retryEnabled: Bool,
                                              retryCount: Int,
                                              lastAttemptErrorCode: Int,
                                              connectionStatus: ConnectionStatus) async throws {

        bool shouldRetry = retryPolicy.shouldRetry(retryEnabled: retryEnabled,
                                                   retryCount: retryCount,
                                                   lastAttemptErrorCode: lastAttemptErrorCode,
                                                   connectionStatus: connectionStatus)
        #expect(shouldRetry == false)
    }
```

Ugh, that arguments list!

So what's we're doing here is trying all variations of the parameters that don't matter -- we want to know that the only thing that affects the outcome is the value of `retryEnabled`, so we try all possible values of the other things too.

That arguments list is a pain though. Can you quickly see if there's a mistake? Can you quickly see the exact intent?

Now take a look at this alternative:

```swift
    @Test("if retry is disabled then shouldRetry always returns false", arguments: [
        RetryParam.variants(
            .values(\.retryEnabled, false),              // a single value
            .values(\.retryCount, 0..2),                 // an int range
            .values(\.lastAttemptErrorCode, [401, 403]), // specific int values 
            .wild(\.connectionStatus)                    // an enum
        )
    ])
    func ifRetryDisabledThenShouldRetryAlwaysReturnFalse(retryParam: RetryParam) async throws {

        bool retry = retryPolicy.shouldRetry(retryEnabled: retryParam.retryEnabled,
                                             retryCount: retryParam.retryCount,
                                             connectionStatus: retryParam.retryCount,
                                             lastAttemptErrorCode: retryParam.lastAttemptErrorCode)
        #expect(retry == false)
    }
```

The crucial part is the `RetryParam.variants` bit where we specify the values each property can take. The use of `.values` means we're explicitly giving all the possible values, and `.wild` means "use all possible values automatically"; it can only be used on types with a finite number states like `enum` and `Bool`.

In order to use this technique we must define a simple mutable struct like this:

```swift
    // mutable struct with a no-param init
    struct RetryParam: WildcardPrototyping {
        var retryEnabled = true
        var retryCount = 0
        var lastAttemptErrorCode = 0
        var connectionStatus = ConnectionStatus.offline
    }
```

This is a kind of prototype value. Any properties your `.variants` call doesn't specify get to keep their default value as defined in the prototype.

<!--

## Ideas

* truth table outputter that makes a string with table containing all input variants and the result (it would be given some func to get that result)

## ResultTypes

Hasn't been made into invariant thing because it's immutable and currently this whole thing works via mutability.
Workaround: use the provided MutableResultType and then call .result on it in the test to get the actual ResultType.

    //    @Test
    //    func resultTypes() {
    //        typealias MyResult = Result<Bool, SomeError>
    //        // Results aren't mutable! Guess we could built something to instantiate it, but... meh
    //        let base = MyResult.success(true)
    //    }



### scratch

```
// thoughts:
//
// * one potential issue is that we mutate the prototype, so you need a mutable object.
//   but the code you're testing might well take an immutable type.
//
//   But this tool is meant for driving Testing test cases, where you will
//   probably construct the real type from it; so I think this mutable aspect is ok.
```

-->
