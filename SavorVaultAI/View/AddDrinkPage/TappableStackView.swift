//
//  TappableStackView.swift
//  SavorVaultAI
//

import UIKit

/// A stack view that forwards all touches to a designated target view.
/// This allows the entire stack view area to trigger the target's action
/// (e.g. showing a menu) while keeping the popup anchored at the target.
class TappableStackView: UIStackView {

    weak var forwardingTarget: UIView?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else {
            return nil
        }
        guard self.point(inside: point, with: event) else {
            return nil
        }
        if let target = forwardingTarget {
            return target
        }
        return super.hitTest(point, with: event)
    }
}
