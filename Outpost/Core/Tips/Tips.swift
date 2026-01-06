//
//  Tips.swift
//  Outpost
//
//  Created by Leonardo Solís on 03/01/26.
//

import Foundation
import TipKit

struct changeIconTip: Tip {
    static let iconChangedEvent = Event(id: "iconChanged")
    
    var title: Text{
        Text("Tap the icon to change the type")
    }
    var message: Text?{
        Text("Map icons update based on the checkpoint type selected below.")
    }
    var image: Image? {
        Image(systemName: "hand.tap.fill")
    }
    
    var rules: [Rule] = [

        #Rule(Self.iconChangedEvent){ event in
            event.donations.count < 1
        }
    ]
}

struct LiveTrackTip: Tip {
    
    static let liveTrackViewVisitedEvent = Event(id: "liveTrackViewVisited")
    
    var title: Text{
        Text("Track runners live")
    }
    var message: Text?{
        Text("Tap here to view live tracking and see all runners’ current status.")
    }
    
    var rules: [Rule] = [
        #Rule(Self.liveTrackViewVisitedEvent){ event in
            event.donations.count < 1
        }
    ]
}
