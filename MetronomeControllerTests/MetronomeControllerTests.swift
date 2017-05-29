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
    
    func testAccelerando() {

        let unfulfilledExpectation = expectation(description: "Accelerando")
        
        let meters = (0..<16).map { _ in Meter(4,4) }
        let interp = Tempo.Interpolation(start: Tempo(30), end: Tempo(480), duration: 64/>4)
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
        let tempi: SortedDictionary<MetricalDuration, Tempo.Interpolation> = [
            .zero: Tempo.Interpolation(start: Tempo(60), end: Tempo(120), duration: 8/>4),
            8/>4: Tempo.Interpolation(start: Tempo(120), end: Tempo(30), duration: 8/>4),
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
        let tempi: SortedDictionary<MetricalDuration, Tempo.Interpolation> = [
            .zero: Tempo.Interpolation(start: Tempo(60), end: Tempo(120), duration: 8/>4),
            8/>4: Tempo.Interpolation(start: Tempo(30), end: Tempo(60), duration: 8/>4),
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
