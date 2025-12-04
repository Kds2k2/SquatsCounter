//
//  ExerciseItemView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 14.10.2025.
//

import SwiftUI

struct ExerciseItemView: View {
    var exercise: Exercise
    
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
                Text("\(exercise.lastRefresh)")
                    .foregroundStyle(AppColors.surface)
            }
            
            HStack {
                Text("Type:")
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.surface)
                Text("\(exercise.type.rawValue)")
                    .foregroundStyle(AppColors.surface)
            }
        }
    }
}

#Preview {
    @Previewable @State var item = Exercise(name: "123", type: .squating, requiredCount: 22)
    ExerciseItemView(exercise: item)
}
