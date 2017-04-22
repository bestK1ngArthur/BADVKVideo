//
//  ViewController.m
//  BADVKVideo
//
//  Created by Artem Belkov on 17/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import "BADVideosController.h"
#import "BADVKManager.h"
#import "BADVideo.h"
#import "BADVideoCell.h"
#import "BADVideoPlayerController.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

static NSInteger videosInRequest = 40;

#warning Add progress spinner

@interface BADVideosController () <UISearchBarDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *videosArray;
@property (assign, nonatomic) BOOL isAuthorised;

@end

@implementation BADVideosController 

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.videosArray = [NSMutableArray array];
    
    // Setup tableview
    [self.tableView setSeparatorColor:[UIColor colorWithRed:11 /255.f
                                                      green:17 /255.f
                                                       blue:23 /255.f
                                                      alpha:1.0f]];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.backgroundColor = [UIColor colorWithRed:27 /255.f
                                                     green:40 /255.f
                                                      blue:54 /255.f
                                                     alpha:1.0f];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // Setup search bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -44, self.view.bounds.size.width - 34, 44)];
    self.searchBar.placeholder = @"Всеобщий поиск";
    self.searchBar.delegate = self;
    [self.searchBar setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    // Add search bar to navigation title
    self.navigationItem.titleView = self.searchBar;

    // Authorise user if needed
    [[BADVKManager sharedManager] authorizeUserWithCompletion:^(bool isAuthorised) {
        self.isAuthorised = isAuthorised;
    }];
}

- (void)playVideo:(BADVideo *)video {
    
    BADVideoPlayerController *player = [[BADVideoPlayerController alloc] initWithVideo:video];
    [self.navigationController pushViewController:player animated:true];
    
    [self.searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.videosArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"BADVideoCell";
    BADVideoCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[BADVideoCell alloc] init];
    }
    
    if (indexPath.row == [self.videosArray count] - 1) { // If last cell, load new videos
        [self searchVideosFromVK];
    }
    
    // Set cell
    
    UIView *bgColorView = [[UIView alloc] initWithFrame:cell.frame];
    bgColorView.backgroundColor = [UIColor colorWithRed:129 /255.f
                                                  green:146 /255.f
                                                   blue:159 /255.f
                                                  alpha:1.f];
    [cell setSelectedBackgroundView:bgColorView];
    
    // Set video information
    
    BADVideo *video = [self.videosArray objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = video.title;
    cell.durationLabel.text = video.durationString;
    cell.photoView.image = nil;
    
    #warning Check uniqueness of the photo in cell
    // Start loading image for video
    [[BADVKManager sharedManager] getPhotoForVideo:video
                                           success:^(UIImage * _Nullable image) {
                                               if (image) {
                                                   // Setting image on main queue
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       cell.photoView.image = image;
                                                       cell.photoView.layer.cornerRadius = 5.f;
                                                       cell.photoView.layer.masksToBounds = YES;
                                                       [cell setNeedsLayout];
                                                   });
                                               }
                                           }
                                           failure:^(NSError * _Nullable error) {
                                               
                                               // Fail to load photo
                                               
                                           }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.f;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BADVideo *video = [self.videosArray objectAtIndex:indexPath.row];
    [self playVideo:video];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.videosArray removeAllObjects];
    [self.searchBar resignFirstResponder];
    [self searchVideosFromVK];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [self.tableView reloadData];
}

#pragma mark - VKAPI

- (void)searchVideosFromVK {
    
    if (self.isAuthorised) {
        
        [self searchVideosFromVKWithQuery:self.searchBar.text];
        
    } else {
        
        [[BADVKManager sharedManager] authorizeUserWithCompletion:^(bool isAuthorised) {
            
            self.isAuthorised = isAuthorised;
            [self searchVideosFromVKWithQuery:self.searchBar.text];
        }];
        
    }
}

- (void)searchVideosFromVKWithQuery:(NSString *)query {
    
    [[BADVKManager sharedManager] searchVideosWithQuery:query
                                                 offset:[self.videosArray count]
                                                  count:videosInRequest
                                                success:^(NSArray * _Nullable videos) {
                                                    
                                                    // Success
                                                    [self.videosArray addObjectsFromArray:videos];
                                                    
                                                    NSMutableArray* newPaths = [NSMutableArray array];
                                                    for (int i = (int)[self.videosArray count] - (int)[videos count]; i < [self.videosArray count]; i++) {
                                                        [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                                    }
                                                    
                                                    // Update tableview on main queue
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.tableView beginUpdates];
                                                        [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationTop];
                                                        [self.tableView endUpdates];
                                                        
                                                    });
                                                }
                                                failure:^(NSError * _Nullable error) {
                                                    
                                                    // Failure
                                                    
                                                }];
}

@end
