//
//  DetailsViewController.m
//  Flixer
//
//  Created by Julia Navarro Goldaraz on 6/17/22.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.titleLabel.text = self.detailsDict[@"title"];
    self.descriptionLabel.text = self.detailsDict[@"overview"];
    NSString *baseURLString =@"https://image.tmdb.org/t/p/w500";
    
    NSString *posterURLString = _detailsDict[@"poster_path"];
    
    NSString *fullPosterURLString = [baseURLString stringByAppendingString: posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString: fullPosterURLString];
    
    //cell.posterView.image = nil;
    [self.ImageLabel setImageWithURL : posterURL];
}

@end
