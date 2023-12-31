#import "Shared.h"

BOOL isSmallDevicePodcasts() {
    if ([UIScreen mainScreen].nativeBounds.size.width <= 750) return YES;
    return NO;
}

BOOL isLargeDevicePodcasts() {
    if ([UIScreen mainScreen].nativeBounds.size.width >= 1284) return YES;
    return NO;
}

UIImageView *artfullPodcastsView;
UIImageView *artfullBackgroundView;
_UIBackdropView *artfullBlurView;

%group Podcasts
%hook MusicNowPlayingControlsViewController
- (void)viewDidLoad {
    %orig;
    UIView *chevronView = MSHookIvar<UIView *>(self, "chevronView");
    chevronView.hidden = YES;
    
    if (self.view) {
        artfullBackgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        artfullBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
        artfullBackgroundView.alpha = 0;
        [self.view insertSubview:artfullBackgroundView atIndex:0];
        
        artfullBackgroundView.translatesAutoresizingMaskIntoConstraints = false;
        [artfullBackgroundView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
        [artfullBackgroundView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0].active = YES;
        [artfullBackgroundView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0].active = YES;
        [artfullBackgroundView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
        
        _UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:4005];
        artfullBlurView = [[_UIBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:settings];
        artfullBlurView.alpha = 0;
        [self.view insertSubview:artfullBlurView aboveSubview:artfullBackgroundView];
        
        artfullPodcastsView = [UIImageView new];
        artfullPodcastsView.contentMode = UIViewContentModeScaleAspectFill;
        float size = self.view.bounds.size.width;
        artfullPodcastsView.frame = CGRectMake(0,0,size,size);
        artfullPodcastsView.backgroundColor = [UIColor clearColor];
        artfullPodcastsView.alpha = 0;
        [self.view insertSubview:artfullPodcastsView atIndex:3];
        artfullPodcastsView.translatesAutoresizingMaskIntoConstraints = false;
        [artfullPodcastsView.widthAnchor constraintEqualToConstant:size].active = true;
        [artfullPodcastsView.heightAnchor constraintEqualToConstant:size].active = true;
        [artfullPodcastsView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
        [artfullPodcastsView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0].active = YES;
        [artfullPodcastsView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0].active = YES;
        float halfView = [UIScreen mainScreen].bounds.size.height/2;
        if (isSmallDevicePodcasts()) {
            [artfullPodcastsView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-halfView+100].active = YES;
        } else if (isLargeDevicePodcasts()) {
            [artfullPodcastsView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-halfView+180].active = YES;
        } else {
            [artfullPodcastsView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-halfView+130].active = YES;
        }
    }
}

- (void)viewDidLayoutSubviews {
    %orig;
    UIView *chevronView = MSHookIvar<UIView *>(self, "chevronView");
    chevronView.hidden = YES;
    [self applyGradientMaskToView:artfullPodcastsView];
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
%hook _TtC12NowPlayingUI25ArtworkComponentImageView // iOS 15
- (void)setImage:(UIImage *)image {
    %orig;
    if ([NSStringFromClass([self.superview class]) isEqualToString:@"NowPlayingUI.NowPlayingContentView"]) {
        artfullPodcastsView.image = image;
        artfullBackgroundView.image = image;
    }
}
%end

// Hide/show original artwork when entering/leaving now playing
%hook _TtC12NowPlayingUI21NowPlayingContentView
- (void)layoutSubviews {
    %orig;
    if (self.bounds.size.width > self.bounds.size.height) { // Music Video
        self.alpha = 1;
        artfullPodcastsView.alpha = 0;
        artfullBackgroundView.alpha = 0;
        artfullBlurView.alpha = 0;
    } else if (self.bounds.size.width <= 100 && self.bounds.size.width == self.bounds.size.height) { // Collapsed/Lyrics/Queue
        self.alpha = 1;
        artfullPodcastsView.alpha = 0;
        artfullBackgroundView.alpha = 0;
        artfullBlurView.alpha = 0;
    } else { // Now Playing
        self.alpha = 0;
        artfullPodcastsView.alpha = 1;
        artfullBackgroundView.alpha = 1;
        artfullBlurView.alpha = 1;
    }
}
%end
%end

%group 15SlidersPodcasts
%hook _TtC12NowPlayingUI17PlayerTimeControl
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

- (void)endTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
    %orig;
    [self adjustSizeOfTrack];
}

- (void)setTracking:(BOOL)arg1 {
    %orig;
    [self adjustSizeOfTrack];
    if (arg1) {
        [self animateTrackToLarge];
    } else {
        [self animateTrackToSmall];
    }
}

-(CGRect)thumbHitRect {
    CGRect thumbRect = %orig;
    CGFloat offsetForValue = 0;
    offsetForValue = thumbRect.size.width * CGFloat(self.value / (self.maximumValue - self.minimumValue)) - ((self.value > 0) ? 10 : 10);
    thumbRect.origin.x += offsetForValue;
    return thumbRect;
}

%new
- (void)adjustSizeOfTrack {
    CGRect elapsedTrackOrigFrame = self.elapsedTrack.frame;
    if (isSmallDevicePodcasts()) {
        self.elapsedTrack.frame = CGRectMake(elapsedTrackOrigFrame.origin.x,elapsedTrackOrigFrame.origin.y,elapsedTrackOrigFrame.size.width,elapsedTrackOrigFrame.size.height+4);
    } else {
        self.elapsedTrack.frame = CGRectMake(elapsedTrackOrigFrame.origin.x,elapsedTrackOrigFrame.origin.y,elapsedTrackOrigFrame.size.width,elapsedTrackOrigFrame.size.height+5);
    }
    self.elapsedTrack.layer.cornerRadius = self.elapsedTrack.frame.size.height/2;
    self.elapsedTrack.layer.masksToBounds = YES;
    self.elapsedTrack.clipsToBounds = YES;
    
    CGRect remainingTrackOrigFrame = self.remainingTrack.frame;
    if (isSmallDevicePodcasts()) {
        self.remainingTrack.frame = CGRectMake(remainingTrackOrigFrame.origin.x,remainingTrackOrigFrame.origin.y,remainingTrackOrigFrame.size.width,remainingTrackOrigFrame.size.height+4);
    } else {
        self.remainingTrack.frame = CGRectMake(remainingTrackOrigFrame.origin.x,remainingTrackOrigFrame.origin.y,remainingTrackOrigFrame.size.width,remainingTrackOrigFrame.size.height+5);
    }
    self.remainingTrack.layer.cornerRadius = self.remainingTrack.frame.size.height/2;

    self.remainingTrack.layer.masksToBounds = YES;
    self.remainingTrack.clipsToBounds = YES;
    
    CGRect bufferTrackOrigFrame = self.bufferTrack.frame;
    if (isSmallDevicePodcasts()) {
        self.bufferTrack.frame = CGRectMake(bufferTrackOrigFrame.origin.x,bufferTrackOrigFrame.origin.y,bufferTrackOrigFrame.size.width,bufferTrackOrigFrame.size.height+4);
    } else {
        self.bufferTrack.frame = CGRectMake(bufferTrackOrigFrame.origin.x,bufferTrackOrigFrame.origin.y,bufferTrackOrigFrame.size.width,bufferTrackOrigFrame.size.height+5);
    }
    self.bufferTrack.layer.cornerRadius = self.bufferTrack.frame.size.height/2;
    self.bufferTrack.layer.masksToBounds = YES;
    self.bufferTrack.clipsToBounds = YES;
    
    if (self.accessibilityTotalDuration == self.accessibilityElapsedDuration) {
        self.elapsedTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
        self.remainingTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
        self.bufferTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    } else if (self.accessibilityElapsedDuration >= self.accessibilityTotalDuration - 0.05) {
        self.elapsedTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
        self.remainingTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
        self.bufferTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    } else if (self.accessibilityElapsedDuration <= 0.05) {
        self.elapsedTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
        self.remainingTrack.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
        self.bufferTrack.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    } else {
        self.elapsedTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
        self.remainingTrack.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
        self.bufferTrack.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    }
    
    self.knobView.hidden = YES;
    self.knobView.frame = CGRectMake(self.bounds.origin.x,self.bounds.origin.y,5,self.elapsedTrack.bounds.size.height);
    
    self.accessibilityKnobView.hidden = YES;
    self.accessibilityKnobView.frame = CGRectMake(self.bounds.origin.x,self.bounds.origin.y,5,self.elapsedTrack.bounds.size.height);
    self.accessibilityKnobView.alpha = 0;
    
    if (@available(iOS 15.0, *)) {
        UIView *knobKnockoutView = MSHookIvar<UIView *>(self, "knobKnockoutView");
        knobKnockoutView.hidden = YES;
        knobKnockoutView.alpha = 0;
    }
    
    self.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.30];
    
    if (self.tracking) {
        [self animateTrackToLarge];
    } else {
        [self animateTrackToSmall];
    }
    
    self.remainingTrack.alpha = 0.5;
    self.bufferTrack.alpha = 1;
}

%new
- (void)animateTrackToLarge {
    UIView *elapsedTimeLabel = MSHookIvar<UIView *>(self, "elapsedTimeLabel");
    UIView *remainingTimeLabel = MSHookIvar<UIView *>(self, "remainingTimeLabel");
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        self.elapsedTrack.layer.cornerRadius = self.elapsedTrack.frame.size.height/2;
        self.remainingTrack.layer.cornerRadius = self.remainingTrack.frame.size.height/2;
        self.bufferTrack.layer.cornerRadius = self.bufferTrack.frame.size.height/2;
        self.elapsedTrack.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.70];
        self.remainingTrack.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.50];
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
        self.bufferTrack.layer.cornerRadius = self.bufferTrack.frame.size.height/2;
        self.elapsedTrack.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.45];
        self.remainingTrack.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        elapsedTimeLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        remainingTimeLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
}
%end

%hook _TtC12NowPlayingUI16VolumeSlider_iOS
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
    if (isSmallDevicePodcasts()) {
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
    
    maxTrackView.alpha = 0.5;
    
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
        self.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.50];
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
        self.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.30];
        visualElement.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
}
%end
%end

%ctor {
    if (![NSProcessInfo processInfo]) return;
    NSString *processName = [NSProcessInfo processInfo].processName;
    if ([processName isEqualToString:@"Podcasts"]) {
        if (SYSTEM_VERSION_LESS_THAN(@"16.0")) %init(15SlidersPodcasts);
        %init(Podcasts);
        return;
    }
}
