
//
//  NSEFunctionalTests.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import NessieFmwk

class AccountTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        self.testGetAccounts()
    }
    
    func testGetAccounts() {
        let accountType = AccountType.Savings
        
        AccountRequest().getAccounts(accountType, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Account>? {
                    if array.count > 0 {
                        let account = array[0] as Account?
                        self.testGetAccount(accountId: account!.accountId)
                        print(array)
                    } else {
                        print("No accounts found")
                    }
                }
            }
        })
    }
    
    func testGetAccount(accountId: String) {
        AccountRequest().getAccount(accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let account = response as Account? {
                    print(account)
                    self.testGetCustomerAccounts(customerId: account.customerId)
                }
            }
        })
    }
    
    func testGetCustomerAccounts(customerId: String) {
        AccountRequest().getCustomerAccounts(customerId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Account>? {
                    print(array)
                    let account = array[0] as Account?
                    self.testPostAccount(customerId: account!.customerId)
                    self.testPutAccount(accountId: account!.accountId, nickname: "New nickname", accountNumber: "0987654321123456")
                    self.testDeleteAccount(accountId: account!.accountId)
                }
            }
        })
    }
    
    func testPostAccount(customerId: String) {
        let accountType = AccountType.Savings
        let accountToCreate = Account(accountId: "", accountType:accountType, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456", customerId: customerId)
        AccountRequest().postAccount(accountToCreate, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let accountResponse = response as BaseResponse<Account>?
                let message = accountResponse?.message
                let accountCreated = accountResponse?.object
                print("\(message): \(accountCreated)")
            }
        })
    }
    
    func testPutAccount(accountId: String, nickname: String, accountNumber: String?) {
        AccountRequest().putAccount(accountId, nickname: nickname, accountNumber: accountNumber, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let accountResponse = response as BaseResponse<Account>?
                let message = accountResponse?.message
                let accountCreated = accountResponse?.object
                print("\(message): \(accountCreated)")
            }
        })
    }
    
    func testDeleteAccount(accountId: String) {
        AccountRequest().deleteAccount(accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let accountResponse = response as BaseResponse<Account>?
                if let message = accountResponse?.message {
                    print(message)
                }
            }
        })
    }
}

class ATMTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        self.testGetAtms()
    }
    
    func testGetAtms() {
        let latitude = 38.9283 as Float
        let longitude = -77.1753 as Float
        let radius = "1" as String
        
        ATMRequest().getAtms(latitude, longitude: longitude, radius: radius, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let array = response as AtmResponse?
                print(array!.requestArray)
                
                self.testGetNextAtms(nextString: array!.nextPage)
            }
        })
    }
    
    func testGetNextAtms(nextString: String) {
        ATMRequest().getNextAtms(nextString, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let array = response as AtmResponse?
                print(array!.requestArray)
                
                self.testGetPreviousAtms(previousString: array!.previousPage)
            }
        })
    }
    
    func testGetPreviousAtms(previousString: String) {
        ATMRequest().getPreviousAtms(previousString, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let array = response as AtmResponse?
                print(array!.requestArray)
            }
        })
    }
    
}

class BillTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        testGetAllBills()
    }
    
    var accountToAccess: Account = Account(accountId: "57d213d71fd43e204dd4841e", accountType:.CreditCard, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456", customerId: "57d0c20d1fd43e204dd48282")
    var accountToPay: Account = Account(accountId: "123", accountType:.CreditCard, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456", customerId: "")
    
    func testGetAllBills() {
        BillRequest().getAccountBills(accountToAccess.accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Bill>? {
                    if array.count > 0 {
                        let bill = array[0]
                        print(array)
                        self.testGetBill(billId: bill.billId)
                    } else {
                        print("No accounts found")
                    }
                }
            }
        })
    }
    
    func testGetBill(billId: String) {
        BillRequest().getBill(billId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let bill = response as Bill? {
                    print(bill)
                    self.testGetCustomerBills()
                }
            }
        })
    }
    
    func testGetCustomerBills() {
        BillRequest().getCustomerBills(accountToAccess.customerId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Bill>? {
                    if array.count > 0 {
                        print(array)
                        self.testPostBill()
                    } else {
                        print("No accounts found")
                    }
                }
            }
        })
    }
    
    func testPostBill() {
        let billToCreate = Bill(status: .Pending, payee: "Victor", nickname: "Nickname", creationDate: Date(), paymentDate: nil, recurringDate: 1, upcomingPaymentDate: Date(), paymentAmount: 123, accountId: accountToAccess.accountId)
        BillRequest().postBill(billToCreate, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let billResponse = response as BaseResponse<Bill>?
                let message = billResponse?.message
                let billCreated = billResponse?.object
                print("\(message): \(billCreated)")
                self.testPutBill(bill: billCreated!)
            }
        })
    }
    
    func testPutBill(bill: Bill) {
        bill.payee = "Raul"
        BillRequest().putBill(bill, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let billResponse = response as BaseResponse<Bill>?
                let message = billResponse?.message
                print("\(message)")
                self.testDeleteBill(billId: bill.billId)
            }
        })
    }
    
    func testDeleteBill(billId: String) {
        BillRequest().deleteBill(billId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let billResponse = response as BaseResponse<Bill>?
                let message = billResponse?.message
                print("\(message)")
            }
        })
    }
}

class BranchTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        self.testGetBranches()
    }
    
    func testGetBranches() {
        BranchRequest().getBranches({(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Branch>? {
                    if array.count > 0 {
                        let branch = array[0] as Branch?
                        self.testGetBranch(branchId: branch!.branchId)
                        print(array)
                    } else {
                        print("No branches found")
                    }
                }
            }
        })
    }
    
    func testGetBranch(branchId: String) {
        BranchRequest().getBranch(branchId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let branch = response as Branch? {
                    print(branch)
                }
            }
        })
    }
}

class CustomerTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        testGetCustomers()
    }
    
    func testGetCustomers() {
        CustomerRequest().getCustomers({(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Customer>? {
                    if array.count > 0 {
                        let customer = array[0] as Customer?
                        self.testGetCustomer(customerId: customer!.customerId)
                        print(array)
                    } else {
                        print("No accounts found")
                    }
                }
            }
        })
    }
    
    func testGetCustomer(customerId: String) {
        CustomerRequest().getCustomer(customerId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let customer = response as Customer? {
                    print(customer)
                    self.testGetCustomers(from: "57d20f881fd43e204dd48418")
                }
            }
        })
    }
    
    func testGetCustomers(from accountId: String) {
        CustomerRequest().getCustomer(accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let customer = response as Customer? {
                    print(customer)
                    self.testPostCustomer()
                }
            }
        })
    }
    
    func testPostCustomer() {
        let address = Address(streetName: "Street", streetNumber: "1", city: "City", state: "VA", zipCode: "12345")
        let customerToCreate = Customer(firstName: "Victor", lastName: "Lopez", address: address, customerId: "asd")
        CustomerRequest().postCustomer(customerToCreate, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let customerResponse = response as BaseResponse<Customer>?
                let message = customerResponse?.message
                let customerCreated = customerResponse?.object
                print("\(message): \(customerCreated)")
                self.testPutCustomer(customerToBeModified: customerCreated!)
            }
        })
    }
    
    func testPutCustomer(customerToBeModified: Customer) {
        customerToBeModified.firstName = "Raul"
        CustomerRequest().putCustomer(customerToBeModified, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let accountResponse = response as BaseResponse<Customer>?
                let message = accountResponse?.message
                let accountCreated = accountResponse?.object
                print("\(message): \(accountCreated)")
            }
        })
    }
}

class DepositsTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        testGetAllDepositsFromAccount()
    }
    
    var account: Account = Account(accountId: "57d213d71fd43e204dd4841e", accountType:.CreditCard, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456", customerId: "57d0c20d1fd43e204dd48282")
    
    func testGetDeposit(depositId: String) {
        DepositRequest().getDeposit(depositId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let deposit = response as Deposit? {
                    print(deposit)
                    self.testPostDeposit()
                }
            }
        })
    }
    
    func testGetAllDepositsFromAccount() {
        DepositRequest().getDepositsFromAccountId(account.accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Deposit>? {
                    if array.count > 0 {
                        let deposit = array[0]
                        print(array)
                        self.testGetDeposit(depositId: deposit.depositId)
                    } else {
                        print("No deposits found")
                    }
                }
            }
        })
    }
    
    func testPostDeposit() {
        let depositToCreate = Deposit(depositId: "", status: .Pending, medium: .Balance, payeeId: "asd", amount: 1, type: "merchant", transactionDate: Date(), description: "Description")
        DepositRequest().postDeposit(depositToCreate, accountId: account.accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let depositResponse = response as BaseResponse<Deposit>?
                let message = depositResponse?.message
                let depositCreated = depositResponse?.object
                print("\(message): \(depositCreated)")
                self.testPutDeposit(deposit: depositCreated!)
            }
        })
    }
    
    func testPutDeposit(deposit: Deposit) {
        deposit.medium = .Rewards
        DepositRequest().putDeposit(deposit, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let depositResponse = response as BaseResponse<Deposit>?
                let message = depositResponse?.message
                print("\(message)")
                self.testDeleteDeposit(depositId: deposit.depositId)
            }
        })
    }
    
    func testDeleteDeposit(depositId: String) {
        DepositRequest().deleteDeposit(depositId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let DepositResponse = response as BaseResponse<Deposit>?
                let message = DepositResponse?.message
                print("\(message)")
            }
        })
    }
}

class LoanTests {
    let client = NSEClient.sharedInstance
    let account: Account = Account(accountId: "57d32a5ce63c5995587e85ec",
                                   accountType:.CreditCard,
                                   nickname: "Hola",
                                   rewards: 10,
                                   balance: 100,
                                   accountNumber: "1234567890123456",
                                   customerId: "57d0c20d1fd43e204dd48282")
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        testCreateLoan()
    }
    
    func testGetLoans(accountId: String) {
        LoanRequest().getLoansFromAccountId(accountId) { (loans, error) in
            if let error = error {
                print(error)
            }
            if let loans = loans {
                print("\(loans.count) loans")
                for loan in loans {
                    print(loan.description ?? "Amount: \(loan.amount), credit score: \(loan.creditScore)")
                }
            }
        }
    }
    
    func testCreateLoan() {
        AccountRequest().postAccount(account) { (response, error0) in
            if let error = error0 {
                print(error)
            }
            else {
                let accountId = response?.object?.accountId ?? ""
                let loan = Loan(loanId: "abcd1234", type: .home, status: .approved, creditScore: 800, monthlyPayment: 50, amount: 100, creationDate: Date(), description: "A home loan for the ages")
                LoanRequest().postLoan(loan, accountId: accountId, completion: { (loanResponse, error) in
                    if let error = error {
                        print(error)
                    }
                    else if let loanResponse = loanResponse {
                        let message = loanResponse.message
                        let loanCreated = loanResponse.object
                        print("\(message): \(loanCreated)")
                        
//                        self.testGetLoans(accountId: accountId)
//                        self.testGetLoan(loanId: loan.loanId)
//                        self.testUpdateLoan(loan: loanCreated!)
                        self.testDeleteLoan(loanId: loanCreated!.loanId)
                    }
                })
            }
        }
    }
    
    func testGetLoan(loanId: String) {
        LoanRequest().getLoan(loanId) { (loan, error) in
            if let error = error {
                print(error)
            }
            if let loan = loan {
                print("Amount: \(loan.amount), credit score: \(loan.creditScore)")
            }
        }
    }
    
    func testUpdateLoan(loan: Loan) {
        let originalLoanId = loan.loanId
        loan.creditScore = 600
        LoanRequest().putLoan(loan) { (loanResponse, error) in
            if let error = error {
                print(error)
            }
            if let loanResponse = loanResponse, let loan = loanResponse.object {
                print(loanResponse.message!)
                self.testGetLoan(loanId: originalLoanId)
            }
        }
    }
    
    func testDeleteLoan(loanId: String) {
        LoanRequest().deleteLoan(loanId) { (loanResponse, error) in
            if let error = error {
                print(error)
            }
            if let loanResponse = loanResponse {
                print(loanResponse.message!)
                self.testGetLoan(loanId: loanId)
            }
        }
    }
}

class PurchasesTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        testGetAllPurchasesFromAccount()
    }
    
    var account: Account = Account(accountId: "57d32a5ce63c5995587e85ec",
                                   accountType:.CreditCard,
                                   nickname: "Hola",
                                   rewards: 10,
                                   balance: 100,
                                   accountNumber: "1234567890123456",
                                   customerId: "57d0c20d1fd43e204dd48282")
    let merchant: Merchant = Merchant(merchantId: "57cf75cea73e494d8675ec49",
                                      name: "Best Productions",
                                      category: ["Production"],
                                      address: Address(streetName: "Lafayette St.",
                                                       streetNumber: "5901",
                                                       city: "Brooklyn",
                                                       state: "NY",
                                                       zipCode: "07009"),
                                      geocode: Geocode(lng: -1, lat: 33))
    
    func testGetPurchase(PurchaseId: String) {
        PurchaseRequest().getPurchase(PurchaseId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let purchase = response as Purchase? {
                    print(purchase)
                    self.testPostPurchase()
                }
            }
        })
    }
    
    func testGetAllPurchasesFromMerchant() {
        PurchaseRequest().getPurchasesFromMerchantId(merchant.merchantId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Purchase>? {
                    if array.count > 0 {
                        print(array)
                    } else {
                        print("No purchases found")
                    }
                }
            }
            self.testGetAllPurchasesFromMerchantAndAccount()
        })
    }
    
    func testGetAllPurchasesFromAccount() {
        PurchaseRequest().getPurchasesFromAccountId(account.accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Purchase>? {
                    if array.count > 0 {
                        let purchase = array[0]
                        print(array)
                        self.testGetPurchase(PurchaseId: purchase.purchaseId)
                    } else {
                        print("No purchases found")
                    }
                }
            }
        })
    }
    
    func testGetAllPurchasesFromMerchantAndAccount() {
        PurchaseRequest().getPurchasesFromMerchantAndAccountIds(merchant.merchantId, accountId: account.accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Purchase>? {
                    if array.count > 0 {
                        print(array)
                    } else {
                        print("No purchases found")
                    }
                }
            }
        })
    }
    
    func testPostPurchase() {
        let purchaseToCreate = Purchase(merchantId: "57cf75cea73e494d8675ec49", status: .Cancelled, medium: .Balance, payerId: account.accountId, amount: 4.5, type: "merchant", purchaseDate: Date(), description: "Description", purchaseId: "asd")
        PurchaseRequest().postPurchase(purchaseToCreate, accountId: account.accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let purchaseResponse = response as BaseResponse<Purchase>?
                let message = purchaseResponse?.message
                let purchaseCreated = purchaseResponse?.object
                print("\(message): \(purchaseCreated)")
                self.testPutPurchase(purchase: purchaseCreated!)
            }
        })
    }
    
    func testPutPurchase(purchase: Purchase) {
        purchase.medium = .Rewards
        PurchaseRequest().putPurchase(purchase, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let purchaseResponse = response as BaseResponse<Purchase>?
                let message = purchaseResponse?.message
                print("\(message)")
                self.testDeletePurchase(purchaseId: purchase.purchaseId)
            }
        })
    }
    
    func testDeletePurchase(purchaseId: String) {
        PurchaseRequest().deletePurchase(purchaseId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let PurchaseResponse = response as BaseResponse<Purchase>?
                let message = PurchaseResponse?.message
                print("\(message)")
                self.testGetAllPurchasesFromMerchant()
            }
        })
    }
}

class MerchantTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        testGetMerchants()
    }
    
    func testGetMerchants() {
        MerchantRequest().getMerchants(completion: {(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Merchant>? {
                    if array.count > 0 {
                        let merchant = array[0] as Merchant?
                        self.testGetMerchant(merchantId: merchant!.merchantId)
                        print(array)
                    } else {
                        print("No merchants found")
                    }
                }
            }
        })
    }
    
    func testGetMerchant(merchantId: String) {
        MerchantRequest().getMerchant(merchantId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let merchant = response as Merchant? {
                    print(merchant)
                }
            }
            self.testPostMerchant()
        })
    }
    
    func testPostMerchant() {
        let address = Address(streetName: "Street", streetNumber: "1", city: "City", state: "VA", zipCode: "12345")
        let geocode = Geocode(lng: 1, lat: 0)
        let merchantToCreate = Merchant(merchantId: "", name: "Name", category: ["Cateogry"], address: address, geocode: geocode)
        MerchantRequest().postMerchant(merchantToCreate, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let merchantResponse = response as BaseResponse<Merchant>?
                let message = merchantResponse?.message
                let merchantCreated = merchantResponse?.object
                print("\(message): \(merchantCreated)")
                self.testPutMerchant(merchantToBeModified: merchantCreated!)
            }
        })
    }
    
    func testPutMerchant(merchantToBeModified: Merchant) {
        merchantToBeModified.name = "Raul"
        MerchantRequest().putMerchant(merchantToBeModified, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let accountResponse = response as BaseResponse<Merchant>?
                let message = accountResponse?.message
                let accountCreated = accountResponse?.object
                print("\(message): \(accountCreated)")
            }
        })
    }
}

class TransfersTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        testGetAllTransfersFromAccount()
    }
    
    var account: Account = Account(accountId: "57d34859e63c5995587e8613", accountType:.CreditCard, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456", customerId: "57d0c20d1fd43e204dd48282")
    
    func testGetTransfer(TransferId: String) {
        TransferRequest().getTransfer(TransferId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let transfer = response as Transfer? {
                    print(transfer)
                    self.testPostTransfer()
                }
            }
        })
    }
    
    func testGetAllTransfersFromAccount() {
        TransferRequest().getTransfersFromAccountId(account.accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Transfer>? {
                    if array.count > 0 {
                        let transfer = array[0]
                        print(array)
                        self.testGetTransfer(TransferId: transfer.transferId)
                    } else {
                        print("No transfers found")
                    }
                }
            }
        })
    }
    
    func testPostTransfer() {
        let transferToCreate = Transfer(transferId: "", type: .Deposit, transactionDate: Date(), status: .Pending, medium: .Balance, payerId: "57d34859e63c5995587e8613", payeeId: "57d359e7e63c5995587e8620", amount: 12, description: "Desc")
        TransferRequest().postTransfer(transferToCreate, accountId: account.accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let transferResponse = response as BaseResponse<Transfer>?
                let message = transferResponse?.message
                let transferCreated = transferResponse?.object
                print("\(message): \(transferCreated)")
                self.testPutTransfer(transfer: transferCreated!)
            }
        })
    }
    
    func testPutTransfer(transfer: Transfer) {
        transfer.medium = .Rewards
        TransferRequest().putTransfer(transfer, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let transferResponse = response as BaseResponse<Transfer>?
                let message = transferResponse?.message
                print("\(message)")
                self.testDeleteTransfer(transferId: transfer.transferId)
            }
        })
    }
    
    func testDeleteTransfer(transferId: String) {
        TransferRequest().deleteTransfer(transferId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let TransferResponse = response as BaseResponse<Transfer>?
                let message = TransferResponse?.message
                print("\(message)")
            }
        })
    }
}

class WithdrawalsTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        testGetAllWithdrawalsFromAccount()
    }
    
    var account: Account = Account(accountId: "57d34859e63c5995587e8613", accountType:.CreditCard, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456", customerId: "57d0c20d1fd43e204dd48282")
    
    func testGetWithdrawal(WithdrawalId: String) {
        WithdrawalRequest().getWithdrawal(WithdrawalId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let withdrawal = response as Withdrawal? {
                    print(withdrawal)
                    self.testPostWithdrawal()
                }
            }
        })
    }
    
    func testGetAllWithdrawalsFromAccount() {
        WithdrawalRequest().getWithdrawalsFromAccountId(account.accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Withdrawal>? {
                    if array.count > 0 {
                        let withdrawal = array[0]
                        print(array)
                        self.testGetWithdrawal(WithdrawalId: withdrawal.withdrawalId)
                    } else {
                        print("No withdrawals found")
                    }
                }
            }
        })
    }
    
    func testPostWithdrawal() {
        let withdrawalToCreate = Withdrawal(withdrawalId: "", type: .Deposit, transactionDate: Date(), status: .Cancelled, medium: .Balance, payerId: "57d34859e63c5995587e8613", amount: 12, description: "Desc")
        WithdrawalRequest().postWithdrawal(withdrawalToCreate, accountId: account.accountId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let withdrawalResponse = response as BaseResponse<Withdrawal>?
                let message = withdrawalResponse?.message
                let withdrawalCreated = withdrawalResponse?.object
                print("\(message): \(withdrawalCreated)")
                self.testPutWithdrawal(withdrawal: withdrawalCreated!)
            }
        })
    }
    
    func testPutWithdrawal(withdrawal: Withdrawal) {
        withdrawal.medium = .Rewards
        WithdrawalRequest().putWithdrawal(withdrawal, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let withdrawalResponse = response as BaseResponse<Withdrawal>?
                let message = withdrawalResponse?.message
                print("\(message)")
                self.testDeleteWithdrawal(withdrawalId: withdrawal.withdrawalId)
            }
        })
    }
    
    func testDeleteWithdrawal(withdrawalId: String) {
        WithdrawalRequest().deleteWithdrawal(withdrawalId, completion:{(response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let WithdrawalResponse = response as BaseResponse<Withdrawal>?
                let message = WithdrawalResponse?.message
                print("\(message)")
            }
        })
    }
}

class EnterpriseAccountTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        self.testGetAccounts()
    }
    
    func testGetAccounts() {
        let request = EnterpriseAccountRequest()
        request.getAccounts(){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Account>? {
                    if array.count > 0 {
                        let account = array[0] as Account?
                        self.testGetAccount(accountId: account!.accountId)
                        print(array)
                    } else {
                        print("No accounts found")
                    }
                }
            }
        }
    }
    
    func testGetAccount(accountId: String) {
        var request = EnterpriseAccountRequest()
        request.getAccount(accountId){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if (error != nil) {
                    print(error!)
                } else {
                    if let account = response as Account? {
                        print(account)
                    }
                }
            }
        }
    }
}

class EnterpriseBillTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        self.testGetBills()
    }
    
    func testGetBills() {
        let request = EnterpriseBillRequest()
        request.getBills(){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Bill>? {
                    if array.count > 0 {
                        let bill = array[0] as Bill?
                        self.testGetBill(billId: bill!.billId)
                        print(array)
                    } else {
                        print("No accounts found")
                    }
                }
            }
        }
    }
    
    func testGetBill(billId: String) {
        var request = EnterpriseBillRequest()
        request.getBill(billId){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if (error != nil) {
                    print(error!)
                } else {
                    if let account = response as Bill? {
                        print(account)
                    }
                }
            }
        }
    }
}

class EnterpriseCustomerTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        self.testGetCustomers()
    }
    
    func testGetCustomers() {
        let request = EnterpriseCustomerRequest()
        request.getCustomers(){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Customer>? {
                    if array.count > 0 {
                        let customer = array[0] as Customer?
                        self.testGetCustomer(customerId: customer!.customerId)
                        print(array)
                    } else {
                        print("No accounts found")
                    }
                }
            }
        }
    }
    
    func testGetCustomer(customerId: String) {
        var request = EnterpriseCustomerRequest()
        request.getCustomer(customerId){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if (error != nil) {
                    print(error!)
                } else {
                    if let account = response as Customer? {
                        print(account)
                    }
                }
            }
        }
    }
}

class EnterpriseDepositTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        self.testGetDeposits()
    }
    
    func testGetDeposits() {
        let request = EnterpriseDepositRequest()
        request.getDeposits(){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Deposit>? {
                    if array.count > 0 {
                        let deposit = array[0] as Deposit?
                        self.testGetDeposit(depositId: deposit!.depositId)
                        print(array)
                    } else {
                        print("No accounts found")
                    }
                }
            }
        }
    }
    
    func testGetDeposit(depositId: String) {
        var request = EnterpriseDepositRequest()
        request.getDeposit(depositId){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if (error != nil) {
                    print(error!)
                } else {
                    if let account = response as Deposit? {
                        print(account)
                    }
                }
            }
        }
    }
}

class EnterpriseMerchantTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        self.testGetMerchants()
    }
    
    func testGetMerchants() {
        let request = EnterpriseMerchantRequest()
        request.getMerchants(){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Merchant>? {
                    if array.count > 0 {
                        let merchant = array[0] as Merchant?
                        self.testGetMerchant(merchantId: merchant!.merchantId)
                        print(array)
                    } else {
                        print("No accounts found")
                    }
                }
            }
        }
    }
    
    func testGetMerchant(merchantId: String) {
        var request = EnterpriseMerchantRequest()
        request.getMerchant(merchantId){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if (error != nil) {
                    print(error!)
                } else {
                    if let account = response as Merchant? {
                        print(account)
                    }
                }
            }
        }
    }
}

class EnterpriseTransferTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        self.testGetTransfers()
    }
    
    func testGetTransfers() {
        let request = EnterpriseTransferRequest()
        request.getTransfers(){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Transfer>? {
                    if array.count > 0 {
                        let transfer = array[0] as Transfer?
                        self.testGetTransfer(transferId: transfer!.transferId)
                        print(array)
                    } else {
                        print("No accounts found")
                    }
                }
            }
        }
    }
    
    func testGetTransfer(transferId: String) {
        var request = EnterpriseTransferRequest()
        request.getTransfer(transferId){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if (error != nil) {
                    print(error!)
                } else {
                    if let account = response as Transfer? {
                        print(account)
                    }
                }
            }
        }
    }
}

class EnterpriseWithdrawalTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        self.testGetWithdrawals()
    }
    
    func testGetWithdrawals() {
        let request = EnterpriseWithdrawalRequest()
        request.getWithdrawals(){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if let array = response as Array<Withdrawal>? {
                    if array.count > 0 {
                        let withdrawal = array[0] as Withdrawal?
                        self.testGetWithdrawal(withdrawalId: withdrawal!.withdrawalId)
                        print(array)
                    } else {
                        print("No accounts found")
                    }
                }
            }
        }
    }
    
    func testGetWithdrawal(withdrawalId: String) {
        var request = EnterpriseWithdrawalRequest()
        request.getWithdrawal(withdrawalId){ (response, error) in
            if (error != nil) {
                print(error!)
            } else {
                if (error != nil) {
                    print(error!)
                } else {
                    if let account = response as Withdrawal? {
                        print(account)
                    }
                }
            }
        }
    }
}
