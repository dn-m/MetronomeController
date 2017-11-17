//
//  MetronomeControllerTests.swift
//  MetronomeController
//
//  Created by James Bean on 4/26/17.
//
//

import XCTest
import Collections
import ArithmeticTools
import Rhythm
import Timeline
@testable import MetronomeController

class MetronomeControllerTests: XCTestCase {
    
    func testInit() {
        let metronome = Timeline.metronome(tempo: Tempo(78)) { print("tick") }
        print(metronome)
    }
    
    func testMeterStructure() {

        let meters = Meter.Collection([Meter(4,4)])
        let tempi = Tempo.Stratum.Builder()
            .addTempo(Tempo(120), at: .zero)
            .fit(to: meters)
            .build()

        let metronome = Timeline.metronome(
            meters: meters,
            tempi: tempi,
            performingOnDownbeat: { _ in },
            performingOnUpbeat: { _ in }
        )
        XCTAssertEqual(metronome.schedule.keys, [0, 0.5, 1, 1.5])
    }
    
    func testAccelerando() {

        let unfulfilledExpectation = expectation(description: "Accelerando")
        
        let meters = Meter.Collection((0..<16).map { _ in Meter(4,4) })

        let tempi = Tempo.Stratum.Builder()
            .addTempo(Tempo(30), at: .zero, interpolating: true)
            .addTempo(Tempo(480), at: 64/>4)
            .fit(to: meters)
            .build()

        let metronome = Timeline.metronome(
            meters: meters,
            tempi: tempi,
            performingOnDownbeat: { beatContext in
                NSBeep()
                print("DOWNBEAT: \(beatContext)")
            },
            performingOnUpbeat:  { beatContext in
                NSBeep()
                print("- \(beatContext)")
            }
        )
        
        metronome.completion = { unfulfilledExpectation.fulfill() }
        metronome.start()
        
        waitForExpectations(timeout: 48)
    }
    
    func testAccelThenRall() {
        
        let unfulfilledExpectation = expectation(description: "Rollercoaster")
        
        let meters = Meter.Collection((0..<4).map { _ in Meter(4,4) })

        let tempi = Tempo.Stratum.Builder()
            .addTempo(Tempo(60), at: .zero, interpolating: true)
            .addTempo(Tempo(120), at: 8/>4, interpolating: true)
            .addTempo(Tempo(30), at: 16/>4, interpolating: true)
            .fit(to: meters)
            .build()
        
        let metronome = Timeline.metronome(
            meters: meters,
            tempi: tempi,
            performingOnDownbeat: { beatContext in
                NSBeep()
                print("DOWNBEAT: \(beatContext)")
            },
            performingOnUpbeat: { beatContext in
                NSBeep()
                print("- \(beatContext)")
            }
        )
        
        metronome.completion = { unfulfilledExpectation.fulfill() }
        metronome.start()
        
        waitForExpectations(timeout: 48)
    }
    
    func testAccelSubitoAccel() {
        
        let unfulfilledExpectation = expectation(description: "Rollercoaster")
        
        let meters = Meter.Collection((0..<4).map { _ in Meter(4,4) })
        let tempi = Tempo.Stratum.Builder()
            .addTempo(Tempo(60), at: .zero, interpolating: true)
            .addTempo(Tempo(120), at: 8/>4, interpolating: true)
            .addTempo(Tempo(30), at: 16/>4, interpolating: true)
            .addTempo(Tempo(60), at: 24/>4, interpolating: false)
            .fit(to: meters)
            .build()
        
        let metronome = Timeline.metronome(
            meters: meters,
            tempi: tempi,
            performingOnDownbeat: { beatContext in
                NSBeep()
                print("DOWNBEAT: \(beatContext)")
            },
            performingOnUpbeat: { beatContext in
                NSBeep()
                print("- \(beatContext)")
            }
        )
        
        metronome.completion = { unfulfilledExpectation.fulfill() }
        metronome.start()
        
        waitForExpectations(timeout: 48)
    }

    func testSecondsOffsetInIntepolationWithMeterCollectionWithOffset() {
        // Create Meter.Collection
        let first = Meter.Fragment(Meter(4,4), in: Fraction(2,4) ..< Fraction(4,4))
        let rest = (0..<4).map { _ in Meter.Fragment(Meter(4,4)) }
        let meters = Meter.Collection(first + rest)
        dump(meters.beatContexts.map { $0.metricalOffset })
    }
}
