//
//  TempoMetronome.swift
//  MetronomeController
//
//  Created by James Bean on 5/23/17.
//
//

import Rhythm
import Timeline

/// - returns: `Timeline` capable of performing the given `closure` at the given `tempo`.
public func metronome(
    tempo: Tempo,
    performing closure: @escaping Timeline.Action.Body
) -> Timeline
{
    let interval = tempo.durationOfBeat
    let action = Timeline.Action(kind: .looping(interval: interval, status: .source), body: closure)
    let timeline = Timeline()
    timeline.add(action, at: 0)
    return timeline
}
