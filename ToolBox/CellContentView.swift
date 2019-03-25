//
//  CellContentView.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import UIKit
import SnapKit

/// The view class to show the image on the left side if needed,
/// a stack of content in the midle, and stack of additional content
/// on the right if needed
final class CellContentView: UIView {

    // MARK: - Constants

    private struct Constants {
        static let padding: CGFloat = 16.0
        static let stackSpacing: CGFloat = 4.0
    }

    // MARK: - Public properties

    /// The mainImageView shown on the lift side
    lazy var mainImageView: UIImageView = {
        UIImageView(frame: CGRect(x: 0,
                                  y: 0,
                                  width: mainImageSize.width,
                                  height: mainImageSize.height))
    }()

    /// The info stach view to contain all the useful info
    lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        // Default spacing, if it will be needed to configure this, expose the API
        stackView.spacing = Constants.stackSpacing

        return stackView
    }()

    /// The additional stack view shown on the right side
    lazy var rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        // Default spacing, if it will be needed to configure this, expose the API
        stackView.spacing = Constants.stackSpacing

        return stackView
    }()

    // MARK: - Private Properties

    /// The height of the view
    private let height: CGFloat

    /// The size of the main image view
    private let mainImageSize: CGSize

    // MARK: - Initializers

    /// Creates an instace of the CellContentView
    ///
    /// - Parameters:
    ///   - height: The height of the cell
    ///   - mainImageSize: The main image size
    init(height: CGFloat, mainImageSize: CGSize) {
        self.height = height
        self.mainImageSize = mainImageSize
        super.init(frame: .zero)
        layoutComponents()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    /// Sets up the layout
    private func layoutComponents() {
        addSubview(mainImageView)
        addSubview(infoStackView)
        addSubview(rightStackView)

        self.snp.updateConstraints { make in
            make.height.equalTo(height)
        }

        mainImageView.snp.updateConstraints { make in
            make.centerY.equalTo(self)
            make.height.equalTo(mainImageSize.height)
            make.width.equalTo(mainImageSize.width)
            make.leading.equalTo(self).offset(Constants.padding / 2)
        }

        infoStackView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.leading.equalTo(mainImageView.snp.trailing).offset(Constants.padding / 2)
            make.trailing.lessThanOrEqualTo(rightStackView.snp.leading).offset(-Constants.padding / 2)
        }

        rightStackView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-Constants.padding)
        }
    }

    // MARK: - Public methods

    /// Update the main image view image from the bundle
    ///
    /// - Parameter imageName: The image name to be used to load the image
    func setMainImageView(withImageName imageName: String) {
        mainImageView.image = UIImage(named: imageName)
    }

    /// The info to be shown
    ///
    /// - Parameter infoStack: The array of info views to show
    func setInfo(infoStack: [UIView]) {
        infoStackView.removeAllArrangedSubviews()
        for view in infoStack {
            infoStackView.addArrangedSubview(view)
        }
    }

    /// Adds additional info on the right of the view
    ///
    /// - Parameter views: The array of info views to show
    func setRightViews(views: [UIView]) {
        rightStackView.removeAllArrangedSubviews()
        for view in views {
            rightStackView.addArrangedSubview(view)
        }
    }
}
