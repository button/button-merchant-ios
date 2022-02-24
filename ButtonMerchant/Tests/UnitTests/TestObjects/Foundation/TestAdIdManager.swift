//
// TestAdIdManager.swift
// 
// Copyright © 2018 Button, Inc. All rights reserved. (https://usebutton.com) 
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

import UIKit
@testable import ButtonMerchant

class TestAdIdManager: ASIdentifierManagerType {
    
    enum AdIDType: String {
        case validId = "11111111-1111-1111-1111-111111111111"
        case validIdWithLeadingZeros = "00000000-0011-1111-1111-111111111111"
        case validIdWithTrailingZeros = "11111111-1111-1111-1111-110000000000"
        case validIdWithMidZeros = "11111111-1000-0000-0001-111111111111"
        case invalidId = "00000000-0000-0000-0000-000000000000"
    }
    
    var stubbedID: AdIDType
    
    var advertisingIdentifier: UUID {
        return UUID(uuidString: stubbedID.rawValue)!
    }

    init(_ adIDType: AdIDType = .validId) {
        stubbedID = adIDType
    }
}
