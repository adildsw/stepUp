//
//  LineChart.swift
//  stepup
//
//  Created by Adil Rahman on 3/13/21.
//

import Foundation
import SwiftUI
import Charts

struct LineChart : UIViewRepresentable {
    
    var dataArray : [ChartDataEntry]
    var dataLabel : String
    
    func makeUIView(context: Context) -> LineChartView {
        let chart = LineChartView()
        chart.data = getData()
        
        chart.setVisibleYRangeMinimum(1, axis: YAxis.AxisDependency.right)
        chart.leftAxis.axisMinimum = 0.5
        chart.rightAxis.axisMinimum = 0.5
        chart.setVisibleXRangeMinimum(0.0)
        
        chart.isUserInteractionEnabled = false
        
        return chart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = getData()
        
        uiView.setVisibleYRangeMinimum(1, axis: YAxis.AxisDependency.right)
        uiView.leftAxis.axisMinimum = 0.5
        uiView.rightAxis.axisMinimum = 0.5
        uiView.setVisibleXRangeMinimum(0.0)
        
        uiView.isUserInteractionEnabled = false
    }
    
    func getData() -> LineChartData {
        let dataSet : LineChartDataSet
        
        if dataArray.count == 0 {
            dataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: 0)])
        }
        else {
            dataSet = LineChartDataSet(entries: dataArray)
        }
        dataSet.label = dataLabel
        
        dataSet.setColor(UIColor.systemIndigo)
        dataSet.lineWidth = 2.0
        dataSet.valueTextColor = UIColor.black.withAlphaComponent(0) // Removing Point Value Text
        dataSet.circleRadius = 0.0 // Removing Point Marker Circle
        
        return LineChartData(dataSet: dataSet)
    }
    
    typealias UIViewType = LineChartView
}

struct LineChart_Previews : PreviewProvider {
    static var previews: some View {
        LineChart(dataArray: [
            ChartDataEntry(x: 1, y: 0.3),
            ChartDataEntry(x: 200, y: 2.3),
            ChartDataEntry(x: 300, y: 1.3)
        ], dataLabel: "YZ Acceleration Magnitude")
    }
}
