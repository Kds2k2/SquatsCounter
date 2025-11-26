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
            
            HStack {
                Text("Required count:")
                    .fontWeight(.semibold)
                Text("\(exercise.requiredCount)")
            }
        }
    }
}

#Preview {
    @Previewable @State var item = Exercise(name: "123", type: .squating, requiredCount: 22)
    ExerciseItemView(exercise: item)
}
