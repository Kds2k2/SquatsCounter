//
//  ExerciseView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 13.10.2025.
//

import SwiftUI

//1. Animation for change screen 'isStarted'

struct ExerciseView: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject var poseEstimator: PoseEstimator
    @ObservedObject var exercise: Exercise
    
    @State private var isStarted: Bool = false
    @State private var isPaused: Bool = false
    @State private var isEdit: Bool = false
    @State private var isHide: Bool = false
    
    init(exercise: Exercise) {
        self.exercise = exercise
        _poseEstimator = StateObject(wrappedValue: PoseEstimator(type: exercise.type, count: exercise.count, customExercise: exercise.customExercise))
    }
    
    var body: some View {
        content
            .animation(.easeInOut(duration: 0.3), value: isStarted)
    }
    
    @ViewBuilder
    private var content: some View {
        if isStarted {
            exerciseView
                .toolbar(.hidden, for: .tabBar)
        } else {
            editView
        }
    }
    
    private var exerciseView: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geo in
                FrontCameraView(poseEstimator: poseEstimator)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                
                if !isHide {
                    StickFigureView(postEstimator: poseEstimator, size: geo.size, exercise: exercise.type)
                }
            }
            
            VStack {
                HStack {
                    Text("\(exercise.displayName) reps:")
                        .font(.title)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("\(exercise.count) / \(exercise.requiredCount)")
                        .font(.title.bold())
                        .foregroundStyle(AppColors.textPrimary)
                }
                
                HStack {
                    HStack {
                        if isPaused {
                            Button {
                                stopExercise()
                            } label: {
                                Label("Stop", systemImage: "stop.circle.fill")
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.gradient)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                continueExercise()
                            } label: {
                                Label("Continue", systemImage: "play.fill")
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.gradient)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .cornerRadius(12)
                            }
                        } else {
                            Button {
                                pauseExercise()
                            } label: {
                                Label("Pause", systemImage: "pause.fill")
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.yellow.gradient)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    
                    Button {
                        isHide.toggle()
                    } label: {
                        Label("", systemImage: isHide ? "eye.fill" : "eye.slash.fill")
                            .font(.title3.bold())
                            .padding()
                            .background(Color.purple.gradient)
                            .foregroundStyle(AppColors.textPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background {
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.black, Color.black.opacity(0.8), Color.black.opacity(0.5), Color.clear]), startPoint: .bottom, endPoint: .top)
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: 300)
                }
            }
            .ignoresSafeArea()
            .onAppear {
                poseEstimator.count = exercise.count
            }
            .onReceive(poseEstimator.$count) { newCount in
                if newCount >= exercise.count {
                    updateExerciseCount(newCount)
                }
            }
        }
    }
    
    private var editView: some View {
        VStack {
            Form {
                Section("Edit") {
                    TextField("Exercise name", text: $exercise.name)
                        .disabled(!isEdit)
                    
                    Picker("Type", selection: $exercise.type) {
                        ForEach(ExerciseType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .disabled(!isEdit)
                    
                    Picker("Repeat count", selection: $exercise.requiredCount) {
                        ForEach(1...100, id: \.self) { count in
                            Text("\(count)").tag(count)
                        }
                    }
                    .pickerStyle(.wheel)
                    .disabled(!isEdit)
                    
                    if isEdit {
                        HStack {
                            Button("Cancel") { isEdit = false }
                            Spacer()
                            Button("Save") {
                                try? modelContext.save()
                                isEdit = false
                                poseEstimator.changeType(exercise.type, customExercise: exercise.customExercise)
                            }
                        }
                    } else {
                        Button("Edit") { isEdit = true }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            
            Button(action: { startExercise() }) {
                Text(exercise.isStart ? "Continue Exercise" : "Start Exercise")
                    .foregroundStyle(AppColors.background)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                    .padding(15)
                    .background(AppColors.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            }
            .disabled(exercise.isDone)
            .padding(.horizontal)
            .safeAreaPadding(.bottom)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
    
    private func startExercise() {
        isStarted = true
        exercise.isStart = true
    }
    
    private func pauseExercise() {
        isPaused = true
        poseEstimator.isPaused = isPaused
    }
    
    private func continueExercise() {
        isPaused = false
        poseEstimator.isPaused = isPaused
    }
    
    private func stopExercise() {
        isStarted = false
        try? modelContext.save()
    }
    
    private func updateExerciseCount(_ newCount: Int) {
        exercise.count = newCount
        
        if exercise.count >= exercise.requiredCount {
            exercise.isDone = true
            exercise.streak?.recordCompletion()
            isStarted = false
        }
        
        try? modelContext.save()
    }
}
