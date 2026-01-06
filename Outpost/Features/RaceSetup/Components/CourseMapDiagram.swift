//
//  CourseMapDiagram.swift
//  Outpost
//
//  Created by Leonardo Solís on 29/12/25.
//

import SwiftUI

struct CourseMapDiagram: View {
    let raceType: RaceType
    let checkpoints: [RaceCreationViewModel.tempCheckpoint]
    var body: some View {
        VStack {
            if raceType == .backyard {
                BackyardLoopDiagram(checkpoints: checkpoints)
            }else {
                StandarLinearDiagram(checkpoints: checkpoints)
            }
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct BackyardLoopDiagram: View {
    let checkpoints: [RaceCreationViewModel.tempCheckpoint]
    var isArrowObstructed: Bool {
        
        let arrowLocation: Double = 3.35
        let safeZone: Double = 0.4
        
        return checkpoints.contains { checkpoint in
            let distance = abs(checkpoint.distance - arrowLocation)
            return distance < safeZone
        }
    }
    
    var body: some View {
        ZStack{
            
            let ellipseWidth: CGFloat = 170
            let ellipseHeight: CGFloat = 120
            let rx = ellipseWidth / 2
            let ry = ellipseHeight / 2
            let loopDist = 6.706
            
            ZStack {
                
                Ellipse()
                    .stroke(Color.slateBlue, lineWidth: 4)
                    .frame(width: ellipseWidth, height: ellipseHeight)

                Image(systemName: "arrow.left")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(Color.slateBlue)
                    .clipShape(Circle())
                    .frame(width: ellipseWidth, height: ellipseHeight, alignment: .bottom)
                    .offset(y: 12)
                    .opacity(isArrowObstructed ? 0 : 1)
               
            }

            
            ForEach(checkpoints) { cp in
                let progress = cp.distance / loopDist
                let angle = Angle(degrees: progress * 360 - 90)
                
                Image(systemName: cp.type.icon)
                    .font(.caption2)
                    .foregroundStyle(Color(cp.type.color))
                    .padding(6)
                    .background(
                        Circle()
                            .fill(.white)
                            .shadow(radius: 2)
                    )
                    .offset(
                        x: rx * cos(angle.radians),
                        y: ry * sin(angle.radians)
                    )
            }
            
            VStack {
                Text("LOOP")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.slateBlue)
                Text("6.7km")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
}

struct StandarLinearDiagram: View {
    let checkpoints: [RaceCreationViewModel.tempCheckpoint]
    
    var body: some View {
        GeometryReader{ geo in
            let totalDist = checkpoints.max(by: { $0.distance < $1.distance })?.distance ?? 1
            let width = geo.size.width
            let centerY = geo.size.height / 2
            let centerX = width / 2
            
            ZStack(alignment: .leading){
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .position(x: centerX, y: centerY)
                
                ForEach(checkpoints){ cp in
                    let progress = totalDist > 0 ? (cp.distance / totalDist) : 0
                    let xPos = width * CGFloat(progress)
                    
                    VStack{
                        Image(systemName: cp.type.icon)
                            .font(.caption2)
                            .foregroundStyle(Color(cp.type.color))
                            .padding(6)
                            .background(Circle().fill(.white).shadow(radius: 2))
                        
                        Text("\(Int(cp.distance))km")
                            .font(.caption2)
                            .foregroundStyle(.slateBlue)
                    }
                    .position(x: xPos, y: centerY)
                }
            }
        }
    }
    
}

extension Color {
    init(_ name: String) {
        switch name {
        case "green": self = .green
        case "red": self = .red
        case "blue": self = .blue
        case "gray": self = .gray
        case "black": self = .primary
        default: self = .primary
        }
    }
}

#Preview {
    CourseMapDiagram(raceType: .backyard, checkpoints: [
        RaceCreationViewModel.tempCheckpoint(name: "Test", distance: 1.5, type: .waterOnly),
        RaceCreationViewModel.tempCheckpoint(name: "Test", distance: 3, type: .aidStation),
        RaceCreationViewModel.tempCheckpoint(name: "Test", distance: 0, type: .start),
    ])
}
