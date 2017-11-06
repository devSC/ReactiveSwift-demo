//
//  ViewController.swift
//  TestReactiveSwift
//
//  Created by Wilson Yuan on 2017/11/1.
//  Copyright © 2017年 Being Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

func scopedExample(_ exampleDescription: String, _ action: () -> Void) {
    print("\n-----\(exampleDescription)-----\n")
    action()
}

class ViewController: UIViewController {

    @IBOutlet weak var push: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        testPropertyAndOperator()
    }
    
    @IBAction func pushAction(_ sender: Any) {
        let controller = FormViewController(FormViewModel(userService: FormUserService()))
        self.show(controller, sender: sender)
    }
    
    func testPropertyAndOperator() {
        scopedExample("testSimpleSignal") {
            let signal = Signal<Int, NoError>.pipe()
            
            //subscribe
            let subscribe1 = Signal<Int, NoError>.Observer { (value) in
                print("subscribe1 received: \(value)")
            }
            
            signal.output.observe(subscribe1)
            
            signal.input.send(value: 19)
            
            signal.output.observe { (event) in
                print("subscribe2 received: \(event)")
            }
            
            signal.input.send(value: 20)
            
            let subscribe3 = Signal<Int, NoError>.Observer(
                value: { (value) in
                    
            }, failed: { (error) in
                
            }, completed: {
                
            }) {
                //interrupted
                
            }
            signal.output.observe(subscribe3)
            signal.input.send(value: 30)
        }
        
        scopedExample("property") {
            
        }
        
        scopedExample("Bind from SignalProducer") {
            let producer = SignalProducer<Int, NoError> { (observer, _) in
                observer.send(value: 1)
                observer.send(value: 2)
            }
            
            let property = MutableProperty(0)
            property.producer.startWithValues({ (value) in
                print("value: \(value)")
            })
            
            //将 producer 绑定给 property 相当于 propety 会收到 producer 的值
            property <~ producer
        }
        
        scopedExample("Bind from Signal") {
            //            let (signal, observer) = Signal<Int, NoError>.pipe()
            
        }
    }
}

