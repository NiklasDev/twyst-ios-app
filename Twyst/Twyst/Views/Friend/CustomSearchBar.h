//
//  CustomSearchBar.h
//  Twyst
//
//  Created by Niklas Ahola on 8/15/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchBarDelegate <NSObject>

@optional
- (void)searchBarDidStart;
- (void)searchBarDidEndOnExit:(NSString *)searchText;
- (void)searchBarDidChanged:(NSString *)searchText;
- (void)searchBarDidCancel;
- (void)searchBarDidClear;

@end

@interface CustomSearchBar : UIView

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (nonatomic, assign) id <SearchBarDelegate> delegate;

- (id)initWithTarget:(id)target;
- (void) focusFriendSearchBar;
- (void) resignFriendSearchBar;
- (BOOL) isSearchBarFirstResponder;
- (void) addSearchBarObserver;
- (void) removeSearchBarObserver;

@end
