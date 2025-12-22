//
//  ExerciseListView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 04.12.2025.
//

import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    
    @State private var showAddExercise = false
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: AppColors.textPrimary.uiColor]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: AppColors.textPrimary.uiColor]
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                List {
                    ForEach(ExerciseType.allCases) { type in
                        let items = exercises.filter { $0.type == type }
                        if !items.isEmpty {
                            Section(type.displayName) {
                                ForEach(items) { exercise in
                                    NavigationLink {
                                        ExerciseView(exercise: exercise)
                                    } label: {
                                        ExerciseItemView(exercise: exercise)
                                    }
                                }
                                .onDelete { indexSet in
                                    deleteExercises(at: indexSet, from: items)
                                }
                            }
                        }
                    }
                    
                    let customExercises = exercises.filter { $0.type == .custom }
                    if !customExercises.isEmpty {
                        Section("Custom Exercises") {
                            ForEach(customExercises) { exercise in
                                NavigationLink {
                                    ExerciseView(exercise: exercise)
                                } label: {
                                    ExerciseItemView(exercise: exercise)
                                }
                            }
                            .onDelete { indexSet in
                                deleteExercises(at: indexSet, from: customExercises)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(AppColors.background)
                .navigationTitle("Exercises")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withoutAnimation {
                                showAddExercise = true
                            }
                        } label: {
                            Label("Add Exercise", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAddExercise) {
                    AddExerciseView()
                        .presentationDetents([.height(160)])
                        .interactiveDismissDisabled(false)
                        .presentationBackgroundInteraction(.disabled)
                        .presentationDragIndicator(.hidden)
                }
            }
        }
        .onAppear() {
            reset()
        }
    }
    
    private func reset() {
        let manager = DailyResetManager.shared
        
        guard manager.needsReset() else { return }
        
        for exercise in exercises {
            exercise.refresh()
            exercise.streak?.check()
        }

        try? modelContext.save()
        manager.lastReset = Date()
    }
    
    private func deleteExercises(at offsets: IndexSet, from items: [Exercise]) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

#Preview {
    ExerciseListView()
}
