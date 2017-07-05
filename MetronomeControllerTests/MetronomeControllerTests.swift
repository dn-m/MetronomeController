//
//  MetronomeControllerTests.swift
//  MetronomeController
//
//  Created by James Bean on 4/26/17.
//
//

import XCTest
import Collections
import Rhythm
import Timeline
@testable import MetronomeController

class MetronomeControllerTests: XCTestCase {
    
    func testInit() {
        let metronome = Timeline.metronome(tempo: Tempo(78)) { print("tick") }
        print(metronome)
    }
    
    func testMeterStructure() {
        let meters = [Meter(4,4)]
        let builder = Tempo.Stratum.Builder()
        builder.add(Tempo(120), at: .zero)
        let stratum = builder.build()
        let structure = Meter.Structure(meters: meters, tempi: stratum)
        let metronome = Timeline.metronome(
            structure: structure,
            performingOnDownbeat: { _ in },
            performingOnUpbeat: { _ in }
        )
        XCTAssertEqual(metronome.schedule.keys, [0, 0.5, 1, 1.5])
    }
    
    func testAccelerando() {

        let unfulfilledExpectation = expectation(description: "Accelerando")
        
        let meters = (0..<16).map { _ in Meter(4,4) }
        let interp = Interpolation(start: Tempo(30), end: Tempo(480), duration: 64/>4)
        let stratum = Tempo.Stratum(tempi: [.zero: interp])
        let structure = Meter.Structure(meters: meters, tempi: stratum)
        
        let metronome = Timeline.metronome(
            structure: structure,
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
        
        let meters = (0..<4).map { _ in Meter(4,4) }
        let tempi: SortedDictionary<MetricalDuration, Interpolation> = [
            .zero: Interpolation(start: Tempo(60), end: Tempo(120), duration: 8/>4),
            8/>4: Interpolation(start: Tempo(120), end: Tempo(30), duration: 8/>4),
        ]
        
        let stratum = Tempo.Stratum(tempi: tempi)
        let structure = Meter.Structure(meters: meters, tempi: stratum)
        
        let metronome = Timeline.metronome(
            structure: structure,
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
        
        let meters = (0..<4).map { _ in Meter(4,4) }
        let tempi: SortedDictionary<MetricalDuration, Interpolation> = [
            .zero: Interpolation(start: Tempo(60), end: Tempo(120), duration: 8/>4),
            8/>4: Interpolation(start: Tempo(30), end: Tempo(60), duration: 8/>4),
        ]
        
        let stratum = Tempo.Stratum(tempi: tempi)
        let structure = Meter.Structure(meters: meters, tempi: stratum)
        
        let metronome = Timeline.metronome(
            structure: structure,
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
}
