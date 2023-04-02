//
//  AuthService.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import AuthenticationServices

final class AuthService: NSObject {
    static func checkAuthStatus( callback: @escaping (_ state: ASAuthorizationAppleIDProvider.CredentialState) -> Void) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                callback(credentialState)
                break
            case .revoked, .notFound:
                callback(credentialState)
                break
            case .transferred:
                print("App has been transfered to a different apple id")
                callback(credentialState)
                break
            @unknown default:
                print("Auth Apple in unknown state")
                callback(credentialState)
                break
            }
        }
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
        print("handle request")
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print(authorization)
    }
}

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if os(macOS)
        return NSApplication.shared.windows.first!
        #else
        return UIApplication.shared.windows.first!
        #endif
    }
    
}
