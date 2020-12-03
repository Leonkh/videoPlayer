//
//  RewindView.swift
//  TestTaskVideoPlayer
//
//  Created by Леонид Хабибуллин on 03.12.2020.
//

import UIKit

class RewindView: UIView {
    
    let forwardView: UIView = UIView()
    let backwardView: UIView = UIView()
    var delegate: ViewControllerDelegate?
    
    func setUpAll() {
        setUpMyForwardView()
        setUpMyBackwardView()
    }
    
    func setUpMyForwardView() {
        makeConstraint(view: forwardView)
        forwardView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        setUpTapRecognizer(view: forwardView)
    }
    
    func setUpMyBackwardView() {
        makeConstraint(view: backwardView)
        backwardView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        setUpTapRecognizer(view: backwardView)
    }
    
    func setUpTapRecognizer(view: UIView) {
        let doubleTap = UITapGestureRecognizer()
        
        if view == forwardView {
            doubleTap.addTarget(self, action: #selector(forwardViewTapped))
        } else {
            doubleTap.addTarget(self, action: #selector(backwardViewTapped))
        }
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }
    
    func makeConstraint(view: UIView) {
        view.backgroundColor = nil
        self.addSubview(view)
        view.alpha = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
    }
    

    
    @objc func forwardViewTapped() {
        delegate?.forwardRewind()
    }
    
    @objc func backwardViewTapped() {
        delegate?.backwardRewind()
    }
    
}
