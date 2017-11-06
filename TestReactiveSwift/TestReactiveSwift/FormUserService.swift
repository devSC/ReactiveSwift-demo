//
//  FormUserService.swift
//  TestReactiveSwift
//
//  Created by Wilson Yuan on 2017/11/6.
//  Copyright © 2017年 Being Inc. All rights reserved.
//

import ReactiveSwift
import Result

final class FormUserService {
    let (requestSignal, requestObserver) = Signal<String, NoError>.pipe()
    func canUseUsername(_ string: String) -> SignalProducer<Bool, NoError> {
        return SignalProducer { observer, disposeable in
            self.requestObserver.send(value: string)
            observer.send(value: true)
            observer.sendCompleted()
        }
    }
}
