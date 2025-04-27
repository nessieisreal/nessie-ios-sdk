
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
    
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        await self.testGetAccounts()
    }
    
    func testGetAccounts() async {
        do {
            let accountType = AccountType.Savings
            
            if let accounts = try await AccountRequest().getAccounts(accountType) {
                if accounts.count > 0 {
                    let account = accounts[0]
                    await self.testGetAccount(accountId: account.accountId)
                    print(accounts)
                } else {
                    print("No accounts found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetAccount(accountId: String) async {
        do {
            if let account = try await AccountRequest().getAccount(accountId) {
                print(account)
                await self.testGetCustomerAccounts(customerId: account.customerId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetCustomerAccounts(customerId: String) async {
        do {
            if let accounts = try await AccountRequest().getCustomerAccounts(customerId) {
                if accounts.count > 0 {
                    let account = accounts[0]
                    await self.testPostAccount(customerId: account.customerId)
                    await self.testPutAccount(accountId: account.accountId, nickname: "New nickname", accountNumber: "0987654321123456")
                    await self.testDeleteAccount(accountId: account.accountId)
                    print(accounts)
                } else {
                    print("No accounts found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPostAccount(customerId: String) async {
        do {
            let accountType = AccountType.Savings
            let accountToCreate = Account(accountId: "", accountType:accountType, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456", customerId: customerId)
            if let accountPostResponse = try await AccountRequest().postAccount(accountToCreate) {
                let message = accountPostResponse.message
                let accountCreated = accountPostResponse.objectCreated
                print("\(message): \(accountCreated)")
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPutAccount(accountId: String, nickname: String, accountNumber: String) async {
        do {
            if let accountPutResponse = try await AccountRequest().putAccount(accountId, nickname: nickname, accountNumber: accountNumber) {
                let message = accountPutResponse.message
                print("\(message)")
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testDeleteAccount(accountId: String) async {
        do {
            if let accountDeleteResponse = try await AccountRequest().deleteAccount(accountId) {
                let message = accountDeleteResponse.message
                print("\(message)")
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

class ATMTests {
    let client = NSEClient.sharedInstance
    
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        await self.testGetAtms()
    }
    
    func testGetAtms() async {
        do {
            let latitude = 38.9283 as Float
            let longitude = -77.1753 as Float
            let radius = "1" as String
            
            if let atmResponse = try await ATMRequest().getAtms(latitude, longitude: longitude, radius: radius) {
                if atmResponse.data.count > 0 {
                    let atm = atmResponse.data[0]
                    await self.testGetAtm(atmId: atm.atmId)
                    print(atmResponse.data)
                } else {
                    print("No atms found")
                }
                await self.testGetNextAtms(nextString: atmResponse.paging.next)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetNextAtms(nextString: String) async {
        do {
            if let atmResponse = try await ATMRequest().getNextAtms(nextString) {
                if atmResponse.data.count > 0 {
                    print(atmResponse.data)
                } else {
                    print("No atms found")
                }
                await self.testGetPreviousAtms(previousString: atmResponse.paging.previous)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetPreviousAtms(previousString: String) async {
        do {
            if let atmResponse = try await ATMRequest().getPreviousAtms(previousString) {
                if atmResponse.data.count > 0 {
                    print(atmResponse.data)
                } else {
                    print("No atms found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetAtm(atmId: String) async {
        do {
            if let atm = try await ATMRequest().getAtm(atmId) {
                print(atm)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
}

class BillTests {
    let client = NSEClient.sharedInstance
    
    var accountToAccess: Account = Account(accountId: "", accountType:.CreditCard, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456", customerId: "57d0c20d1fd43e204dd48282")
    var accountToAccessId: String
    
    let dateFormatter = DateFormatter()
    
    init() async throws {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let accountToAccessResponse = try await AccountRequest().postAccount(accountToAccess)
        accountToAccessId = accountToAccessResponse?.objectCreated?.accountId ?? ""
        let billToCreate = Bill(status: .Pending, payee: "Victor", nickname: "Nickname", paymentDate: nil, recurringDate: 1, upcomingPaymentDate: dateFormatter.string(from: Date()), paymentAmount: 123, accountId: accountToAccessId)
        _ = try await BillRequest().postBill(billToCreate)
        await testGetAllBills()
        _ = try await AccountRequest().deleteAccount(accountToAccess.accountId)
    }
    
    func testGetAllBills() async {
        do {
            if let bills = try await BillRequest().getAccountBills(accountToAccessId) {
                if bills.count > 0 {
                    let bill = bills[0]
                    print(bills)
                    await self.testGetBill(billId: bill.billId)
                } else {
                    print("No bills found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetBill(billId: String) async {
        do {
            if let bill = try await BillRequest().getBill(billId) {
                print(bill)
                await self.testGetCustomerBills()
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetCustomerBills() async {
        do {
            if let customerBills = try await BillRequest().getCustomerBills(accountToAccess.customerId) {
                if customerBills.count > 0 {
                    print(customerBills)
                    await self.testPostBill()
                } else {
                    print("No bills found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPostBill() async {
        do {
            let billToCreate = Bill(status: .Pending, payee: "Victor", nickname: "Nickname", paymentDate: dateFormatter.string(from: Date()), recurringDate: 1, upcomingPaymentDate: dateFormatter.string(from: Date()), paymentAmount: 123, accountId: accountToAccessId)
            if let billPostResponse = try await BillRequest().postBill(billToCreate) {
                let message = billPostResponse.message
                let billCreated = billPostResponse.objectCreated
                print("\(message): \(billCreated)")
                await self.testPutBill(billId: billCreated!.billId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPutBill(billId: String) async {
        do {
            let billToUpdate = BillPutData(status: BillStatus.Pending, payee: "Raul", nickname: "AwesomeName", recurringDate: 2, paymentAmount: 321)
            if let billPutResponse = try await BillRequest().putBill(billId, billToUpdate) {
                let message = billPutResponse.message
                print("\(message)")
                await self.testDeleteBill(billId: billId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testDeleteBill(billId: String) async {
        do {
            if let billDeleteResponse = try await BillRequest().deleteBill(billId) {
                let message = billDeleteResponse.message
                print("\(message)")
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

class BranchTests {
    let client = NSEClient.sharedInstance
    
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        await self.testGetBranches()
    }
    
    func testGetBranches() async {
        do {
            if let branches = try await BranchRequest().getBranches() {
                if branches.count > 0 {
                    let branch = branches[0]
                    print(branches)
                    await self.testGetBranch(branchId: branch.branchId)
                } else {
                    print("No branches found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetBranch(branchId: String) async {
        do {
            if let branch = try await BranchRequest().getBranch(branchId) {
                print(branch)
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

class CustomerTests {
    let client = NSEClient.sharedInstance
    
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        await testGetCustomers()
    }
    
    func testGetCustomers() async {
        do {
            if let customers = try await CustomerRequest().getCustomers() {
                if customers.count > 0 {
                    let customer = customers[0]
                    print(customers)
                    await self.testGetCustomer(customerId: customer.customerId)
                } else {
                    print("No customers found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetCustomer(customerId: String) async {
        do {
            if let customer = try await CustomerRequest().getCustomer(customerId) {
                print(customer)
                await self.testGetCustomer(accountId: "5cf88f206759394351beee6b")
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetCustomer(accountId: String) async  {
        do {
            if let customer = try await CustomerRequest().getCustomerFromAccountId(accountId) {
                print(customer)
                await self.testPostCustomer()
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPostCustomer() async {
        do {
            let address = Address(streetName: "Street", streetNumber: "1", city: "City", state: "VA", zipCode: "12345")
            let customerToCreate = Customer(firstName: "Victor", lastName: "Lopez", address: address, customerId: "123")
            if let customerPostResponse = try await CustomerRequest().postCustomer(customerToCreate) {
                let message = customerPostResponse.message
                let customerCreated = customerPostResponse.objectCreated
                print("\(message): \(customerCreated)")
                await self.testPutCustomer(customerId: customerCreated!.customerId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPutCustomer(customerId: String) async {
        do {
            let address = Address(streetName: "Street", streetNumber: "2", city: "City", state: "MD", zipCode: "54321")
            let customerToUpdate = CustomerPutData(address: address)
            if let customerPutResponse = try await CustomerRequest().putCustomer(customerId, customerToUpdate) {
                let message = customerPutResponse.message
                print("\(message)")
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

class DepositsTests {
    let client = NSEClient.sharedInstance
    let accountId = "59df8251ceb8abe24251c1e6"
    
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        await testGetAllDepositsFromAccount()
    }
    
    func testGetDeposit(depositId: String) async {
        do {
            if let deposit = try await DepositRequest().getDeposit(depositId) {
                print(deposit)
                await self.testPostDeposit()
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetAllDepositsFromAccount() async {
        do {
            if let deposits = try await DepositRequest().getDepositsFromAccountId(accountId) {
                if deposits.count > 0 {
                    let deposit = deposits[0]
                    print(deposits)
                    await self.testGetDeposit(depositId: deposit.depositId)
                } else {
                    print("No deposits found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPostDeposit() async {
        do {
            let depositToCreate = DepositPostData(medium: .Balance, amount: 20)
            if let depositPostResponse = try await DepositRequest().postDeposit(accountId, depositToCreate) {
                let message = depositPostResponse.message
                let depositCreated = depositPostResponse.objectCreated
                print("\(message): \(depositCreated)")
                await self.testPutDeposit(depositId: depositCreated!.depositId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPutDeposit(depositId: String) async {
        do {
            let depositToUpdate = DepositPutData(medium: .Balance, amount: 100)
            if let depositPutResponse = try await DepositRequest().putDeposit(depositId, depositToUpdate) {
                let message = depositPutResponse.message
                print("\(message)")
                await self.testDeleteDeposit(depositId: depositId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testDeleteDeposit(depositId: String) async {
        do {
            if let depositDeleteResponse = try await DepositRequest().deleteDeposit(depositId) {
                let message = depositDeleteResponse.message
                print("\(message)")
            }
        } catch let error as NSError {
            print(error)
        }
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
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        await testPostLoan()
    }
    
    func testGetLoans(accountId: String) async {
        do {
            if let loans = try await LoanRequest().getLoansFromAccountId(accountId) {
                if loans.count > 0 {
                    print(loans)
                } else {
                    print("No loans found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPostLoan() async {
        do {
            if let accountPostResponse = try await AccountRequest().postAccount(account) {
                let accountId = accountPostResponse.objectCreated?.accountId ?? ""
                let loanToCreate = LoanPostData(type: .home, status: .approved, creditScore: 800, monthlyPayment: 50, amount: 100, description: "A home loan for the ages")
                if let loanPostResponse = try await LoanRequest().postLoan(accountId, loanToCreate) {
                    let message = loanPostResponse.message
                    let loanCreated = loanPostResponse.objectCreated
                    print("\(message): \(loanCreated)")
                    await self.testGetLoans(accountId: accountId)
                    await self.testGetLoan(loanId: loanCreated!.loanId)
                    await self.testPutLoan(loanId: loanCreated!.loanId)
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetLoan(loanId: String) async {
        do {
            if let loan = try await LoanRequest().getLoan(loanId) {
                print(loan)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPutLoan(loanId: String) async {
        do {
            let loanToUpdate = LoanPutData(type: .auto, status: .approved, monthlyPayment: 400)
            if let loanPutResponse = try await LoanRequest().putLoan(loanId, loanToUpdate) {
                let message = loanPutResponse.message
                print("\(message)")
                await self.testDeleteLoan(loanId: loanId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testDeleteLoan(loanId: String) async {
        do {
            if let loanDeleteResponse = try await LoanRequest().deleteLoan(loanId) {
                let message = loanDeleteResponse.message
                print("\(message)")
            }
        } catch let error as NSError {
            print(error)
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
    var request = EnterpriseAccountRequest()
    
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        await self.testGetAccounts()
    }
    
    func testGetAccounts() async {
        do {
            if let enterpriseAccountResponse = try await request.getAccounts() {
                if enterpriseAccountResponse.results.count > 0 {
                    let account = enterpriseAccountResponse.results[0]
                    await self.testGetAccount(accountId: account.accountId)
                    print(enterpriseAccountResponse.results)
                } else {
                    print("No accounts found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetAccount(accountId: String) async {
        do {
            if let account = try await request.getAccount(accountId) {
                print(account)
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

class EnterpriseBillTests {
    let client = NSEClient.sharedInstance
    var request = EnterpriseBillRequest()

    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        await self.testGetBills()
    }
    
    func testGetBills() async {
        do {
            if let enterpriseBillResponse = try await request.getBills() {
                if enterpriseBillResponse.results.count > 0 {
                    let bill = enterpriseBillResponse.results[0]
                    await self.testGetBill(billId: bill.billId)
                    print(enterpriseBillResponse.results)
                } else {
                    print("No bills found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetBill(billId: String) async {
        do {
            if let bill = try await request.getBill(billId) {
                print(bill)
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

class EnterpriseCustomerTests {
    let client = NSEClient.sharedInstance
    var request = EnterpriseCustomerRequest()

    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        await self.testGetCustomers()
    }
    
    func testGetCustomers() async {
        do {
            if let enterpriseCustomerResponse = try await request.getCustomers() {
                if enterpriseCustomerResponse.results.count > 0 {
                    let customer = enterpriseCustomerResponse.results[0]
                    await self.testGetCustomer(customerId: customer.customerId)
                    print(enterpriseCustomerResponse.results)
                } else {
                    print("No customers found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetCustomer(customerId: String) async {
        do {
            if let customer = try await request.getCustomer(customerId) {
                print(customer)
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

class EnterpriseDepositTests {
    let client = NSEClient.sharedInstance
    var request = EnterpriseDepositRequest()
    
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        await self.testGetDeposits()
    }
    
    func testGetDeposits() async {
        do {
            if let enterpriseDepositResponse = try await request.getDeposits() {
                if enterpriseDepositResponse.results.count > 0 {
                    let deposit = enterpriseDepositResponse.results[0]
                    await self.testGetDeposit(depositId: deposit.depositId)
                    print(enterpriseDepositResponse.results)
                } else {
                    print("No deposits found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetDeposit(depositId: String) async {
        do {
            if let deposit = try await request.getDeposit(depositId) {
                print(deposit)
            }
        } catch let error as NSError {
            print(error)
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
