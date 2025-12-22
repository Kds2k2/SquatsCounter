//
//  AddExerciseView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 20.10.2025.
//

import SwiftUI

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedType: ExerciseType = .pushUps
    @State private var repeatCount = 10
    @State private var showCustomExerciseCreation = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing) {
                FocusableTextField(text: $name, autoFocus: true, placeholder: "Exercise name")
                
                Picker("Type", selection: $selectedType) {
                    ForEach(ExerciseType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("Repeat count", selection: $repeatCount) {
                    ForEach(1...100, id: \.self) { count in
                        Text("\(count)")
                            .tag(count)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 50)
                
                HStack {
                    Button("Create Custom") {
                        showCustomExerciseCreation = true
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Save") {
                        print("Saved: \(name), \(selectedType.rawValue), \(repeatCount)x")
                        
                        let ex = Exercise(name: name, type: selectedType, requiredCount: repeatCount)
                        modelContext.insert(ex)
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
            .padding()
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .sheet(isPresented: $showCustomExerciseCreation) {
                CreateCustomExerciseView()
            }
        }
    }
}
