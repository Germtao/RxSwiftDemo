//
//  TTChatViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2021/2/25.
//  Copyright © 2021 tTao. All rights reserved.
//

import UIKit
import MessageKit
import RxSwift
import InputBarAccessoryView

class TTChatViewController: MessagesViewController {
    var messages: [MessageType] = []
    
    let sendPressed = PublishSubject<String>()
    
    let senderSelected = PublishSubject<SenderType>()
    let mentionSelected = PublishSubject<String>()
    let hashtagSelected = PublishSubject<String>()
    let urlSelected = PublishSubject<URL>()
    
    let currentUser = TTUser.currentUser()
    
    /// 从InputBarAccessoryView管理自动完成的对象
    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.messageInputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindViewModel()
    }
    
    func makeUI() {
        configureAutocomplete()
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    func bindViewModel() {
        
    }
}

extension TTChatViewController {
    /// 配置 自动完成
    func configureAutocomplete() {
        autocompleteManager.register(prefix: "@", with: [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
            NSAttributedString.Key.foregroundColor: UIColor.secondary,
            NSAttributedString.Key.backgroundColor: UIColor.secondary.withAlphaComponent(0.1)
        ])
        
        autocompleteManager.register(prefix: "#")
        autocompleteManager.maxSpaceCountDuringCompletion = 1 // 允许有空格的自动完成
        
        messageInputBar.inputPlugins = [autocompleteManager]
        
        autocompleteManager.defaultTextAttributes = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout),
            NSAttributedString.Key.foregroundColor: UIColor.text
        ]
        
        themeService.rx
            .bind({ $0.primaryDark }, to: autocompleteManager.tableView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        themeService.rx
            .bind({ $0.primaryDark }, to: [view.rx.backgroundColor, messagesCollectionView.rx.backgroundColor])
            .disposed(by: rx.disposeBag)
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.keyboardType = .twitter
        messageInputBar.inputTextView.cornerRadius = Configs.BaseDimensions.cornerRadius
        
        themeService.rx
            .bind({ $0.primary }, to: messageInputBar.backgroundView.rx.backgroundColor)
            .bind({ $0.primaryDark }, to: messageInputBar.inputTextView.rx.backgroundColor)
            .bind({ $0.secondary }, to: [messageInputBar.rx.tintColor, messageInputBar.sendButton.rx.titleColor(for: .normal)])
            .bind({ $0.secondaryDark }, to: messageInputBar.sendButton.rx.titleColor(for: .highlighted))
            .bind({ $0.separator }, to: messageInputBar.separatorLine.rx.backgroundColor)
            .bind({ $0.keyboardAppearance }, to: messageInputBar.inputTextView.rx.keyboardAppearance)
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - InputBarAccessoryViewDelegate

extension TTChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        sendPressed.onNext(text)
    }
}

// MARK: - MessagesDataSource

extension TTChatViewController: MessagesDataSource {
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> SenderType {
        return currentUser ?? TTUser()
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1).bold,
            NSAttributedString.Key.foregroundColor: UIColor.secondary
        ])
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = message.sentDate.toRelative()
        return NSAttributedString(string: dateString, attributes: [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2),
            NSAttributedString.Key.foregroundColor: UIColor.text
        ])
    }
}

// MARK: - MessagesLayoutDelegate

extension TTChatViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 22
    }
}

// MARK: - MessagesDisplayDelegate

extension TTChatViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .text : .text
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        return [.foregroundColor: UIColor.secondary]
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.primary.darken(by: 0.15) : UIColor.primary
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if let user = message.sender as? TTUser {
            avatarView.isHidden = isNextMessageSameSender(at: indexPath)
            avatarView.kf.setImage(with: user.avatarUrl?.url)
            avatarView.borderColor = .secondary
            avatarView.borderWidth = Configs.BaseDimensions.borderWidth
        }
    }
    
    // MARK: - Helpers
    
    private func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        
        return (messages[indexPath.section].sender as? TTUser) == (messages[indexPath.section + 1].sender as? TTUser)
    }
}

// MARK: - MessageCellDelegate

extension TTChatViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else { return }
        senderSelected.onNext(message.sender)
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else { return }
        senderSelected.onNext(message.sender)
    }
}

// MARK: - MessageLabelDelegate

extension TTChatViewController: MessageLabelDelegate {
    func didSelectURL(_ url: URL) {
        urlSelected.onNext(url)
    }
    
    func didSelectMention(_ mention: String) {
        mentionSelected.onNext(mention)
    }
    
    func didSelectHashtag(_ hashtag: String) {
        hashtagSelected.onNext(hashtag)
    }
}

// MARK: - AutocompleteManagerDataSource

extension TTChatViewController: AutocompleteManagerDataSource {
    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        switch prefix {
        case "@":
            return messages.map { $0.sender as? TTUser }
                .withoutDuplicates()
                .map {
                    AutocompleteCompletion(text: $0?.displayName ?? "", context: ["avatar": $0?.avatarUrl ?? ""])
                }
        default:
            return []
        }
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else { fatalError("Oops, some unknown error occurred.") }
        
        let image = session.completion?.context?["avatar"] as? String
        cell.imageView?.kf.setImage(with: image?.url)
        cell.imageViewEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        cell.imageView?.cornerRadius = 20
        cell.imageView?.borderColor = .secondary
        cell.imageView?.borderWidth = Configs.BaseDimensions.borderWidth
        cell.imageView?.clipsToBounds = true
        
        let attributedText = manager.attributedText(matching: session, fontSize: 15.0)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.text, range: NSRange(location: 0, length: attributedText.length))
        
        cell.textLabel?.attributedText = attributedText
        cell.backgroundColor = .primary
        cell.separatorLine.backgroundColor = .separator
        
        return cell
    }
}

// MARK: - AutocompleteManagerDelegate

extension TTChatViewController: AutocompleteManagerDelegate {
    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        setAutocompleteManager(active: shouldBecomeVisible)
    }
    
    private func setAutocompleteManager(active: Bool) {
        let topStackView = messageInputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
        }
        messageInputBar.invalidateIntrinsicContentSize()
    }
}
