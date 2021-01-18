//
//  PostView.swift
//  Post
//
//  Created by Erik Kamalov on 11/12/20.
//

import Combine
import UIKit

struct Item: Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Item {
    static var stubs: [Item] {
        return [
            Item(title: "Ann Mccoy", subtitle: "@AnnMccoy", imageName: "ava_status"),
            Item(title: "Darrell Cooper", subtitle: "@DarCooper", imageName: "ava_status"),
            Item(title: "Great monument", subtitle: "@Grandiose", imageName: "ava_status"),
            Item(title: "Blue Sky", subtitle: "@Ahh", imageName: "ava_status"),
            Item(title: "Indoor Cafe", subtitle: "@An", imageName: "ava_status"),
            Item(title: "Ann Mccoy", subtitle: "@AnnMccoy", imageName: "ava_status")
        ]
    }
}

final class PostView: UIViewController, ViewInterface {
    
    // MARK: - Attributes
    var presenter: PostPresenterViewInterface!
    
    lazy var bgImageView = UIImageView.build {
        $0.image = temporaryBgImage
    }
    
    lazy var navigationBar: NavigationBar = {
        let backItem = NavigationItem(icon: UIImage.backButton, complition: presenter.tapBackBt)
        let settingsItem = NavigationItem(icon: UIImage.settings, complition: presenter.tapSettingBt)
        return .init(title: "Choose recipients", leftItem: backItem, rightItem: settingsItem)
    }()
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    private var searchBarHeight: CGFloat = 53.adaptive
    private var sendViewHeight: CGFloat = 0
    
    enum Section: String, Hashable, CaseIterable {
        case basic = ""
        case recent = "RECENT"
        case myFriends = "ALL MY FRIENDS"
    }
    
    private var section = Section.allCases
    lazy var sendView: SendPostButtonView = .init(titleText: "SEND")
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        presenter.reload()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.setContentOffset(.init(x: 0, y: searchBarHeight + 2), animated: true)
    }
    
    // MARK: - Layouting
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("CaptionView viewDidLayoutSubviews")
        bgImageView.pin.all()
        navigationBar.pin.left().right().top(self.view.safeAreaInsets.top).marginTop(9).height(37)
        
        sendView.pin.left().right().bottom().height(sendViewHeight)
        collectionView.pin.below(of: navigationBar, aligned: .center).above(of: sendView, aligned: .center).left().right()
    }
    
    // MARK: - Binding
    private var cancellables: Set<AnyCancellable> = []
    
    func bindTargets() { }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
// MARK: - Viper
extension PostView: PostViewPresenterInterface {
    func updateSendView(subTitle:String?, height: CGFloat) {
        sendView.setSubtitle(subTitle)
        self.sendViewHeight = height
        UIView.animate(withDuration: 0.3) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    func display(recents: [Item]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(recents, toSection: .recent)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func display(myFriends: [Item]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(myFriends, toSection: .myFriends)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func display(basic: [Item]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(basic, toSection: .basic)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    func setupInitial() {
        self.view.addSubviews(bgImageView, navigationBar)
        configureHierarchy()
        configureDataSource()
        
        view.addSubview(sendView)
    }
}

// MARK: - CollectionView delegate
extension PostView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        presenter.didSelect(item)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        presenter.deselect(item)
    }
}

// MARK: - DataSource
extension PostView {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        collectionView.register(cellWithClass: PostCell.self)
        collectionView.register(PostCellHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: PostCellHeader.reuseIdentifier)
        collectionView.register(PostSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: PostSearchBarHeader.reuseIdentifier)
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (index, env) -> NSCollectionLayoutSection? in
            
            let currentSection = self.section[safe: index] ?? .basic
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(currentSection == .basic ? 56.adaptive : 50.adaptive))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            
            let section = NSCollectionLayoutSection(group: group)
            
            if currentSection == .basic {
                section.interGroupSpacing = 9
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(self.searchBarHeight))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                elementKind: UICollectionView.elementKindSectionHeader,
                                                                                alignment: .top)
                section.boundarySupplementaryItems = [sectionHeader]
            } else {
                section.interGroupSpacing = 8
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                elementKind: UICollectionView.elementKindSectionHeader,
                                                                                alignment: .top)
                
                section.boundarySupplementaryItems = [sectionHeader]
            }
            return section
        }
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView: UICollectionView,
                                                                                                          indexPath: IndexPath, identifier: Item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withClass: PostCell.self, for: indexPath)
            cell.apply(identifier, imageHeight: indexPath.section == 0 ? 47.adaptive : 40.adaptive, selectMarkEnable: indexPath.section == 0)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { ( collectionView: UICollectionView, kind: String,
                                                   indexPath: IndexPath) -> UICollectionReusableView? in
            if kind == UICollectionView.elementKindSectionHeader {
                if  indexPath.section == 0 {
                    guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                            ofKind: kind,
                            withReuseIdentifier: PostSearchBarHeader.reuseIdentifier,
                            for: indexPath) as? PostSearchBarHeader else { fatalError("Cannot create new supplementary") }
                    return supplementaryView
                }
                guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: PostCellHeader.reuseIdentifier,
                        for: indexPath) as? PostCellHeader, let title = self.section[safe: indexPath.section] else { fatalError("Cannot create new supplementary") }
                supplementaryView.apply(title.rawValue)
                return supplementaryView
                
            }
            return nil
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(section)
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }
}



// MARK: - ScrollView delegate
extension PostView {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scOffsetY = scrollView.contentOffset.y
        let targetOffset = targetContentOffset.pointee.y
        
        switch true {
        case targetOffset == 0 && scOffsetY > searchBarHeight:
            targetContentOffset.pointee.y = searchBarHeight
        case (searchBarHeight.half...searchBarHeight).contains(scOffsetY) && targetOffset != 0:
            targetContentOffset.pointee.y = searchBarHeight
        case scOffsetY < searchBarHeight.half && targetOffset < searchBarHeight.half:
            targetContentOffset.pointee.y = 0
        default: break
        }
    }
}
