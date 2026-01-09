//
//  RunnerCard.swift
//  Outpost
//
//  Created by Leonardo Solís on 09/01/26.
//

import SwiftUI

struct RunnerStatusCard: View {
    let bib: String
    let laps: Int
    let status: RunnerStatus
    
    var body: some View {
        VStack {
            Text(bib)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(status == .active ? .white : .secondary)
            
            Text("\(laps) " + (laps == 1 ? "Lap" : "Laps"))
                .font(.caption)
                .foregroundStyle(status == .active ? .white.opacity(0.8) : .secondary.opacity(0.5))
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(status == .active ? Color.green.gradient : Color.gray.opacity(0.2).gradient)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(status == .active ? Color.white.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    RunnerStatusCard(bib: "123", laps: 1, status: .active)
}
