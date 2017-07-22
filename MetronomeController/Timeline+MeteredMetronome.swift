//
//  MeteredMetronome.swift
//  MetronomeController
//
//  Created by James Bean on 5/23/17.
//
//

import ArithmeticTools
import Rhythm
import Timeline

extension Timeline {
    
    /// Closure exposing the `MetricalInfo` at each beat of a metered metronome.
    public typealias BeatContextCallback = (BeatContext) -> Void

    public static func metronome(
        meters: Meter.Collection,
        tempi: Tempo.Stratum,
        performingOnDownbeat onDownbeat: @escaping BeatContextCallback,
        performingOnUpbeat onUpbeat: @escaping BeatContextCallback
    ) -> Timeline
    {
        return Timeline(
            identifier: "Metronome",
            actions: meters.beatContexts.map { beatContext in
                let secondsOffset = tempi.secondsOffset(for: beatContext.metricalOffset)
                let closure = beatContext.offset == .zero ? onDownbeat : onUpbeat
                let action = Timeline.Action(kind: .atomic, body: { closure(beatContext) })
                return (secondsOffset, action)
            }
        )
    }
}
