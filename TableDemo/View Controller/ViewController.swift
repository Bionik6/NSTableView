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
  }
  
  
  // MARK: - IBAction Methods
  
  @IBAction func switchDisplayMode(_ sender: Any) {
    
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
  
}



extension ViewController: NSTableViewDataSource {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return viewModel.purchases.count
  }
}


extension ViewController: NSTableViewDelegate {
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let currentPurchase = viewModel.purchases[row]
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
  }
  
  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return 21
  }
  
}
