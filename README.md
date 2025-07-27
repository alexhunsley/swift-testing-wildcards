
# Swift Testing: a wildcard helper for testing invariants

This is an experimental tool for writing exhaustive tests in the Testing framework.

The idea is to make tests easier to write, and easier to read, by making the intentions around invariant testing easy to state and quite explicit.

If the word 'invariants' doesn't mean much to you, just think of wildcards and see the example below.

## Example

Suppose you've writing tests for a `RetryPolicy` type. In Swift Testing you might write the following:

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
                                              connectionStatus: ConnectionStatus) {

        bool shouldRetry = RetryPolicy.shouldRetry(retryEnabled: retryEnabled,
                                                   retryCount: retryCount,
                                                   lastAttemptErrorCode: lastAttemptErrorCode,
                                                   connectionStatus: connectionStatus)
        #expect(shouldRetry == retryEnabled)
    }
```

Ugh, that arguments list!

So what we're doing here is trying all variations of the parameters that don't matter -- we want to know that the only thing that affects the outcome is the value of `retryEnabled`, so we try all possible values of the other things too.

That arguments list is a pain though. Can you quickly see if there's a mistake? Can you quickly see the exact intent?

Now take a look at this alternative:

```swift
    @Test("if retry is disabled then shouldRetry always returns false", arguments:
        RetryParam.variants(
            .values(\.retryEnabled, false),              // a single value
            .values(\.retryCount, 0..2),                 // an int range
            .values(\.lastAttemptErrorCode, [401, 403]), // specific int values 
            .wild(\.connectionStatus)                    // an enum
        )
    )
    func ifRetryDisabledThenShouldRetryAlwaysReturnFalse(retryParam: RetryParam) {

        bool retry = RetryPolicy.shouldRetry(retryEnabled: retryParam.retryEnabled,
                                             retryCount: retryParam.retryCount,
                                             connectionStatus: retryParam.retryCount,
                                             lastAttemptErrorCode: retryParam.lastAttemptErrorCode)
        #expect(retry == retryEnabled)
    }
```

The crucial part is the `RetryParam.variants` bit where we specify the values each property can take. The use of `.values` means we're explicitly giving all the possible values (by giving some `Sequence`), and `.wild` means "use all possible values automatically"; it can only be used on types with a finite number of states like `enum` and `Bool`.

In order to use this technique we must define a simple mutable struct:

```swift
    // mutable struct with a no-param init
    struct RetryParam: WildcardPrototyping {
        var retryEnabled = true
        var retryCount = 0
        var lastAttemptErrorCode = 0
        var connectionStatus = ConnectionStatus.offline
    }
```

To conform to `WildcardPrototyping` you must have a no-param init, and if you initialise all your properties as you declare them you get that for free.

This struct is a kind of prototype value. Any properties your `.variants` invocation doesn't override get to keep their default value as defined in the prototype.

If you're sure you will never mutate some prototype property you can declare it `let` to enforce that.

## What can I use `.wild` on?

Currently `.wild` work with these types:

* `Bool`
* `enum` (simpler ones that are `CaseIterable`, i.e. no associated values)
* `Result` (only if its success and failure types are both `.wild` compatible). You must use the provided `MutableResult` in your prototype struct and  then access the real `Result` via its `.result` property
* `Optional` (only if its wrapped type is `.wild` compatible; its variants consist of the nil value plus all possible values of the wrapped type)

## Can I get all the variants passed into my test method as a list?

Yes, by using `.variantsList` instead of `.variants`, and receiving an array parameter to your func, like so:

```swift
    @Test("if retry is disabled then shouldRetry always returns false", arguments:
        RetryParam.variantsList(   // NOTE we're calling .variantsList here
            .values(\.retryEnabled, false),
            .values(\.retryCount, 0..2),
            .values(\.lastAttemptErrorCode, [401, 403]),
            .wild(\.connectionStatus)
        )
    )
    // NOTE we're taking in [RetryParams] below
    func ifRetryDisabledThenShouldRetryAlwaysReturnFalse(retryParam: [RetryParam]) {
        // this func will only be called once with all the variants in a list
    }
```



## Use outside of Testing

Although this experiment is made with Testing in mind, you can use it in any context, for example:

```swift
    struct RetryParam: WildcardPrototyping {
        var retryEnabled = true
        var retryCount = 0
        var lastAttemptErrorCode = 0
        var connectionStatus = ConnectionStatus.offline
    }
    
    let variants = RetryParam.variants(
        .values(\.retryEnabled, false),
        .values(\.retryCount, 0..2),
        .values(\.lastAttemptErrorCode, [401, 403]),
        .wild(\.connectionStatus)
    )
    
    print(variants)
```

## Ideas

1. Could add a peer macro to make it nicer to call, e.g. `@TestWildcards`.

2. We could have a `.wildSample` that would allow infinite type wildcarding by making you specify a random choice function on the type and how many samples to take. (In the interests of maintaining deterministic testing the random choice should be based on the same random seed and alg each time.) Such an idea could also be applied to iterators with potentially infinite values to provide; you just give a count for how many values to take.

## Known issues

If you repeat one of the variant spec lines, for example:

```swift
    let variants = RetryParam.variants(
        .values(\.retryEnabled, false),
        .values(\.retryEnabled, false),
    // ...
```

then your generated variants will contain duplicates, which isn't ideal. If I add `Hashable` conformance to a few places this can be fixed.

<!-- * `OptionSet` -->


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
