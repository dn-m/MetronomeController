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
    
    /// Information exposed by the `MetronomeInfoCallback` at each beat of a metered metronome.
    ///
    /// - TODO: If `BeatContext` regains `meter` as a member, get rid of this, and redefine
    /// `MetronomeInfoCallback` as `(BeatContext) -> Void`.
    ///
    public typealias MetronomeInfo = (Meter, BeatContext)
    
    /// Closure exposing the `MetricalInfo` at each beat of a metered metronome.
    public typealias MetronomeInfoCallback = (MetronomeInfo) -> Void
    
//    /// - returns: `Timeline` capable of performing the given `onDownbeat` and `onUpbeat` 
//    /// closures for the given `meter` and the given `tempo`.
//    public static func metronome(
//        meter: Meter,
//        tempo: Tempo,
//        performingOnDownbeat onDownbeat: @escaping MetronomeInfoCallback,
//        performingOnUpbeat onUpbeat: @escaping MetronomeInfoCallback
//    ) -> Timeline
//    {
//        return Timeline(
//            actions: offsetsAndActions(
//                meter: meter,
//                tempo: tempo,
//                performingOnDownbeat: onDownbeat,
//                performingOnUpbeat: onUpbeat,
//                looping: true
//            )
//        )
//    }
//
//    private static func offsetsAndActions(
//        meter: Meter,
//        tempo: Tempo,
//        performingOnDownbeat onDownbeat: @escaping MetronomeInfoCallback,
//        performingOnUpbeat onUpbeat: @escaping MetronomeInfoCallback,
//        looping: Bool
//    ) -> [(Seconds, Timeline.Action)]
//    {
//        
//        func closure(_ position: Int) -> MetronomeInfoCallback {
//            return position == 0 ? onDownbeat : onUpbeat
//        }
//        
//        let kind: Timeline.Action.Kind = looping
//            ? .looping(interval: meter.duration(at: tempo), status: .source)
//            : .atomic
//        
//        return zip(meter.offsets(tempo: tempo), (0 ..< meter.numerator)).map { offset, position in
//            
//            let beatContext = BeatContext(subdivision: meter.denominator, position: position)
//            
//            let action = Timeline.Action(
//                kind: kind,
//                body: { closure(position)(meter, beatContext, tempo) }
//            )
//            
//            return (offset, action)
//        }
//    }

    /// - returns: A `Timeline` capable of performing the given `onDownbeat` and `onUpbeat`
    /// closures for the given metrical `structure`.
    public static func metronome(
        structure: Meter.Structure,
        performingOnDownbeat onDownbeat: @escaping MetronomeInfoCallback,
        performingOnUpbeat onUpbeat: @escaping MetronomeInfoCallback
    ) -> Timeline
    {
        
        /// - returns: A tuple composed of the offset in seconds and metronome action for the
        /// the beat at the given `meterOffset` and `beatOffset` within the given `meter`.
        func offsetAndAction(
            meter: Meter,
            meterOffset: MetricalDuration,
            beatOffset: MetricalDuration
        ) -> (Seconds, Action)
        {
            // Prepare Offset
            let metricalOffset = meterOffset + beatOffset
            let secondsOffset = structure.secondsOffset(metricalOffset: metricalOffset)
            
            // Prepare Action
            let closure: MetronomeInfoCallback = beatOffset == .zero ? onDownbeat : onUpbeat
            let interpolation = structure.interpolation(containing: metricalOffset)
            let beatContext = BeatContext(offset: metricalOffset, interpolation: interpolation)

            let action = Timeline.Action(
                kind: .atomic,
                body: { closure(meter, beatContext) }
            )
            
            return (secondsOffset, action)
        }
        
        /// - returns: An array of tuples composed of the offset in seconds and metronome
        /// action for each beat in the given `meter` and the given `meterOffset`.
        func offsetsAndActions(meter: Meter, meterOffset: MetricalDuration)
            -> [(Seconds, Action)]
        {
            return meter.beatOffsets.map { beatOffset in
                return offsetAndAction(
                    meter: meter,
                    meterOffset: meterOffset,
                    beatOffset: beatOffset
                )
            }
        }
       
        // TODO: Expose this as part of the `Meter.Structure` API.
        let meterOffsetsAndMeters = zip(structure.meterOffsets, structure.meters)
        let actions = meterOffsetsAndMeters.flatMap { meterOffset, meter in
            offsetsAndActions(meter: meter, meterOffset: meterOffset)
        }
        
        let timeline = Timeline(identifier: "Metronome", actions: actions)
        return timeline
    }
}
