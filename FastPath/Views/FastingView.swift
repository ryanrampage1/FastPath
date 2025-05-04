//
//  FastingView.swift
//  FastPath
//
//  Created on 5/4/25.
//

import SwiftUI
import ComposableArchitecture

struct FastingView: View {
    let store: StoreOf<FastingFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 30) {
                // Title
                Text("FastPath")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Timer display
                VStack(spacing: 10) {
                    Text(viewStore.isFasting ? "Fasting in progress" : "Ready to start fasting")
                        .font(.headline)
                        .foregroundColor(viewStore.isFasting ? .green : .gray)
                    
                    Text(formatTimeInterval(viewStore.isFasting ? viewStore.currentElapsedTime : 0))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(viewStore.isFasting ? .primary : .secondary)
                        .monospacedDigit()
                        .frame(height: 70)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                if viewStore.isFasting {
                    Button(action: {
                        viewStore.send(.stopFastButtonTapped)
                    }) {
                        Text("Stop Fast")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red)
                            )
                    }
                    .padding(.horizontal)
                } else {
                    Button(action: {
                        viewStore.send(.startFastButtonTapped)
                    }) {
                        Text("Start Fast")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green)
                            )
                    }
                    .padding(.horizontal)
                }
                
                // History button
                Button(action: {
                    viewStore.send(.historyButtonTapped)
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Fasting History")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                }
                .padding(.bottom)
            }
            .onAppear {
                viewStore.send(.loadInitialState)
            }
        }
    }
    
    // Helper function to format time interval
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        
        return formatter.string(from: interval) ?? "00:00:00"
    }
}

#Preview {
    FastingView(
        store: Store(
            initialState: FastingFeature.State(),
            reducer: { FastingFeature() }
        )
    )
}
