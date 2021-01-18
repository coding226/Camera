//
//  CanvasView.swift
//  Camera
//
//  Created by Erik Kamalov on 11/21/20.
//

import UIKit
import Combine

extension Notification.Name {
    static let canvasViewColorChange = Notification.Name("canvasViewColorChange")
    static let canvasViewEnabled = Notification.Name("canvasViewUserInteractionEnabled")
    static let canvasViewUndo = Notification.Name("canvasViewUndo")
    static let canvasViewRedo = Notification.Name("canvasViewRedo")
}

class CanvasView: UIView {
    struct Line {
        let strokeWidth: Float
        let color: UIColor
        var points: [CGPoint]
    }
    
    // MARK: - Attributes
    private var strokeColor = UIColor(hue: 0.5, saturation: 1, brightness: 1, alpha: 1)
    private var strokeWidth: Float = 4
    private var lines: [Line] = []
    private var cancellables: Set<AnyCancellable> = []
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        bindViewModel()
    }
    
    private func bindViewModel() {
        NotificationCenter.default.publisher(for: .canvasViewColorChange).sink {
            guard let value = $0.object as? CGFloat else { return }
            self.strokeColor = UIColor.init(hue: value, saturation: 1, brightness: 1, alpha: 1)
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .canvasViewEnabled).sink {
            self.isUserInteractionEnabled = $0.object as? Bool ?? false
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .canvasViewUndo).sink { _ in
            self.undoManager?.undo()
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .canvasViewRedo).sink { _ in
            self.undoManager?.redo()
        }.store(in: &cancellables)
    }
    
    deinit {
        print(#file, #function)
        cancellables.removeAll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        lines.forEach { (line) in
            context.setStrokeColor(line.color.cgColor)
            context.setLineWidth(CGFloat(line.strokeWidth))
            context.setLineCap(.round)
            for (i, p) in line.points.enumerated() {
                if i == 0 {
                    context.move(to: p)
                } else {
                    context.addLine(to: p)
                }
            }
            context.strokePath()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append(Line.init(strokeWidth: strokeWidth, color: strokeColor, points: []))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: nil) else { return }
        guard var lastLine = lines.popLast() else { return }
        lastLine.points.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let last = lines.last else { return }
        self.addUndoActionRegister(at: last)
    }
    
    func clear() {
        lines.removeAll()
        self.undoManager?.removeAllActions()
        setNeedsDisplay()
    }
    
    var snapshot: UIImage? {
        return lines.count > 0 ? self.screenshot : nil
    }
}

//MARK:- Add/Remove Line : Undo/Redo Actions
extension CanvasView {
    private func addLine(at line: Line){
        lines.append(line)
        setNeedsDisplay()
    }
    
    private func removeRemoveLine(at line: Line) {
        _ = lines.popLast()
        setNeedsDisplay()
    }
    
    private func addUndoActionRegister(at line: Line){
        self.undoManager?.registerUndo(withTarget: self, handler: { (selfTarget) in
            selfTarget.removeRemoveLine(at: line)
            selfTarget.removeUndoActionRegister(at: line)
        })
    }
    
    private func removeUndoActionRegister(at line: Line){
        self.undoManager?.registerUndo(withTarget: self, handler: { (selfTarget) in
            selfTarget.addLine(at: line)
            selfTarget.addUndoActionRegister(at: line)
        })
    }
}
