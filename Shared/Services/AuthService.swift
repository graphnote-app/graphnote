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
    
    func process(authorization: ASAuthorization, callback: @escaping (Bool, User?, AuthServiceError?) -> Void) {
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
            DispatchQueue.main.async {
                do {
                    if !UserBuilder.create(user: user) {
                        callback(true, nil, AuthServiceError.createUserFailed)
                    }
                    
                    callback(true, user, nil)
                } catch let error {
                    print(error)
                    
                    callback(false, nil, AuthServiceError.createUserFailed)
                    
                    #if DEBUG
                    fatalError()
                    #endif
                    
                    return
                }
            }
            
        } else {
            print("SIGN IN")
            // Add check for user existing in local DB vs not (throw error)
            let userRepo = UserRepo()
            if let user = userRepo.read(id: id) {
                print(user)
                DispatchQueue.main.async {
                    callback(false, user, nil)
                }
                return
            } else {
                // Check server for User
                
                UserService().fetchUser(id: id) { (user, error) in
                    if let error {
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            callback(false, nil, AuthServiceError.fetchFailed)
                        }
                        return
                    }
                    
                    if let user {
                        print(user)
        
                        DispatchQueue.main.async {
                            do {
                                try DataService.shared.createUserMessage(user: user)
                                
                            } catch let error {
                                print(error)
                                DispatchQueue.main.async {
                                    callback(false, nil, AuthServiceError.createUserFailed)
                                }
                                
                                #if DEBUG
                                fatalError()
                                #endif
                                
                                return
                            }
                            
                            callback(false, user, nil)
                            return
                        }
                        
                        
                    } else {
                        // Todo add error alert
                        print("SyncService couldn't find the user")
                        print("Failure in system. Please contact use for human support!")
                        DispatchQueue.main.async {
                            callback(false, nil, AuthServiceError.userNotFound)
                        }
                        return
                    }
                }
            }
            
        }
    }
}
