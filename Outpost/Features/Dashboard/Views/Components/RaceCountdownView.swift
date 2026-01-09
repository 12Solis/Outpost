//
//  RaceStartView.swift
//  Outpost
//
//  Created by Leonardo Solís on 09/01/26.
//

import SwiftUI
import Combine

struct RaceCountdownView: View {
    var onComplete: () -> Void
    var onCancel: () -> Void
    
    @State private var count = 10
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                Text("RACE STARTS IN")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(4)
                
                Text("\(count)")
                    .font(.system(size: 150, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText(value: Double(count)))
                    .shadow(color: count > 5 ? Color.white.opacity(0.5) : Color.red.opacity(0.5), radius: 20)
                
                Spacer()
                
                Button {
                    onCancel()
                }label:{
                    Text("Cancel")
                        .font(.title)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red.opacity(0.8))
                .controlSize(.large)
                .padding(.bottom,20)
            }
        }
        .onReceive(timer) { _ in
            if count > 1 {
                withAnimation(.bouncy) {
                    count -= 1
                }
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            } else {
                timer.upstream.connect().cancel()
                onComplete()
            }
        }
    }
}

#Preview {
    RaceCountdownView(onComplete: {}, onCancel: {})
}
