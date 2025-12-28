//
//  ExerciseView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 26.12.2025.
//

import SwiftUI
import SwiftData

struct ExerciseView: View {
    var exercise: Exercise
    @StateObject var delegate: PoseEstimator
    
    init(exercise: Exercise) {
        self.exercise = exercise
        _delegate = StateObject(wrappedValue: PoseEstimator(exercisePattern: exercise.pattern!))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geo in
                ExerciseCameraView(delegate: delegate)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                
                StickFigureView(delegate: delegate, size: geo.size)
            }
            
            VStack {
                HStack {
                    Text("\(exercise.name) reps:")
                        .font(.title)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("\(exercise.count) / \(exercise.requiredCount)")
                        .font(.title.bold())
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
    }
}
