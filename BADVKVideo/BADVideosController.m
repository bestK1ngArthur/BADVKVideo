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

static NSInteger videosInRequest = 40;

@interface BADVideosController () <UISearchBarDelegate>

@property (weak, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;

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
    
    // Add activity indicator
    
    CGFloat side = 50.f;
    CGFloat centerX = (self.view.frame.size.width - side) / 2;
    CGFloat centerY = (self.view.frame.size.height - side) / 2;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(centerX, centerY, side, side)];
    activityIndicator.color = [UIColor colorWithRed:227 /255.f
                                              green:228 /255.f
                                               blue:329 /255.f
                                              alpha:1.f];
    [self.view addSubview:activityIndicator];
    [self.view bringSubviewToFront:activityIndicator];
    self.activityIndicator = activityIndicator;
    
    // Setup search bar
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -44, self.view.bounds.size.width - 34, 44)];
    searchBar.placeholder = @"Всеобщий поиск";
    searchBar.delegate = self;
    [searchBar setKeyboardAppearance:UIKeyboardAppearanceDark];
    searchBar.barStyle = UISearchBarStyleMinimal;
    
    self.searchBar = searchBar;
    
    // Add search bar to navigation title
    
    self.navigationItem.titleView = self.searchBar;

    // Authorise user if needed
    
    [[BADVKManager sharedManager] authorizeUserWithCompletion:^(BOOL isAuthorised) {
        self.isAuthorised = isAuthorised;
    }];
}

- (void)playVideo:(BADVideo *)video {
    
    BADVideoPlayerController *player = [[BADVideoPlayerController alloc] initWithVideo:video];
    [self.navigationController pushViewController:player animated:YES];
    
    [self.searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.videosArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"BADVideoCell";
    BADVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[BADVideoCell alloc] initWithReuseIdentifier:@"BADVideoCell"];
    }
    
    if (indexPath.row == [self.videosArray count] - 1) { // If last cell, load new videos
        [self searchVideosFromVK];
    }
    
    // Set video information
    
    BADVideo *video = [self.videosArray objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = video.title;
    cell.durationLabel.text = video.durationString;
    cell.photoView.image = nil;
    
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
    [self.activityIndicator startAnimating];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if ([searchText length] == 0) { // If button 'clear' pressed
        
        [self.videosArray removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [self.tableView reloadData];
}

#pragma mark - VKAPI

- (void)searchVideosFromVK {
    
    if (self.isAuthorised) {
        
        [self searchVideosFromVKWithQuery:self.searchBar.text];
        
    } else {
        
        [[BADVKManager sharedManager] authorizeUserWithCompletion:^(BOOL isAuthorised) {
            
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
                                                        
                                                        [self.activityIndicator stopAnimating];
                                                        
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
