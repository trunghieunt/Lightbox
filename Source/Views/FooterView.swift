import UIKit

public protocol FooterViewDelegate: class {
    
    func footerView(_ footerView: FooterView, didExpand expanded: Bool)
}

open class FooterView: UIView {
    
    open var isImageActionEnabled = false {
        didSet {
            self.imageButton.isHidden = !isImageActionEnabled
        }
    }

  open fileprivate(set) lazy var infoLabel: InfoLabel = { [unowned self] in
    let label = InfoLabel(text: "")
    label.isHidden = !LightboxConfig.InfoLabel.enabled

    label.textColor = LightboxConfig.InfoLabel.textColor
    label.isUserInteractionEnabled = true
    label.delegate = self

    return label
  }()
    
    open fileprivate(set) lazy var imageButton: UIButton = { [unowned self] in
        
        let button = UIButton(type: .system)
        return button
    }()

  open fileprivate(set) lazy var pageLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: CGRect.zero)
    label.isHidden = !LightboxConfig.PageIndicator.enabled
    label.numberOfLines = 1

    return label
  }()

  open fileprivate(set) lazy var separatorView: UIView = { [unowned self] in
    let view = UILabel(frame: CGRect.zero)
    view.isHidden = !LightboxConfig.PageIndicator.enabled
    view.backgroundColor = LightboxConfig.PageIndicator.separatorColor

    return view
  }()

  let gradientColors = [UIColor(hex: "040404").withAlphaComponent(0.1), UIColor(hex: "040404")]
  open weak var delegate: FooterViewDelegate?

  // MARK: - Initializers

  public init() {
    super.init(frame: CGRect.zero)

    backgroundColor = UIColor.clear
    _ = addGradientLayer(gradientColors)

    [pageLabel, infoLabel, separatorView, imageButton].forEach { addSubview($0) }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Helpers

  func expand(_ expand: Bool) {
    expand ? infoLabel.expand() : infoLabel.collapse()
  }

  func updatePage(_ page: Int, _ numberOfPages: Int) {
    let text = "\(page)/\(numberOfPages)"

    pageLabel.attributedText = NSAttributedString(string: text,
      attributes: LightboxConfig.PageIndicator.textAttributes)
    pageLabel.sizeToFit()
  }

  func updateText(_ text: String) {
    infoLabel.fullText = text

    if text.isEmpty {
      _ = removeGradientLayer()
    } else if !infoLabel.expanded {
      _ = addGradientLayer(gradientColors)
    }
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    do {
      let bottomPadding: CGFloat
      if #available(iOS 11, *) {
        bottomPadding = safeAreaInsets.bottom
      } else {
        bottomPadding = 0
      }

      pageLabel.frame.origin = CGPoint(
        x: (frame.width - pageLabel.frame.width) / 2,
        y: frame.height - pageLabel.frame.height - 2 - bottomPadding
      )
    }

    separatorView.frame = CGRect(
      x: 0,
      y: pageLabel.frame.minY - 2.5,
      width: frame.width,
      height: 0.5
    )

    infoLabel.frame.origin.y = separatorView.frame.minY - infoLabel.frame.height - 5

    resizeGradientLayer()
  }
}

// MARK: - LayoutConfigurable

extension FooterView: LayoutConfigurable {

  @objc public func configureLayout() {
    let widthImageButton = self.imageButton.currentTitle?.widthOfString(usingFont: .systemFont(ofSize: 17.0)) ?? 0 + 20
    imageButton.frame = CGRect(x: bounds.width/2 - widthImageButton/2,
                               y: 6,
                               width: widthImageButton,
                               height: 37.5)
    
    infoLabel.frame = CGRect(x: 17, y: 45, width: frame.width - 17 * 2, height: 35)
    infoLabel.configureLayout()
  }
}

extension FooterView: InfoLabelDelegate {

  public func infoLabel(_ infoLabel: InfoLabel, didExpand expanded: Bool) {
    _ = (expanded || infoLabel.fullText.isEmpty) ? removeGradientLayer() : addGradientLayer(gradientColors)
    
    self.imageButton.isHidden = expanded ? true : self.isImageActionEnabled ? false : true
    
    delegate?.footerView(self, didExpand: expanded)
  }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}
