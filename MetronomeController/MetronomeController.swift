//
//  MetronomeController.swift
//  MetronomeController
//
//  Created by James Bean on 4/26/17.
//
//

import Collections
import Rhythm
import Timeline

// MARK: - Tempo Metronome

/// - returns: Looping `Timeline.Action` to perform the given `closure` at the given `tempo`.
public func metronomeTimeline(
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

public typealias MeteredAction = (Meter, BeatContext, Tempo) -> ()

/// - returns: Array of looping `Timeline.Action` objects
public func metronomeActions(
    meter: Meter,
    tempo: Tempo,
    performingOnDownbeat onDownbeat: @escaping MeteredAction,
    performingOnUpbeat onUpbeat: @escaping MeteredAction
) -> Timeline
{
    let timeline = Timeline()

    metronomeActions(
        meter: meter,
        tempo: tempo,
        performingOnDownbeat: onDownbeat,
        performingOnUpbeat: onUpbeat,
        looping: true
    ).forEach { offset, action in timeline.add(action, at: offset) }
    
    return timeline
}

public func metronomeActions(
    meters: [Meter],
    tempo: Tempo,
    performingOnDownbeat onDownbeat: @escaping MeteredAction,
    performingOnUpbeat onUpbeat: @escaping MeteredAction
) -> Timeline
{
    let timeline = Timeline()
    
    meters.flatMap { meter in
        return metronomeActions(
            meter: meter,
            tempo: tempo,
            performingOnDownbeat: onDownbeat,
            performingOnUpbeat: onUpbeat,
            looping: false
        )
    }.forEach { offset, action in timeline.add(action, at: offset) }
    
    return timeline
}

/// - returns: Array of looping `Timeline.Action` objects
private func metronomeActions(
    meter: Meter,
    tempo: Tempo,
    performingOnDownbeat onDownbeat: @escaping MeteredAction,
    performingOnUpbeat onUpbeat: @escaping MeteredAction,
    looping: Bool
) -> [(Seconds, Timeline.Action)]
{
    
    /// Create a tuple of offset in seconds and actions for each beat
    return zip(meter.offsets(tempo: tempo), (0 ..< meter.numerator)).map { offset, position in
        
        let beatContext = BeatContext(subdivision: meter.denominator, position: position)
        let closure = position == 0 ? onDownbeat : onUpbeat
        
        let kind: Timeline.Action.Kind = looping
            ? .looping(interval: meter.duration(at: tempo), status: .source)
            : .atomic
        
        let action = Timeline.Action(
            kind: kind,
            body: { closure(meter, beatContext, tempo) }
        )
        
        return (offset, action)
    }
}
