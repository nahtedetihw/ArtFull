
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

BOOL isSmallDevice() {
    if ([UIScreen mainScreen].nativeBounds.size.width <= 750) return YES;
    return NO;
}

BOOL isLargeDevice() {
    if ([UIScreen mainScreen].nativeBounds.size.width >= 1284) return YES;
    return NO;
}

@interface MusicNowPlayingControlsViewController : UIViewController
- (void)applyGradientMaskToView:(UIView *)view;
@end

@interface _TtC16MusicApplication21NowPlayingContentView : UIView
@end

@interface MusicArtworkComponentImageView : UIImageView
@end

@interface _TtC16MusicApplication25ArtworkComponentImageView : UIImageView
@end

UIImageView *artfullMusicView;

%group Music
%hook MusicNowPlayingControlsViewController
- (void)viewDidLoad {
    %orig;
    UIView *grabberView = MSHookIvar<UIView *>(self, "grabberView");
    grabberView.hidden = YES;
    
    if (self.view) {
        artfullMusicView = [UIImageView new];
        artfullMusicView.contentMode = UIViewContentModeScaleAspectFill;
        float size = self.view.bounds.size.width;
        artfullMusicView.frame = CGRectMake(0,0,size,size);
        artfullMusicView.backgroundColor = [UIColor clearColor];
        artfullMusicView.alpha = 0;
        [self.view insertSubview:artfullMusicView atIndex:0];
        artfullMusicView.translatesAutoresizingMaskIntoConstraints = false;
        [artfullMusicView.widthAnchor constraintEqualToConstant:size].active = true;
        [artfullMusicView.heightAnchor constraintEqualToConstant:size].active = true;
        [artfullMusicView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
        [artfullMusicView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0].active = YES;
        [artfullMusicView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0].active = YES;
        float halfView = [UIScreen mainScreen].bounds.size.height/2;
        if (isSmallDevice()) {
            [artfullMusicView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-halfView+100].active = YES;
        } else if (isLargeDevice()) {
            [artfullMusicView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-halfView+180].active = YES;
        } else {
            [artfullMusicView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-halfView+130].active = YES;
        }
    }
}

- (void)viewDidLayoutSubviews {
    %orig;
    UIView *grabberView = MSHookIvar<UIView *>(self, "grabberView");
    grabberView.hidden = YES;
    [self applyGradientMaskToView:artfullMusicView];
}

%new // New method to apply a gradient to bottom portion of UIView
- (void)applyGradientMaskToView:(UIView *)view {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    gradientLayer.colors = @[ (id)[UIColor blackColor].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor];
    gradientLayer.locations = @[@0,@0,@0.5,@0.9];
    view.layer.mask = gradientLayer;
}
%end

// Set the image to the original Apple Music Image
%hook MusicArtworkComponentImageView // iOS 16
- (void)setImage:(UIImage *)image {
    %orig;
    if ([NSStringFromClass([self.superview class]) isEqualToString:@"MusicApplication.NowPlayingContentView"]) {
        artfullMusicView.image = image;
    }
}
%end

// Set the image to the original Apple Music Image
%hook _TtC16MusicApplication25ArtworkComponentImageView // iOS 15
- (void)setImage:(UIImage *)image {
    %orig;
    if ([NSStringFromClass([self.superview class]) isEqualToString:@"MusicApplication.NowPlayingContentView"]) {
        artfullMusicView.image = image;
    }
}
%end

// Hide/show original artwork when entering/leaving now playing
%hook _TtC16MusicApplication21NowPlayingContentView
- (void)layoutSubviews {
    %orig;
    if (@available(iOS 15.0, *)) {
        NSObject *videoContext = MSHookIvar<NSObject *>(self, "videoContext");
        if (videoContext != nil) { // Music Video
            self.alpha = 1;
            artfullMusicView.alpha = 0;
        } else if (self.bounds.size.width <= 100 && self.bounds.size.width == self.bounds.size.height) { // Collapsed/Lyrics/Queue
            self.alpha = 1;
            artfullMusicView.alpha = 0;
        } else { // Now Playing
            self.alpha = 0;
            artfullMusicView.alpha = 1;
        }
    } else {
        if (self.bounds.size.width > self.bounds.size.height) { // Music Video
            self.alpha = 1;
            artfullMusicView.alpha = 0;
        } else if (self.bounds.size.width <= 100 && self.bounds.size.width == self.bounds.size.height) { // Collapsed/Lyrics/Queue
            self.alpha = 1;
            artfullMusicView.alpha = 0;
        } else { // Now Playing
            self.alpha = 0;
            artfullMusicView.alpha = 1;
        }
    }
}
%end
%end

@interface _TtC16MusicApplication17PlayerTimeControl : UIControl
@property (nonatomic) CGFloat accessibilityTotalDuration;
@property (nonatomic) CGFloat accessibilityElapsedDuration;
@property (nonatomic) UIView *elapsedTrack;
@property (nonatomic) UIView *remainingTrack;
@property (nonatomic) UIView *knobView;
- (void)adjustSizeOfTrack;
- (void)animateTrackToLarge;
- (void)animateTrackToSmall;
@end

@interface _TtCC16MusicApplication32NowPlayingControlsViewController12VolumeSlider : UISlider
@property (nonatomic) UIView *thumbView;
- (void)adjustSizeOfTrack;
- (void)animateTrackToLarge;
- (void)animateTrackToSmall;
@end

%group 15Sliders
%hook _TtC16MusicApplication17PlayerTimeControl
- (id)initWithFrame:(CGRect)arg1 primaryAction:(id)arg2 {
    id o = %orig;
    [self adjustSizeOfTrack];
    return o;
}

- (void)layoutSubviews {
    %orig;
    [self adjustSizeOfTrack];
}

- (BOOL)beginTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
    [self adjustSizeOfTrack];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
    BOOL o = %orig;
    [self adjustSizeOfTrack];
    return o;
}

- (BOOL)endTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
    BOOL o = %orig;
    [self adjustSizeOfTrack];
    return o;
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)panGesture {
    %orig;
    [self adjustSizeOfTrack];
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self animateTrackToLarge];
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self animateTrackToLarge];
    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self animateTrackToSmall];
    }
}

%new
- (void)adjustSizeOfTrack {
    CGRect elapsedTrackOrigFrame = self.elapsedTrack.frame;
    if (isSmallDevice()) {
        self.elapsedTrack.frame = CGRectMake(elapsedTrackOrigFrame.origin.x,elapsedTrackOrigFrame.origin.y,elapsedTrackOrigFrame.size.width,elapsedTrackOrigFrame.size.height+4);
    } else {
        self.elapsedTrack.frame = CGRectMake(elapsedTrackOrigFrame.origin.x,elapsedTrackOrigFrame.origin.y,elapsedTrackOrigFrame.size.width,elapsedTrackOrigFrame.size.height+5);
    }
    self.elapsedTrack.layer.cornerRadius = self.elapsedTrack.frame.size.height/2;
    self.elapsedTrack.layer.masksToBounds = YES;
    self.elapsedTrack.clipsToBounds = YES;
    
    CGRect remainingTrackOrigFrame = self.remainingTrack.frame;
    if (isSmallDevice()) {
        self.remainingTrack.frame = CGRectMake(remainingTrackOrigFrame.origin.x,remainingTrackOrigFrame.origin.y,remainingTrackOrigFrame.size.width,remainingTrackOrigFrame.size.height+4);
    } else {
        self.remainingTrack.frame = CGRectMake(remainingTrackOrigFrame.origin.x,remainingTrackOrigFrame.origin.y,remainingTrackOrigFrame.size.width,remainingTrackOrigFrame.size.height+5);
    }
    self.remainingTrack.layer.cornerRadius = self.remainingTrack.frame.size.height/2;

    self.remainingTrack.layer.masksToBounds = YES;
    self.remainingTrack.clipsToBounds = YES;
    
    self.knobView.hidden = YES;
    self.knobView.frame = CGRectMake(self.bounds.origin.x,self.bounds.origin.y,self.bounds.size.width,self.elapsedTrack.bounds.size.height);
}

%new
- (void)animateTrackToLarge {
    UIView *elapsedTimeLabel = MSHookIvar<UIView *>(self, "elapsedTimeLabel");
    UIView *remainingTimeLabel = MSHookIvar<UIView *>(self, "remainingTimeLabel");
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        self.elapsedTrack.layer.cornerRadius = self.elapsedTrack.frame.size.height/2;
        self.remainingTrack.layer.cornerRadius = self.remainingTrack.frame.size.height/2;
        self.elapsedTrack.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.70];
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.5);
        elapsedTimeLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.7);
        remainingTimeLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.7);
    } completion:nil];
}

%new
- (void)animateTrackToSmall {
    UIView *elapsedTimeLabel = MSHookIvar<UIView *>(self, "elapsedTimeLabel");
    UIView *remainingTimeLabel = MSHookIvar<UIView *>(self, "remainingTimeLabel");
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        self.elapsedTrack.layer.cornerRadius = self.elapsedTrack.frame.size.height/2;
        self.remainingTrack.layer.cornerRadius = self.remainingTrack.frame.size.height/2;
        self.elapsedTrack.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.45];
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        elapsedTimeLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        remainingTimeLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
}
%end

%hook _TtCC16MusicApplication32NowPlayingControlsViewController12VolumeSlider
- (id)initWithFrame:(CGRect)arg1 style:(NSInteger)arg2 {
    id o = %orig;
    [self adjustSizeOfTrack];
    return o;
}

-(void)setValue:(float)arg1 {
    %orig;
    [self adjustSizeOfTrack];
}

- (void)layoutSubviews {
    %orig;
    [self adjustSizeOfTrack];
}

-(void)_controlTouchBegan:(id)arg1 withEvent:(id)arg2 {
    %orig;
    [self animateTrackToLarge];
    [self adjustSizeOfTrack];
}

-(void)_controlTouchMoved:(id)arg1 withEvent:(id)arg2 {
    %orig;
    [self animateTrackToLarge];
    [self adjustSizeOfTrack];
}

-(void)_controlTouchEnded:(id)arg1 withEvent:(id)arg2 {
    %orig;
    [self animateTrackToSmall];
    [self adjustSizeOfTrack];
}

- (void)_installVisualElement:(id)arg1 {
    %orig;
    [self adjustSizeOfTrack];
}

-(CGRect)trackRectForBounds:(CGRect)arg1 {
    CGRect origBounds = %orig;
    if (isSmallDevice()) {
        origBounds.origin.y -= 2;
        origBounds.size.height += 4;
    } else {
        origBounds.origin.y -= 2.5;
        origBounds.size.height += 5;
    }
    return origBounds;
}

-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thumbRect = %orig;
    CGFloat offsetForValue = 0;
    offsetForValue = thumbRect.size.width * CGFloat(value / (self.maximumValue - self.minimumValue)) - ((value > 0) ? 10 : 10);
    thumbRect.origin.x += offsetForValue;
    return thumbRect;
}

- (BOOL)beginTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
    return YES;
}

%new
- (void)adjustSizeOfTrack {
    UIView *visualElement = MSHookIvar<UIView *>(self, "_visualElement");
    visualElement.layer.cornerRadius = visualElement.frame.size.height/2;
    visualElement.clipsToBounds = YES;
    
    UIView *minTrackView = MSHookIvar<UIView *>(visualElement, "_minTrackView");
    UIView *maxTrackView = MSHookIvar<UIView *>(visualElement, "_maxTrackView");
    minTrackView.layer.cornerRadius = minTrackView.frame.size.height/2;
    maxTrackView.layer.cornerRadius = maxTrackView.frame.size.height/2;
    if (self.value >= 0.985) {
        minTrackView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
        maxTrackView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    } else if (self.value <= 0.008) {
        minTrackView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
        maxTrackView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    } else {
        minTrackView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
        maxTrackView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    }
    minTrackView.clipsToBounds = YES;
    maxTrackView.clipsToBounds = YES;
    
    self.thumbView.hidden = YES;
}

%new
- (void)animateTrackToLarge {
    UIView *visualElement = MSHookIvar<UIView *>(self, "_visualElement");
    UIView *minValueImageView = MSHookIvar<UIView *>(visualElement, "_minValueImageView");
    UIView *maxValueImageView = MSHookIvar<UIView *>(visualElement, "_maxValueImageView");
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        minValueImageView.hidden = YES;
        maxValueImageView.hidden = YES;
        self.minimumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.70];
        visualElement.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.5);
    } completion:nil];
}

%new
- (void)animateTrackToSmall {
    UIView *visualElement = MSHookIvar<UIView *>(self, "_visualElement");
    UIView *minValueImageView = MSHookIvar<UIView *>(visualElement, "_minValueImageView");
    UIView *maxValueImageView = MSHookIvar<UIView *>(visualElement, "_maxValueImageView");
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        minValueImageView.hidden = NO;
        maxValueImageView.hidden = NO;
        self.minimumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.45];
        visualElement.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
}
%end
%end

@interface MRUNowPlayingTimeControlsView : UIControl
@property (nonatomic) CGFloat accessibilityTotalDuration;
@property (nonatomic) CGFloat accessibilityElapsedDuration;
@property (nonatomic) UIView *elapsedTrack;
@property (nonatomic) UIView *remainingTrack;
@property (nonatomic) UIView *knobView;
- (void)adjustSizeOfTrack;
- (void)animateTrackToLarge;
- (void)animateTrackToSmall;
- (void)setMaskedCornersForSlider;
@end

@interface MRUNowPlayingVolumeSlider : UISlider
@property (nonatomic) UIView *growingThumbView;
@property (nonatomic) UIView *thumbView;
- (void)adjustSizeOfTrack;
- (void)animateTrackToLarge;
- (void)animateTrackToSmall;
@end

%group SpringBoard
%hook MRUNowPlayingTimeControlsView
- (id)initWithFrame:(CGRect)arg1 primaryAction:(id)arg2 {
    id o = %orig;
    [self adjustSizeOfTrack];
    return o;
}

- (void)layoutSubviews {
    %orig;
    [self adjustSizeOfTrack];
}

- (BOOL)beginTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
    [self animateTrackToLarge];
    [self adjustSizeOfTrack];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
    BOOL o = %orig;
    [self animateTrackToLarge];
    [self adjustSizeOfTrack];
    return o;
}

- (BOOL)endTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
    BOOL o = %orig;
    [self animateTrackToSmall];
    [self adjustSizeOfTrack];
    return o;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    return CGRectContainsPoint(bounds, point);
}

- (void)setElapsedTimeFactor:(CGFloat)arg1 {
    %orig;
    [self setMaskedCornersForSlider];
}

- (void)updateElapsedTime {
    %orig;
    [self setMaskedCornersForSlider];
}

%new
- (void)adjustSizeOfTrack {
    CGRect elapsedTrackOrigFrame = self.elapsedTrack.frame;
    if (isSmallDevice()) {
        self.elapsedTrack.frame = CGRectMake(elapsedTrackOrigFrame.origin.x,elapsedTrackOrigFrame.origin.y,elapsedTrackOrigFrame.size.width,elapsedTrackOrigFrame.size.height+4);
    } else {
        self.elapsedTrack.frame = CGRectMake(elapsedTrackOrigFrame.origin.x,elapsedTrackOrigFrame.origin.y,elapsedTrackOrigFrame.size.width,elapsedTrackOrigFrame.size.height+5);
    }
    self.elapsedTrack.layer.masksToBounds = YES;
    self.elapsedTrack.layer.cornerRadius = self.elapsedTrack.frame.size.height/2;
    self.elapsedTrack.clipsToBounds = YES;
    
    CGRect remainingTrackOrigFrame = self.remainingTrack.frame;
    if (isSmallDevice()) {
        self.remainingTrack.frame = CGRectMake(remainingTrackOrigFrame.origin.x,remainingTrackOrigFrame.origin.y,remainingTrackOrigFrame.size.width,remainingTrackOrigFrame.size.height+4);
    } else {
        self.remainingTrack.frame = CGRectMake(remainingTrackOrigFrame.origin.x,remainingTrackOrigFrame.origin.y,remainingTrackOrigFrame.size.width,remainingTrackOrigFrame.size.height+5);
    }
    self.remainingTrack.layer.masksToBounds = YES;
    self.remainingTrack.layer.cornerRadius = self.remainingTrack.frame.size.height/2;
    self.remainingTrack.clipsToBounds = YES;
    
    self.knobView.hidden = YES;
    self.knobView.frame = CGRectMake(self.bounds.origin.x,self.bounds.origin.y,self.bounds.size.width,self.elapsedTrack.bounds.size.height);
    
    [self setMaskedCornersForSlider];
}

%new
- (void)setMaskedCornersForSlider {
    CGFloat elapsedTimeFactor = MSHookIvar<CGFloat>(self, "_elapsedTimeFactor");
    
    if (elapsedTimeFactor <= 0.008) {
        self.elapsedTrack.layer.maskedCorners = self.elapsedTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
        self.remainingTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    } else if (elapsedTimeFactor >= 0.985) {
        self.elapsedTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
        self.remainingTrack.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    } else {
        self.elapsedTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
        self.remainingTrack.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    }
}

%new
- (void)animateTrackToLarge {
    UIView *elapsedTimeLabel = MSHookIvar<UIView *>(self, "_elapsedTimeLabel");
    UIView *remainingTimeLabel = MSHookIvar<UIView *>(self, "_remainingTimeLabel");
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.5);
        elapsedTimeLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.7);
        remainingTimeLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.7);
    } completion:nil];
}

%new
- (void)animateTrackToSmall {
    UIView *elapsedTimeLabel = MSHookIvar<UIView *>(self, "_elapsedTimeLabel");
    UIView *remainingTimeLabel = MSHookIvar<UIView *>(self, "_remainingTimeLabel");
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        elapsedTimeLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        remainingTimeLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
}
%end

%hook MRUNowPlayingVolumeSlider
- (id)initWithFrame:(CGRect)arg1 style:(NSInteger)arg2 {
    id o = %orig;
    [self adjustSizeOfTrack];
    return o;
}

-(void)setValue:(float)arg1 {
    %orig;
    [self adjustSizeOfTrack];
}

- (void)layoutSubviews {
    %orig;
    [self adjustSizeOfTrack];
}

-(void)_controlTouchBegan:(id)arg1 withEvent:(id)arg2 {
    %orig;
    [self animateTrackToLarge];
    [self adjustSizeOfTrack];
}

-(void)_controlTouchMoved:(id)arg1 withEvent:(id)arg2 {
    %orig;
    [self animateTrackToLarge];
    [self adjustSizeOfTrack];
}

-(void)_controlTouchEnded:(id)arg1 withEvent:(id)arg2 {
    %orig;
    [self animateTrackToSmall];
    [self adjustSizeOfTrack];
}

- (void)_installVisualElement:(id)arg1 {
    %orig;
    [self adjustSizeOfTrack];
}

-(CGRect)trackRectForBounds:(CGRect)arg1 {
    CGRect origBounds = %orig;
    if (isSmallDevice()) {
        origBounds.origin.y -= 2;
        origBounds.size.height += 4;
    } else {
        origBounds.origin.y -= 2.5;
        origBounds.size.height += 5;
    }
    return origBounds;
}

-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thumbRect = %orig;
    CGFloat offsetForValue = 0;
    offsetForValue = thumbRect.size.width * CGFloat(value / (self.maximumValue - self.minimumValue)) - ((value > 0) ? 10 : 10);
    thumbRect.origin.x += offsetForValue;
    return thumbRect;
}

- (BOOL)beginTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
    return YES;
}

%new
- (void)adjustSizeOfTrack {
    UIView *visualElement = MSHookIvar<UIView *>(self, "_visualElement");
    visualElement.layer.cornerRadius = visualElement.frame.size.height/2;
    visualElement.clipsToBounds = YES;
    
    UIView *minTrackView = MSHookIvar<UIView *>(visualElement, "_minTrackView");
    UIView *maxTrackView = MSHookIvar<UIView *>(visualElement, "_maxTrackView");
    minTrackView.layer.cornerRadius = minTrackView.frame.size.height/2;
    maxTrackView.layer.cornerRadius = maxTrackView.frame.size.height/2;
    if (self.value >= 0.985) {
        minTrackView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
        maxTrackView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    } else if (self.value <= 0.008) {
        minTrackView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
        maxTrackView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    } else {
        minTrackView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
        maxTrackView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    }
    minTrackView.clipsToBounds = YES;
    maxTrackView.clipsToBounds = YES;
    
    self.thumbView.hidden = YES;
    self.thumbView.frame = CGRectZero;
    self.growingThumbView.hidden = YES;
    self.growingThumbView.frame = CGRectZero;
}

%new
- (void)animateTrackToLarge {
    UIView *visualElement = MSHookIvar<UIView *>(self, "_visualElement");
    UIView *minValueImageView = MSHookIvar<UIView *>(visualElement, "_minValueImageView");
    UIView *maxValueImageView = MSHookIvar<UIView *>(visualElement, "_maxValueImageView");
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        minValueImageView.hidden = YES;
        maxValueImageView.hidden = YES;
        visualElement.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.5);
    } completion:nil];
}

%new
- (void)animateTrackToSmall {
    UIView *visualElement = MSHookIvar<UIView *>(self, "_visualElement");
    UIView *minValueImageView = MSHookIvar<UIView *>(visualElement, "_minValueImageView");
    UIView *maxValueImageView = MSHookIvar<UIView *>(visualElement, "_maxValueImageView");
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        minValueImageView.hidden = NO;
        maxValueImageView.hidden = NO;
        visualElement.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
}
%end
%end

%ctor {
    if (![NSProcessInfo processInfo]) return;
    NSString *processName = [NSProcessInfo processInfo].processName;
    if ([processName isEqualToString:@"Music"]) {
        if (SYSTEM_VERSION_LESS_THAN(@"16.0")) %init(15Sliders);
        %init(Music);
        return;
    } else if ([processName isEqualToString:@"SpringBoard"]) {
        if (SYSTEM_VERSION_LESS_THAN(@"16.0")) %init(SpringBoard);
        return;
    }
}
