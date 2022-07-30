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
    let taskName: String
    let tasks: FetchRequest<Task>
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var canBeDeleted: Bool
    @State private var searchedStepName: String
    
    @State private var canCreateNewStep = false
    @State private var newStepName = ""
    @State private var newStepLengthHours = 0
    @State private var newStepLengtMinutes = 0
    @State private var newStepLengthSeconds = 0
    @State private var disposableStep: Step?
    @State private var stepNotDisposable = false
    
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
    
    init(stepsInTask: Binding<[Step]>, taskName: String) {
        _stepsInTask = stepsInTask
        self.taskName = taskName
        fetchedSteps = FetchRequest<Step>(
            entity: Step.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Step.name, ascending: true)]
        )
        _steps = State(wrappedValue: [])
        
        _canBeDeleted = State(wrappedValue: false)
        _searchedStepName = State(wrappedValue: "")
        
        tasks = FetchRequest<Task>(
            entity: Task.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Task.name, ascending: true)]
        )
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
                            Text(step.length.naturalLength())
                            
                            Image(systemName: "plus.circle.fill")
                                .renderingMode(.template)
                                .foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
            .onDelete { offsets in
                canBeDeleted.toggle()
                
                for offset in offsets {
                    disposableStep = searchedSteps[offset]
                }
            }
            .alert("Confirm delete step", isPresented: $canBeDeleted) {
                Button("Delete", role: .destructive) {
                    stepNotDisposable = deleteStep()
                    
                    if !stepNotDisposable {
                        steps.remove(at: steps.firstIndex(of: disposableStep!)!)
                    }
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            NavigationView {
                VStack {
                    HStack(alignment: .center) {
                        Text(taskName)
                            .font(.title2)
                    }
                    
                    List {
                        disposableSteps
                        
                        if canCreateNewStep {
                            NewStep(
                                canCreateNewStep: $canCreateNewStep,
                                newStepName: $newStepName,
                                newStepLengthHours: $newStepLengthHours,
                                newStepLengtMinutes: $newStepLengtMinutes,
                                newStepLengthSeconds: $newStepLengthSeconds,
                                steps: $steps,
                                geoWidth: geo.size.width
                            )
                        }
                        
                        availableSteps
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: $searchedStepName, prompt: "Type the name of the step")
                }
            }
            .onAppear {
                steps.append(contentsOf: fetchedSteps.wrappedValue.map({ $0 }))
            }
            .alert("Step could not be deleted", isPresented: $stepNotDisposable) {
                Button("Ok", role: .cancel) {}
            }
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
    
    private func onCreateNewStepClicked() {
        newStepName = ""
        newStepLengthHours = 0
        newStepLengtMinutes = 0
        newStepLengthSeconds = 0
        
        canCreateNewStep.toggle()
        canWriteName.toggle()
    }
    
    private func deleteStep() -> Bool {
        var cantBeDeleted = false
        for task in tasks.wrappedValue where task.taskSteps.contains(disposableStep!) && task.taskSteps.count == 1 {
            cantBeDeleted = true
            break
        }
        
        if cantBeDeleted {
            return true
        } else {
            dataController.container.viewContext.delete(disposableStep!)
            return false
        }
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
                Text(step.length.naturalLength())
                
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

struct NewStep: View {
    @EnvironmentObject var dataController: DataController
    @FocusState var canWriteName: Bool
    @Binding var canCreateNewStep: Bool
    @Binding var newStepName: String
    @Binding var newStepLengthHours: Int
    @Binding var newStepLengtMinutes: Int
    @Binding var newStepLengthSeconds: Int
    @Binding var steps: [Step]
    var geoWidth: CGFloat
    
    @State private var canPickLength = false
    
    var body: some View {
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
            
            VStack {
                Button {
                    canPickLength.toggle()
                } label: {
                    HStack {
                        Text("\(newStepLengthHours)h")
                        Text("\(newStepLengtMinutes)m")
                        Text("\(newStepLengthSeconds)s")
                        
                        Spacer()
                    }
                }
                
                if canPickLength {
                    HStack(spacing: 0) {
                        Picker("Step's length in hours", selection: $newStepLengthHours) {
                            ForEach(0...24, id: \.self) { hour in
                                Text("\(hour)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .overlay(Text("hrs").padding(.leading, 50))
                        .frame(width: geoWidth / 3.5)
                        .clipped()
                        .compositingGroup()
                        .onChange(of: newStepLengthHours) { _ in
                            setMinSeconds()
                        }
                        
                        Picker("Step's length in minutes", selection: $newStepLengtMinutes) {
                            ForEach(0...60, id: \.self) { minute in
                                Text("\(minute)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .overlay(Text("min").padding(.leading, 55))
                        .frame(width: geoWidth / 3.5)
                        .clipped()
                        .compositingGroup()
                        .onChange(of: newStepLengtMinutes) { _ in
                            setMinSeconds()
                        }
                        
                        Picker("Step's length in seconds", selection: $newStepLengthSeconds) {
                            let seconds = newStepLengthHours > 0 || newStepLengtMinutes > 0 ? 0...60 : 10...60
                            ForEach(seconds, id: \.self) { second in
                                Text("\(second)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .overlay(Text("sec").padding(.leading, 55))
                        .frame(width: geoWidth / 3.5)
                        .clipped()
                        .compositingGroup()
                        .onChange(of: newStepLengthSeconds) { _ in
                            setMinSeconds()
                        }
                    }
                }
                
            }
            
            Button("Add") {
                saveNewStep()
            }
            .disabled(newStepName.isEmpty)
        }
    }
    
    private func saveNewStep() {
        if !steps.contains(where: { $0.stepName == newStepName }) {
            let step = Step(context: dataController.container.viewContext)
            
            step.objectWillChange.send()
            
            let hours = (newStepLengthHours * 60) * 60
            let minutes = newStepLengtMinutes * 60
            step.length = Int16(hours + minutes + newStepLengthSeconds)
            step.name = newStepName
            
            steps.append(step)
        }
        
        canCreateNewStep.toggle()
    }
    
    private func setMinSeconds() {
        if newStepLengthHours == 0
            && newStepLengtMinutes == 0
            && (newStepLengthSeconds > 0 && newStepLengthSeconds < 10) {
            newStepLengthSeconds = 10
        }
    }
}

struct StepsView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        StepsView(
            stepsInTask: .constant(Task.example.taskSteps),
            taskName: Task.example.taskName
        )
        .environment(\.managedObjectContext, dataController.container.viewContext)
        .environmentObject(dataController)
    }
}

extension UIPickerView {
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: super.intrinsicContentSize.height)
    }
}
