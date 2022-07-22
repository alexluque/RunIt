//
//  StepsView.swift
//  RunIt
//
//  Created by Àlex G. Luque on 19/7/22.
//

import SwiftUI

struct StepsView: View {
    @EnvironmentObject var dataController: DataController
    @Binding var stepsInTask: [Step]
    @State var steps: [Step]
    let fetchedSteps: FetchRequest<Step>
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var canBeDeleted: Bool
    @State private var searchedStepName: String
    
    @State private var canCreateNewStep = false
    @State private var newStepName = ""
    @State private var newStepLength = ""
    @FocusState private var canWriteName: Bool
    
    var sortedStepsInTask: [Step] {
        stepsInTask.sorted(by: { $0.stepName < $1.stepName })
    }
    var searchedSteps: [Step] {
        let selectableSteps = steps.filter { step in
            !stepsInTask.contains(step)
        }
        
        if searchedStepName.isEmpty {
            return selectableSteps.map({ $0 })
                .sorted(by: { $0.stepName < $1.stepName })
        } else {
            return selectableSteps.filter { step in
                step.stepName.contains(searchedStepName)
            }
            .sorted(by: { $0.stepName < $1.stepName })
        }
    }
    
    init(stepsInTask: Binding<[Step]>) {
        _stepsInTask = stepsInTask
        fetchedSteps = FetchRequest<Step>(
            entity: Step.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Step.name, ascending: true)]
        )
        _steps = State(wrappedValue: [])
        
        _canBeDeleted = State(wrappedValue: false)
        _searchedStepName = State(wrappedValue: "")
    }
    
    var disposableSteps: some View {
        Section(header: Text("Steps in task")) {
            ForEach(sortedStepsInTask) { step in
                Button {
                    swapDisposableStep(step)
                } label: {
                    DisposableStep(step: step, sortedStepsInTask: sortedStepsInTask)
                }
            }
        }
    }
    var newStep: some View {
        Section(
            header: HStack {
                Text("New Step")
                
                Spacer()
                
                Button("Cancel") {
                    canCreateNewStep.toggle()
                }
            }
        ) {
            TextField("Step name", text: $newStepName)
                .padding(5)
                .border(newStepName.isEmpty ? Color.red : Color.clear)
                .focused($canWriteName)
            
            TextField("Step length in seconds", text: $newStepLength)
                .keyboardType(.numberPad)
            
            Button("Save") {
                saveNewStep()
            }
            .disabled(newStepName.isEmpty)
        }
    }
    var availableSteps: some View {
        Section(
            header: HStack {
                Text("Steps")
                
                Spacer()
                
                if !canCreateNewStep {
                    Button("Create") {
                        onCreateNewStepClicked()
                    }
                }
            }
        ) {
            ForEach(searchedSteps) { step in
                Button {
                    steps.remove(at: steps.firstIndex(of: step)!)
                    stepsInTask.append(step)
                } label: {
                    HStack {
                        Text(step.stepName)
                        
                        Spacer()
                        
                        HStack {
                            Text(step.length > 0 ? "\(step.length) Sec." : "No length defined")
                            
                            Image(systemName: "plus.circle.fill")
                                .renderingMode(.template)
                                .foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
            .onDelete { _ in
                canBeDeleted.toggle()
            }
            .alert("Do you want to delete the step?", isPresented: $canBeDeleted) {
                Button("Delete", role: .destructive) {
                    /// TODO remove step
                    /// In order to remove the step we need to check if it is the only existing step in some task,
                    /// and only remove it if it's not.
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                disposableSteps
                
                if canCreateNewStep {
                    newStep
                }                
                
                availableSteps
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchedStepName, prompt: "Type the name of the step")
        }
        .onAppear {
            steps.append(contentsOf: fetchedSteps.wrappedValue.map({ $0 }))
        }
    }
    
    private func swapDisposableStep(_ step: Step) {
        if sortedStepsInTask.count > 1 {
            stepsInTask.remove(at: stepsInTask.firstIndex(of: step)!)
            
            if !steps.contains(step) {
                steps.append(step)
            }
        }
    }
    
    private func saveNewStep() {
        if !steps.contains(where: { $0.stepName == newStepName }) {
            let step = Step(context: dataController.container.viewContext)
            
            step.objectWillChange.send()
            
            step.name = newStepName
            step.length = Int16(newStepLength) ?? 0
            
            steps.append(step)
        }
        
        canCreateNewStep.toggle()
    }
    
    private func onCreateNewStepClicked() {
        newStepName = ""
        newStepLength = ""
        
        canCreateNewStep.toggle()
        canWriteName.toggle()
    }
}

struct DisposableStep: View {
    let step: Step
    var sortedStepsInTask: [Step]
    
    var body: some View {
        HStack {
            Text(step.stepName)
            
            Spacer()
            
            HStack {
                Text(step.length > 0 ? "\(step.length) Sec." : "No length defined")
                
                if sortedStepsInTask.count > 1 {
                    Image(systemName: "minus.circle.fill")
                        .renderingMode(.template)
                        .foregroundColor(.red)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

struct StepsView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        StepsView(stepsInTask: .constant(Task.example.taskSteps))
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
