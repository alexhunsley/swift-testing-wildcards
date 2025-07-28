
# Wildcard helper for Swift Testing

This is an experimental tool for reducing boilerplate and tedium when tests.

The idea is to make tests easier to write, and easier to read, by having a way to explicitly define combinations that signals intent.

## Example

Suppose you've writing tests for a some feature flags. In bog standard Swift `Testing` you might write the following:

```swift
    @Test("feature flag combinations", arguments: [
        (false, false, 0),
        (true, false, 0),
        (false, true, 0),
        (true, true, 0),
        (false, false, 1),
        (true, false, 1),
        (true, true, 1),
        (false, false, 2),
        (true, false, 2),
        (false, true, 2),
        (true, true, 2),

    ])
    func featureFlags(flagNewUI: Int,
                      flagOfflineAllowed: Int,
                      numItemsInBasket: Int) {
        #expect( // some test on the three parameters )
    }
```

Ugh, that arguments list! Can you quickly see if there's a mistake been made? Actually, one combo *is* missed out. Which one? Was that deliberate?

Could we use some nested for loops in our test to generate the combos? We could, but I think it's annoying, and worse still we lose the lovely feature of `Testing` where we get the test result for every argument individually.

Hence the creation of this wildcard test helper. Here's how we'd express the test setup:

```swift
    @Test("feature flag combinations", arguments:
        FeatureFlagParams.variants(
            .wild(\.newUI),
            .wild(\.offlineAllowed), 
            .values(\.numItemsInBasket, 0...2)
        )
    )
    func featureFlags(ffParams: FeatureFlagParams) {
        #expect( // some test based on ffParams )
    }
```

We've replaced the tedious arguments list with a call to `FeatureFlagParams.variants`. We say how to generate a list of `FeatureFlagParam` using keypaths with either `.wild` or `.values`.

`.wild` means use all possible variants of a value -- it can only be used for some simpler types like `bool`.

`.values` means use the explicitly given values for that keypath. In this example we use `0...2`, but that expression can be any `Sequence`.

In order to use this technique we must define a simple mutable helper struct:

```swift
    // mutable struct with a no-param init
    struct FeatureFlagParams: WildcardPrototyping {
        var retryEnabled = false
        var retryCount = false
        var numItemsInBasket = 0
    }
```

To conform to `WildcardPrototyping` you must have a no-param init; you get that for free if you initialise all your properties as you declare them.

This struct specifies a prototype value for your test. Any properties your `.variants` invocation doesn't override have the default value defined in the prototype.

## The flexibility of `Sequence`

`.values` takes a Sequence which is great for expressiveness. Examples:

```
    // this bool will only be false
    .values(\.newUI, false)

    // explicit int values
    .values(\.numItemsInBasket, [0, 3, 15])
 
     // a stride over ints
    .values(\.numItemsInBasket, stride(from: 2, to: 20, by: 2))
    
    // first 5 vals of some infinite sequence
    .values(\.numItemsInBasket, someInfiniteSequence.prefix(5))
```

## What can I use `.wild` on?

* `Bool`
* `enum`: must be `CaseIterable` compatible; add the `WildcardEnum` marker protocol
* `Optional`: its wrapped type must be `.wild` compatible; its generated values for the test are the `nil` value plus all possible values of the wrapped type
* `MutableResult`: a provided helper similar to `Result`. Your success and failure types must be `.wild` compatible. You must use the provided `MutableResult` in your prototype struct and then in your test func you access the real `Result` via its `.result` property

## Can I get all the variants passed into my test method as a list?

Yes, by calling `.variantsList` instead of `.variants`, and receiving an array to your func. Exmaple:

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

## Use outside of `Testing`

Although this experiment is made with `Testing` in mind, you can use it in any context, for example:

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

## Design choices

This helper uses mutability of a prototype to configure your test parameter. If instead it constructed the test parameter with the correct values from the get-go that might be nicer; for example we might not need the `MutableResult` helper.

## Known issues

If you repeat one of the variant spec lines, for example:

```swift
    let variants = RetryParam.variants(
        .values(\.retryEnabled, false),
        .values(\.retryEnabled, false),
    // ...
```

then your generated variants will contain duplicates or can crash the tests, which isn't ideal.

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
