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
    
//    func testMeterMetronome() {
//        let metronome = Timeline.metronome(
//            meter: Meter(3,16),
//            tempo: Tempo(112),
//            performingOnDownbeat: { _ in },
//            performingOnUpbeat: { _ in }
//        )
//        print(metronome)
//    }
    
    func testAccelerando() {

        let unfulfilledExpectation = expectation(description: "Accelerando")
        
        let meters = (0..<16).map { _ in Meter(4,4) }
        let interp = Tempo.Interpolation(start: Tempo(30), end: Tempo(480), duration: 64/>4)
        let stratum = Tempo.Stratum(tempi: [.zero: interp])
        let structure = Meter.Structure(meters: meters, tempi: stratum)
        
        let metronome = Timeline.metronome(
            structure: structure,
            performingOnDownbeat: { meter, beatContext in
                print("DOWNBEAT: \(meter); \(beatContext)")
            },
            performingOnUpbeat:  { meter, beatContext in
                print("- \(meter); beatContext: \(beatContext)")
            }
        )
        
        metronome.completion = { unfulfilledExpectation.fulfill() }
        metronome.start()
        
        waitForExpectations(timeout: 48)
    }
}
