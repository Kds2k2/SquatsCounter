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
    @State private var showCreatePattern = false
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: AppColors.textPrimary.uiColor]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: AppColors.textPrimary.uiColor]
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                if exercises.isEmpty {
                    ContentUnavailableView {
                        Label("No Exercises", systemImage: "dumbbell")
                    } description: {
                        Text("Get started by adding your first exercise.")
                    } actions: {
                        Button {
                            withoutAnimation {
                                showAddExercise = true
                            }
                        } label: {
                            Text("Add Exercise")
                                .font(.headline)
                                .foregroundStyle(AppColors.background)
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
                            showAddExercise = true
                        }
                    } label: {
                        Label("Add Exercise", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddExercise) {
                AddExerciseView(onCreatePattern: {
                    showAddExercise = false
                    showCreatePattern = true
                })
                .presentationDetents([.height(160)])
                .interactiveDismissDisabled(false)
                .presentationBackgroundInteraction(.disabled)
                .presentationDragIndicator(.hidden)
            }
            .navigationDestination(isPresented: $showCreatePattern) {
                AddPatternView()
            }
            .onAppear() {
                reset()
            }
        }
    }
    
    private func reset() {
        let manager = DailyResetManager.shared
        
        guard manager.needsReset() else { return }
        
        for exercise in exercises {
            exercise.refresh()
            exercise.streak.check()
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
