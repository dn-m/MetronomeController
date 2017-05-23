//
//  MeteredMetronome.swift
//  MetronomeController
//
//  Created by James Bean on 5/23/17.
//
//

import Rhythm
import Timeline

public typealias MeteredAction = (Meter, BeatContext, Tempo) -> ()

/// - returns: `Timeline` capable of performing the given `onDownbeat` and `onUpbeat` closures
/// for the given `meter` and the given `tempo`.
public func metronome(
    meter: Meter,
    tempo: Tempo,
    performingOnDownbeat onDownbeat: @escaping MeteredAction,
    performingOnUpbeat onUpbeat: @escaping MeteredAction
) -> Timeline
{
    let timeline = Timeline()
    
    offsetsAndActions(
        meter: meter,
        tempo: tempo,
        performingOnDownbeat: onDownbeat,
        performingOnUpbeat: onUpbeat,
        looping: true
    ).forEach { offset, action in timeline.add(action, at: offset) }
    
    return timeline
}

/// - returns: `Timeline` capable of performing the given `onDownbeat` and `onUpbeat` closures
/// for the given `meters` at the given `tempo`.
public func metronome(
    meters: [Meter],
    tempo: Tempo,
    performingOnDownbeat onDownbeat: @escaping MeteredAction,
    performingOnUpbeat onUpbeat: @escaping MeteredAction
) -> Timeline
{
    let timeline = Timeline()
    
    meters.flatMap { meter in
        return offsetsAndActions(
            meter: meter,
            tempo: tempo,
            performingOnDownbeat: onDownbeat,
            performingOnUpbeat: onUpbeat,
            looping: false
        )
    }.forEach { offset, action in timeline.add(action, at: offset) }
    
    return timeline
}

private func offsetsAndActions(
    meter: Meter,
    tempo: Tempo,
    performingOnDownbeat onDownbeat: @escaping MeteredAction,
    performingOnUpbeat onUpbeat: @escaping MeteredAction,
    looping: Bool
) -> [(Seconds, Timeline.Action)]
{
    
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