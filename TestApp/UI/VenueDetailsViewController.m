//
//  VenueDetailsViewController.m
//  TestApp
//
//  Created by Nurmela, Tomi on 18.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import "VenueDetailsViewController.h"

#import "FoursquareVenueInformation.h"

@interface VenueDetailsViewController () {
    FoursquareVenueInformation *_venueInfo;
}

@property IBOutlet UILabel *nameTitle;
@property IBOutlet UILabel *nameLabel;
@property IBOutlet UILabel *distanceTitle;
@property IBOutlet UILabel *distanceLabel;
@property IBOutlet UILabel *addressTitle;
@property IBOutlet UILabel *addressLabel;

@end

@implementation VenueDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"VENUE_DETAILS_VIEW_TITLE", @"Details");
    self.nameTitle.text = NSLocalizedString(@"VENUE_DETAILS_NAME_LABEL_TITLE", @"Name");
    self.distanceTitle.text = NSLocalizedString(@"VENUE_DETAILS_DISTANCE_LABEL_TITLE", @"Distance");
    self.addressTitle.text = NSLocalizedString(@"VENUE_DETAILS_ADDRESS_LABEL_TITLE", @"Address");

    // We need to add label multiline support definition here, in a code, because of bug in Xcode. Xcode gives warning, when trying to
    // define multiline label directly in storyboard.
    // See http://stackoverflow.com/questions/25398312/automatic-preferred-max-layout-width-is-not-available-on-ios-versions-prior-to-8
    self.nameLabel.numberOfLines = 0;
    self.distanceLabel.numberOfLines = 0;
    self.addressLabel.numberOfLines = 0;
    // Update venue details
    [self updateInfo];
}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)setVenueInformation:(FoursquareVenueInformation *)venueInfo {
    _venueInfo = venueInfo;
    [self updateInfo];
}

- (void)updateInfo {

    // Update venue information in UI. Show "information not available" if information is missing
    NSAssert(_venueInfo != nil, @"Detailed venue information is missing");
    NSString *informationNotAvailabeText =  NSLocalizedString(@"VENUE_DETAILS_INFORMATION_NOT_AVAILABLE", @"");
    self.nameLabel.text = (_venueInfo.name ? _venueInfo.name : informationNotAvailabeText);

    self.distanceLabel.text = (_venueInfo.distance == kUnknownDistance) ? informationNotAvailabeText :
                            [NSString stringWithFormat:NSLocalizedString(@"VENUE_DETAILS_DISTANCE_LABEL", @"%d meters"), _venueInfo.distance];

    self.addressLabel.text = ((_venueInfo.address) ? _venueInfo.address : informationNotAvailabeText);
}

@end
