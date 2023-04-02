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
    
    func process(authorization: ASAuthorization) {
        let credential = authorization.credential as! ASAuthorizationAppleIDCredential
        print(credential.user)
        
        if let fullName = credential.fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
            print(givenName)
            print(familyName)
        }
        
        if let email = credential.email {
            print(email)
        }
    }
}
