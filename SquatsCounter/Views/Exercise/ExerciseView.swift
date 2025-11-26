//
//  ExerciseView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 13.10.2025.
//

import SwiftUI

struct ExerciseView: View {
    
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var exercise: Exercise
    
    @StateObject var poseEstimator: PoseEstimator = PoseEstimator()
    @State private var isStarted: Bool = false
    @State private var isEdit: Bool = false
    @State private var isHide: Bool = false
    
    init(exercise: Exercise) {
        self.exercise = exercise
        _poseEstimator = StateObject(wrappedValue: PoseEstimator(type: exercise.type))
    }
    
    var body: some View {
        VStack {
            if isStarted {
                ZStack(alignment: .bottom) {
                    GeometryReader { geo in
                        FrontCameraView(poseEstimator: poseEstimator)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .background(Color.red)
                            .clipped()
                        
                        if !isHide {
                            StickFigureView(
                                postEstimator: poseEstimator,
                                size: geo.size,
                                exercise: exercise.type
                            )
                        }
                    }
                    
                    VStack {
                        HStack {
                            Text("\(exercise.type.rawValue) Counter:")
                                .font(.title)
                            Text(String(exercise.count))
                                .font(.title.bold())
                        }
                        
                        HStack {
                            Button {
                                stopExercise()
                            } label: {
                                Label("Stop", systemImage: "stop.circle.fill")
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.gradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                isHide.toggle()
                            } label: {
                                Label("Hide", systemImage: "figure")
                                    .font(.title3.bold())
                                    .padding()
                                    .background(Color.green.gradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.35))
                }
                .ignoresSafeArea()
                .onAppear {
                    poseEstimator.count = exercise.count
                }
                .onReceive(poseEstimator.$count) { newCount in
                    updateExerciseCount(newCount)
                }
            }
            else {
                VStack {
                    Form {
                        Section("Edit") {
                            TextField("Exercise name", text: $exercise.name)
                                .disabled(!isEdit)
                            
                            Picker("Type", selection: $exercise.type) {
                                ForEach(ExerciseType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            .disabled(!isEdit)
                            
                            Picker("Repeat count", selection: $exercise.requiredCount)
                            {
                                ForEach(1...100, id: \.self) { count in
                                    Text("\(count)").tag(count)
                                }
                            }
                            .pickerStyle(.wheel)
                            .disabled(!isEdit)
                            
                            if isEdit {
                                HStack {
                                    Button("Cancel") {
                                        //TODO: ...
                                        isEdit = false
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Save") {
                                        try? modelContext.save()
                                        isEdit = false
                                        poseEstimator.changeType(exercise.type)
                                    }
                                }
                            } else {
                                Button("Edit") {
                                    isEdit = true
                                }
                            }
                        }
                    }
                    
                    Button {
                        startExercise()
                    } label: {
                        Label("Start Exercise", systemImage: "figure.walk")
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isStarted)
    }
    
    // MARK: - Actions
    private func startExercise() {
        isStarted = true
    }
    
    private func stopExercise() {
        isStarted = false
        try? modelContext.save()
    }
    
    private func updateExerciseCount(_ newCount: Int) {
        exercise.count = newCount
        
        if exercise.count >= exercise.requiredCount {
            exercise.isDone = true
            exercise.isDoneDate = .now
            try? modelContext.save()
            isStarted = false
        }
    }
}
