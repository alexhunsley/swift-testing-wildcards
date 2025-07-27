

## ResultTypes

Hasn't been made into invariant thing because it's immutable and currently this whole thing works via mutability.
Workaround: use the provided MutableResultType and then call .result on it in the test to get the actual ResultType.

    //    @Test
    //    func resultTypes() {
    //        typealias MyResult = Result<Bool, SomeError>
    //        // Results aren't mutable! Guess we could built something to instantiate it, but... meh
    //        let base = MyResult.success(true)
    //    }


