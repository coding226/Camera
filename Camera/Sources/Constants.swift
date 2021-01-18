//
//  Constants.swift
//  Camera
//
//  Created by Erik Kamalov on 11/1/20.
//

import UIKit

let mainScreen = UIScreen.main.bounds
var temporaryBgImage: UIImage?

extension UIImage {
    static var background: UIImage { return UIImage(named: "background")! }
    
    static var cancel = UIImage(named: "cancel")
    static var filterbg = UIImage(named: "filterbg")
    static var backButton = UIImage(named: "backButton")
    static var settings = UIImage(named: "settings")
    static var search = UIImage(named: "search")
    
    struct Camera {
        static var cancel = UIImage(named: "cancel")
        static var playbt = UIImage(named: "playbt")
    
        struct TopMenu {
            static var cameraTorch = UIImage(named: "cameraTorch")
            static var rotate = UIImage(named: "cameraRotate")
            static var gallery = UIImage(named: "library")
        }
        struct BottomsMenu {
            static var undo = UIImage(named: "undo")
            static var redo = UIImage(named: "redo")
            static var downArrow = UIImage(named: "downArrow")
        }
        
        struct Capture {
            static var ready = UIImage(named: "cameraReadyState")
            static var stop = UIImage(named: "cameraStopState")
            static var finishing = UIImage(named: "cameraFinishState")
            static var mock = UIImage(named: "cameraMock")
        }
    }
    
    struct Post {
        static var selectMark = UIImage(named: "selectedMark")
    }
}


extension UIColor {
    struct Gradients {
        static var topToBottom: [UIColor] { return [UIColor.black.withAlphaComponent(0.6), UIColor.clear] }
        static var bottomToTop: [UIColor] { return [UIColor.clear, UIColor.black.withAlphaComponent(0.8)] }
        static var bottomToTopV2: [UIColor] { return [UIColor.clear, UIColor.black.withAlphaComponent(0.4)] }
    }
    
    struct Camera {
        struct BottomMenu {
            static var primary: UIColor = .white
            static var selected: UIColor = .init(hexString: "93A7B9")
        }
    }
    struct Caption {
        static var primary: UIColor = .white
        static var textViewErrorBg: UIColor = .init(hexString: "FF3A72")
    }
    struct Post {
        struct Settings {
            static var caption: UIColor = UIColor.white.withAlphaComponent(0.5)
        }
        static var primary: UIColor = .white
        static var cellSubtitle: UIColor = .init(hexString: "868F98")
        static var cellHeader: UIColor = UIColor.white.withAlphaComponent(0.9)
        static var cellSelectedTint: UIColor = UIColor(hexString: "FF3A72")
        static var cellUnselected: UIColor = UIColor(hexString: "868F98")
    }
    struct NavigationBar {
        static var primary: UIColor = .white
    }
}


extension UIFont {
    struct Camera {
        static var downCount = UIFont.init(font: .avenirNextCyrBold, size: 23)
        struct BottomMenu {
            static var cellTitle = UIFont.init(font: .avenirNextCyrMedium, size: 12.adaptive)
            static var sliderTitle = UIFont.init(font: .avenirNextCyrDemi, size: 16.adaptive)
        }
    }
    struct Caption {
        static var primary = UIFont.init(font: .avenirNextCyrDemi, size: 17.adaptive)
        static var textView = UIFont.init(font: .avenirNextCyrMedium, size: 16.adaptive)
    }
    struct NavigationBar {
        static var primary = UIFont.init(font: .avenirNextCyrDemi, size: 17.adaptive)
    }
    struct Post {
        struct Setting {
            static var caption = UIFont.init(font: .avenirNextCyrMedium, size: 16.adaptive)
        }
        static var cellTitle = UIFont.init(font: .avenirNextCyrDemi, size: 14.5.adaptive)
        static var cellHeader = UIFont.init(font: .avenirNextCyrMedium, size: 13.adaptive)
        static var cellSubtitle = UIFont.init(font: .avenirNextCyrMedium, size: 13.adaptive)
    }
}

