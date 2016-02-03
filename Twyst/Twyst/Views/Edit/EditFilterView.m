//
//  EditFilterView.m
//  Twyst
//
//  Created by Niklas Ahola on 7/4/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "EditFilterView.h"
#import "EditFilterViewCell.h"

@interface EditFilterView()<UICollectionViewDataSource, UICollectionViewDelegate> {
    UICollectionView *_collectionView;
    NSString *_reuseId;
    
    NSArray *_arrBundleImages;
    NSArray *_arrBundleSelectedImages;
    
    CGFloat _cellWidth;
}
@end

@implementation EditFilterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        DeviceType type = [Global deviceType];
        switch (type) {
            case DeviceTypePhone6:
                _cellWidth = 86;
                break;
            case DeviceTypePhone6Plus:
                _cellWidth = 95;
                break;
            default:
                _cellWidth = 74;
                break;
        }
        
        float imageH = self.bounds.size.height;
        // Initialization code
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(_cellWidth, imageH);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 6, 0, 6);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delaysContentTouches = NO;
        
        [self addSubview:_collectionView];
        
        _reuseId = @"edit-filter-collection-cell";
        
        [_collectionView registerClass:[EditFilterViewCell class] forCellWithReuseIdentifier:_reuseId];
        
        _arrBundleImages = [[NSArray alloc] initWithObjects:@"ic_filter_new_natural_off", @"ic_filter_new_digi_off", @"ic_filter_new_vint_off", @"ic_filter_new_mate_off", @"ic_filter_new_turt_off", @"ic_filter_new_linc_off", @"ic_filter_new_lair_off", @"ic_filter_new_rusy_off", @"ic_filter_new_cali_off", @"ic_filter_new_bano_off", @"ic_filter_new_watts_off", @"ic_filter_new_wake_off", @"ic_filter_new_luca_off", @"ic_filter_new_brite_off", @"ic_filter_new_bery_off", @"ic_filter_new_leon_off", @"ic_filter_new_pelle_off", @"ic_filter_new_beegee_off", nil];
        _arrBundleSelectedImages = [[NSArray alloc] initWithObjects:@"ic_filter_new_natural_on", @"ic_filter_new_digi_on", @"ic_filter_new_vint_on", @"ic_filter_new_mate_on", @"ic_filter_new_turt_on", @"ic_filter_new_linc_on", @"ic_filter_new_lair_on", @"ic_filter_new_rusy_on", @"ic_filter_new_cali_on", @"ic_filter_new_bano_on", @"ic_filter_new_watts_on", @"ic_filter_new_wake_on", @"ic_filter_new_luca_on", @"ic_filter_new_brite_on", @"ic_filter_new_bery_on", @"ic_filter_new_leon_on", @"ic_filter_new_pelle_on", @"ic_filter_new_beegee_on", nil];
    }
    return self;
}

#pragma delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([Global getCurrentFlipframePhotoModel].filterIndex != indexPath.row) {
        // deselect current filter
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:[Global getCurrentFlipframePhotoModel].filterIndex inSection:0];
        if ([[collectionView indexPathsForVisibleItems] containsObject:currentIndexPath]) {
            EditFilterViewCell *cell = (EditFilterViewCell*)[collectionView cellForItemAtIndexPath:currentIndexPath];
            [cell cellSelected:NO];
        }
        
        // select new filter
        [Global getCurrentFlipframePhotoModel].filterIndex = indexPath.row;
        EditFilterViewCell *cell = (EditFilterViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        [cell cellSelected:YES];
        
        if (self.delegate)  {
            [self.delegate editFilderView:self didSelect:indexPath.row];
        }
    }
    
    // Auto scroll
    CGFloat delta = 1.0;
    UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect frame = [collectionView convertRect:attributes.frame toView:self];
    if (frame.origin.x < _cellWidth * delta) {
        CGFloat x = MAX(0, _cellWidth * (indexPath.row - delta));
        [collectionView setContentOffset:CGPointMake(x, 0) animated:YES];
    }
    else if (frame.origin.x > collectionView.frame.size.width - _cellWidth * (1 + delta)) {
        CGFloat x = MIN(_cellWidth * (indexPath.row + (1 + delta)) - collectionView.frame.size.width, collectionView.contentSize.width - collectionView.frame.size.width);
        [collectionView setContentOffset:CGPointMake(x, 0) animated:YES];
    }
}

#pragma datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section    {
    return 18;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EditFilterViewCell *cellView = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseId forIndexPath:indexPath];
    if (cellView)   {
        BOOL isSelected = NO;
        if ([Global getCurrentFlipframePhotoModel].filterIndex == indexPath.row) {
            isSelected = YES;
        }
        
        NSString *bundleImage = [_arrBundleImages objectAtIndex:indexPath.row];
        NSString *bundleSelectedImage = [_arrBundleSelectedImages objectAtIndex:indexPath.row];
        
        [cellView updateState:isSelected withBundleImage:bundleImage selectedBundleImage:bundleSelectedImage];
    }
    return cellView;
}

- (void) reloadAll  {
    [_collectionView reloadData];
}

- (void) startNewSession {
    [_collectionView reloadData];
    [_collectionView setContentOffset:CGPointZero];
}

- (void) enableGraphics:(BOOL) isEnable {
    if (isEnable)   {
        
    }   else    {
        
    }
}

@end
