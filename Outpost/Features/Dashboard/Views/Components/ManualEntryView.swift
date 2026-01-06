//
//  ManualEntryView.swift
//  Outpost
//
//  Created by Leonardo Solís on 04/01/26.
//

import SwiftUI
import SwiftData

struct ManualEntryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @Environment(SessionManager.self) var sessionManager
    
    @State private var viewModel = EntryViewModel()
    
    let columns = [
        GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack{
            VStack(spacing:20){
                
                // MARK: Info
                VStack(spacing:10){
                    Picker("Mode", selection: $viewModel.selectedMode){
                        Text("Arriving").tag(EventType.arrival)
                        Text("Departing").tag(EventType.departure)
                    }
                    .pickerStyle(.segmented)
                    .padding(40)
                    
                    
                    Text(viewModel.bibInput.isEmpty ? "Enter BIB" : viewModel.bibInput)
                        .font(.system(size: 60,weight: .bold, design: .monospaced))
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(viewModel.bibInput.isEmpty ? .secondary.opacity(0.3) : Color.primary)
                        .frame(height: 80)
                    
                    if let message = self.viewModel.lastActionMessage {
                        Text(message)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.vertical,8)
                            .padding(.horizontal,20)
                            .background(Color(viewModel.isSuccess ? .green : .red))
                            .clipShape(.capsule)
                            .transition(.scale.combined(with: .opacity))
                    }else{
                        Text(" ")
                            .padding(.vertical, 8)
                    }
                }
                .padding(.top,20)
                
                Divider()
                
                //MARK: Keyboard
                LazyVGrid(columns: columns, spacing: 20){
                    ForEach(1...9, id: \.self){ num in
                        keypadButton("\(num)"){
                            viewModel.append("\(num)")
                        }
                    }
                    
                    Button{
                        viewModel.deleteLast()
                    } label: {
                        Image(systemName: "delete.left.fill")
                            .font(.title)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundStyle(.red)
                    }
                    .frame(height: 80)
                    
                    keypadButton("0"){
                        viewModel.append("0")
                    }
                    
                    Button {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        withAnimation {
                            viewModel.sumbit(context: context, session: sessionManager)
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.largeTitle)
                            .bold()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(viewModel.bibInput.isEmpty ? Color.gray : Color.green)
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                    }
                    .frame(height: 80)
                    .disabled(viewModel.bibInput.isEmpty)
                }
                .padding(.horizontal)
                
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Close"){
                        dismiss()
                    }
                }
            }
            
        }
        
        
    }
    
    private func keypadButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .foregroundStyle(.slateBlue.opacity(0.9))
                .clipShape(Circle())
        }
        .frame(height: 80)
    }
}

#Preview {
    ManualEntryView()
        .environment(SessionManager())
}
