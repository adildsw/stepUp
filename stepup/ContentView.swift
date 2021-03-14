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
    
    @State private var accX : Double = 0.0
    @State private var accY : Double = 0.0
    @State private var accZ : Double = 0.0
    
    @State private var dataArray : [ChartDataEntry] = []
    
    @State private var test: String = "Not Running"
    
    @State private var timeIdx : Int = 0
    
    @State private var stepCounter : Int = 0
    @State private var stepFlag : Bool = true
    
    let motion = CMMotionManager()
    
    var body: some View {
        
        VStack(spacing: 30.0) {
            VStack {
                Text("Steps")
                    .font(.title)
                    .fontWeight(.black)
                    .padding(5.0)

                Text(String(stepCounter))
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundColor(Color.white)
                    .padding(5.0)
                    .background(Color.red)
                
//                Text("Acceleration X")
//                    .font(.title)
//                    .fontWeight(.black)
//                    .padding(5.0)
//
//                Text(String(accX))
//                    .font(.title)
//                    .fontWeight(.black)
//                    .foregroundColor(Color.white)
//                    .padding(5.0)
//                    .background(Color.red)
//
//
//                Text("Acceleration Y")
//                    .font(.title)
//                    .fontWeight(.black)
//                    .padding(5.0)
//
//                Text(String(accY))
//                    .font(.title)
//                    .fontWeight(.black)
//                    .foregroundColor(Color.white)
//                    .padding(5.0)
//                    .background(Color.green)
//
//
//                Text("Acceleration Z")
//                    .font(.title)
//                    .fontWeight(.black)
//                    .padding(5.0)
//
//                Text(String(accZ))
//                    .font(.title)
//                    .fontWeight(.black)
//                    .foregroundColor(Color.white)
//                    .padding(5.0)
//                    .background(Color.blue)
            }
            
            LineChart(dataArray: dataArray)
            
            HStack {
                Button(action: startAccelerometers, label: {
                    Text(test)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                })
                    .padding(10.0)
                .background(Color.yellow)
                
                Button(action: resetStep, label: {
                    Text("Reset")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                })
                    .padding(10.0)
                .background(Color.blue)
            }
            
        }
        .padding(0.0)
        .onAppear {
            self.motion.startAccelerometerUpdates()
            print("Here")
        }
        .onDisappear {
            self.motion.stopAccelerometerUpdates()
            print("Not Here")
        }
        
    }
    
    func resetStep() {
        stepCounter = 0
    }
    
    func startAccelerometers() {
        if test == "Running" {
            test = "Not Running"
        }
        else {
            test = "Running"
        }
        
//        self.motion.accelerometerUpdateInterval = 1.0 / 60.0
//        self.motion.startAccelerometerUpdates()
        
        if self.motion.isAccelerometerActive {
        
            let timer = Timer(fire: Date(), interval: (1.0 / 60.0), repeats: true, block: { (timer) in
                if test == "Running" {
                    if let data = self.motion.accelerometerData {
                        accX = round(data.acceleration.x * 10000) / 10000
                        accY = round(data.acceleration.y * 10000) / 10000
                        accZ = round(data.acceleration.z * 10000) / 10000

                        // Write logic here
                        
                        let aggAcc : Double = sqrt(pow(accY, 2) + pow(accZ, 2) + pow(accX, 2))
                        print(aggAcc)
                        
                        dataArray.append(ChartDataEntry(x: Double(timeIdx), y:aggAcc))
                        if dataArray.count > 300 {
                            dataArray.removeFirst()
                        }
                        timeIdx += 1
                        
                        if aggAcc > 1.15 && stepFlag == true {
                            stepCounter += 1
                            stepFlag = false
                        }
                        else if aggAcc <= 1 {
                            stepFlag = true
                        }
                    }
                }
            })

            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
