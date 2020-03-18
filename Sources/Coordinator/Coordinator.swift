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

public protocol CoordinatorProtocol {
    func procceed()
}

open class Coordinator {
    public var startView: View.Type?
    
    let bag: Bag
    
    private let navigationController: UINavigationController
    
    public required init(navigationController: UINavigationController, bag: Bag = Bag()) {
        self.navigationController = navigationController
        self.bag = bag
        
        start()
        pushView(startView)
    }
    
    open func start() {
    }
    
    open func procceed(from type: View.Type) -> View.Type? {
        return nil
    }
    
    @discardableResult
    public func procceed<T: Coordinator>(to: T.Type) -> View.Type? {
        let _ = T.init(navigationController: navigationController, bag: bag)
        return nil
    }
    
    private func pushView(_ view: View.Type?) {
        guard let view = view as? (UIViewController & View).Type else {
            return
        }
        
        let viewController = view.instantiateViewController()
        
        viewController.bind(coordinator: self)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension Coordinator {
    public class func start() {
        guard let topViewController = UIApplication.topViewController() else {
            return
        }
        
        let navigationController = UINavigationController()
        let _ = Self.init(navigationController: navigationController)
        
        topViewController.present(navigationController, animated: true)
    }
}

extension Coordinator: CoordinatorProtocol {
    public func procceed() {
        guard let viewController = navigationController.visibleViewController, let view = type(of: viewController) as? View.Type else {
            return
        }
        
        pushView(procceed(from: view))
    }
}
