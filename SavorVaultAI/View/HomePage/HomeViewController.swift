//
//  HomeViewController.swift
//  SavorVaultAI
//
//  Created by Lung-Hao Tung on 3/26/26.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - Scroll Container

    let scrollView = UIScrollView()
    let contentView = UIView()

    // MARK: - AI Analysis Section

    let aiAnalysisCardView = UIView()
    let tabSelectorView = UIView()
    var tabButtons: [UIButton] = []
    let selectedPillView = UIView()
    var selectedPillLeadingConstraint: NSLayoutConstraint!
    var selectedPillWidthConstraint: NSLayoutConstraint!
    let analysisContentContainer = UIView()
    let analysisLabel = UILabel()
    var selectedTabIndex: Int = 0

    // MARK: - Recently Added Section

    let recentlyAddedHeaderLabel = UILabel()

    lazy var recentlyAddedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 200)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()

    let recentlyAddedItems: [DrinkCardItem] = [
        DrinkCardItem(name: "Château Margaux", category: "Red Wine"),
        DrinkCardItem(name: "Hoegaarden White", category: "Wheat Beer"),
        DrinkCardItem(name: "Aperol Spritz", category: "Cocktail"),
        DrinkCardItem(name: "Cloudy Bay Sauvignon", category: "White Wine"),
        DrinkCardItem(name: "Guinness Draught", category: "Stout"),
    ]

    // MARK: - Lifecycle

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureScrollContainer()
        configureAIAnalysisSection()
        configureRecentlyAddedSection()
        applyLayoutConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePillLayout()
    }
}
