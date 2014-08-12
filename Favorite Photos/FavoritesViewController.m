//
//  FavoritesViewController.m
//  Favorite Photos
//
//  Created by Nicolas Semenas on 12/08/14.
//  Copyright (c) 2014 Nicolas Semenas. All rights reserved.
//

#import "FavoritesViewController.h"
#import "ViewController.h"
#import "PhotoCell.h"

@interface FavoritesViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (nonatomic, strong) NSMutableArray * favorites;


#define urlToRetrieveFlickrPhotos @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=4d0b397e77019c74a5d42d08253e500a&format=json&nojsoncallback=1&license=1,2,3&per_page=10&tags="

@end

@implementation FavoritesViewController





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self load];
    if (self.favorites == nil){
        self.favorites = [NSMutableArray new];
        
    }

    
    self.countLabel.text = [NSString stringWithFormat:@"Favorites: %lu Photos",self.favorites.count];
    
    
    
}


-(void) viewDidAppear:(BOOL)animated{
    
    //NOT WORKING...
    [self.myCollectionView reloadData];

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






#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
	return [self.favorites count];

}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
	cell.imageView.image = nil;
    NSString * imageURLString = self.favorites[indexPath.row];
    
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    
    cell.imageView.image = image;
    NSLog(@"+1");
	return cell;
    
}




@end
