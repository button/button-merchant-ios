//
// ViewController.m
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

#import "ViewController.h"
#import "Example_ObjC-Swift.h"
@import ButtonMerchant;

@interface ViewController ()

@property (nonatomic, strong) NSString *attributionTokenString;

@property (weak, nonatomic) IBOutlet UITableViewCell *attributionTokenCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *trackIncomingURLCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *reportOrderCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *clearAllDataCell;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.attributionTokenString = ButtonMerchant.attributionToken;

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(attributionTokenDidChange:)
                                               name:ButtonMerchant.AttributionTokenDidChangeNotification
                                             object:nil];
}


- (void)setAttributionTokenString:(NSString *)attributionTokenString {
    if (attributionTokenString.length) {
        _attributionTokenCell.textLabel.font = [UIFont fontWithName:@"Menlo" size:12.0];
        _attributionTokenCell.textLabel.text = attributionTokenString;
    }
    else {
        _attributionTokenCell.textLabel.font = [UIFont fontWithName:@"Menlo-Italic" size:12.0];
        _attributionTokenCell.textLabel.text = @"no token found";
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (cell == _trackIncomingURLCell) {
        [self trackIncomingURL];
    }
    else if (cell == _reportOrderCell) {
        [self reportOrder];
    }
    else if (cell == _clearAllDataCell) {
        [self clearAllData];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)trackIncomingURL {
    // Simulates an incoming url with a Button attribution token.
    NSString *srctok = [[[NSUUID.UUID.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:16] lowercaseString];
    NSString *urlString = [NSString stringWithFormat:@"merchant-demo-objc:///?btn_ref=fakesrctok-%@", srctok];
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:urlString]];
}


- (void)reportOrder {
    NSString *identifier = NSUUID.UUID.UUIDString;
    LineItem *lineitem = [[LineItem alloc] initWithId:identifier total:arc4random_uniform(1000)];
    Customer *customer = [[Customer alloc] initWithId:NSUUID.UUID.UUIDString];
    Order *order = [[Order alloc] initWithId:NSUUID.UUID.UUIDString purchaseDate:[NSDate date] lineItems: @[lineitem]];
    order.customer = customer;
    [ButtonMerchant reportOrder:order completion:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (error) {
                [MessageView showWithTitle:@"Order Reporting Failed" body:@"" in:self.navigationController.view];
            }
            else {
                [MessageView showWithTitle:@"Order Created" body:[NSString stringWithFormat:@"Id: %@", identifier] in:self.navigationController.view];
            }
        });
    }];
}


- (void)clearAllData {
    // Note: In practice, this is only intended to be called when your user logs out.
    [ButtonMerchant clearAllData];
    self.attributionTokenString = nil;
}


- (void)attributionTokenDidChange:(NSNotification *)note {
    NSString *newToken = note.userInfo[ButtonMerchant.AttributionTokenKey];
    self.attributionTokenString = newToken;
    [MessageView showWithTitle:@"New Attribution Token" body:newToken in:self.navigationController.view];
}

@end
