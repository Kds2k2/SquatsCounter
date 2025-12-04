//
//  ExerciseView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 13.10.2025.
//

import SwiftUI

//Fix logic

struct ExerciseView: View {
    
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var exercise: Exercise
    
    @StateObject var poseEstimator: PoseEstimator
    @State private var isStarted: Bool = false
    @State private var isPaused: Bool = false
    @State private var isEdit: Bool = false
    @State private var isHide: Bool = false
    
    init(exercise: Exercise) {
        self.exercise = exercise
        _poseEstimator = StateObject(wrappedValue: PoseEstimator(type: exercise.type, count: exercise.count))
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
                        .foregroundStyle(AppColors.textPrimary)
                    Text(String(exercise.count))
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
                print("LOG0-apper-exer.count:\(exercise.count)")
                print("LOG0-apper-eposeEstimator.count:\(poseEstimator.count)")
                
                poseEstimator.count = exercise.count
                
                print("LOG1-apper-exer.count:\(exercise.count)")
                print("LOG1-apper-poseEstimator.count:\(poseEstimator.count)")
            }
            .onReceive(poseEstimator.$count) { newCount in
                print("LOG2-onReceive-newCount:\(newCount)")
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
                            Text(type.rawValue).tag(type)
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
                                poseEstimator.changeType(exercise.type)
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
            isStarted = false
        }
        
        try? modelContext.save()
    }
}

//var body: some View {
//    VStack {
//        if isStarted {
//            ZStack(alignment: .bottom) {
//                GeometryReader { geo in
//                    FrontCameraView(poseEstimator: poseEstimator)
//                        .frame(width: geo.size.width, height: geo.size.height)
//                        .background(Color.red)
//                        .clipped()
//                    
//                    if !isHide {
//                        StickFigureView(
//                            postEstimator: poseEstimator,
//                            size: geo.size,
//                            exercise: exercise.type
//                        )
//                    }
//                }
//                
//                VStack {
//                    HStack {
//                        Text("\(exercise.type.rawValue) Counter:")
//                            .font(.title)
//                        Text(String(exercise.count))
//                            .font(.title.bold())
//                    }
//                    
//                    HStack {
//                        Button {
//                            stopExercise()
//                        } label: {
//                            Label("Stop", systemImage: "stop.circle.fill")
//                                .font(.title3.bold())
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.red.gradient)
//                                .foregroundColor(.white)
//                                .cornerRadius(12)
//                        }
//                        
//                        Button {
//                            isHide.toggle()
//                        } label: {
//                            Label("Hide", systemImage: "figure")
//                                .font(.title3.bold())
//                                .padding()
//                                .background(Color.green.gradient)
//                                .foregroundColor(.white)
//                                .cornerRadius(12)
//                        }
//                    }
//                }
//                .padding()
//                .background(Color.gray.opacity(0.35))
//            }
//            .ignoresSafeArea()
//            .onAppear {
//                poseEstimator.count = exercise.count
//            }
//            .onReceive(poseEstimator.$count) { newCount in
//                updateExerciseCount(newCount)
//            }
//        }
//        else {
//            VStack {
//                Form {
//                    Section("Edit") {
//                        TextField("Exercise name", text: $exercise.name)
//                            .disabled(!isEdit)
//                        
//                        Picker("Type", selection: $exercise.type) {
//                            ForEach(ExerciseType.allCases) { type in
//                                Text(type.rawValue).tag(type)
//                            }
//                        }
//                        .pickerStyle(.segmented)
//                        .disabled(!isEdit)
//                        
//                        Picker("Repeat count", selection: $exercise.requiredCount)
//                        {
//                            ForEach(1...100, id: \.self) { count in
//                                Text("\(count)").tag(count)
//                            }
//                        }
//                        .pickerStyle(.wheel)
//                        .disabled(!isEdit)
//                        
//                        if isEdit {
//                            HStack {
//                                Button("Cancel") {
//                                    //TODO: ...
//                                    isEdit = false
//                                }
//                                
//                                Spacer()
//                                
//                                Button("Save") {
//                                    try? modelContext.save()
//                                    isEdit = false
//                                    poseEstimator.changeType(exercise.type)
//                                }
//                            }
//                        } else {
//                            Button("Edit") {
//                                isEdit = true
//                            }
//                        }
//                    }
//                }
//                
//                Button(action: {
//                    startExercise()
//                }) {
//                    Text("Start Exercise")
//                        .foregroundStyle(AppColors.background)
//                        .font(.system(size: 20, weight: .semibold))
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 30)
//                        .padding(15)
//                        .background(AppColors.textPrimary)
//                        .clipShape(RoundedRectangle(cornerRadius: 30))
//                }
//                .safeAreaPadding(.bottom)
//            }
//        }
//    }
//    .animation(.easeInOut(duration: 0.3), value: isStarted)
//}
