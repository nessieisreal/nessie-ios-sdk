//
//  ViewController.swift
//  NessieTestProj
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func testAccountsRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = await AccountTests()
        }
    }
    
    @IBAction func testAtmRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = await ATMTests()
        }
    }
    
    @IBAction func testBillRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = try await BillTests()
        }
    }
    
    @IBAction func testBranchesRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = await BranchTests()
        }
    }
    
    @IBAction func testCustomersRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = await CustomerTests()
        }
    }

    @IBAction func testDepositsRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = await DepositsTests()
        }
    }
    
    @IBAction func testPurchasesRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = await PurchasesTests()
        }
    }
    
    @IBAction func testMerchantsRequests(sender: UIButton) {
        Task { @MainActor in
            let _ = await MerchantTests()
        }
    }
    
    @IBAction func testTransfersRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = await TransfersTests()
        }
    }
    
    @IBAction func testWithdrawalsRequests(sender: UIButton) {
        Task { @MainActor in
            let _ = await WithdrawalsTests()
        }
    }
    @IBAction func testLoanRequests(sender: UIButton) {
        Task { @MainActor in
            let _ = await LoanTests()
        }
    }
}
