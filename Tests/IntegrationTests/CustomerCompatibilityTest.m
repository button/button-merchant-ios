//
// CustomerCompatibility.m
//
// Copyright © 2021 Button, Inc. All rights reserved. (https://usebutton.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
	

#import <XCTest/XCTest.h>
#import "Customer.h"
@import ButtonMerchant;

@interface CustomerCompatibilityTest : XCTestCase

@end

@implementation CustomerCompatibilityTest

- (void)testCustomerAliasesBTNCustomer {
    Customer *customer = [[Customer alloc] initWithId:@"test"];
    XCTAssert([customer.class isSubclassOfClass:BTNCustomer.class]);
}

- (void)testCustomerByStringLookupIsNotBTNCustomer {
    XCTAssertFalse([NSClassFromString(@"Customer") isSubclassOfClass:BTNCustomer.class]);
}

#undef Customer

- (void)testCusomerAliasCanBeUndefined {
    id unexpectedCustomer = nil;
    @try {
        Class customerClass = Customer.class;
        unexpectedCustomer = [[customerClass alloc] initWithId:@"test"];
    } @catch (NSException *exception) {
        XCTAssertEqual(exception.name, NSInvalidArgumentException);
        XCTAssertTrue([exception.reason hasPrefix:@"-[Customer initWithId:]: unrecognized selector sent to instance"]);
    }
    XCTAssertNil(unexpectedCustomer, @"Did not expect an customer");
}


- (void)testConflictingCustomerClassCanBeInitialized {
    Customer *customer = [[Customer alloc] init];
    XCTAssertTrue([customer.class isSubclassOfClass:Customer.class]);
}

@end
