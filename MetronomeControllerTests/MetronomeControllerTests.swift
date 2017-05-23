//
//  MetronomeControllerTests.swift
//  MetronomeController
//
//  Created by James Bean on 4/26/17.
//
//

import XCTest
import Rhythm
import Timeline
@testable import MetronomeController

class MetronomeControllerTests: XCTestCase {
    
    func testInit() {
        let metronome = Timeline.metronome(tempo: Tempo(78)) { print("tick") }
        print(metronome)
    }
    
    func testMeterMetronome() {
        let metronome = Timeline.metronome(
            meter: Meter(3,16),
            tempo: Tempo(112),
            performingOnDownbeat: { _ in },
            performingOnUpbeat: { _ in }
        )
        print(metronome)
    }
}
