//
//  TempoMetronome.swift
//  MetronomeController
//
//  Created by James Bean on 5/23/17.
//
//

import Rhythm
import Timeline

extension Timeline {
    
    /// - returns: `Timeline` capable of performing the given `closure` at the given `tempo`.
    public static func metronome(
        tempo: Tempo,
        performing closure: @escaping Timeline.Action.Body
    ) -> Timeline
    {
        let action = Timeline.Action(
            kind: .looping(interval: tempo.durationOfBeat, status: .source),
            body: closure
        )
        return Timeline(actions: [(0, action)])
    }
}
