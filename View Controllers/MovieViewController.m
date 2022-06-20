//
//  MovieViewController.m
//  Flixer
//
//  Created by Julia Navarro Goldaraz on 6/15/22.
//

#import "MovieViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"


@interface MovieViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>




@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIAlertController *alertController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSArray *filteredData;

@property (weak, nonatomic) IBOutlet UIView *searchBarPlaceholder;

@property (nonatomic, strong) NSArray *devices;
@property (strong, nonatomic) NSMutableArray *filteredDevices;
@property BOOL isFiltered;

@end

@implementation MovieViewController

- (void)viewDidLoad {
    
    self.isFiltered = false;
    self.searchBar.delegate = self;
    [super viewDidLoad];
    //self.devices = self.movies[@"title"];
    
    
    
    //[self.devices addObjectsFromArray:self.movies];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fechMovies];
    self.refreshControl =[[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(fechMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    self.data = @[@"Fantastic Beasts: The Secrets of Dumbledor", @"Sonic the Hedgehog 2", @"The Lost City", @"Jurastic World Dominion",
                      @"Morbius", @"Phoenix, AZ", @"San Diego, CA", @"San Antonio, TX",
                      @"Dallas, TX", @"Memory", @"The Unbearable Weight of Massive Talent", @"The Northman",
                      @"Dragon Ball Super: Super Hero", @"Interceptor", @"Hustle", @"See For Me",
                      @"The Bad Guys", @"Lightyear", @"Charlotte, ND", @"Fort Worth, TX"];

    self.devices = @[@"Iphone", @"Fan", @"Son"];
    self.filteredData = self.devices;
    
    //self.devices = @[@"Iphone", @"Ipad"];//

}
    
- (void) fechMovies{
        
    // Do any additional setup after loading the view.
    [self.activityIndicator startAnimating];
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=0a89e900f2558e433154e66bbbd47da0"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
            [self showError];
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSLog(@"%@", dataDictionary);// log an object with the %@ formatter.
               self.movies = dataDictionary[@"results"];
               for (NSDictionary *movies in self.movies){
                   NSLog(@"%@", movies[@"tittle"]);
               }
               [self.tableView reloadData];
           }
        [self.refreshControl endRefreshing];
       }];
    [task resume];
    [self.activityIndicator stopAnimating];
    
}

- (void)showError{
    
    UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Cannot Get Movies"
                                     message:@"The internet connection apears to be offline."
                                     preferredStyle:UIAlertControllerStyleAlert];

        //Add Buttons

        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Try Again"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
            [self fechMovies];
                                    }];
        //Add your buttons to alert controller

        [alert addAction:yesButton];

        [self presentViewController:alert animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
    (NSInteger)section{
    if (self.isFiltered) {
        return self.filteredDevices.count;
    }
    return self.movies.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
    (NSIndexPath *)indexPath{
    MovieCell *cell = [tableView
        dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    
    NSString *baseURLString =@"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString: posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString: fullPosterURLString];
    
    //cell.posterView.image = nil;
    [cell.posterImage setImageWithURL : posterURL];
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length == 0) {
        self.isFiltered = false;
        [self.searchBar endEditing:YES];
    } else {
        self.isFiltered = true;
        self.filteredDevices = [[NSMutableArray alloc]init];
        self.filteredData = self.devices;
     for (NSString *device in self.devices) {
            NSRange range = [device rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                [self.filteredDevices addObject:device];
            }
        }
    }
    [self.tableView reloadData];
 
}


//[NSString stringWithFormat:@"row: %d, section %d", indexPath.row, indexPath.section];
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

     NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:sender];
     NSDictionary *movieInfo = self.movies[cellIndexPath.row];
    DetailsViewController *detailsVC = [segue destinationViewController];
     detailsVC.detailsDict = movieInfo;
}

//- (void) connection: (NSURLConnection *)connection didFailWithError: (NSError *)error; avoid
@end
