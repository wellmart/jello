//
//  Jello
//
//  Copyright (c) 2020 Wellington Marthas
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public final class Observable<T> {
    private struct Observer {
        weak var target: AnyObject?
        let action: (T) -> Void
    }
    
    public var value: T? {
        didSet {
            notifyObservers()
        }
    }
    
    private lazy var observers = [Observer]()
    
    public init(value: T? = nil) {
        self.value = value
    }
    
    public func observe(on target: AnyObject, action: @escaping (T) -> Void) {
        if let value = value {
            action(value)
        }
        
        observers.append(Observer(target: target, action: action))
    }
    
    private func notifyObservers() {
        for i in stride(from: observers.count - 1, through: 0, by: -1) {
            let observer = observers[i]
            
            if let value = value, observer.target != nil {
                DispatchQueue.main.async {
                    observer.action(value)
                }
            }
            else {
                observers.remove(at: i)
            }
        }
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        self.value = textField.text as? T
    }
}

extension Observable {
    public func bind(_ textField: UITextField?) {
        textField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @inlinable
    public func bind(_ label: UILabel?, on target: AnyObject) {
        guard let label = label else {
            return
        }
        
        observe(on: target) {
            label.text = "\($0)"
        }
    }
    
    @inlinable
    public func bind(_ label: UILabel?, on target: AnyObject, format action: @escaping (T) -> String?) {
        guard let label = label else {
            return
        }
        
        observe(on: target) {
            label.text = action($0)
        }
    }
}
