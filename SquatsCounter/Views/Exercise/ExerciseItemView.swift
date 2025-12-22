//
//  ExerciseItemView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 14.10.2025.
//

import SwiftUI
import Foundation

struct ExerciseItemView: View {
    var exercise: Exercise
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
                .font(.title2.bold())
                .foregroundStyle(AppColors.textPrimary)
            
            HStack {
                Text("Required count:")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.surface)
                Text("\(exercise.requiredCount)")
                    .foregroundStyle(AppColors.surface)
            }
            
            HStack {
                Text("Count:")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.surface)
                Text("\(exercise.count)")
                    .foregroundStyle(AppColors.surface)
            }
            
            HStack {
                Text("isDone:")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.surface)
                Text("\(exercise.isDone)")
                    .foregroundStyle(AppColors.surface)
            }
            
            HStack {
                Text("isStart:")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.surface)
                Text("\(exercise.isStart)")
                    .foregroundStyle(AppColors.surface)
            }
            
            HStack {
                Text("lastRefresh:")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.surface)
                Text(formatted(exercise.lastRefresh))
                    .foregroundStyle(AppColors.surface)
            }
            
            HStack {
                Text("Type:")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.surface)
                Text("\(exercise.type == .custom && exercise.customExercise != nil ? exercise.customExercise!.name : exercise.type.displayName)")
                    .foregroundStyle(AppColors.surface)
            }
            
            HStack {
                Text("Streak - count:")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.surface)
                Text("\(exercise.streak?.current)")
                    .foregroundStyle(AppColors.surface)
            }
            
            HStack {
                Text("Streak - best:")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.surface)
                Text("\(exercise.streak?.best)")
                    .foregroundStyle(AppColors.surface)
            }
            
            HStack {
                Text("Streak - lastCompleted:")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.surface)
                Text(formatted(exercise.streak?.lastCompleted))
                    .foregroundStyle(AppColors.surface)
            }
        }
    }
    
    private func formatted(_ date: Date?) -> String {
        guard let date else { return "—" }
        return dateFormatter.string(from: date)
    }
}

#Preview {
    @Previewable @State var item = Exercise(name: "123", type: .squating, requiredCount: 22)
    ExerciseItemView(exercise: item)
}
