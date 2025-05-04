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
                    
                    // Goal countdown display
                    if viewStore.isFasting, let goal = viewStore.fastingGoal {
                        VStack(spacing: 4) {
                            if viewStore.hasReachedGoal {
                                Text("Goal Reached! 🎉")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            } else if let remainingTime = viewStore.remainingTimeToGoal {
                                Text("Goal: \(formatDuration(goal.targetDuration))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Remaining: \(formatTimeInterval(remainingTime))")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.top, 8)
                    }
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
                
                // Goal and History buttons
                HStack(spacing: 20) {
                    Button(action: {
                        viewStore.send(.setGoalButtonTapped)
                    }) {
                        HStack {
                            Image(systemName: "target")
                            Text(viewStore.fastingGoal != nil ? "Change Goal" : "Set Goal")
                        }
                        .font(.headline)
                        .foregroundColor(.purple)
                    }
                    
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
                }
                .padding(.bottom, 8)
                
                // Live Activity toggle (iOS 16.1+ only)
                if #available(iOS 16.1, *) {
                    Toggle(isOn: viewStore.binding(get: \.liveActivityEnabled, send: { .toggleLiveActivity($0) })) {
                        HStack {
                            Image(systemName: "rectangle.inset.filled.and.person.filled")
                            Text("Show in Dynamic Island")
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .onAppear {
                viewStore.send(.loadInitialState)
            }
            .sheet(isPresented: viewStore.binding(get: \.showingGoalPicker, send: { _ in .goalPickerDismissed })) {
                GoalPickerView(store: store)
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
    
    // Helper function to format duration in a human-readable way
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if minutes == 0 {
            return "\(hours) hours"
        } else {
            return "\(hours)h \(minutes)m"
        }
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
