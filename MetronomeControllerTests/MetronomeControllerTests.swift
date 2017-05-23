//
//  MetronomeControllerTests.swift
//  MetronomeController
//
//  Created by James Bean on 4/26/17.
//
//

import XCTest
import Rhythm
import MetronomeController

class MetronomeControllerTests: XCTestCase {
    
    func testInit() {
        
        let _ = MetronomeController(
            meters: [],
            tempo: Tempo(72),
            downbeat: { _ in },
            upbeat: { _ in }
        )
    }
}
