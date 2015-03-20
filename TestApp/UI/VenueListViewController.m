//
//  VenueListViewController.m
//  TestApp
//
//  Created by Nurmela, Tomi on 17.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import "VenueListViewController.h"

#import "FoursquareVenueInformation.h"
#import "VenueDataUpdater.h"
#import "VenueDetailsViewController.h"


static float const kWaitDelayBeforeSearchInSeconds = 0.0;

@interface VenueListViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {

    // Timer that is used for delaying search, after search text change
    NSTimer *_delayedSearchTimer;

    // Object that is used for searching venues
    VenueDataUpdater *_venueDataUpdater;

    // Index path that is stored when some item is opened in a details view
    NSIndexPath *_selectedItemIndexPath;

    // Current search results. Contains FoursquareVenueInformation objects
    NSArray *_resultsArray;

    // For showing errors
    UIAlertController *_alertController; // iOS 8
    UIAlertView *_alertView;             // iOS 7
}

@property IBOutlet UITableView *tableView;
@property IBOutlet UISearchBar *searchBar;

@end

@implementation VenueListViewController

#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"VENUE_LIST_VIEW_TITLE", @"Venues");
    _venueDataUpdater = VenueDataUpdater.new;
    _resultsArray = NSArray.new;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_selectedItemIndexPath) {
        // We are coming back from details view, unselect selection now
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        _selectedItemIndexPath = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // No need to update anything when our view goes background
    [self cancelSearch];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSAssert(section == 0, @"Unknown section");
    return _resultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSAssert(indexPath.section == 0, @"Unknown section");
    NSAssert(indexPath.row < _resultsArray.count, @"row index out of bounds");

    static NSString *CellIdentifier = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    FoursquareVenueInformation *venueInfo = [_resultsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = venueInfo.name;
    return cell;
}

#pragma mark UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Hide keyboard
    [self.view endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.view endEditing:YES];
    // Cancel search when we are opening details view, for avoiding situation that this view and details view are not in sync
    [self cancelSearch];
    _selectedItemIndexPath = indexPath;    
    [self performSegueWithIdentifier:@"VenueDetails" sender:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.destinationViewController isKindOfClass:[VenueDetailsViewController class]]) {
        // Set correct information item in details view
        VenueDetailsViewController *targetView = segue.destinationViewController;
        NSAssert(_selectedItemIndexPath != nil, @"selected index missing");
        NSAssert(_selectedItemIndexPath.row < _resultsArray.count, @"row out of bounds");
        FoursquareVenueInformation *info = [_resultsArray objectAtIndex:_selectedItemIndexPath.row];
        [targetView setVenueInformation:info];
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    NSLog(@"");
    // Trigger search after a small interval
    [_delayedSearchTimer invalidate];
    _delayedSearchTimer = [NSTimer scheduledTimerWithTimeInterval:kWaitDelayBeforeSearchInSeconds
                                                           target:self
                                                         selector:@selector(refreshSearch)
                                                         userInfo:nil
                                                          repeats:NO];
}

#pragma mark -

- (void)cancelSearch {

    [_delayedSearchTimer invalidate];
    _delayedSearchTimer = nil;
    [_venueDataUpdater cancel];
    [self updateTitle];
}

- (void)refreshSearch {

    __weak VenueListViewController * weakSelf = self;
    [self dismissErrorAlert];

    // Ensure that previous request is cancelled
    [_venueDataUpdater cancel];

    NSAssert(self.searchBar, @"Search bar is missing");
    NSString *queryText = self.searchBar.text;
    if (queryText == nil || queryText.length == 0) {
        [self updateWithVenues:nil];
    } else {
        // We started to fetch new items. Reset current view because it is not up-to-date anymore
        _resultsArray = NSArray.new;
        [self.tableView reloadData];
        self.title = NSLocalizedString(@"VENUE_LIST_VIEW_SEARCH_ONGOING_TITLE", @"Searching...");
        [_venueDataUpdater searchVenuesWithQuery:self.searchBar.text onComplete:^(NSArray *venues) {
            [weakSelf updateWithVenues:venues];
        } onFail:^(NSError *error) {
            [weakSelf searchFailedWithError:error];
        }];
    }
}

- (void)dismissErrorAlert {

    if ([UIAlertController class]) {
        if (_alertController) {
            [_alertController dismissViewControllerAnimated:YES completion:nil];
            _alertController = nil;
        }
    } else {
        [_alertView dismissWithClickedButtonIndex:-1 animated:YES];
        _alertView = nil;
    }
}

- (void)searchFailedWithError:(NSError *)error {

    if ([UIAlertController class]) {
        NSAssert(_alertController == nil, @"Already showing error");
        // Show error popup
        if (_alertController == nil) {
            _alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ERROR_VENUE_SEARCH_TITLE", "")
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_BUTTON_TRY_AGAIN", "Try again")
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action) {
                                                                       _alertController = nil;
                                                                       [self refreshSearch];
                                                                   }];
            [_alertController addAction:tryAgainAction];
            [self presentViewController:_alertController animated:YES completion:nil];
        }
    } else {
        NSAssert(_alertView == nil, @"Already showing error");
        _alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_VENUE_SEARCH_TITLE", "")
                                                message:error.localizedDescription
                                               delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"ALERT_BUTTON_TRY_AGAIN", "Try again"), nil];
        [_alertView show];
    }
    [self updateTitle];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _alertView = nil;
    [self refreshSearch];
}

- (void)updateTitle {
    if ((_resultsArray.count == 0) && (self.searchBar.text.length == 0)) {
        // No active search
        self.title = NSLocalizedString(@"VENUE_LIST_VIEW_TITLE", @"");
    } else if (_resultsArray.count == 1) {
        self.title = NSLocalizedString(@"VENUE_LIST_VIEW_SEARCH_RESULTS_ONE_TITLE", @"");
    } else {
        // zero or more than one item
        self.title = [NSString stringWithFormat:NSLocalizedString(@"VENUE_LIST_VIEW_SEARCH_RESULTS_MULTIPLE_TITLE", @""), _resultsArray.count];
    }
}

- (void)updateWithVenues:(NSArray *)venueInformationArray {

    if (venueInformationArray == nil) {
        _resultsArray = NSArray.new;
    } else {
        _resultsArray = [venueInformationArray copy];
    }
    [self updateTitle];
    [self.tableView reloadData];
}

@end
