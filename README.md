# Wildcard helper for Swift `Testing`

This is an experimental tool for reducing boilerplate and tedium when writing certain kinds of tests.

The idea is to make tests easier to write, and easier to read, by having a way to explicitly define combinations that signals intent.

To use this helper add this URL to your SPM dependencies:

```
https://github.com/alexhunsley/swift-testing-wildcards
```

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
    (true, true, 2)
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

We've replaced the tedious arguments list with `FeatureFlagParams.variants`. It's much clearer to read thanks to the keypaths and it's more type-safe (we can avoid some of the vague `Any` errors you can get in regular `Testing` use).

It works by generating a list of `FeatureFlagParam` combinations using keypaths wrapped in either `.wild` or `.values`:
`.wild` means use all possible variants of a value (think *wildcard*) -- it can only be used for some simpler types like `Bool`, certain `enum` and `Optional`, and a few others.

`.values` means use the explicitly given values for that keypath. In this example we use a range `0...2`, but that expression can be any `Sequence`.

In order to use the above code we must define a simple mutable helper struct:

```swift
// mutable struct with a no-param init
struct FeatureFlagParams: WildcardPrototyping {
    var retryEnabled = false
    var retryCount = false
    var numItemsInBasket = 0
}
```

This struct specifies a prototype value for your test. Any properties your `.variants` invocation doesn't override have the default value defined in the prototype.

To conform to `WildcardPrototyping` you must be `Equatable` and have a no-param init (hint: initialise all your properties as you declare them and you're covered).

## The flexibility of `Sequence`

`.values` takes a `Sequence` which is great for expressiveness. Examples:

```swift
// this bool will only be false
.values(\.newUI, false)

// explicit int values
.values(\.numItemsInBasket, [0, 3, 15])

 // a stride over ints
.values(\.numItemsInBasket, stride(from: 2, to: 20, by: 2))

// first 5 vals of some infinite sequence
.values(\.numItemsInBasket, someInfiniteSequence.prefix(5))

// a single value like this is not actually a sequence but it gets converted
.values(\.newUI, false)
```

## What can I use `.wild` on?

* `Bool`
* `enum`: must be `CaseIterable` compatible; add the `WildcardEnum` marker protocol
* `Error`: some of your Error enums will be compatible (see `enum`)
* `Optional`: its wrapped type must be `.wild` compatible; its generated values for the test are the `nil` value plus all possible values of the wrapped type
* `Result`: your success and failure types must be `.wild` compatible. Support is provided for `Result<Never, Error>`, and `Result<SomeType, Never>`.
* `OptionSet`: add the `InvariantOptionSet` marker protocol; must be `Equatable`
## Can I call `.variants` on an arbitrary instance of my helper type?

Yes, just call `.variants` on your instance: 

```swift
@Test("feature flag combinations", arguments:
    FeatureFlagParams(newUI: false, offlineAllow: true)
    .variants(
        .values(\.numItemsInBasket, 0...2)
    )
)
func featureFlags(ffParams: FeatureFlagParams) {
```

Note that you can safely just omit any values that are mentioned in `.variants(` in your init call.

## Can I omit certain combinations?

You can use a `.filter` to remove any specific combos you don't want. Example:

```swift
FeatureFlagParams.variants(
    .wild(\.newUI),
    .wild(\.offlineAllowed), 
    .values(\.numItemsInBasket, 0...2)
)
// remove combo where neither feature flag is set
.filter { $0.newUI || $0.offlineAllowed }
```


## Can I get all the variants into a test func as a single list?

Yes, by calling `.variantsList` instead of `.variants`:

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

This isn't recommended though; `Testing` gives better test feedback when you use `.variants`.

## Use outside of `Testing`

Although this experimental helper is made with `Testing` in mind, you can use it in any context, for example:

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

Could add a peer macro to make it even easier to call, e.g. `@TestWildcards` which would rewrite to a `@Test` macro.


## Known issues

If you repeat one of the variant spec lines, for example:

```swift
let variants = RetryParam.variants(
    .values(\.retryEnabled, false),
    .values(\.retryEnabled, false), // oh no, same thing twice!
```

then behaviour is undocumented. Usually, your generated variants will contain duplicates or the tests can crash, which isn't ideal.
