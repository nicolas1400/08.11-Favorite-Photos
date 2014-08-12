//
//  ViewController.m
//  Favorite Photos
//
//  Created by Nicolas Semenas on 11/08/14.
//  Copyright (c) 2014 Nicolas Semenas. All rights reserved.
//

#import "ViewController.h"
#import "PhotoCell.h"
#import "FavoritesViewController.h"

@interface ViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;

@property (nonatomic, strong) NSMutableArray * photos;
@property (nonatomic, strong) NSMutableArray * favorites;


#define urlToRetrieveFlickrPhotos @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=4d0b397e77019c74a5d42d08253e500a&format=json&nojsoncallback=1&license=1,2,3&per_page=10&tags="

@end

@implementation ViewController



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
       [self.view endEditing:YES];
     [self loadFlickrPhotosWithKeyword:self.mySearchBar.text];
    NSLog(@"%@",self.mySearchBar.text);

}

-(void) onFavorite{
    NSLog(@"fav!");
}


- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.photos = [[NSMutableArray alloc]init];

    [self load];
    if (self.photos == nil){
        self.photos = [NSMutableArray new];
        
    }
    

    
}



- (void)loadFlickrPhotosWithKeyword:(NSString *)aKeyword {
    
//PARSE NOT WORKING , TODO: FIX IT
    
//    NSString * allKeywords = [[NSString alloc]init];
//    
//    NSArray *keywords = [aKeyword componentsSeparatedByString: @" "];
//    
//    for (NSString * keyword in keywords){
//        allKeywords = [allKeywords stringByAppendingString:keyword];
//        allKeywords = [allKeywords stringByAppendingString:@","];
//    }
    
//    NSURL *url = [NSURL URLWithString:[urlToRetrieveFlickrPhotos stringByAppendingString:allKeywords]];
    
    
    NSURL *url = [NSURL URLWithString:[urlToRetrieveFlickrPhotos stringByAppendingString:aKeyword]];

	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	[NSURLConnection sendAsynchronousRequest:urlRequest
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
							   NSDictionary *decodedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               self.photos = decodedJSON[@"photos"][@"photo"];
                               [self.myCollectionView reloadData];
                               
                           }];
}




#pragma mark - NSUserDefault Stuff

-(NSURL *)documentsDirectory{
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray *directories =  [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    ///NSLog(@"%@", directories.firstObject);
    return directories.firstObject;
    
}


-(void) load {
    
    NSURL *plist = [[self documentsDirectory] URLByAppendingPathComponent:@"pastes1.plist"];
    self.favorites = [NSMutableArray arrayWithContentsOfURL:plist];
    NSLog(@"Total favorites: %lu",self.favorites.count);
}


- (void) save{
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSURL * plist = [[self documentsDirectory]URLByAppendingPathComponent:@"pastes1.plist"];
    
    NSLog(@"%@", plist);
    [self.favorites writeToURL:plist atomically:YES];
    [defaults setObject:[NSDate date] forKey:@"lastSaved"];
    [defaults synchronize];
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"%lu", (unsigned long)self.photos.count);

	return [self.photos count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
  
	cell.imageView.image = nil;
	NSDictionary *photoDictionary = self.photos[indexPath.row];
	NSString *photoId = photoDictionary[@"id"];
    
    NSString *imageURLString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg",
                                photoDictionary[@"farm"],
                                photoDictionary[@"server"],
                                photoId,
                                photoDictionary[@"secret"]];

    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];

    cell.imageView.image = image;
    NSLog(@"+1");
	return cell;
    
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didselect");
	NSDictionary *photoDictionary = self.photos[indexPath.row];
	NSString *photoId = photoDictionary[@"id"];
    
    NSString *imageURLString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg",
                                photoDictionary[@"farm"],
                                photoDictionary[@"server"],
                                photoId,
                                photoDictionary[@"secret"]];
    
    [self.favorites addObject:imageURLString];
    [self save];

}
@end
