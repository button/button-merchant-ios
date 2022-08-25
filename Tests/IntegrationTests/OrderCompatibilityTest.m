//
// OrderCompatibilityTest.m
//
// Copyright © 2022 Button, Inc. All rights reserved. (https://usebutton.com)
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
#import "Order.h"
@import ButtonMerchant;

@interface OrderCompatibilityTest : XCTestCase

@end

@implementation OrderCompatibilityTest

- (void)testOrderAliasesBTNOrder {
    Order *order = [[Order alloc] initWithId:@"test" purchaseDate:NSDate.new lineItems:@[]];
    XCTAssert([order.class isSubclassOfClass:BTNOrder.class]);
}

- (void)testOrderByStringLookupIsNotBTNOrder {
    XCTAssertFalse([NSClassFromString(@"Order") isSubclassOfClass:BTNOrder.class]);
}

#undef Order

- (void)testOrderAliasCanBeUndefined {
    id unexpectedOrder = nil;
    @try {
        Class orderClass = Order.class;
        unexpectedOrder = [[orderClass alloc] initWithId:@"test" purchaseDate:NSDate.new lineItems:@[]];
    } @catch (NSException *exception) {
        XCTAssertEqual(exception.name, NSInvalidArgumentException);
        XCTAssertTrue([exception.reason hasPrefix:@"-[Order initWithId:purchaseDate:lineItems:]: unrecognized selector sent to instance"]);
    }
    XCTAssertNil(unexpectedOrder, @"Did not expect an order");
}


- (void)testConflictingOrderClassCanBeInitialized {
    Order *order = [[Order alloc] init];
    XCTAssertTrue([order.class isSubclassOfClass:Order.class]);
}

@end

