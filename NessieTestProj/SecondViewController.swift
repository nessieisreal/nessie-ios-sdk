//
//  SecondViewController.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 9/16/16.
//  Copyright © 2016 Nessie. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func testEnterpriseAccountsRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = await EnterpriseAccountTests()
        }
    }
    
    @IBAction func testEnterpriseBillsRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = await EnterpriseBillTests()
        }
    }
    
    @IBAction func testEnterpriseCustomerRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = await EnterpriseCustomerTests()
        }
    }
    
    @IBAction func testEnterpriseDepositsRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = await EnterpriseDepositTests()
        }
    }
    
    @IBAction func testEnterpriseMerchantsRequests(sender: AnyObject) {
        let _ = EnterpriseMerchantTests()
    }
    
    @IBAction func testEnterpriseTransfersRequests(sender: AnyObject) {
        Task { @MainActor in
            let _ = await EnterpriseTransferTests()
        }
    }
    
    @IBAction func testEnterpriseWithdrawalsRequests(sender: AnyObject) {
        let _ = EnterpriseWithdrawalTests()
    }
}
