//
//  QuestListView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.12.2025.
//

import SwiftUI
import SwiftData

struct QuestListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var quests: [Quest]
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    QuestListView()
}
