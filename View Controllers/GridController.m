//
//  GridController.m
//  Flixer
//
//  Created by Julia Navarro Goldaraz on 6/17/22.
//

#import "GridController.h"
#import "ColorCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface GridController ()<UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *GridCollector;
@property (nonatomic, strong) NSArray *movies;

@end

@implementation GridController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.GridCollector.dataSource = self;
    self.GridCollector.delegate = self;
    [self fechMovies];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.movies[indexPath.row];
    NSString *baseURLString =@"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    if (posterURLString != nil){
        NSString *fullPosterURLString = [baseURLString stringByAppendingString: posterURLString];
        NSURL *posterURL = [NSURL URLWithString: fullPosterURLString];
        [cell.imageLabel setImageWithURL : posterURL];
    }
    return cell;
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

- (void) fechMovies{
        
    // Do any additional setup after loading the view.
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
               [self.GridCollector reloadData];
           }
       }];
    [task resume];
}

- (void)viewDidLayoutSubviews {
   [super viewDidLayoutSubviews];

    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    int totalwidth = self.view.frame.size.width-15;
    int numberOfCellsPerRow = 3;
    int dimensions = (CGFloat)(totalwidth / numberOfCellsPerRow);
    return CGSizeMake(dimensions, 190);
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}


- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    ColorCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showDetailFromGrid" sender:cell];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *cellIndexPath = [self.GridCollector indexPathForCell:sender];
    NSDictionary *movieInfo = self.movies[cellIndexPath.row];
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DetailsViewController *detailsVC = [segue destinationViewController];
    detailsVC.detailsDict = movieInfo;
}

@end
