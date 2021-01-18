////
////  UIView+Animation.swift
////  Camera
////
////  Created by Erik Kamalov on 11/5/20.
////
//
//import UIKit
//
///// Animation protocol defines the initial transform for a view for it to
///// animate to its identity position.
//public protocol Animation {
//
//    /// Defines the starting point for the animations.
//    var initialTransform: CGAffineTransform { get }
//}
//
///// Configuration class for the default values used in animations.
///// All it's values are used when creating 'random' animations as well.
//public class ViewAnimatorConfig {
//
//    /// Amount of movement in points.
//    /// Depends on the Direction given to the AnimationType.
//    public static var offset: CGFloat = 30.0
//
//    /// Duration of the animation.
//    public static var duration: Double = 0.3
//
//    /// Interval for animations handling multiple views that need
//    /// to be animated one after the other and not at the same time.
//    public static var interval: Double = 0.075
//
//    /// Maximum zoom to be applied in animations using random AnimationType.zoom.
//    public static var maxZoomScale: Double = 2.0
//
//    /// Maximum rotation (left or right) to be applied in animations using random AnimationType.rotate
//    public static var maxRotationAngle: CGFloat = CGFloat.pi/4
//
//    /// The damping ratio for the spring animation as it approaches its quiescent state.
//    public static var springDampingRatio: CGFloat = 1
//
//    /// The initial spring velocity. For smooth start to the animation, match this value to the view’s velocity as it was prior to attachment.
//    public static var initialSpringVelocity: CGFloat = 0
//}
//
///// AnimationType available to perform/
/////
///// - vector: Animation from x and y values
///// - zoom: Zoom animation.
///// - rotate: Rotation animation.
//public enum AnimationType: Animation {
//
//    case vector(CGVector)
//    case zoom(scale: CGFloat)
//    case rotate(angle: CGFloat)
//    case identity
//
//    /// Creates the corresponding CGAffineTransform for AnimationType.from.
//    public var initialTransform: CGAffineTransform {
//        switch self {
//        case .vector(let vector):
//            return CGAffineTransform(translationX: vector.dx, y: vector.dy)
//        case .zoom(let scale):
//             return CGAffineTransform(scaleX: scale, y: scale)
//        case .rotate(let angle):
//            return CGAffineTransform(rotationAngle: angle)
//        case .identity:
//            return .identity
//        }
//    }
//}
//
//
//public extension UIView {
//    // MARK: - Single View
//    /// Animation based on the UIView.animateWithDuration API
//    /// - Parameters:
//    ///   - animations: Array of Animations to perform on the animation block.
//    ///   - reversed: Initial state of the animation. Reversed will start from its original position.
//    ///   - initialAlpha: Initial alpha of the view prior to the animation.
//    ///   - finalAlpha: View's alpha after the animation.
//    ///   - delay: Time Delay before the animation.
//    ///   - duration: TimeInterval the animation takes to complete.
//    ///   - options: UIView.AnimationsOptions to pass to the animation block.
//    ///   - completion: block to run  after the animation finishes.
//    func animate(animations: [Animation], reversed: Bool = false, initialAlpha: CGFloat = 0.0, finalAlpha: CGFloat = 1.0,
//                 delay: Double = 0, duration: TimeInterval = ViewAnimatorConfig.duration,  options: UIView.AnimationOptions = [],
//                 completion: (() -> Void)? = nil) {
//
//        let transformFrom = transform
//        var transformTo = transform
//        animations.forEach { transformTo = transformTo.concatenating($0.initialTransform) }
//        if !reversed {
//            transform = transformTo
//        }
//
//        alpha = initialAlpha
//
//        UIView.animate(withDuration: duration, delay: delay, options: options, animations: { [weak self] in
//            self?.transform = reversed ? transformTo : transformFrom
//            self?.alpha = finalAlpha
//        }) { _ in
//            completion?()
//        }
//    }
//
//    /// Animation based on UIView.animateWithDuration using springs
//    ///
//    /// - Parameters:
//    ///   - animations: Array of Animations to perform on the animation block.
//    ///   - reversed: Initial state of the animation. Reversed will start from its original position.
//    ///   - initialAlpha: Initial alpha of the view prior to the animation.
//    ///   - finalAlpha: View's alpha after the animation.
//    ///   - delay: Time Delay before the animation.
//    ///   - duration: TimeInterval the animation takes to complete.
//    ///   - dampingRatio: The damping ratio for the spring animation.
//    ///   - velocity: The initial spring velocity.
//    ///   - options: UIView.AnimationsOptions to pass to the animation block. Timing functions will have no impact on spring based animations.
//    ///   - completion: CompletionBlock after the animation finishes.
//    func animate(animations: [Animation], reversed: Bool = false, initialAlpha: CGFloat = 0.0, finalAlpha: CGFloat = 1.0,
//                 delay: Double = 0,  duration: TimeInterval = ViewAnimatorConfig.duration, usingSpringWithDamping dampingRatio: CGFloat,
//                 initialSpringVelocity velocity: CGFloat, options: UIView.AnimationOptions = [], completion: (() -> Void)? = nil) {
//
//        let transformFrom = transform
//        var transformTo = transform
//        animations.forEach { transformTo = transformTo.concatenating($0.initialTransform) }
//        if !reversed {
//            transform = transformTo
//        }
//
//        alpha = initialAlpha
//
//        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: dampingRatio,
//                       initialSpringVelocity: velocity,  options: options, animations: { [weak self] in
//            self?.transform = reversed ? transformTo : transformFrom
//            self?.alpha = finalAlpha
//        }) { _ in
//            completion?()
//        }
//    }
//
//    // MARK: - UIView Array
//
//    /// Animates multiples views with cascading effect using the UIView.animateWithDuration API
//    ///
//    /// - Parameters:
//    ///   - animations: Array of Animations to perform on the animation block.
//    ///   - reversed: Initial state of the animation. Reversed will start from its original position.
//    ///   - initialAlpha: Initial alpha of the view prior to the animation.
//    ///   - finalAlpha: View's alpha after the animation.
//    ///   - delay: Time Delay before the animation.
//    ///   - animationInterval: Interval between the animations of each view.
//    ///   - duration: TimeInterval the animation takes to complete.
//    ///   - dampingRatio: The damping ratio for the spring animation.
//    ///   - velocity: The initial spring velocity.
//    ///   - options: UIView.AnimationsOptions to pass to the animation block. Timing functions will have no impact on spring based animations.
//    ///   - completion: CompletionBlock after the animation finishes.
//    static func animate(views: [UIView], animations: [Animation], reversed: Bool = false, initialAlpha: CGFloat = 0.0,
//                        finalAlpha: CGFloat = 1.0, delay: Double = 0, animationInterval: TimeInterval = 0.05,
//                        duration: TimeInterval = ViewAnimatorConfig.duration, options: UIView.AnimationOptions = [],
//                        completion: (() -> Void)? = nil) {
//
//        performAnimation(views: views, animations: animations, reversed: reversed, initialAlpha: initialAlpha, delay: delay, animationBlock: { view, index, dispatchGroup in
//            view.animate(animations: animations, reversed: reversed, initialAlpha: initialAlpha,
//                         finalAlpha: finalAlpha, delay: Double(index) * animationInterval, duration: duration,
//                         options: options,
//                         completion: { dispatchGroup.leave() })
//        }, completion: completion)
//    }
//
//    /// Animates multiples views with cascading effect using the UIView.animateWithDuration with springs
//    ///
//    /// - Parameters:
//    ///   - animations: Array of Animations to perform on the animation block.
//    ///   - reversed: Initial state of the animation. Reversed will start from its original position.
//    ///   - initialAlpha: Initial alpha of the view prior to the animation.
//    ///   - finalAlpha: View's alpha after the animation.
//    ///   - delay: Time Delay before the animation.
//    ///   - animationInterval: Interval between the animations of each view.
//    ///   - duration: TimeInterval the animation takes to complete.
//    ///   - dampingRatio: The damping ratio for the spring animation.
//    ///   - velocity: The initial spring velocity.
//    ///   - options: UIView.AnimationsOptions to pass to the animation block. Timing functions will have no impact on spring based animations.
//    ///   - completion: CompletionBlock after the animation finishes.
//    static func animate(views: [UIView], animations: [Animation], reversed: Bool = false, initialAlpha: CGFloat = 0.0,
//                        finalAlpha: CGFloat = 1.0, delay: Double = 0, animationInterval: TimeInterval = 0.05,
//                        duration: TimeInterval = ViewAnimatorConfig.duration, usingSpringWithDamping dampingRatio: CGFloat,
//                        initialSpringVelocity velocity: CGFloat, options: UIView.AnimationOptions = [],
//                        completion: (() -> Void)? = nil) {
//
//        performAnimation(views: views, animations: animations, reversed: reversed, initialAlpha: initialAlpha, delay: delay, animationBlock: { view, index, dispatchGroup in
//            view.animate(animations: animations, reversed: reversed,
//                         initialAlpha: initialAlpha, finalAlpha: finalAlpha,
//                         delay: Double(index) * animationInterval, duration: duration,
//                         usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity,
//                         options: options, completion: { dispatchGroup.leave() })
//        }, completion: completion)
//    }
//
//    static private func performAnimation(views: [UIView], animations: [Animation], reversed: Bool = false, initialAlpha: CGFloat = 0.0,
//                                         delay: Double = 0, animationBlock: @escaping ((UIView, Int, DispatchGroup) -> Void),
//                                         completion: (() -> Void)? = nil) {
//        guard views.count > 0 else {
//            completion?()
//            return
//        }
//
//        views.forEach { $0.alpha = initialAlpha }
//        let dispatchGroup = DispatchGroup()
//        for _ in 1...views.count { dispatchGroup.enter() }
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//            for (index, view) in views.enumerated() {
//                animationBlock(view, index, dispatchGroup)
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            completion?()
//        }
//    }
//}
