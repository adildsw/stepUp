//
//  ContentView.swift
//  stepup
//
//  Created by Adil Rahman on 3/13/21.
//

import SwiftUI
import CoreMotion
import Charts

struct ContentView: View {
    
    let motion = CMMotionManager()
    let refreshRate : Double = 1.0 / 60.0 // Data sampled at 60Hz
    
    @State private var accX : Double = 0.0
    @State private var accY : Double = 0.0
    @State private var accZ : Double = 0.0
    @State private var aggAcc : Double = 0.0
    
    private let avgSampleCount : Int = 5
    @State private var avgIdx : Int = 0
    @State private var avgAggAcc : Double = 0.0
    @State private var aggAccSamples : [Double] = []
    
    @State private var timeIdx : Int = 0
    @State private var dataArray : [ChartDataEntry] = []
    private var dataLabel : String = "YZ Acceleration Magnitude"
    
    @State private var isTimerRunning : Bool = false
    @State private var monitoring : Bool = false
    
    @State private var toggleLabel : String = "Start"
    @State private var toggleIcon : String = "play.circle.fill"
    @State private var toggleColor : Color = Color.green
    
    @State private var noAccelerometerErrorAlertFlag = false
    
    @State private var movementStatus : String = "Idle"
    @State private var movementStatusColor : Color = Color.gray
    @State private var stepCounter : Int = 0
    @State private var stepFlag : Bool = true
    
    @State private var lastStepTimeIdx : Int = 0
    @State private var lastMovementStatusTimeIdx : Int = 0
    
    private let stepThreshold : Double = 1.1
    private let stepReleaseThreshold : Double = 1.0
    private let runStepThreshold : Double = 1.4
    private let jumpThreshold : Double = 2.4
    private let jumpPenalty : Int = 2
    private let moveRetentionTimeThreshold = 40
    
    init() {
        self.motion.accelerometerUpdateInterval = refreshRate
        self.motion.startAccelerometerUpdates()
    }
    
    var body: some View {
        
        VStack {
            VStack {
                // Steps Counter UI
                Text("Steps")
                    .font(.title)
                    .fontWeight(.black)

                Text(String(stepCounter))
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundColor(Color.white)
                    .padding(5.0)
                    .background(Color.blue)
                
                // Movement Status UI
                Text("Movement Status")
                    .font(.title)
                    .fontWeight(.black)

                Text(String(movementStatus))
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundColor(Color.white)
                    .padding(5.0)
                    .background(movementStatusColor)
            }
            
            // Chart UI
            LineChart(dataArray: dataArray, dataLabel: dataLabel)
                .padding(.vertical)
            
            // Buttons UI
            HStack {
                Button(action: toggleMode, label: {
                    HStack {
                        Image(systemName: toggleIcon)
                            .accentColor(.white)
                            .imageScale(.large)
                        
                        Text(toggleLabel)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                })
                .padding(10.0)
                .background(toggleColor)
                .cornerRadius(8)
                
                Button(action: resetStep, label: {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .accentColor(.white)
                            .imageScale(.large)
                        
                        Text("Reset")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                })
                .padding(10.0)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
            }
        }
        .padding()
        .alert(isPresented: $noAccelerometerErrorAlertFlag, content: {
            noAccelerometerErrorAlert()
        })
        
    }
    
    func noAccelerometerErrorAlert() -> Alert {
        Alert(title: Text("Could Not Access Device Accelerometer"), message: Text("Please ensure that your device has an accelerometer and that you have sufficient privileges to access it."), dismissButton: .default(Text("Cancel"), action: {
            noAccelerometerErrorAlertFlag = false;
        }))
    }
    
    func resetStep() {
        stepCounter = 0
        dataArray.removeAll()
        timeIdx = 0
        lastStepTimeIdx = 0
        movementStatus = "Idle"
        movementStatusColor = Color.gray
        
        if monitoring {
            toggleMode()
        }
    }
    
    func toggleMode() {
        if !isTimerRunning {
            RunLoop.current.add(getStepCounterTimer(), forMode: RunLoop.Mode.default)
            isTimerRunning = true
        }
        
        if monitoring {
            monitoring = false
            toggleLabel = "Start"
            toggleIcon = "play.circle.fill"
            toggleColor = Color.green
        }
        else {
            if self.motion.isAccelerometerActive {
                monitoring = true
                toggleLabel = "Pause"
                toggleIcon = "pause.circle.fill"
                toggleColor = Color.orange
            }
            else {
                noAccelerometerErrorAlertFlag = true;
            }
        }
    }
    
    func getStepCounterTimer() -> Timer {
        let timer = Timer(fire: Date(), interval: refreshRate, repeats: true, block: { (timer) in
            if monitoring {
                if let data = self.motion.accelerometerData {
                    accX = data.acceleration.x
                    accY = data.acceleration.y
                    accZ = data.acceleration.z

                    aggAcc = sqrt(pow(accY, 2) + pow(accZ, 2))
                    
                    // Calculating running average
                    aggAccSamples.append(aggAcc)
                    if aggAccSamples.count > avgSampleCount {
                        aggAccSamples.removeFirst()
                    }
                    avgAggAcc = 0
                    for idx in 0...(aggAccSamples.count - 1) {
                        avgAggAcc += aggAccSamples[idx]
                    }
                    avgAggAcc = avgAggAcc / Double(aggAccSamples.count)
                    
                    dataArray.append(ChartDataEntry(x: Double(timeIdx), y:avgAggAcc))
                    if dataArray.count > 300 {
                        dataArray.removeFirst()
                    }
                    timeIdx += 1
                    
                    // Recording step
                    if avgAggAcc > stepThreshold && stepFlag == true {
                        stepCounter += 1
                        stepFlag = false
                        
                        // Storing the time when the last step was recorded
                        lastStepTimeIdx = timeIdx
                        
                        // Overwriting "Running" and "Jumping" status to "Walking" only if move retention time has passed
                        if movementStatus == "Idle" || timeIdx - lastStepTimeIdx > moveRetentionTimeThreshold || timeIdx - lastMovementStatusTimeIdx > moveRetentionTimeThreshold {
                            movementStatus = "Walking"
                            movementStatusColor = Color.green
                            lastMovementStatusTimeIdx = timeIdx
                        }
                        
                    }
                    else if avgAggAcc <= stepReleaseThreshold {
                        stepFlag = true
                    }
                    
                    // Determining movement status
                    if avgAggAcc > jumpThreshold {
                        // Only keeping track of the time when jumping was initially triggered
                        if movementStatus != "Jumping" {
                            lastStepTimeIdx = timeIdx
                            lastMovementStatusTimeIdx = timeIdx
                        }
                        
                        movementStatus = "Jumping"
                        movementStatusColor = Color.red
                        
                    }
                    else if avgAggAcc > runStepThreshold {
                        // Overwriting "Jumping" status to "Running" only if move retention time has passed
                        if movementStatus != "Jumping" || timeIdx - lastStepTimeIdx > moveRetentionTimeThreshold {
                            // Only keeping track of the time when running was initially triggered
                            if movementStatus != "Running" {
                                lastStepTimeIdx = timeIdx
                                lastMovementStatusTimeIdx = timeIdx
                            }
                            movementStatus = "Running"
                            movementStatusColor = Color.purple
                            
                        }
                    }
                    
                    // Resetting movement status if user is idle for more than moveRetentionTimeThreshold
                    if timeIdx - lastStepTimeIdx > moveRetentionTimeThreshold {
                        
                        // Applying a jump penalty on the total number of counted steps
                        if movementStatus == "Jumping" {
                            stepCounter -= jumpPenalty
                        }
                        
                        movementStatus = "Idle"
                        movementStatusColor = Color.gray
                    }
                }
            }
        })
        
        return timer
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
