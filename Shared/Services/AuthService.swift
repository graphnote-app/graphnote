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
    static func checkAuthStatus(user: User, callback: @escaping (_ state: ASAuthorizationAppleIDProvider.CredentialState) -> Void) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        print("USER ID: \(user.id)")
        appleIDProvider.getCredentialState(forUserID: user.id) { (credentialState, error) in
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
        
        // Check if user exists locally and remotely if possible (with internet)
        // Temporarily use a static user
        print("credential.user: \(credential.user)")
        let id = credential.user
        
        let user = User(id: id, createdAt: .now, modifiedAt: .now)
        
        do {
            try UserBuilder.create(user: user)
        } catch let error {
            print(error)
        }
        
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
