# Jello

[![Build Status](https://travis-ci.org/wellmart/jello.svg?branch=master)](https://travis-ci.org/wellmart/jello)
[![Swift 5](https://img.shields.io/badge/swift-5-blue.svg)](https://developer.apple.com/swift/)
![Version](https://img.shields.io/badge/version-0.1.0-blue)
[![Software License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
[![Swift Package Manager Compatible](https://img.shields.io/badge/swift%20package%20manager-compatible-blue.svg)](https://github.com/apple/swift-package-manager)

A framework with a experimental architecture based on MVVM with Coordinator using property wrappers, observers and binding.

## Requirements

Swift 5 and beyond.

## Usage

```swift
import Jello

// Model
class UserModel: Model {
    @Field(.required)
    var name: Observable<String>!
    
    @Field
    var password: Observable<String>!
}

// View Model
class RegisterPasswordViewModel: ViewModel {
    @Binding
    var user: UserModel!
    
    func procceed() {
        guard user.password.value != "" else {
            return
        }
        
        coordinator?.procceed()
    }
}

// View Controller
class RegisterPasswordViewController: UIViewController, View {
    static var storyboard = "Register"
    
    @Binding
    var viewModel: RegisterPasswordViewModel!
    
    @IBOutlet weak var passwordField: UITextField? {
        didSet {
            viewModel.user.password.bind(passwordField)
        }
    }
    
    @IBAction func procceedTouch(_ sender: Any) {
        viewModel.procceed()
    }
}

class RegisterSuccessViewController: UIViewController, View {
    static var storyboard = "Register"
    
    @Binding
    var viewModel: RegisterEmptyViewModel!
    
    @IBOutlet weak var nameLabel: UILabel? {
        didSet {
            viewModel.user.name.bind(nameLabel, on: self) {
                return "Tudo certo\n\($0);D"
            }
        }
    }
}

// Coordinator
class RegisterCoordinator: Coordinator {
    override func start() {
        startView = RegisterWelcomeViewController.self
    }
    
    override func procceed(from view: View.Type) -> View.Type? {
        if view is RegisterWelcomeViewController.Type {
            return RegisterNameViewController.self
        }
        
        if view is RegisterNameViewController.Type {
            return RegisterPasswordViewController.self
        }
        
        if view is RegisterPasswordViewController.Type {
            return procceed(to: ProfileCoordinator.self)
        }
        
        return nil
    }
}
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
