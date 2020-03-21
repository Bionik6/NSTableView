//
//  ViewController.swift
//  TableDemo
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  
  // MARK: - IBOutlet Properties
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBOutlet weak var viewModeButton: NSButton?
  
  @IBOutlet weak var selectedAmountLabel: NSTextField?
  
  
  
  // MARK: - Properties
  
  var viewModel = ViewModel()
  
  var originalColumns = [NSTableColumn]()
  
  
  
  // MARK: - View Controller Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    tableView.reloadData()
  }
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    originalColumns = tableView.tableColumns
    tableView.doubleAction = #selector(handleDoubleClick)
  }
  
  
  // MARK: - IBAction Methods
  
  @IBAction func switchDisplayMode(_ sender: Any) {
    viewModel.switchDisplayMode()
    if viewModel.displayMode == .detail {
      for column in tableView.tableColumns.reversed() { tableView.removeTableColumn(column) }
      let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("detailsColumn"))
      column.width = tableView.frame.size.width
      column.title = "Purchases Detailed View"
      tableView.addTableColumn(column)
      viewModeButton?.title = "Switch to Plain Display Mode"
    } else {
      tableView.removeTableColumn(tableView.tableColumns[0])
      for column in originalColumns { tableView.addTableColumn(column) }
      viewModeButton?.title = "Switch to Detail Display Mode"
    }
    tableView.reloadData()
  }
  
  
  
  // MARK: - Custom Methods
  
  func showAlert(forPurchase purchase: Purchases) {
    var user = "User"
    var displayAmount = "$0"
    if let username = purchase.userInfo?.username {
      user = username
    }
    if let amount = purchase.paymentInfo?.amount {
      displayAmount = amount
    }
    
    let alert = NSAlert()
    alert.messageText = "\(user) spent \(displayAmount) in purchases over the last 24 hours."
    alert.beginSheetModal(for: self.view.window!) { (response) in
      
    }
  }
  
  @objc private func handleDoubleClick() {
    let clickedRow = tableView.clickedRow
    guard clickedRow >= 0 else { return }
    let purchase = viewModel.purchases[clickedRow]
    showAlert(forPurchase: purchase)
  }
  
}



extension ViewController: NSTableViewDataSource {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return viewModel.purchases.count
  }
}


extension ViewController: NSTableViewDelegate {
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let currentPurchase = viewModel.purchases[row]
    if viewModel.displayMode == .plain {
      if tableColumn?.identifier == NSUserInterfaceItemIdentifier("idColumn") {
        let cellIdentifier = NSUserInterfaceItemIdentifier("idCell")
        guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
        cellView.textField?.integerValue = currentPurchase.id ?? 0
        return cellView
      } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier("userInfoColumn") {
        let cellIdentifier = NSUserInterfaceItemIdentifier("userInfoCell")
        guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
        cellView.textField?.stringValue = currentPurchase.userInfo?.username ?? ""
        if let data = viewModel.getAvatarData(forUserWithID: currentPurchase.userInfo?.id) {
          cellView.imageView?.image = NSImage(data: data)
        }
        return cellView
      } else {
        let cellIdentifier = NSUserInterfaceItemIdentifier("paymentInfoCell")
        guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? PaymentInfoCellView else { return nil }
        cellView.textField?.stringValue = currentPurchase.paymentInfo?.creditCard ?? ""
        cellView.creditCardTypeLabel?.stringValue = currentPurchase.paymentInfo?.creditCardType ?? ""
        cellView.amountLabel?.stringValue = currentPurchase.paymentInfo?.amount ?? ""
        cellView.purchasesPopup?.removeAllItems()
        cellView.purchasesPopup?.addItems(withTitles: currentPurchase.paymentInfo?.purchaseTypes ?? [])
        return cellView
      }
    } else {
      let view = PurchasesDetailView()
      view.usernameLabel.stringValue = currentPurchase.userInfo?.username ?? ""
      view.idLabel.integerValue = currentPurchase.id ?? 0
      if let avatarData = viewModel.getAvatarData(forUserWithID: currentPurchase.userInfo?.id) {
        view.avatarImageView.image = NSImage(data: avatarData)
      }
      view.creditCardNumberLabel.stringValue = currentPurchase.paymentInfo?.creditCard ?? ""
      view.creditCardTypeLabel.stringValue = currentPurchase.paymentInfo?.creditCardType ?? ""
      view.amountLabel.stringValue = currentPurchase.paymentInfo?.amount ?? ""
      view.purchasesLabel.stringValue = currentPurchase.paymentInfo?.purchaseTypes?.joined(separator: ", ") ?? ""
      return view
    }
  
  }
  
  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return viewModel.displayMode == .plain ? 21 : 150
  }
  
}
