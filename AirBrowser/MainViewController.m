//
//  Created by Caio Lima on 28/10/12.
//  Copyright (c) 2012 Five Startup. All rights reserved.
//
//  This is the controller from the AirApps list


#import "MainViewController.h"
#import "Application.h"
#import "AppViewController.h"
#import <CoreFoundation/CoreFoundation.h>
#import <QuartzCore/QuartzCore.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include "NetworkUtils.h"

id __weak refToSelf;
CFSocketRef cfSocket;
CFRunLoopSourceRef rls;
bool flagServerFound;

@interface MainViewController (){
    
    NSMutableDictionary *clickStateDic;
    
}

@property NSMutableArray *data;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ld_apps;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btReload;



-(void)appsRecieved: (NSData*)data;
-(void)startSearchAirServer;
- (IBAction)refreshConnection:(id)sender;



@end


@implementation MainViewController



static void ReadCallback (CFSocketRef theSocket, CFSocketCallBackType theType, CFDataRef theAddress, const void *data, void *info)
{
    if(data==NULL)
        NSLog(@"Data not received");
    else{
        flagServerFound=true;
        NSData *m_data = (__bridge NSData*)data; // no adjustment of retain counts.
        MainViewController *myCurrent=refToSelf;
        [myCurrent appsRecieved:m_data];
        
    }
    
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), rls, kCFRunLoopCommonModes);
    CFRelease(rls);
    CFSocketInvalidate(cfSocket);
    CFRelease(cfSocket);
    
}

-(void)appsRecieved: (NSData*)data{
    NSError* error;
    
    NSDictionary *resultados = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingMutableContainers error:&error];
    if(!error){
        NSArray *applications=[resultados objectForKey:@"applications"];
        int lenght=[applications count];
        for(int i=0;i<lenght;i++){
            NSDictionary *application=[applications objectAtIndex:i];
            
            [[self data] addObject:[Application createFromJSON:application ipServer:[resultados objectForKey:@"ip_server"]]];
            
        }
        [[self ld_apps] setHidden:true];
        [_btReload setEnabled:true];
        [self.collectionView reloadData];
        
    }else{
        NSLog(@"Respsota não é um JSON Válido!");
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    refToSelf=self;
    _data=[[NSMutableArray alloc]init];
    clickStateDic=[[NSMutableDictionary alloc]init];
    
    UIEdgeInsets insets=UIEdgeInsetsMake(10, 20, 10, 20);

    UICollectionViewFlowLayout *flowLayout=(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    [flowLayout setSectionInset:insets];
    
    [self startSearchAirServer];
    
    
}

-(void)startSearchAirServer{
    
    if([_ld_apps isHidden]){
        [_ld_apps setHidden:false];
        
    }
    
    [_btReload setEnabled:false];
    flagServerFound=false;
    NSString *ip=[NetworkUtils getIPAddress];
    if(ip==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro de conexão!"
                                                        message:@"Você parece não estar conectado numa rede wireless. Por favor, verifique suas configuração!"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        [[self ld_apps] setHidden:true];
        [_btReload setEnabled:true];
        
        return;
    }
    
    CFSocketError socket_error = 0;
    NSString *msg=@"DISCOVER_AIR_SERVER";
    int sock;
    struct sockaddr_in destination;
    unsigned int echolen;
    int broadcast = 1;
    // if that doesn't work, try this
    //char broadcast = '1';
    
    /* Create the UDP socket */
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
    {
        NSLog(@"Failed to create socket\n");
        socket_error=-1;
    }
    
    /* Construct the server sockaddr_in structure */
    memset(&destination, 0, sizeof(destination));
    
    /* Clear struct */
    destination.sin_family = AF_INET;
    
    /* Internet/IP */
    destination.sin_addr.s_addr = inet_addr([ip UTF8String]);
    
    /* IP address */
    destination.sin_port = htons(8888);
    destination.sin_len = sizeof(destination);
    
    /* server port */
    setsockopt(sock,
               IPPROTO_IP,
               IP_MULTICAST_IF,
               &destination,
               sizeof(destination));
    const char *cmsg = [msg UTF8String];   echolen = strlen(cmsg);
    
    // this call is what allows broadcast packets to be sent:
    if (setsockopt(sock,
                   SOL_SOCKET,
                   SO_BROADCAST,
                   &broadcast,
                   sizeof broadcast) == -1)
    {
        NSLog(@"setsockopt (SO_BROADCAST)");
        socket_error=-1;
    }
    if (sendto(sock,
               cmsg,
               echolen,
               0,
               (struct sockaddr *) &destination,
               sizeof(destination)) != echolen)
    {
        NSLog(@"Mismatch in number of sent bytes\n");
        socket_error=-1;
    }
    
    if(socket_error < 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Socket situation"
                                                        message:@"Socket error"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
    }else{
        //Escuta resposta
        
        
        cfSocket=CFSocketCreateWithNative(NULL, sock, kCFSocketDataCallBack, ReadCallback, NULL);
        
        rls = CFSocketCreateRunLoopSource(kCFAllocatorDefault, cfSocket, 0);
        
        
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopCommonModes);
        
        
    }
    
    [self performSelector:@selector(dataVerifier) withObject:nil afterDelay:8];
}

- (IBAction)refreshConnection:(id)sender {
    [[self data] removeAllObjects];
    [self.collectionView reloadData];
    [self startSearchAirServer];
}

- (void)viewDidUnload
{
    [self setLd_apps:nil];
    [self setBtReload:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

//overrides to UICollectionController
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    
    return 1;
    
}



- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_data count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"app_cell" forIndexPath:indexPath];
    
    Application *app=[_data objectAtIndex:indexPath.item];
    
    UIImageView *icon_image=(UIImageView *)[newCell viewWithTag:10];
    UILabel* label=(UILabel *)[newCell viewWithTag:20];
    
    NSURL *url = [NSURL URLWithString:[app icon]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    UIImage *img = [[UIImage alloc]initWithData:data];
    
    [icon_image setImage:img];
    
    [label setText:[app name]];
    
    return newCell;
    
}

- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    
    UIImageView *image=(UIImageView *)[cell viewWithTag:10];
    
    UIView *overlay = [[UIView alloc] initWithFrame:image.bounds];
    overlay.backgroundColor = [UIColor blackColor];
    overlay.alpha = 0.5f;
    image.alpha=0.5f;
    
    [clickStateDic setObject:overlay forKey:indexPath];
    
    [image addSubview:overlay];
}



- (void)collectionView:(UICollectionView *)colView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    
    UIImageView *image=(UIImageView *)[cell viewWithTag:10];
    UIView *overlay = [clickStateDic objectForKey:indexPath];
    
    [overlay removeFromSuperview];
    image.alpha=1;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier]isEqual:@"open_app"]){
        AppViewController *controller=( AppViewController *)[segue destinationViewController];
        
        
        UICollectionViewCell* cell=(UICollectionViewCell *) sender;
        
        NSInteger pos=[self.collectionView indexPathForCell:cell].item;
        
        
        [controller setApplication:[_data objectAtIndex:pos]];
        
    }
}

-(void) dataVerifier{
    
    if(!flagServerFound){
        [[self ld_apps] setHidden:true];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro de conexão!"
                                                        message:@"Não foi possível estabelecer uma cominicação com o servidor de aplicações!"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
         [_btReload setEnabled:true];

        if(rls==NULL||cfSocket==NULL)
            return;
        
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), rls, kCFRunLoopCommonModes);
        CFRelease(rls);
        CFSocketInvalidate(cfSocket);
        CFRelease(cfSocket);
    }
    
    
        
}


@end
