//
//  OnboardingView.swift
//  Outpost
//
//  Created by Leonardo Solís on 10/01/26.
//

import SwiftUI

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    
    @State private var currentPage = 0
    
    @State private var nickname: String = ""
    @AppStorage("UserNickname") private var storedNickname: String = ""
    
    var body: some View {
        VStack {
            // MARK: Pages
            TabView(selection: $currentPage) {
                
                // Welcome Page
                VStack{
                    Spacer()
                    Image("Logo")
                        .resizable()
                        .frame(width: 300, height: 300)
                        .padding(.top, 70)
                    OnboardingPage(
                        imageName: "",
                        title: "Welcome to Outpost",
                        description: "The professional, offline-first timing system designed for remote trails and Backyard Ultras.",
                        color: .blue
                    )
                }
                .tag(0)
                
                // Mesh Network Page
                OnboardingPage(
                    imageName: "antenna.radiowaves.left.and.right.slash.circle.fill",
                    title: "No Signal? No Problem.",
                    description: "Outpost uses a peer-to-peer Mesh Network. Devices sync race data automatically when they are near each other—no internet required.",
                    color: .green
                )
                .tag(1)
                
                // Race Modes Page
                OnboardingPage(
                    imageName: "figure.run.circle.fill",
                    title: "Built for Endurance",
                    description: "Support for standard point-to-point stages and the 'Backyard Ultra' elimination format.",
                    color: .orange
                )
                .tag(2)
                
                // Safety Alerts Page
                OnboardingPage(
                    imageName: "exclamationmark.triangle.fill",
                    title: "Safety First",
                    description: "Automatic overdue runner alerts and critical pace monitoring ensure no one is ever left behind on the trail.",
                    color: .red
                )
                .tag(3)
                
                // Setup Page
                DeviceSetupPage(nickname: $nickname)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // MARK: Footer
            VStack(spacing: 20) {
                
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(currentPage == index ? Color.slateBlue : Color.secondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.top)
                
                // Buttons
                if currentPage < 4 {
                    Button {
                        withAnimation {
                            currentPage += 1
                        }
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.slateBlue)
                            .foregroundStyle(Color(UIColor.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    
                    Button("Skip to Setup") {
                        withAnimation { currentPage = 4 }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                } else {
                    Button {
                        finishOnboarding()
                    } label: {
                        Text("Start Racing")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(nickname.isEmpty ? Color.gray.opacity(0.3) : Color.slateBlue)
                            .foregroundStyle(nickname.isEmpty ? .secondary : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(nickname.isEmpty)
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 20)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    func finishOnboarding() {
        storedNickname = nickname
        isOnboardingComplete = true
    }
}

// MARK: Subviews

struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundStyle(color.gradient)
                .shadow(color: color.opacity(0.3), radius: 10, y: 10)
                .padding(.bottom, 20)
            
            Text(title)
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 30)
                .lineSpacing(4)
            
            Spacer()
        }
    }
}

struct DeviceSetupPage: View {
    @Binding var nickname: String
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: "iphone.gen3")
                .font(.system(size: 80))
                .foregroundStyle(.slateBlue)
                .padding(.bottom)
            
            Text("Identify This Device")
                .font(.title.bold())
            
            Text("This name will be visible to other devices on the mesh network.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading) {
                Text("DEVICE NICKNAME")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                TextField("e.g. Start Line, Checkpoint 1...", text: $nickname)
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.large)
                    .submitLabel(.done)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
