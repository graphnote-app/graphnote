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

enum AuthServiceError: Error {
    case createUserFailed
    case fetchFailed
    case userNotFound
    case unknown
}

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
    
    func process(authorization: ASAuthorization, callback: @escaping (Bool, AuthServiceError?) -> Void) {
        let credential = authorization.credential as! ASAuthorizationAppleIDCredential
        
        // Check if user exists locally and remotely if possible (with internet)
        print("credential.user: \(credential.user)")
        let id = credential.user
        
        
        print(credential.user)
        
        // We only get the email on Sign Up and not Sign In (important)
        if let email = credential.email {
            print("SIGN UP")
            
            // Name is always optional so don't rely on it
            let fullName = credential.fullName
            print(email)
            print(fullName as Any)
            
            let givenName = fullName?.givenName
            let familyName = fullName?.familyName
            
            let user = User(id: id, email: email, givenName: givenName, familyName: familyName, createdAt: .now, modifiedAt: .now)
            
            if !DataService.shared.watching {
                DataService.shared.startWatching(user: user)
            }
            
            do {
                try DataService.shared.createUser(user: user)
            } catch let error {
                print(error)
                callback(true, AuthServiceError.createUserFailed)
                return
            }
            
            
            
            _ = DataService.shared.$statusCode.sink { statusCode in
                print("statusCode: \(statusCode)")
                switch statusCode {
                case 201, 409:
                    DispatchQueue.main.async {
                        callback(true, nil)
                    }
                default:
                    DispatchQueue.main.async {
                        callback(true, AuthServiceError.unknown)
                    }
                }
            }
            
        } else {
            print("SIGN IN")
            // Add check for user existing in local DB vs not (throw error)
            let userRepo = UserRepo()
            if let user = userRepo.read(id: id) {
                print(user)
                DispatchQueue.main.async {
                    callback(false, nil)
                }
                return
            } else {
                // Check server for User
                
                UserService().fetchUser(id: id) { (user, error) in
                    if let error {
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            callback(false, AuthServiceError.fetchFailed)
                        }
                        return
                    }
                    
                    if let user {
                        print(user)
            
                        if UserBuilder.create(user: user) == false {
                            DispatchQueue.main.async {
                                callback(false, AuthServiceError.createUserFailed)
                            }
                            return
                        }
                        
                        DispatchQueue.main.async {
                            callback(false, nil)
                        }
                        
                        return
                        
                    } else {
                        // Todo add error alert
                        print("SyncService couldn't find the user")
                        print("Failure in system. Please contact use for human support!")
                        DispatchQueue.main.async {
                            callback(false, AuthServiceError.userNotFound)
                        }
                        return
                    }
                }
            }
            
        }
    }
}
