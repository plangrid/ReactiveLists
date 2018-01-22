/**
 Allows to perform a parameterized tests, in which each test case can  have different inputs and
 expecations but in which the test preparation & execution code are shared.
 */
public struct ParameterizedTest<TestParameter> {

    public typealias Expectation = (TestParameter) -> Void
    public typealias TestCase = (TestParameter, expectation: Expectation)
    public typealias TestClosure = (TestParameter, Expectation) -> Void

    public static func test(testCases: [TestCase], testClosure: TestClosure) {
        testCases.forEach { testClosure($0.0, $0.expectation) }
    }
}

/// Run the same expectation code for any number of single parameter cases
///
/// Note: For type inferencing to work on nil cases, you may have to do two things:
///
/// (1) order the nil case first in the list of cases
///
/// (2) explicitly type the nil, e.g. `Optional<String>()`
public func parameterize<A>(cases: A..., expectation: ((A) -> Void)) {
    cases.forEach { expectation($0) }
}
