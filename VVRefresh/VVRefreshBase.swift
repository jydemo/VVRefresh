//
//  VVREfreshBase.swift
//  VVRefresh
//
//  Created by jay on 2016/12/7.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class VVRefreshBase: UIView {

    typealias beginRefreshBlock = () -> Void
    
    enum VVRefreshState {
        case normal
        case pulling
        case refreshing
    }
    
    enum VVRefreshViewType {
        case header
        case footer
    }
    
    var scrollView: UIScrollView!
    
    var scrolViewOriginalInset: UIEdgeInsets!
    
    var statusLabel: UILabel!
    
    var arrowImage: UIImageView!
    
    var activityView: UIActivityIndicatorView!
    
    var oldState: VVRefreshState?
    
    var beginRefreshingCallback: beginRefreshBlock?
    
    var state: VVRefreshState = .normal {
        
        willSet {
            
            oldState = newValue
        
        }
        
        didSet {
            
            guard self.state != self.oldState else {
                
                return
            
            }
            
            switch state {
            case .normal:
                self.arrowImage.isHidden = false
                
                self.activityView.stopAnimating()
                
            case .pulling:
                break
                
            case .refreshing:
                self.arrowImage.isHidden = true
                
                activityView.startAnimating()
                
                if let _ = self.beginRefreshingCallback {
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(VVTimer * Double(NSEC_PER_SEC))), execute: {
                        
                        self.state = .normal
                        
                        self.beginRefreshingCallback!()
                    })
                
                }
            }
        
        }
    
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        self.arrowImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        self.arrowImage.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        
        self.arrowImage.image = UIImage(named: "pull_to_refresh_icon")
        
        self.addSubview(arrowImage)
        
        statusLabel = UILabel(frame: CGRect(x: 0, y: 55, width: SCREEN_WIDTH, height: 20))
        
        statusLabel.autoresizingMask = .flexibleWidth
        
        statusLabel.font = VVRefreshLabelTextSize
        
        statusLabel.textColor = VVRefreshLabelTextColor
        
        statusLabel.backgroundColor = UIColor.clear
        
        statusLabel.textAlignment = .center
        
        self.addSubview(statusLabel)
        
        
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        self.activityView.bounds = self.arrowImage.bounds
        
        self.autoresizingMask = self.arrowImage.autoresizingMask
        
        self.activityView.hidesWhenStopped = true
        
        self.activityView.color = VVRefreshLabelTextColor
        
        self.addSubview(activityView)
        
        self.autoresizingMask = .flexibleWidth
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.arrowImage.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.height / 2)
        
        self.activityView.center = self.arrowImage.center
        
    }
    
    override func draw(_ rect: CGRect) {
        superview?.draw(rect)
        if self.state == .pulling {
            
            self.state = .refreshing
        
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if self.superview != nil {
            
            self.superview?.removeObserver(self, forKeyPath: VVRefreshContentOffset, context: nil)
        
        }
        
        if newSuperview != nil {
            //之前没有看到这一行
            newSuperview?.addObserver(self, forKeyPath: VVRefreshContentOffset, options: .new, context: nil)
            
            var rect: CGRect = self.frame
            
            rect.size.width = newSuperview!.frame.size.width
            
            rect.origin.x = 0
            
            self.frame = frame
            
            scrollView = newSuperview as! UIScrollView
            
            scrolViewOriginalInset = scrollView.contentInset
        
        }
    }
    
    func isRefreshing() -> Bool {
        
        return VVRefreshState.refreshing == self.state
    
    }
    
    func beginRefreshing() {
        
        if self.window != nil {
            
            self.state = .refreshing
        
        } else {
            
            state = .pulling
            
            super.setNeedsDisplay()
        
        }
    
    }
    
    func endrefreshing() {
        
        let delayInSceonds = 0.3
        
        let time = DispatchTime(uptimeNanoseconds: UInt64(delayInSceonds))
        
        DispatchQueue.main.asyncAfter(deadline: time) {
            
            self.state = .normal
        
        }
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
