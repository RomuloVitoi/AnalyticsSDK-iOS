import XCTest
@testable import ParselyTracker

class EngagedTimeTests: ParselyTestCase {
    let testUrl: String = "http://parsely-stuff.com"
    
    func testHeartbeatFn() {
        let dummyEventArgs: Dictionary<String, Any> = parselyTestTracker.track.engagedTime.generateEventArgs(
            url: testUrl, urlref: "", extra_data: nil, idsite: ParselyTestCase.testApikey)
        let dummyAccumulator: Accumulator = Accumulator(key: "", accumulatedTime: 0, totalTime: 0,
                                                        lastSampleTime: Date(), lastPositiveSampleTime: Date(),
                                                        heartbeatTimeout: 0, contentDuration: 0, isEngaged: false,
                                                        eventArgs: dummyEventArgs)
        parselyTestTracker.track.engagedTime.heartbeatFn(data: dummyAccumulator, enableHeartbeats: true)
        XCTAssertEqual(parselyTestTracker.eventQueue.length(), 1,
                       "A call to Parsely.track.engagedTime.heartbeatFn should add an event to eventQueue")
    }
    
    func testStartInteraction() {
        parselyTestTracker.track.engagedTime.startInteraction(url: testUrl, urlref: "", extra_data: nil,
                                                              idsite: ParselyTestCase.testApikey)
        let internalAccumulators:Dictionary<String, Accumulator> = parselyTestTracker.track.engagedTime.accumulators
        let testUrlAccumulator: Accumulator = internalAccumulators[testUrl]!
        XCTAssert(testUrlAccumulator.isEngaged,
                  "After a call to Parsely.track.engagedTime.startInteraction, the internal accumulator for the engaged " +
                  "url should exist and its isEngaged flag should be set")
    }
    
    func testEndInteraction() {
        parselyTestTracker.track.engagedTime.startInteraction(url: testUrl, urlref: "", extra_data: nil,
                                                              idsite: ParselyTestCase.testApikey)
        parselyTestTracker.track.engagedTime.endInteraction()
        let internalAccumulators:Dictionary<String, Accumulator> = parselyTestTracker.track.engagedTime.accumulators
        let testUrlAccumulator: Accumulator = internalAccumulators[testUrl]!
        XCTAssertFalse(testUrlAccumulator.isEngaged,
                       "After a call to Parsely.track.engagedTime.startInteraction followed by a call to " +
                       "Parsely.track.engagedTime.stopInteraction, the internal accumulator for the engaged " +
                       "url should exist and its isEngaged flag should be unset")
    }
}
