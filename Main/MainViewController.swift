//
//  ViewController.swift
//  PhotoLibrary
//
//  Created by 김윤석 on 2023/10/31.
//
import Combine
import Photos
import UIKit

final class MainViewController: UIViewController {
    private typealias DataSource    = UICollectionViewDiffableDataSource<Section, PHAsset>
    private typealias Snapshot      = NSDiffableDataSourceSnapshot<Section, PHAsset>
    
    enum Section { case main }
    
    private var diffableDataSource: DataSource?
    private let contentView = MainView()
    private let viewModel: MainViewModel
    private var cancellables: Set<AnyCancellable>
    
    init(_ viewModel: MainViewModel) {
        self.viewModel = viewModel
        self.cancellables = .init()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = contentView
    }
    
    private var statusButton: [UIAction] {
        return [
            UIAction(title: "3", handler: {[weak self] (_) in
                self?.viewModel.setCellStatus(.three)
                self?.updateData()
            }),
            UIAction(title: "4", handler: {[weak self] (_) in
                self?.viewModel.setCellStatus(.four)
                self?.updateData()
            }),
            UIAction(title: "5", handler: {[weak self] (_) in
                self?.viewModel.setCellStatus(.five)
                self?.updateData()
            })
        ]
    }
}

//MARK: - Life Cycle
extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        configureDiffableDataSource()
        bind()
    }
}

//MARK: - Navigation Bar
extension MainViewController {
    private func configureNavigationItem() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: "",
                image: .init(systemName: "slider.horizontal.3"),
                primaryAction: nil,
                menu: UIMenu(
                    title: "",
                    image: nil,
                    identifier: nil,
                    options: [.singleSelection],
                    children: statusButton
                )
            )
        ]
    }
}

//MARK: - Binding with ViewModel
extension MainViewController {
    private func bind() {
        contentView.collectionView.delegate = self
        viewModel
            .mainViewModelPublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] type in
                guard let self = self else { return }
                switch type {
                case .updateData:
                    self.updateData()
                    
                case .showAlert(let message):
                    self.showAlert(of: message)
                }
            }
            .store(in: &cancellables)
    }
}

extension MainViewController {
    private func showAlert(of message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .destructive)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Diffable DataSource
extension MainViewController {
    private func configureDiffableDataSource() {
        diffableDataSource = DataSource(
            collectionView: contentView.collectionView,
            cellProvider: {[weak self] collectionView, indexPath, follower in
                guard
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: PhotoCell.identifier,
                        for: indexPath
                    ) as? PhotoCell,
                    let self
                else { return UICollectionViewCell() }
                viewModel.imageOfAsset(at: indexPath.item) { image in
                    cell.configure(image: image)
                }
                return cell
            }
        )
    }
    
    private func updateData() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.viewModel.assets)
        self.diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }
}

//MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.convertToImage(fromAssetAt: indexPath.item) { [weak self] image in
            self?.contentView.setSelectedImage(image)
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(
            width: UIScreen.main.bounds.width/CGFloat(viewModel.cellStatus.rawValue),
            height: UIScreen.main.bounds.width/CGFloat(viewModel.cellStatus.rawValue)
        )
    }
}
