//
//  ScreenshotSecure.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 09/12/25.
//

import SwiftUI
import UIKit

struct ScreenshotPrivacy<Content: View>: UIViewRepresentable {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIView(context: Context) -> PrivacyHostingView {
        return PrivacyHostingView(rootView: content)
    }
    
    func updateUIView(_ uiView: PrivacyHostingView, context: Context) {
        uiView.hostingController.rootView = AnyView(content)
    }
}

class PrivacyHostingView: UIView {
    
    // O campo de texto "seguro" que fará a mágica
    private let secureTextField = UITextField()
    
    // O controlador que segura o conteúdo SwiftUI
    let hostingController: UIHostingController<AnyView>
    
    init<Content: View>(rootView: Content) {
        self.hostingController = UIHostingController(rootView: AnyView(rootView))
        super.init(frame: .zero)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayer() {
        // 1. Configura o campo para ser seguro (senha)
        secureTextField.isSecureTextEntry = true
        
        // 2. Hack para acessar a camada interna onde o texto (senha) é renderizado
        // O iOS esconde tudo que está dentro dessa subview específica
        guard let hiddenView = secureTextField.subviews.first else { return }
        
        // 3. Adiciona a View segura na hierarquia
        addSubview(secureTextField)
        secureTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // 4. Adiciona o conteúdo SwiftUI DENTRO da camada oculta do TextField
        hiddenView.addSubview(hostingController.view)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 5. Constraints para preencher tudo
        NSLayoutConstraint.activate([
            // TextField preenche a View Container
            secureTextField.topAnchor.constraint(equalTo: topAnchor),
            secureTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            secureTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            secureTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Conteúdo SwiftUI preenche a camada oculta
            hostingController.view.topAnchor.constraint(equalTo: hiddenView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: hiddenView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: hiddenView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: hiddenView.trailingAnchor)
        ])
        
        // 6. TRUQUE DO TOQUE:
        // O TextField normalmente rouba o toque. Desativamos a interação dele
        // para que o toque "atravesse" e chegue no SwiftUI lá dentro.
        secureTextField.isUserInteractionEnabled = false
        
        // Mas precisamos que a view do SwiftUI receba toques.
        hostingController.view.isUserInteractionEnabled = true
    }
    
    // 7. Garante que o toque passe corretamente para o SwiftUI
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Converte o ponto para a view do hosting controller
        let convertedPoint = self.convert(point, to: hostingController.view)
        
        // Pergunta para o SwiftUI: "Tem alguém aí pra receber esse toque?"
        if let hitView = hostingController.view.hitTest(convertedPoint, with: event) {
            return hitView
        }
        return super.hitTest(point, with: event)
    }
}
