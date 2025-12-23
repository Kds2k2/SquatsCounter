//
//  AddExerciseView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 20.10.2025.
//

import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var repeatCount = 10
    @State private var showingEmptyPatternsAlert = false
    
    @Query private var patterns: [ExercisePattern]
    @State private var selectedPattern: ExercisePattern?
    
    let onCreatePattern: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing) {
                FocusableTextField(text: $name, autoFocus: true, placeholder: "Exercise name")
                
                if patterns.isEmpty {
                    // Show message when no patterns exist
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("No patterns available")
                            .font(.headline)
                        
                        Text("You need to create a custom pattern first")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.vertical, 4)
                } else {
                    Picker("Pattern", selection: $selectedPattern) {
                        Text("Select a pattern")
                            .tag(Optional<ExercisePattern>(nil))
                        
                        ForEach(patterns) { pattern in
                            Text(pattern.name)
                                .tag(Optional(pattern))
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                if !patterns.isEmpty {
                    Picker("Repeat count", selection: $repeatCount) {
                        ForEach(1...100, id: \.self) { count in
                            Text("\(count)")
                                .tag(count)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 50)
                }
                
                HStack {
                    Button("Create Custom Pattern") {
                        onCreatePattern()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveExercise()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(patterns.isEmpty || selectedPattern == nil || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.top, 8)
            }
            .padding()
            .frame(height: patterns.isEmpty ? 160 : 220) // Adjust height based on content
            .frame(maxWidth: .infinity)
            .onAppear {
                if !patterns.isEmpty {
                    selectedPattern = patterns.first
                }
            }
            .alert("No Patterns Available", isPresented: $showingEmptyPatternsAlert) {
                Button("Create Pattern", action: onCreatePattern)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You need to create a custom pattern before adding an exercise.")
            }
        }
    }
    
    private func saveExercise() {
        guard let pattern = selectedPattern else {
            if patterns.isEmpty {
                showingEmptyPatternsAlert = true
            }
            return
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        print("Saved: \(trimmedName), \(pattern.name), \(repeatCount)x")
        
        let ex = Exercise(name: trimmedName, pattern: pattern, requiredCount: repeatCount)
        modelContext.insert(ex)
        try? modelContext.save()
        dismiss()
    }
}
