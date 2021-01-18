//
//  PostSettingsView.swift
//  PostSettings
//
//  Created by Erik Kamalov on 11/13/20.
//

import UIKit
import Combine
import PinLayout

final class PostSettingsView: UIViewController, ViewInterface {
    
    // MARK: - Attributes
    var presenter: PostSettingsPresenterViewInterface!
    
    lazy var bgImageView = UIImageView.build {
        $0.image = temporaryBgImage
    }
    
    lazy var navigationBar: NavigationBar = {
        let backItem = NavigationItem(icon: UIImage.backButton, complition: presenter.tappedBackBt)
        return .init(title: "Post settings", leftItem: backItem)
    }()
    
    private lazy var saveBt: SendPostButtonView = SendPostButtonView(titleText: "SAVE")
    private lazy var captionView: CaptionViewFooter = CaptionViewFooter()
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset = .init(top: 10, left: 0, bottom: 24, right: 0)
        let cv = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        cv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cv.backgroundColor = .clear
        cv.allowsMultipleSelection = true
        //        cv.allowsSelection = true
        cv.delegate = self
        cv.register(cellWithClass: PostSettingCell.self)
        return cv
    }()
    
    enum Section: CaseIterable {
        case main
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, PostSettingItem>! = nil
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Layouting
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgImageView.pin.all()
        navigationBar.pin.left().right().top(self.view.safeAreaInsets.top).marginTop(9).height(37)
        saveBt.pin.left().right().bottom().height(63.adaptive)
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionView.pin.below(of: navigationBar, aligned: .center).left().right().height(contentSize)
        captionView.pin.below(of: collectionView, aligned: .center).above(of: saveBt, aligned: .center).width(100%)
    }
    
    // MARK: - Binding
    private var cancellables: Set<AnyCancellable> = []
    
    func bindTargets() {
        captionView.gesture().sink { [weak self] _ in
            self?.presenter.tappedCationView()
        }.store(in: &cancellables)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let cellTemplate = PostSettingCell()
}

extension PostSettingsView: PostSettingsViewPresenterInterface {
    func display(caption text: String) {
        captionView.update(text: text)
        saveBt.isEnabled = text.isEmpty ? false : true
    }
    
    func display(_ items: [PostSettingItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostSettingItem>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Configuration
    func setupInitial() {
        self.view.addSubviews(bgImageView, navigationBar, collectionView, captionView,  saveBt)

        configureDataSource()
        presenter.loadData()
        bindTargets()
    }
}

extension PostSettingsView: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        presenter.didSelect(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        presenter.deselect(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataSource.snapshot().itemIdentifiers[indexPath.row]
        cellTemplate.apply(item)
        return cellTemplate.sizeThatFits(.init(width: collectionView.bounds.width, height: .greatestFiniteMagnitude))
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, PostSettingItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: PostSettingItem) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withClass: PostSettingCell.self, for: indexPath)
            cell.apply(identifier)
            return cell
        }
    }
}
