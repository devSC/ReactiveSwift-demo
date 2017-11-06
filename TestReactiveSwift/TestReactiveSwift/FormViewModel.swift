//
//  FormViewModel.swift
//  TestReactiveSwift
//
//  Created by Wilson Yuan on 2017/11/6.
//  Copyright © 2017年 Being Inc. All rights reserved.
//

import ReactiveSwift
import Result

class FormViewModel {
    struct FormError: Error {
        let reason: String
        static let invalidEmail = FormError(reason: "The address must end with `@reactivecocoa.io`.")
        static let mismatchEmail = FormError(reason: "The e-mail addresses do not match.")
        static let usernameUnavailable = FormError(reason: "The username has been taken.")
    }
    
    let email: ValidatingProperty<String, FormError>
    let emailConfirmation: ValidatingProperty<String, FormError>
    let termsAccepted: MutableProperty<Bool>
    let submit: Action<(), (), FormError>
    let reasons: Signal<String, NoError>
    
    init(userService: FormUserService) {
        email = ValidatingProperty<String, FormError>("") { (input) -> ValidatingProperty<String, FormViewModel.FormError>.Decision in
            return input.hasSuffix("@reactivecocoa.io") ? .valid : .invalid(.invalidEmail)
        }
        
        emailConfirmation = ValidatingProperty<String, FormError>("", with: email, { (input, email) -> ValidatingProperty<String, FormViewModel.FormError>.Decision in
            return input == email ? .valid : .invalid(.mismatchEmail)
        })
        
        termsAccepted = MutableProperty<Bool>(false)
        
        let validatedEmail: Property<String?> = Property
            .combineLatest(emailConfirmation.result, termsAccepted)
            .map { (email, accepted) -> String? in
                return !email.isInvalid && accepted ? email.value! : nil
        }
        
        submit = Action(unwrapping: validatedEmail, execute: { (email: String) in
            let username = email.stripSuffix("@reactivecocoa.io")!
            return userService.canUseUsername(username)
                .promoteError(FormError.self)
                .attemptMap({ (can) -> Result<(), FormViewModel.FormError> in
                    return Result<(), FormError>(can ? () : nil, failWith: .usernameUnavailable)
                })
        })
        
        reasons = Property.combineLatest(email.result, emailConfirmation.result)
            .signal
            .debounce(0.1, on: QueueScheduler.main)
            .map({ (email, confirmation) -> String in
                let string = [email, confirmation].flatMap{ $0.error?.reason }.joined(separator: "\n")
                print("string:\(string), email: \(email.error?.reason ?? " "), confirmation: \(confirmation)")
                return string
            })
    }
}

extension String {
    public func stripSuffix(_ suffix: String) -> String? {
        if let range = range(of: suffix) {
            return substring(with: startIndex ..< range.lowerBound)
        }
        return nil
    }
}
