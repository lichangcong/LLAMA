//
//  LLAEditVideoProgressView.m
//  LLama
//
//  Created by Live on 16/1/28.
//  Copyright © 2016年 heihei. All rights reserved.
//

#import "LLAEditVideoProgressView.h"

static NSString *const leftToggleImageName = @"arrow_time";
static NSString *const rightToggleImageName = @"arrow_time";

//
const CGFloat editVideo_progressViewHeight = 6;

@interface LLAEditVideoProgressView()
{
    UIView *progressBackView;
    UIView *cutProgressView;
    
    UIImageView *leftToggleView;
    UIImageView *rightToggleView;
    
    UIView *thumbImageContentView;
    
    //
    UIColor *progressBackViewBKColor;
    UIColor *cutProgressViewBKColor;
    
}

@property(nonatomic , readwrite , assign) CGFloat editBeginRatio;
@property(nonatomic , readwrite , assign) CGFloat editEndRatio;

@property(nonatomic , readwrite , weak) AVAsset *editAsset;

@end

@implementation LLAEditVideoProgressView

@synthesize numberOfThumbImages;
@synthesize editBeginRatio,editEndRatio;
@synthesize editAsset;

#pragma mark - Life Cycle

- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    //
    [self updateLeftRightTogglePosition];
}

#pragma mark - Init

- (instancetype) initWithAsset:(AVAsset *)asset {
    
    self = [super init];
    if (self) {
        editAsset = asset;
        
        [self initVariables];
        [self initSubViews];
        [self initSubContraints];
        [self initThumbImages];
        
        self.backgroundColor = progressBackViewBKColor;
    }
    return self;
}

- (void) initVariables {
    
    numberOfThumbImages = 8;
    
    editBeginRatio = 0;
    editBeginRatio = 1.0;
    
    progressBackViewBKColor = [UIColor colorWithHex:0x18182d];
    cutProgressViewBKColor = [UIColor colorWithHex:0xffd409];
    
}

- (void) initSubViews {
    progressBackView = [[UIView alloc] init];
    progressBackView.translatesAutoresizingMaskIntoConstraints = NO;
    progressBackView.backgroundColor = progressBackViewBKColor;
    
    [self addSubview:progressBackView];
    
    //
    cutProgressView = [[UIView alloc] init];
    cutProgressView.translatesAutoresizingMaskIntoConstraints = NO;
    cutProgressView.backgroundColor = cutProgressViewBKColor;
    
    [self addSubview:cutProgressView];
    
    //
    leftToggleView = [[UIImageView alloc] init];
    //leftToggleView.translatesAutoresizingMaskIntoConstraints = NO;
    leftToggleView.image = [UIImage llaImageWithName:leftToggleImageName];
    [leftToggleView sizeToFit];
    leftToggleView.userInteractionEnabled = YES;
    [self addSubview:leftToggleView];
    
    UIPanGestureRecognizer *leftPan =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(togglePan:)];
    [leftToggleView addGestureRecognizer:leftPan];
    
    //
    rightToggleView = [[UIImageView alloc] init];
    //rightToggleView.translatesAutoresizingMaskIntoConstraints = NO;
    rightToggleView.image = [UIImage llaImageWithName:rightToggleImageName];
    [rightToggleView sizeToFit];
    rightToggleView.userInteractionEnabled = YES;
    
    [self addSubview:rightToggleView];
    
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(togglePan:)];
    [rightToggleView addGestureRecognizer:rightPan];
    
    //
    thumbImageContentView = [[UIView alloc] init];
    thumbImageContentView.translatesAutoresizingMaskIntoConstraints = NO;
    thumbImageContentView.backgroundColor = progressBackViewBKColor;
    thumbImageContentView.layer.borderWidth = 1.0;
    thumbImageContentView.layer.borderColor = [UIColor whiteColor].CGColor;
    thumbImageContentView.clipsToBounds = YES;
    
    [self addSubview:thumbImageContentView];
    
    [self sendSubviewToBack:thumbImageContentView];
}

- (void) initThumbImages {
    
    //preView
    UIView *preView = nil;
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:editAsset];
    imageGenerator.appliesPreferredTrackTransform = YES;

    
    for (int i=0;i<numberOfThumbImages;i++) {
        
        UIImageView *thumb = [[UIImageView alloc] init];
        thumb.translatesAutoresizingMaskIntoConstraints = NO;
        thumb.contentMode = UIViewContentModeScaleAspectFill;
        
        //set image
        
        NSError *error = nil;
        CGImageRef thumbnailImage = [imageGenerator copyCGImageAtTime:CMTimeMake(i/(float)numberOfThumbImages, 1) actualTime:nil error:&error];
        if (!error){
            thumb.image = [UIImage imageWithCGImage:thumbnailImage];
        }else {
            thumb.image = [UIImage llaImageWithName:@"placeHolder_200"];
        }

        [thumbImageContentView addSubview:thumb];
        
        //constraints
        [thumbImageContentView addConstraints:
         [NSLayoutConstraint
          constraintsWithVisualFormat:@"V:|-(0)-[thumb]-(0)-|"
          options:NSLayoutFormatDirectionLeadingToTrailing
          metrics:nil
          views:NSDictionaryOfVariableBindings(thumb)]];
        
        if (preView) {
            [thumbImageContentView addConstraints:
             [NSLayoutConstraint
              constraintsWithVisualFormat:@"H:[preView]-(0)-[thumb]"
              options:NSLayoutFormatDirectionLeadingToTrailing
              metrics:nil
              views:NSDictionaryOfVariableBindings(preView,thumb)]];
        
        }else {
            [thumbImageContentView addConstraints:
             [NSLayoutConstraint
              constraintsWithVisualFormat:@"H:|-(0)-[thumb]"
              options:NSLayoutFormatDirectionLeadingToTrailing
              metrics:nil
              views:NSDictionaryOfVariableBindings(thumb)]];
        }
        
        [thumbImageContentView addConstraint:
         [NSLayoutConstraint
          constraintWithItem:thumb
          attribute:NSLayoutAttributeWidth
          relatedBy:NSLayoutRelationEqual
          toItem:thumbImageContentView
          attribute:NSLayoutAttributeWidth
          multiplier:1/(float)numberOfThumbImages
          constant:0]];
        
        preView = thumb;
        
    }
}

- (void) initSubContraints {
    //
    NSMutableArray *constrArray = [NSMutableArray array];
    
    //vertical
    [constrArray addObjectsFromArray:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|-(0)-[progressBackView(height)]-(0)-[thumbImageContentView]-(0)-|"
      options:NSLayoutFormatDirectionLeadingToTrailing
      metrics:@{@"height":@(editVideo_progressViewHeight)}
      views:NSDictionaryOfVariableBindings(progressBackView,thumbImageContentView)]];
    
    [constrArray addObjectsFromArray:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|-(0)-[cutProgressView(height)]"
      options:NSLayoutFormatDirectionLeadingToTrailing
      metrics:@{@"height":@(editVideo_progressViewHeight)}
      views:NSDictionaryOfVariableBindings(cutProgressView)]];
    
    //horizonal
    [constrArray addObjectsFromArray:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-(toLeft)-[progressBackView]-(toRight)-|"
      options:NSLayoutFormatDirectionLeadingToTrailing
      metrics:@{@"toLeft":@(leftToggleView.frame.size.width/2),
                @"toRight":@(rightToggleView.frame.size.width/2)}
      views:NSDictionaryOfVariableBindings(progressBackView)]];
    
    [constrArray addObjectsFromArray:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-(toLeft)-[cutProgressView]-(toRight)-|"
      options:NSLayoutFormatDirectionLeadingToTrailing
      metrics:@{@"toLeft":@(leftToggleView.frame.size.width/2),
                @"toRight":@(rightToggleView.frame.size.width/2)}
      views:NSDictionaryOfVariableBindings(cutProgressView)]];
    
    [constrArray addObjectsFromArray:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-(0)-[thumbImageContentView]-(0)-|"
      options:NSLayoutFormatDirectionLeadingToTrailing
      metrics:nil
      views:NSDictionaryOfVariableBindings(thumbImageContentView)]];
    
    [self addConstraints:constrArray];
    
}

#pragma mark - Update Left Right toggle Position

- (void) updateLeftRightTogglePosition {
    
    leftToggleView.center = CGPointMake(editBeginRatio*progressBackView.bounds.size.width+leftToggleView.bounds.size.width/2, progressBackView.center.y) ;
    
    rightToggleView.center = CGPointMake(editEndRatio*progressBackView.bounds.size.width+rightToggleView.bounds.size.width/2, progressBackView.center.y) ;
    
}

#pragma mark - Pan gesture

- (void) togglePan:(UIPanGestureRecognizer *) ges {
    UIView *touchedView = ges.view;
    
    if (touchedView != leftToggleView && touchedView != rightToggleView) {
        return ;
    }
    
    static CGFloat originalX = 0;
    
    CGPoint point = [ges locationInView:self];
    
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            originalX = point.x;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat offset = point.x - originalX;
            originalX = point.x;
            
            touchedView.center = CGPointMake(touchedView.center.x+offset, touchedView.center.y);
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
        }
            break;
        case UIGestureRecognizerStateFailed:
        {
            
        }
            break;
            
        default:
            break;
    }
    
}

@end
