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
    
    func makeUIView(context: Context) -> LineChartView {
        let chart = LineChartView()
        chart.data = getData()
        return chart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = getData()
    }
    
    func getData() -> LineChartData {
        let dataSet = LineChartDataSet(entries: dataArray)
        dataSet.setColor(UIColor.purple)
        dataSet.circleRadius = 0.0
        
        let data = LineChartData(dataSet: dataSet)
        return data
    }
    
    typealias UIViewType = LineChartView
}

struct LineChart_Previews : PreviewProvider {
    static var previews: some View {
        LineChart(dataArray: [
            ChartDataEntry(x: 1, y: 2.6),
            ChartDataEntry(x: 2, y: 5),
            ChartDataEntry(x: 3, y: 3.2)
        ])
    }
}
