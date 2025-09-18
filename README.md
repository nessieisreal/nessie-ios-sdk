# Nessie-iOS-Wrapper

### Note: This SDK is Swift 5.0, please use Xcode 14.0 and later 😀

## Synopsis

Capital One Nessie API SDK written in Swift, using SwiftyJSON for JSON parsing. This SDK can be easily embedded in an iOS project.

## Installation

1. Download the entire SDK directory.
2. Open the `Nessie-iOS-Wrapper.xcworkspace` file.
3. Set your API Key in `NSEClient.swift` where `private var key = ""`
4. Start working by either:

- Creating a new Project Target and add your work there.
- Adding your files directly into the `Nessie-iOS-Wrapper` target. See `NessieTestProj` for examples.

## Usage and Examples

#### Important Note

Any parameter marked as optional in the Nessie documentation are also optional in the SDK. They are simply marked as an `Optional` type in Swift. For instance, `accountType` is an optional field here:
![accountTypeExample](http://i.imgur.com/RsLW1ls.png)

In the `getAccounts()` call, `accountType` is optional. If you wish to get all accounts regardless of account type, just pass in a `nil` value for accountType:

```swift
        if let accounts = try await AccountRequest().getAccounts(nil) {
            ...
        }
```

#### Creating a Customer

```Swift
    func testPostCustomer() async {
        do {
            // Construct the Customer object you want to create
            // in this case, address is an object so it needs its own initializer
            let address = Address(streetName: "Street", streetNumber: "1", city: "City", state: "VA", zipCode: "12345")
            let customerToCreate = CustomerPostData(firstName: "Andrew", lastName: "Dunetz", address: address)
            // Send the request using the wrapper!
            if let customerPostResponse = try await CustomerRequest().postCustomer(customerToCreate) {
                // Handle response as you like, print for example
                let message = customerPostResponse.message
                let customerCreated = customerPostResponse.objectCreated
                print("\(message): \(customerCreated)")
                await self.testPutCustomer(customerId: customerCreated!.customerId)
            }
        } catch let error as NSError {
            // Catch any errors
            print(error)
        }
    }
```

#### Retrieving Customers

```Swift
    func testGetCustomers() async {
        do {
            // Retrieve all the Customers!
            if let customers = try await CustomerRequest().getCustomers() {
                // If there are Customers in the result, print the first Customer
                if customers.count > 0 {
                    let customer = customers[0]
                    print(customers)
                    await self.testGetCustomer(customerId: customer.customerId)
                } else {
                    print("No customers found")
                }
            }
        } catch let error as NSError {
            // Catch any errors
            print(error)
        }
    }
```

You can find examples [here](https://github.com/nessieisreal/nessie-ios-sdk-swift/blob/master/NessieTestProj/NSEFunctionalTests.swift).
