//
//  WrappedActivityViewController.swift
//  UIAVCHacking
//
//  Created by Ryan McLeod on 8/21/19.
//  Copyright © 2019 Grow Pixel. All rights reserved.
//

import UIKit

class WrappedActivityViewController : UIViewController {

    private let activityVC: UIActivityViewController
    private let extraView: UIView
    private let extraViewBackgroundView = UIVisualEffectView()
    private let divider = UIVisualEffectView()

    init(activityViewController: UIActivityViewController, extraView: UIView) {
        self.extraView = extraView
        self.activityVC = activityViewController

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        extraViewBackgroundView.effect = UIBlurEffect(style: .systemThickMaterial)
        divider.effect = UIVibrancyEffect(blurEffect: (extraViewBackgroundView.effect as! UIBlurEffect), style: .separator)

        addChild(activityVC)
        view.addSubview(extraViewBackgroundView)
        view.addSubview(extraView)
        view.addSubview(divider)
        view.addSubview(activityVC.view)
        activityVC.didMove(toParent: self)

        extraViewBackgroundView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(activityVC.view.snp.top)
            make.width.equalToSuperview()
        }

        extraView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalTo(extraViewBackgroundView).inset(15)
            make.bottom.equalTo(extraViewBackgroundView)
        }

        divider.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(extraViewBackgroundView)
        }

        activityVC.view.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(extraViewBackgroundView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
