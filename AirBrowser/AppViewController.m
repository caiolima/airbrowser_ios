//
//  AppViewController.m
//  BroadCast Sample
//
//  Created by Caio Lima on 02/11/12.
//  Copyright (c) 2012 Five Startup. All rights reserved.
//

#import "AppViewController.h"

@interface AppViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webContent;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ltLoading;
@property (weak, nonatomic) IBOutlet UIButton *btFoward;
@property (weak, nonatomic) IBOutlet UIButton *btBack;



- (IBAction)close:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)goFoward:(id)sender;
- (IBAction)refreshAction:(id)sender;

@end

@interface UIWebView()

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)even;

@end

@implementation AppViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [[self navigationController] setNavigationBarHidden:YES animated:NO];
  
	NSString *urlAddress = _application.path;
  NSURL *url = [NSURL URLWithString:urlAddress];
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  [_webContent loadRequest:requestObj];
  
  [_webContent setDelegate:self];
  
  
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
  [self setWebContent:nil];
  [self setNavigationBar:nil];
  [self setBtBack:nil];
  [self setBtBack:nil];
  [self setBtBack:nil];
  [self setBtFoward:nil];
  [self setLtLoading:nil];
  [super viewDidUnload];
}

- (IBAction)close:(id)sender {
  
  [self dismissModalViewControllerAnimated:YES];
  
}

- (IBAction)goBack:(id)sender {
  [_webContent goBack];
}

- (IBAction)goFoward:(id)sender {
  [_webContent goForward];
}

- (IBAction)refreshAction:(id)sender {
  [_webContent reload];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
  [_btBack setEnabled:[_webContent canGoBack]];
  [_btBack setHidden:![_webContent canGoBack]];
  
  [_btFoward setEnabled:[_webContent canGoForward]];
  [_btFoward setHidden:![_webContent canGoForward]];
  
  if(![_ltLoading isHidden])
    [_ltLoading setHidden:true];
}


@end
