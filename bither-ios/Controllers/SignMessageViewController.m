//
//  SignMessageViewController.m
//  bither-ios
//
//  Created by 宋辰文 on 14/12/23.
//  Copyright (c) 2014年 宋辰文. All rights reserved.
//

#import "SignMessageViewController.h"
#import "StringUtil.h"
#import "DialogPassword.h"

@interface SignMessageViewController ()<UITextViewDelegate,DialogPasswordDelegate>{
    CGFloat _tvMinHeight;
}
@property (weak, nonatomic) IBOutlet UIView *vOutput;
@property (weak, nonatomic) IBOutlet UITextView *tvOutput;
@property (weak, nonatomic) IBOutlet UIView *vInput;
@property (weak, nonatomic) IBOutlet UIView *vButtons;
@property (weak, nonatomic) IBOutlet UITextView *tvInput;
@property (weak, nonatomic) IBOutlet UIImageView *ivArrow;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ai;
@property (weak, nonatomic) IBOutlet UIScrollView *sv;

@end

@implementation SignMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tvMinHeight = self.tvInput.frame.size.height;
    self.tvInput.delegate = self;
    self.ivArrow.hidden = YES;
    self.ai.hidden = YES;
    self.vOutput.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if(textView != self.tvInput){
        return;
    }
    CGFloat height = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)].height;
    height = MAX(height, _tvMinHeight);
    
    CGRect inputFrame = self.vInput.frame;
    inputFrame.size.height = height + self.tvInput.frame.origin.y * 2 + self.vButtons.frame.size.height + 10;
    self.vInput.frame = inputFrame;
    
    [self configureOutputFrame];
    
    self.vOutput.hidden = YES;
    self.ivArrow.hidden = YES;
    self.vButtons.hidden = NO;
}

- (IBAction)signPressed:(id)sender {
    NSString* input = [self.tvInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([StringUtil isEmpty:input]){
        return;
    }
    [[[DialogPassword alloc]initWithDelegate:self]showInWindow:self.view.window];
}

-(void)onPasswordEntered:(NSString*)password{
    if([StringUtil isEmpty:password]){
        return;
    }
    NSString* input = [self.tvInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([StringUtil isEmpty:input]){
        return;
    }
    [self.view resignFirstResponder];
    self.ai.hidden = NO;
    self.vOutput.hidden = YES;
    self.ivArrow.hidden = YES;
    self.vButtons.hidden = YES;
    self.tvInput.editable = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString* output = [self.address signMessage:input withPassphrase:password];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tvOutput.text = output;
            self.tvInput.editable = YES;
            self.ai.hidden = YES;
            if(![StringUtil isEmpty:output]){
                self.vOutput.hidden = NO;
                self.ivArrow.hidden = NO;
                self.vButtons.hidden = YES;
            } else {
                self.vOutput.hidden = YES;
                self.ivArrow.hidden = YES;
                self.vButtons.hidden = NO;
            }
            [self configureOutputFrame];
        });
    });
}

- (IBAction)outputPressed:(id)sender {

}

- (IBAction)scanPressed:(id)sender {
    
}

-(void)configureOutputFrame{
    CGFloat height = [self.tvOutput sizeThatFits:CGSizeMake(self.tvOutput.frame.size.width, CGFLOAT_MAX)].height;
    height = MAX(height, _tvMinHeight);
    
    CGRect outputFrame = self.vOutput.frame;
    outputFrame.origin.y = CGRectGetMaxY(self.vInput.frame);
    outputFrame.size.height = height + self.tvOutput.frame.origin.y * 2 + 7;
    self.vOutput.frame = outputFrame;
    
    self.sv.contentSize = CGSizeMake(self.sv.contentSize.width, CGRectGetMaxY(self.vOutput.frame));
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
