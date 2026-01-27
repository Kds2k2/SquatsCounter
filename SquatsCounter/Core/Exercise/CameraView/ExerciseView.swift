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
        ZStack {
            GeometryReader { geo in
                ExerciseCameraView(delegate: delegate)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                
                StickFigureView(delegate: delegate, size: geo.size)
            }
            
            trailingStack
            bottomStack
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var trailingStack: some View {
        VStack {
            HStack {
                Spacer()
                
                if !delegate.isBodyPose {
                    Image(systemName: "figure.arms.open")
                        .frame(width: 32, height: 32)
                        .padding()
                        .background(.gray.opacity(0.2))
                        .foregroundStyle(.surface)
                        .clipShape(Circle())
                        .animation(.easeIn(duration: 0.3), value: !delegate.isBodyPose)
                }
                
                if !delegate.isBodyParts {
                    Image(systemName: "hand.raised.slash.fill")
                        .frame(width: 32, height: 32)
                        .padding()
                        .background(.gray.opacity(0.2))
                        .foregroundStyle(.surface)
                        .clipShape(Circle())
                        .animation(.easeIn(duration: 0.3), value: !delegate.isBodyPose)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private var bottomStack: some View {
        VStack {
            Spacer()
            
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
}
