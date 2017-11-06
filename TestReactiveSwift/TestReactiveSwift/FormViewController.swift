//
//  FormViewController.swift
//  TestReactiveSwift
//
//  Created by Wilson Yuan on 2017/11/6.
//  Copyright © 2017年 Being Inc. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa
import Result

class FormViewController: UIViewController {
    private var formView: FormView!
    private let viewModel: FormViewModel
    
    init(_ viewModel: FormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        formView = FormView()
        view = formView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize the interactive controls
        formView.emailField.text = viewModel.email.value
        formView.emailConfirmationField.text = viewModel.emailConfirmation.value
        formView.termsSwitch.isOn = false
        
        //Setup binding with the interactive controls
        viewModel.email <~ formView.emailField.reactive
            .continuousTextValues.skipNil()
        
        viewModel.emailConfirmation <~ formView.emailConfirmationField.reactive
            .continuousTextValues.skipNil()
        
        viewModel.termsAccepted <~ formView.termsSwitch.reactive
            .isOnValues
        
        //Setup bindings with the invalidation reason label
        formView.reasonLabel.reactive.text <~ viewModel.reasons
        
        //Setup the Action bind with the submit button
        formView.submitButton.reactive.pressed = CocoaAction(viewModel.submit)
    }
}


