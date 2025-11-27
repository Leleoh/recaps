//
//  InvitePopUp.swift
//  recaps
//
//  Created by Ana Poletto on 26/11/25.
//

import SwiftUI

struct JoinPopUp: View {
    @Binding var isShowing: Bool
    let join: (String) -> Void
    @Binding var joinErrorMessage: String?
    
    @State private var code: String = ""
    private let numberOfCells = 5
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { isShowing = false }
            
            popupContainer
        }
        .onChange(of: isShowing) { _, newValue in
            if !newValue {
                code = ""
                joinErrorMessage = nil
            }
        }
    }
    
    // MARK: - Popup content com glassEffect condicional
    private var popupContainer: some View {
        
        let content = VStack(alignment: .leading, spacing: 29) {
            
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 34){
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Join Recapsule")
                            .font(.headline)
                            .foregroundColor(.labelPrimary)
                        
                        Text("Insert invite code to join.")
                            .font(.body)
                            .foregroundColor(.labelPrimary)
                    }
                    
                    HStack(spacing: 8) {
                        ForEach(0..<numberOfCells, id: \.self) { index in
                            Text(index < code.count ?
                                 String(code[code.index(code.startIndex, offsetBy: index)]) : "")
                            .font(.headline)
                            .frame(width: 48, height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.fillDarkSecondary)
                            )
                        }
                    }
                    .overlay(
                        TextField("", text: $code)
                            .focused($isTextFieldFocused)
                            .foregroundColor(.clear)
                            .accentColor(.clear)
                            .onChange(of: code) { _, newValue in
                                if newValue.count > numberOfCells {
                                    code = String(newValue.prefix(numberOfCells))
                                }
                                joinErrorMessage = nil
                            }
                            .frame(width: 0, height: 0)
                    )
                    .onAppear { isTextFieldFocused = true
                        code = ""
                        joinErrorMessage = nil}
                }
                
                if let errorCode = joinErrorMessage {
                    Text(errorMessage(errorCode))
                        .font(.subheadline)
                        .foregroundColor(.sweetNSour)
                        .frame(maxWidth: 272)
                }
            }
            
            HStack(spacing: 12) {
                Button {
                    isShowing = false
                    code = ""
                    joinErrorMessage = nil
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: 128, minHeight: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.fillsSecondary)
                        )
                        .foregroundColor(.labelPrimary)
                }
                
                Button {
                    join(code)
                } label: {
                    Text("Join")
                        .frame(maxWidth: 128, minHeight: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(code.count < numberOfCells ? .fillsSecondary : Color.accentColor)
                        )
                        .foregroundColor(.labelPrimary)
                }
                .disabled(code.count < numberOfCells)
            }
        }
            .padding(.vertical, 22)
            .padding(.horizontal, 14)
        return Group {
            if #available(iOS 18.0, *) {
                content
                    .glassEffect(in: .rect(cornerRadius: 32))
            } else {
                content
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(.ultraThinMaterial)
                    )
            }
        }
    }
    
    // MARK: - Error messages
    private func errorMessage(_ code: String) -> String {
        switch code {
        case "NotFound":
            return "We couldn't find this Recapsule, check the code and try again."
        case "AlreadyMember":
            return "You're already part of this Recapsule."
        default:
            return code
        }
    }
}
