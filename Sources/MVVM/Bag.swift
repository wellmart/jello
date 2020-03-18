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

import Foundation

public final class Bag {
    private static var sharedObjects = [UInt: BindingObject]()
    
    static func object<T: BindingObject>(for key: UInt) -> T? {
        return Bag.sharedObjects[key] as? T
    }
    
    private var keys = [UInt]()
    private var objects = [UInt: BindingObject]()
    
    public init() {
    }
    
    func bind<T: BindingObject>(_ subject: Any, for type: T.Type, execute: ((T) -> Void)? = nil) {
        let mirror = Mirror(reflecting: subject)
        
        for child in mirror.children {
            guard let binding = child.value as? BindingProtocol, binding.type is T.Type else {
                continue
            }
            
            if let object = bind(binding.type as! T.Type, for: binding.key) {
                execute?(object)
            }
        }
    }
    
    private func bind<T: BindingObject>(_ type: T.Type, for key: UInt) -> T? {
        let typeKey = UInt(bitPattern: ObjectIdentifier(type))
        
        if let object = objects[typeKey] {
            Bag.sharedObjects[key] = object
            return object as? T
        }
        
        let object = type.init()
        
        objects[typeKey] = object
        Bag.sharedObjects[key] = object
        
        return object
    }
    
    deinit {
        for key in keys {
            Bag.sharedObjects.removeValue(forKey: key)
        }
    }
}
