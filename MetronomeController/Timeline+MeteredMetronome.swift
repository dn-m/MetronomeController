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

//    public static func metronome(
//        meter: Meter,
//        tempo: Tempo,
//        performingOnDownbeat onDownbeat: @escaping BeatContextCallback,
//        performingOnUpbeat onUpbeat: @escaping BeatContextCallback
//    ) -> Timeline
//    {
//        let secondsOffsets = meter.offsets(tempo: tempo)
//        let beatOffsets = meter.beatOffsets
//        
//        let actions: [(Seconds, Timeline.Action)] = zip(secondsOffsets, beatOffsets)
//         
//            .map { secondsOffset, beatOffset in
//            
//                let closure = beatOffset == .zero ? onDownbeat : onUpbeat
//                
//                // TODO: Make .zero default offset
//                let meterContext = Meter.Context(meter: meter, at: .zero)
//                
//                let beatContext = BeatContext(
//                    meterContext: meterContext,
//                    beatOffset: beatOffset,
//                    interpolation: Interpolation(
//                        start: tempo,
//                        end: tempo,
//                        duration: meter.metricalDuration
//                    )
//                )
//                
//                let action = Timeline.Action(
//                    kind: .looping(interval: meter.duration(at: tempo), status: .source),
//                    body: { closure(beatContext) }
//                )
//                
//                return (secondsOffset, action)
//            }
//        
//        return Timeline(identifier: "Metronome", actions: actions)
//    }

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
    
//    /// - returns: A `Timeline` capable of performing the given `onDownbeat` and `onUpbeat`
//    /// closures for the given metrical `structure`.
//    public static func metronome(
//        structure: Meter.Structure,
//        performingOnDownbeat onDownbeat: @escaping BeatContextCallback,
//        performingOnUpbeat onUpbeat: @escaping BeatContextCallback
//    ) -> Timeline
//    {
//     
//        let beatContexts = structure.beatContexts
//        let beatOffsets = structure.beatOffsets
//        
//        print("beat offsets: \(beatOffsets)")
//        
//        return Timeline(
//            identifier: "Metronome",
//            actions: zip(beatOffsets, beatContexts).map { beatOffset, beatContext in
//                let closure = beatContext.beatOffset == .zero ? onDownbeat : onUpbeat
//                let action = Timeline.Action(kind: .atomic, body: { closure(beatContext) })
//                return (beatOffset, action)
//            }
//        )
//    }
}
