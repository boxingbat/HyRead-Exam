//
//  BookCollectionViewCell.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/23.
//

import UIKit

class BookCollectionViewCell: UICollectionViewCell {
    static let identifier = "BookCollectionViewCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let favoriteButton = UIButton()
    private var isFavorite: Bool = false
    private var bookUUID: Int?

    //use closure to send back the event
    var onFavoriteToggle: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        setupFavoriteButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        imageView.image = nil
    }

    private func setupCell() {

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 4.4
        imageView.clipsToBounds = true
        let imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 150)
        imageViewHeightConstraint.isActive = true

        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.pingFangTCRegular(size: 14)


        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    private func setupFavoriteButton() {
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            favoriteButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 28),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28)
        ])

        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .white
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
    }

    @objc private func toggleFavorite() {
        isFavorite = !isFavorite
        updateFavoriteButton()

        if let uuid = bookUUID {
            onFavoriteToggle?(uuid)
        }
    }
    func configure(with book: Book) {
        titleLabel.text = book.title
        if let url = URL(string: "\(book.coverUrl)") {
            imageView.kf.setImage(with: url)
        }

        self.bookUUID = book.uuid

        let favorites = UserDefaults.standard.array(forKey: "favorites") as? [Int] ?? []
        isFavorite = favorites.contains(book.uuid)
        updateFavoriteButton()
    }
    private func updateFavoriteButton() {
        if isFavorite {
            favoriteButton.tintColor = UIColor(red: 80/255, green: 227/255, blue: 194/255, alpha: 1) // #50E3C2
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            favoriteButton.tintColor = .white
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
}
