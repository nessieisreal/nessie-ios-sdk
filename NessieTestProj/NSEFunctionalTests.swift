
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
            let accountToCreate = AccountPostData(accountType: accountType, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456")
            if let accountPostResponse = try await AccountRequest().postAccount(customerId, accountToCreate) {
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
    
    var accountToAccess: AccountPostData = AccountPostData(accountType: .CreditCard, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456")
    var accountToAccessId: String
    let customerId = "57d0c20d1fd43e204dd48282"
    
    let dateFormatter = DateFormatter()
    
    init() async throws {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let accountToAccessResponse = try await AccountRequest().postAccount(customerId, accountToAccess)
        accountToAccessId = accountToAccessResponse?.objectCreated?.accountId ?? ""
        let billToCreate = BillPostData(status: .Pending, payee: "Andrew", nickname: "Nickname", paymentDate: nil, recurringDate: 1, paymentAmount: 123)
        _ = try await BillRequest().postBill(accountToAccessId, billToCreate)
        await testGetAllBills()
        _ = try await AccountRequest().deleteAccount(accountToAccessId)
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
            if let customerBills = try await BillRequest().getCustomerBills(customerId) {
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
            let billToCreate = BillPostData(status: .Pending, payee: "Andrew", nickname: "Nickname", paymentDate: dateFormatter.string(from: Date()), recurringDate: 1, paymentAmount: 123)
            if let billPostResponse = try await BillRequest().postBill(accountToAccessId, billToCreate) {
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
            let customerToCreate = CustomerPostData(firstName: "Andrew", lastName: "Dunetz", address: address)
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
    let account: AccountPostData = AccountPostData(
       accountType: .CreditCard,
       nickname: "Hola",
       rewards: 10,
       balance: 100,
       accountNumber: "1234567890123456"
    )
    let accountId = "57d32a5ce63c5995587e85ec"
    let customerId = "57d0c20d1fd43e204dd48282"
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
            if let accountPostResponse = try await AccountRequest().postAccount(customerId, account) {
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
    
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        await testGetAllPurchasesFromAccount()
    }
    
    var account: AccountPostData = AccountPostData(
       accountType: .CreditCard,
       nickname: "Hola",
       rewards: 10,
       balance: 100,
       accountNumber: "1234567890123456"
    )
    let accountId = "5cf88b096759394351beee67"
    let customerId = "57d0c20d1fd43e204dd48282"
    let merchant: Merchant = Merchant(merchantId: "57cf75cea73e494d8675ec49",
                                      name: "Best Productions", creationDate: "2025-05-09",
                                      category: "Production",
                                      address: Address(streetName: "Lafayette St.",
                                                       streetNumber: "5901",
                                                       city: "Brooklyn",
                                                       state: "NY",
                                                       zipCode: "07009"),
                                      geocode: Geocode(lng: -1, lat: 33))
    
    func testGetPurchase(purchaseId: String) async {
        do {
            if let purchase = try await PurchaseRequest().getPurchase(purchaseId) {
                print(purchase)
                await self.testPostPurchase()
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetAllPurchasesFromMerchant() async {
        do {
            if let purchases = try await PurchaseRequest().getPurchasesFromMerchantId(merchant.merchantId) {
                if purchases.count > 0 {
                    print(purchases)
                } else {
                    print("No purchases found")
                }
            }
            await self.testGetAllPurchasesFromMerchantAndAccount()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetAllPurchasesFromAccount() async {
        do {
            if let purchases = try await PurchaseRequest().getPurchasesFromAccountId(accountId) {
                if purchases.count > 0 {
                    let purchase = purchases[0]
                    print(purchases)
                    await self.testGetPurchase(purchaseId: purchase.purchaseId)
                } else {
                    print("No purchases found")
                }
            }
            await self.testGetAllPurchasesFromMerchantAndAccount()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetAllPurchasesFromMerchantAndAccount() async {
        do {
            if let purchases = try await PurchaseRequest().getPurchasesFromMerchantAndAccountIds(merchant.merchantId, accountId: accountId) {
                if purchases.count > 0 {
                    print(purchases)
                } else {
                    print("No purchases found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPostPurchase() async {
        do {
            if let accountPostResponse = try await AccountRequest().postAccount(customerId, account) {
                let accountId = accountPostResponse.objectCreated?.accountId ?? ""
                let purchaseToCreate = PurchasePostData(merchantId: "57cf75cea73e494d8675ec49", medium: .Balance, amount: 100)
                if let purchasePostResponse = try await PurchaseRequest().postPurchase(accountId: accountId, purchaseToCreate) {
                    let message = purchasePostResponse.message
                    let purchaseCreated = purchasePostResponse.objectCreated
                    print("\(message): \(purchaseCreated)")
                    await self.testPutPurchase(purchaseId: purchaseCreated!.purchaseId)
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPutPurchase(purchaseId: String) async {
        do {
            let purchaseToUpdate = PurchasePutData(payerId: accountId, medium: .Balance, amount: 25)
            if let purchasePutResponse = try await PurchaseRequest().putPurchase(purchaseId, purchaseToUpdate) {
                let message = purchasePutResponse.message
                print("\(message)")
                await self.testDeletePurchase(purchaseId: purchaseId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testDeletePurchase(purchaseId: String) async {
        do {
            if let purchaseDeleteResponse = try await PurchaseRequest().deletePurchase(purchaseId) {
                let message = purchaseDeleteResponse.message
                print("\(message)")
                await self.testGetAllPurchasesFromMerchant()
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

class MerchantTests {
    let client = NSEClient.sharedInstance
    
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        await testGetMerchants()
    }
    
    func testGetMerchants() async {
        do {
            if let merchants = try await MerchantRequest().getMerchants() {
                if merchants.count > 0 {
                    let merchant = merchants[0]
                    await self.testGetMerchant(merchantId: merchant.merchantId)
                    print(merchants)
                } else {
                    print("No merchants found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetMerchant(merchantId: String) async {
        do {
            if let merchant = try await MerchantRequest().getMerchant(merchantId) {
                print(merchant)
            }
            await self.testPostMerchant()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPostMerchant() async {
        do {
            let merchantToCreate = MerchantPostData(name: "Test Merchant")
            if let merchantPostResponse = try await MerchantRequest().postMerchant(merchantToCreate) {
                let message = merchantPostResponse.message
                let merchantCreated = merchantPostResponse.objectCreated
                print("\(message): \(merchantCreated)")
                await self.testPutMerchant(merchantId: merchantCreated!.merchantId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPutMerchant(merchantId: String) async {
        do {
            let merchantToUpdate = MerchantPutData(name: "Updated Merchant")
            if let merchantPutResponse = try await MerchantRequest().putMerchant(merchantId, merchantToUpdate) {
                let message = merchantPutResponse.message
                print("\(message)")
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

class TransfersTests {
    let client = NSEClient.sharedInstance
    
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        await testGetAllTransfersFromAccount()
    }
    
    var account: Account = Account(accountId: "59df8251ceb8abe24251c1e6", accountType:.CreditCard, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456", customerId: "57d0c20d1fd43e204dd48282")
    
    func testGetTransfer(transferId: String) async {
        do {
            if let transfer = try await TransferRequest().getTransfer(transferId) {
                print(transfer)
                await self.testPostTransfer()
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetAllTransfersFromAccount() async {
        do {
            if let transfers = try await TransferRequest().getTransfersFromAccountId(account.accountId) {
                if transfers.count > 0 {
                    let transfer = transfers[0]
                    print(transfers)
                    await self.testGetTransfer(transferId: transfer.transferId)
                } else {
                    print("No transfers found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPostTransfer() async {
        do {
            let transferToCreate = TransferPostData(medium: .Balance, payeeId: "5b181426f0cec56abfa418e3", amount: 20)
            if let transferPostResponse = try await TransferRequest().postTransfer(account.accountId, transferToCreate) {
                let message = transferPostResponse.message
                let transferCreated = transferPostResponse.objectCreated
                print("\(message): \(transferCreated)")
                await self.testPutTransfer(transferId: transferCreated!.transferId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPutTransfer(transferId: String) async {
        do {
            let transferToUpdate = TransferPutData(medium: .Balance, payeeId: "5b181426f0cec56abfa418e3", amount: 25)
            if let transferPutResponse = try await TransferRequest().putTransfer(transferId, transferToUpdate) {
                let message = transferPutResponse.message
                print("\(message)")
                await self.testDeleteTransfer(transferId: transferId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testDeleteTransfer(transferId: String) async {
        do {
            if let transferDeleteResponse = try await TransferRequest().deleteTransfer(transferId) {
                let message = transferDeleteResponse.message
                print("\(message)")
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

class WithdrawalsTests {
    let client = NSEClient.sharedInstance
    
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        
        await testGetAllWithdrawalsFromAccount()
    }
    
    var account: Account = Account(accountId: "59df8251ceb8abe24251c1e6", accountType:.CreditCard, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456", customerId: "57d0c20d1fd43e204dd48282")
    
    func testGetWithdrawal(withdrawalId: String) async {
        do {
            if let withdrawal = try await WithdrawalRequest().getWithdrawal(withdrawalId) {
                print(withdrawal)
                await self.testPostWithdrawal()
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetAllWithdrawalsFromAccount() async {
        do {
            if let withdrawals = try await WithdrawalRequest().getWithdrawalsFromAccountId(account.accountId) {
                if withdrawals.count > 0 {
                    let withdrawal = withdrawals[0]
                    print(withdrawals)
                    await self.testGetWithdrawal(withdrawalId: withdrawal.withdrawalId)
                } else {
                    print("No withdrawals found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPostWithdrawal() async {
        do {
            let withdrawalToCreate = WithdrawalPostData(medium: .Balance, amount: 20)
            if let withdrawalPostResponse = try await WithdrawalRequest().postWithdrawal(account.accountId, withdrawalToCreate) {
                let message = withdrawalPostResponse.message
                let withdrawalCreated = withdrawalPostResponse.objectCreated
                print("\(message): \(withdrawalCreated)")
                await self.testPutWithdrawal(withdrawalId: withdrawalCreated!.withdrawalId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testPutWithdrawal(withdrawalId: String) async {
        do {
            let withdrawalToUpdate = WithdrawalPutData(medium: .Balance, amount: 25)
            if let withdrawalPutResponse = try await WithdrawalRequest().putWithdrawal(withdrawalId, withdrawalToUpdate) {
                let message = withdrawalPutResponse.message
                print("\(message)")
                await self.testDeleteWithdrawal(withdrawalId: withdrawalId)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testDeleteWithdrawal(withdrawalId: String) async {
        do {
            if let withdrawalDeleteResponse = try await WithdrawalRequest().deleteWithdrawal(withdrawalId) {
                let message = withdrawalDeleteResponse.message
                print("\(message)")
            }
        } catch let error as NSError {
            print(error)
        }
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
    var request = EnterpriseMerchantRequest()
    
    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        await self.testGetMerchants()
    }
    
    func testGetMerchants() async {
        do {
            if let enterpriseMerchantResponse = try await request.getMerchants() {
                if enterpriseMerchantResponse.results.count > 0 {
                    let merchant = enterpriseMerchantResponse.results[0]
                    await self.testGetMerchant(merchantId: merchant.merchantId)
                    print(enterpriseMerchantResponse.results)
                } else {
                    print("No merchants found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetMerchant(merchantId: String) async {
        do {
            if let merchant = try await request.getMerchant(merchantId) {
                print(merchant)
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

class EnterpriseTransferTests {
    let client = NSEClient.sharedInstance
    var request = EnterpriseTransferRequest()

    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        await self.testGetTransfers()
    }
    
    func testGetTransfers() async {
        do {
            if let enterpriseTransferResponse = try await request.getTransfers() {
                if enterpriseTransferResponse.results.count > 0 {
                    let transfer = enterpriseTransferResponse.results[0]
                    await self.testGetTransfer(transferId: transfer.transferId)
                    print(enterpriseTransferResponse.results)
                } else {
                    print("No transfers found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetTransfer(transferId: String) async {
        do {
            if let transfer = try await request.getTransfer(transferId) {
                print(transfer)
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

class EnterpriseWithdrawalTests {
    let client = NSEClient.sharedInstance
    var request = EnterpriseWithdrawalRequest()

    init() async {
        client.setKey("bca7093ce9c023bb642d0734b29f1ad2")
        await self.testGetWithdrawals()
    }
    
    func testGetWithdrawals() async {
        do {
            if let enterpriseWithdrawalResponse = try await request.getWithdrawals() {
                if enterpriseWithdrawalResponse.results.count > 0 {
                    let withdrawal = enterpriseWithdrawalResponse.results[0]
                    await self.testGetWithdrawal(withdrawalId: withdrawal.withdrawalId)
                    print(enterpriseWithdrawalResponse.results)
                } else {
                    print("No withdrawals found")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func testGetWithdrawal(withdrawalId: String) async {
        do {
            if let withdrawal = try await request.getWithdrawal(withdrawalId) {
                print(withdrawal)
            }
        } catch let error as NSError {
            print(error)
        }
    }
}
