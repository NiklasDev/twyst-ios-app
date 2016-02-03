//
//  ELCAssetTablePicker.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface ELCAssetTablePicker ()

@property (nonatomic, assign) int columns;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@end

@implementation ELCAssetTablePicker

//Using auto synthesizers

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"ELCAssetTablePicker"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        //Sets a reasonable default bigger then 0 for columns
        //So that we don't have a divide by 0 scenario
        self.columns = 3;
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.tableView setAllowsSelection:NO];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    
    NSMutableArray *tempSelectedArray = [[NSMutableArray alloc] init];
    self.selectedAssets = tempSelectedArray;

//	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    [self preparePhotos];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.columns = 3;
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.columns = 3;
    [self.tableView reloadData];
}

- (void)preparePhotos
{
    @autoreleasepool {
        
        [self.assetGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if ([result defaultRepresentation] == nil) {
                return;
            }
            
            ELCAsset *elcAsset = [[ELCAsset alloc] initWithAsset:result];
            [elcAsset setParent:self];
            
            BOOL isAssetFiltered = NO;
            if (self.assetPickerFilterDelegate &&
                [self.assetPickerFilterDelegate respondsToSelector:@selector(assetTablePicker:isAssetFilteredOut:)]) {
                isAssetFiltered = [self.assetPickerFilterDelegate assetTablePicker:self isAssetFilteredOut:(ELCAsset*)elcAsset];
            }
            
            if (!isAssetFiltered) {
                [self.elcAssets addObject:elcAsset];
            }
        }];

        // Reload albums
        [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
    }
}

- (void)reloadTableView {
    [self.tableView reloadData];
}

- (BOOL)shouldSelectAsset:(ELCAsset *)asset
{
    if([self.mediaTypes containsObject:(NSString *)kUTTypeMovie])
    {
        CGSize size = asset.asset.defaultRepresentation.dimensions;
        if (size.width > size.height) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Sorry but landscape videos will not fit in your twyst. Please try to upload a full screen video."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
        
        double value = [[asset.asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        if (value < 1.0f) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Your video must be at least 1 second long"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
    else if ([self.mediaTypes containsObject:(NSString*)kUTTypeImage]) {
        CGSize size = asset.asset.defaultRepresentation.dimensions;
        if (size.width > size.height) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Sorry but landscape photos will not fit in your twyst. Please try to upload a full screen photo."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
        
        if (size.width < DEF_TWYST_IMAGE_WIDTH || size.height < DEF_TWYST_IMAGE_HEIGHT) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Twysts are full screen photos and videos, so to avoid pixelation please select a larger image that has not been cropped."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
    
    NSUInteger selectionCount = _selectedAssets.count;
    BOOL shouldSelect = YES;
    if ([self.parent respondsToSelector:@selector(shouldSelectAsset:previousCount:)]) {
        shouldSelect = [self.parent shouldSelectAsset:asset previousCount:selectionCount];
    }
    return shouldSelect;
}

- (void)assetSelected:(ELCAsset *)asset
{
    [self.selectedAssets addObject:asset];

    if ([self.parent respondsToSelector:@selector(shouldDoneWithSelectionCount:)]) {
        self.btnDone.enabled =  [self.parent shouldDoneWithSelectionCount:[self totalSelectedAssets]];
    }
    
    [self.tableView reloadData];
}

- (void)assetDeselected:(ELCAsset *)asset {
    [_selectedAssets removeObject:asset];
    
    if ([self.parent respondsToSelector:@selector(shouldDoneWithSelectionCount:)]) {
        self.btnDone.enabled =  [self.parent shouldDoneWithSelectionCount:[self totalSelectedAssets]];
    }
    
    [self.tableView reloadData];
}

#pragma mark -
- (IBAction)handleBtnDoneTouch:(id)sender {
    NSMutableArray *selectedAssetsImages = [[NSMutableArray alloc] init];
    
    for (ELCAsset *elcAsset in self.selectedAssets) {
        [selectedAssetsImages addObject:[elcAsset asset]];
    }
    
    [self.parent selectedAssets:selectedAssetsImages];
}

- (IBAction)handleBtnCloseTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark ELC Assets Selection Delegate
- (BOOL)shouldSelectAsset:(ELCAsset *)asset previousCount:(NSUInteger)previousCount
{
    return [self.parent shouldSelectAsset:asset previousCount:previousCount];
}

- (BOOL)shouldDoneWithSelectionCount:(NSUInteger)selectionCount
{
    return [self.parent shouldDoneWithSelectionCount:selectionCount];
}

- (void)selectedAssets:(NSArray*)assets
{
    [self.parent selectedAssets:assets];
}

#pragma mark -
#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.columns <= 0) { //Sometimes called before we know how many columns we have
        self.columns = 3;
    }
    NSInteger numRows = ceil([self.elcAssets count] / (float)self.columns);
    return numRows;
}

- (NSArray *)assetsForIndexPath:(NSIndexPath *)path
{
    long index = path.row * self.columns;
    long length = MIN(self.columns, [self.elcAssets count] - index);
    return [self.elcAssets subarrayWithRange:NSMakeRange(index, length)];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {		        
        cell = [[ELCAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setAssets:[self assetsForIndexPath:indexPath] selectedAssets:self.selectedAssets mediaTypes:self.mediaTypes];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            return 125;
            break;
        case DeviceTypePhone6Plus:
            return 138;
            break;
        default:
            return 107;
            break;
    }
}

- (NSInteger)totalSelectedAssets
{
    NSInteger count = _selectedAssets.count;
    
    return count;
}

#pragma mark - status bar hidden
- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
