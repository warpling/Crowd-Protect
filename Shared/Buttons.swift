import UIKit

extension UIControl.State: Hashable { }

extension UIButton {
    
    /// Handles storing and retrieving values linked to button states
    /// This allows for adding specific values to a UIButton linked
    /// to any (combo of) button state, like fonts and colors
    final class StateValueContainer<Value> {
        var storage = [State: Value]()
        
        subscript(state: State) -> Value? {
            get {
                return value(for: state)
            }
            set {
                set(newValue, for: state)
            }
        }
        
        /// Sets the value for the given state, removes it if `nil`
        func set(_ value: Value?, for state: State) {
            guard let value = value else {
                storage.removeValue(forKey: state)
                return
            }
            storage[state] = value
        }
        
        /// Returns the value if available
        func value(for state: State) -> Value? {
            storage[state]
        }
        
        /// Whether any values have been stored
        var isEmpty: Bool {
            return storage.isEmpty
        }
        
        /// To closely approximate `UIButton`'s default behavior of using the normal state as a fallback state
        /// and only use a default (or nil) value when there is no value set for the normal state, use this method
        /// when you need to update a specific value in your view
        ///
        /// - This method will not do anything when there's no values set, as to not override any view properties
        /// set outside of the set/get methods.
        /// - Will either use the value for the state given or the value set for the `.normal` state
        /// - Only uses `defaultValue` when the requested state is `.normal`, other wise the view's
        /// properties should not be changed
        /// - Parameters:
        ///   - state: Control state to request the value for
        ///   - defaultValue: Value to use when no value available for the given state or `.normal` state
        ///   - handler: Use this handle to update your view's properties with
        func getValueIfAvailable(for state: State, defaultValue: Value?, handler: (Value?) -> Void) {
            if isEmpty {
                return
            }
            
            if let value = self.value(for: state) ?? self.value(for: .normal) {
                handler(value)
            } else if state == .normal {
                handler(defaultValue)
            }
        }
    }
}

class CustomButton: UIButton {
    
    private(set) lazy var backgroundView: UIView = {
        let view = UIView(frame: bounds)
        view.isUserInteractionEnabled = false
        insertSubview(view, at: 0)
        return view
    }()
    
    private var backgroundColors = StateValueContainer<UIColor>()
    private var imageColors = UIButton.StateValueContainer<UIColor>()
    
    private var originalTintColor: UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        originalTintColor = tintColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool { didSet {
        updateAppearance()
    }}
    
    override var isEnabled: Bool { didSet {
        updateAppearance()
    }}
    
    override var isSelected: Bool { didSet {
        updateAppearance()
    }}
    
    func updateAppearance() {
        updateBackgroundColor()
        updateImageColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if subviews.first != backgroundView {
            // Make sure backgroundView stays in the background
            backgroundView.removeFromSuperview()
            backgroundView.frame = bounds
            insertSubview(backgroundView, at: 0)
        } else {
            backgroundView.frame = bounds
        }
    }
}

// MARK: - Background color
extension CustomButton {
    
    func setBackgroundColor(_ color: UIColor?, for state: State) {
        backgroundColors[state] = color
        updateBackgroundColor()
    }
    
    func backgroundColor(for state: State) -> UIColor? {
        return backgroundColors[state]
    }
    
    private func updateBackgroundColor() {
        backgroundColors.getValueIfAvailable(for: state, defaultValue: nil) { color in
            backgroundView.backgroundColor = color
        }
    }
}

// MARK: - Image color
extension CustomButton {
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        if image?.renderingMode != .alwaysTemplate, imageColor(for: state) != nil {
            super.setImage(image?.withRenderingMode(.alwaysTemplate), for: state)
            return
        }
        super.setImage(image, for: state)
    }
    
    func setImageColor(_ color: UIColor?, for state: State) {
        if let image = image(for: state) {
            setImage(image.withRenderingMode(.alwaysTemplate), for: state)
        }
        imageColors[state] = color
        updateImageColor()
    }
    
    func imageColor(for state: State) -> UIColor? {
        return imageColors[state]
    }
    
    private func updateImageColor() {
        adjustsImageWhenHighlighted = !imageColors.isEmpty
        adjustsImageWhenDisabled = !imageColors.isEmpty
        
        imageColors.getValueIfAvailable(for: state, defaultValue: originalTintColor) { color in
            imageView?.tintColor = color
        }
    }
}
