//
//  Double+toKM.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 28.12.2025.
//

extension Double {
    var toKM: String {
        let km = String(format: "%.2f", self / 1000)
        return "\(km) km"
    }
}
