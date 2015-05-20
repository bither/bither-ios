//
//  ScanQrCodeTransportViewController.m
//  bither-ios
//
//  Copyright 2014 http://Bither.net
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "ScanQrCodeTransportViewController.h"
#import "StringUtil.h"
#import "QRCodeTransportPage.h"

@interface ScanQrCodeTransportViewController () <ScanQrCodeDelegate> {
    NSString *_pageName;
    NSMutableArray *_pages;
    NSInteger _totalPage;
    NSString *_lastResult;
}
@end

@implementation ScanQrCodeTransportViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _pages = [[NSMutableArray alloc] init];
        _totalPage = 1;
    }
    return self;
}

- (instancetype)initWithDelegate:(NSObject <ScanQrCodeDelegate> *)delegate title:(NSString *)title message:(NSString *)message {
    self = [super initWithDelegate:self title:title message:message];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (instancetype)initWithDelegate:(NSObject <ScanQrCodeDelegate> *)delegate title:(NSString *)title pageName:(NSString *)pageName {
    self = [self initWithDelegate:delegate title:title message:nil];
    if (self) {
        self.pageName = pageName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnGallery.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _lastResult = nil;
    [_pages removeAllObjects];
    _totalPage = 1;
    self.scanMessage = [self pageMessage];
}

- (NSString *)pageMessage {
    if (_pages.count == 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"Scan %@", nil), self.pageName];
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"Scan %@\nPage %d, Total %d", nil), self.pageName, _pages.count + 1, _totalPage];
    }
}

- (void)setPageName:(NSString *)pageName {
    _pageName = pageName;
    [self setScanMessage:[self pageMessage]];
}

- (NSString *)pageName {
    return _pageName;
}

- (void)handleScanCancelByReader:(ScanQrCodeViewController *)reader {
    if (self.delegate && [self.delegate respondsToSelector:@selector(handleScanCancelByReader:)]) {
        [self.delegate handleScanCancelByReader:self];
    }
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    if (![StringUtil compareString:_lastResult compare:result]) {
        _lastResult = result;
        QRCodeTransportPage *page = [QRCodeTransportPage formatQrCodeString:result];
        if (page && page.currentPage == _pages.count) {
            _totalPage = page.sumPage;
            [_pages addObject:page];
            [reader playSuccessSound];

            if (!page.hasNextPage) {
                NSString *r = [QRCodeTransportPage formatQRCodeTran:_pages];
                if (self.delegate && [self.delegate respondsToSelector:@selector(handleResult:byReader:)]) {
                    [self.delegate handleResult:r byReader:self];
                }
            }
        }
        self.scanMessage = [self pageMessage];
        [reader vibrate];
    }
}
@end
