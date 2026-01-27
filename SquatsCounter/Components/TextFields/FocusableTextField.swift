//
//  FocusableTextField.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 21.10.2025.
//

import UIKit
import SwiftUI

struct FocusableTextField: UIViewRepresentable {
    @Binding var text: String
    var autoFocus: Bool = false
    var placeholder: String = ""
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.borderStyle = .roundedRect
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        
        if autoFocus {
            DispatchQueue.main.async {
                textField.becomeFirstResponder()
            }
        }
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FocusableTextField
        
        init(_ parent: FocusableTextField) {
            self.parent = parent
        }
        
        @objc func textChanged(_ sender: UITextField) {
            parent.text = sender.text ?? ""
        }
    }
}
