import SwiftUI

struct DifficultyLevelPicker: View {
    @Binding var level: DifficultyLevel

    var body: some View {
        Picker("Difficulty Level", selection: $level) {
            Text("Easy").tag(DifficultyLevel.easy)
            Text("Normal").tag(DifficultyLevel.normal)
            Text("Hard").tag(DifficultyLevel.hard)
        }
        .labelsHidden()
        .pickerStyle(SegmentedPickerStyle())
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.blue, Color.red]),
                startPoint: .leading, endPoint: .trailing
            )
            .opacity(20/100)
            .cornerRadius(8)
        )
    }
}