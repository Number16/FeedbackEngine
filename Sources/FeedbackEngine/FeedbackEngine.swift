//
//  FeedbackEngine.swift
//  Emoji Widget
//
//  Created by Igor Diachuk on 12.09.2022.
//
import SwiftUI
import StoreKit



@available(macOS 13.0, *)
public struct FeedbackViewModifier: ViewModifier {
    
    @State private var appNameForEmail: String = ""
    
    @State var showingAlertAskingToRate = false
    @State var showingAlertAskingForFeedbackIfUserDoesntLikeApp = false
    @State var showingAlertAskingForFeedbackIfUserAlreadyRatedTheApp = false
    @State var showingAlertAskingForToGoAheadAndEmailUs = false
    
    @AppStorage("appOpensCount") private var appOpensCount = 0
    @AppStorage("userSaidTheyLikeTheApp") private var userSaidTheyLikeTheApp = false
    @AppStorage("userAgreedToShareFeedbackAfter10Opens") private var userAgreedToShareFeedbackAfter10Opens = false
    
    #if os(macOS)
        var requestReview: () -> () = {}
    #else
        @Environment(\.requestReview) var requestReview
    #endif
    
    public init(){}
    
    
    public func body(content: Content) -> some View {
        content
            .onAppear() {
                
                print("helo")
                
                if let displayName = Bundle.main.displayName {
                    appNameForEmail = displayName.components(separatedBy: .whitespacesAndNewlines).joined()
                    print(appNameForEmail)
                } else {
                    print("eror")
                    print(Bundle.main.displayName)
                }
                
                appOpensCount += 1
                
                
                if appOpensCount == 3 {
                    showingAlertAskingToRate = true
                }
                
                if appOpensCount > 3 && userSaidTheyLikeTheApp && appOpensCount % 2 == 0 {
                    requestReview()
                }
                
                if appOpensCount >= 10 && appOpensCount % 5 == 0 && userSaidTheyLikeTheApp && !userAgreedToShareFeedbackAfter10Opens {
                    
                    
                    showingAlertAskingForFeedbackIfUserAlreadyRatedTheApp = true
                    
                    
                }
                
               
            }
        
            .alert("Hi! Do you like this app? 🙂", isPresented: $showingAlertAskingToRate) {
                
                Button("Not really...") {
                    showingAlertAskingToRate = false
                    showingAlertAskingForFeedbackIfUserDoesntLikeApp = true
                }
                
                Button("Yes") {
                    requestReview()
                    showingAlertAskingToRate = false
                    userSaidTheyLikeTheApp = true
                }
            
            }
        
            .alert("Sorry to hear this 😢", isPresented: $showingAlertAskingForFeedbackIfUserDoesntLikeApp) {
                Link("Tell us how to improve it", destination: URL(string: "mailto:monochromestudios+"+appNameForEmail+"@icloud.com") ?? URL(string: "https://lekskeks.com")!)
               
            }
        
            .alert("Hi! Have a sec? 🙂", isPresented: $showingAlertAskingForFeedbackIfUserAlreadyRatedTheApp) {
                
                Button("Tell us what you think about our app") {
                    showingAlertAskingForFeedbackIfUserAlreadyRatedTheApp = false
                    userAgreedToShareFeedbackAfter10Opens = true
                    showingAlertAskingForToGoAheadAndEmailUs = true

                }
                
                Button("Sometime later") {
                    showingAlertAskingForFeedbackIfUserAlreadyRatedTheApp = false
                }
            
            }
        
            .alert("Thanks a lot! We try to reply to all the emails 🥹", isPresented: $showingAlertAskingForToGoAheadAndEmailUs) {
                
                Link("Tell us how to improve the app", destination: URL(string: "mailto:monochromestudios+"+appNameForEmail+"@icloud.com")!)
            }
        
        
            
    }
    
    
   
}


public extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}


public extension View {
    func feedbackEngine() -> some View {
        modifier(FeedbackViewModifier())
    }
}
