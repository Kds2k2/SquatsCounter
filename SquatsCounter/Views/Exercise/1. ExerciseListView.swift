//
//  ExerciseListView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 04.12.2025.
//

import SwiftUI
import SwiftData

enum ExerciseSheet: Identifiable {
    case addExercise
    case createPattern
    
    var id: Int { hashValue }
}

struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    
    @State private var exerciseSheet: ExerciseSheet?
    @State private var showCreatePattern = false
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: AppColors.textPrimary.uiColor]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: AppColors.textPrimary.uiColor]
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                if exercises.isEmpty {
                    ContentUnavailableView {
                        Label("No Exercises", systemImage: "dumbbell")
                    } description: {
                        Text("Get started by adding your first exercise.")
                    } actions: {
                        Button {
                            withoutAnimation {
                                exerciseSheet = .addExercise
                            }
                        } label: {
                            Text("Add Exercise")
                                .font(.headline)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(exercises) { exercise in
                            NavigationLink {
                                ExerciseView(exercise: exercise)
                            } label: {
                                ExerciseItemView(exercise: exercise)
                            }
                        }
                        .onDelete { indexSet in
                            deleteExercises(at: indexSet, from: exercises)
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
                            exerciseSheet = .addExercise
                        }
                    } label: {
                        Label("Add Exercise", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $exerciseSheet) { sheet in
                switch sheet {
                case .addExercise:
                    AddExerciseView(onCreatePattern: {
                        exerciseSheet = nil
                        showCreatePattern = true
                    })
                    .presentationDetents([.height(160)])
                    .interactiveDismissDisabled(false)
                    .presentationBackgroundInteraction(.disabled)
                    .presentationDragIndicator(.hidden)
                case .createPattern:
                    CreateCustomExerciseView {
                        exerciseSheet = .addExercise
                    }
                }
            }
            .navigationDestination(isPresented: $showCreatePattern) {
                CreateCustomExerciseView {
                    showCreatePattern = false
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
