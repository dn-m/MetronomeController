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
    public typealias MetronomeInfo = (Meter, BeatContext, Tempo)
    
    /// Closure exposing the `MetricalInfo` at each beat of a metered metronome.
    public typealias MetronomeInfoCallback = (MetronomeInfo) -> Void
    
    /// - returns: `Timeline` capable of performing the given `onDownbeat` and `onUpbeat` 
    /// closures for the given `meter` and the given `tempo`.
    public static func metronome(
        meter: Meter,
        tempo: Tempo,
        performingOnDownbeat onDownbeat: @escaping MetronomeInfoCallback,
        performingOnUpbeat onUpbeat: @escaping MetronomeInfoCallback
    ) -> Timeline
    {
        return Timeline(
            actions: offsetsAndActions(
                meter: meter,
                tempo: tempo,
                performingOnDownbeat: onDownbeat,
                performingOnUpbeat: onUpbeat,
                looping: true
            )
        )
    }
    
    /// - returns: `Timeline` capable of performing the given `onDownbeat` and `onUpbeat` closures
    /// for the given `meters` at the given `tempo`.
    public static func metronome(
        meters: [Meter],
        tempo: Tempo,
        performingOnDownbeat onDownbeat: @escaping MetronomeInfoCallback,
        performingOnUpbeat onUpbeat: @escaping MetronomeInfoCallback
    ) -> Timeline
    {
        return Timeline(
            actions: meters.flatMap { meter in
                return offsetsAndActions(
                    meter: meter,
                    tempo: tempo,
                    performingOnDownbeat: onDownbeat,
                    performingOnUpbeat: onUpbeat,
                    looping: false
                )
            }
        )
    }

    /// - warning: Not yet implemented
    public static func metronome(
        structure: Meter.Structure,
        performingOnDownbeat onDownbeat: @escaping MetronomeInfoCallback,
        performingOnUpbeat onUpbeat: @escaping MetronomeInfoCallback
    ) -> Timeline
    {
        
        func offsetAndAction(
            meter: Meter,
            meterOffset: MetricalDuration,
            beatOffset: MetricalDuration,
            tempo: Tempo
        ) -> (Seconds, Action)
        {
            // Prepare Offset
            let metricalOffset = meterOffset + beatOffset
            let secondsOffset = structure.secondsOffset(metricalOffset: metricalOffset)
            
            // Prepare Action
            let closure: MetronomeInfoCallback = beatOffset == .zero ? onDownbeat : onUpbeat
            let beatContext = BeatContext(metricalOffset: beatOffset)
            let action = Timeline.Action(
                kind: .atomic,
                body: { closure(meter, beatContext, tempo) }
            )
            
            return (secondsOffset, action)
        }
        
        func offsetsAndActions(meter: Meter, meterOffset: MetricalDuration, tempo: Tempo)
            -> [(Seconds, Action)]
        {
            return meter.beatOffsets.map { beatOffset in
                return offsetAndAction(
                    meter: meter,
                    meterOffset: meterOffset,
                    beatOffset: beatOffset,
                    tempo: tempo
                )
            }
        }
       
        let meterOffsetsAndMeters = zip(structure.meterOffsets, structure.meters)
        let actions = meterOffsetsAndMeters.flatMap { meterOffset, meter in
            offsetsAndActions(meter: meter, meterOffset: meterOffset, tempo: Tempo(120))
        }
        
        let timeline = Timeline(identifier: "Metronome", actions: actions)
        return timeline
        
    }
    
    // 1: calculate offsets of all beats (as tempo interpolations may span >1 measure)
    // 2: flatMap all of the beat positions [0,1,2,3,0,1,2,3,4,0,1,0,1,2,3]
    
    private static func offsetsAndActions(
        meter: Meter,
        tempo: Tempo,
        performingOnDownbeat onDownbeat: @escaping MetronomeInfoCallback,
        performingOnUpbeat onUpbeat: @escaping MetronomeInfoCallback,
        looping: Bool
    ) -> [(Seconds, Timeline.Action)]
    {
        
        func closure(_ position: Int) -> MetronomeInfoCallback {
            return position == 0 ? onDownbeat : onUpbeat
        }
        
        let kind: Timeline.Action.Kind = looping
            ? .looping(interval: meter.duration(at: tempo), status: .source)
            : .atomic
        
        return zip(meter.offsets(tempo: tempo), (0 ..< meter.numerator)).map { offset, position in
            
            let beatContext = BeatContext(subdivision: meter.denominator, position: position)
            
            let action = Timeline.Action(
                kind: kind,
                body: { closure(position)(meter, beatContext, tempo) }
            )
            
            return (offset, action)
        }
    }
}

extension BeatContext {
    
    internal init(metricalOffset: MetricalDuration) {
        self.position = metricalOffset.numerator
        self.subdivision = metricalOffset.denominator
    }
}
