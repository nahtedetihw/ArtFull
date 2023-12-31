#import "Shared.h"

BOOL isSmallDeviceMusic() {
    if ([UIScreen mainScreen].nativeBounds.size.width <= 750) return YES;
    return NO;
}

BOOL isLargeDeviceMusic() {
    if ([UIScreen mainScreen].nativeBounds.size.width >= 1284) return YES;
    return NO;
}

BOOL isiPad() {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return NO;
}

UIImageView *artfullMusicView;

%group Music
%hook MusicNowPlayingControlsViewController
- (void)viewDidLoad {
    %orig;
    UIView *grabberView = MSHookIvar<UIView *>(self, "grabberView");
    grabberView.hidden = YES;
    
    if (isiPad()) {
        [self applyArtfullViewOniPad];
    } else {
        [self applyArtfullView];
    }
}

- (void)viewDidLayoutSubviews {
    %orig;
    UIView *grabberView = MSHookIvar<UIView *>(self, "grabberView");
    grabberView.hidden = YES;
    
    [self applyGradientMaskToView:artfullMusicView];
}

%new
- (void)applyArtfullView {
    UIView *contentView = MSHookIvar<UIView *>(self, "mainContainerView");
    
    if (contentView) {
        artfullMusicView = [UIImageView new];
        artfullMusicView.contentMode = UIViewContentModeScaleAspectFill;
        artfullMusicView.frame = contentView.bounds;
        artfullMusicView.backgroundColor = [UIColor clearColor];
        artfullMusicView.alpha = 1;
        [self.view insertSubview:artfullMusicView atIndex:0];
        
        artfullMusicView.translatesAutoresizingMaskIntoConstraints = false;
        [artfullMusicView.widthAnchor constraintEqualToConstant:contentView.bounds.size.width].active = true;
        [artfullMusicView.heightAnchor constraintEqualToConstant:contentView.bounds.size.width].active = true;
        [artfullMusicView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:0].active = YES;
        [artfullMusicView.rightAnchor constraintEqualToAnchor:contentView.rightAnchor constant:0].active = YES;
        [artfullMusicView.leftAnchor constraintEqualToAnchor:contentView.leftAnchor constant:0].active = YES;
        float halfView = [UIScreen mainScreen].bounds.size.height/2;
        if (isSmallDeviceMusic()) {
            [artfullMusicView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-halfView+100].active = YES;
        } else if (isLargeDeviceMusic()) {
            [artfullMusicView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-halfView+180].active = YES;
        } else {
            [artfullMusicView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-halfView+130].active = YES;
        }
    }
}

%new
- (void)applyArtfullViewOniPad {
    UIView *contentView = MSHookIvar<UIView *>(self, "mainContainerView");
    
    if (contentView) {
        artfullMusicView = [UIImageView new];
        artfullMusicView.contentMode = UIViewContentModeScaleAspectFill;
        artfullMusicView.frame = contentView.frame;
        artfullMusicView.backgroundColor = [UIColor clearColor];
        artfullMusicView.alpha = 1;
        [contentView insertSubview:artfullMusicView atIndex:0];
        
        artfullMusicView.translatesAutoresizingMaskIntoConstraints = false;
        [artfullMusicView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:0].active = YES;
        [artfullMusicView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-150].active = YES;
        [artfullMusicView.rightAnchor constraintEqualToAnchor:contentView.rightAnchor constant:65].active = YES;
        [artfullMusicView.leftAnchor constraintEqualToAnchor:contentView.leftAnchor constant:-55].active = YES;
        
        float halfView = [UIScreen mainScreen].bounds.size.height/2;
        if (isSmallDeviceMusic()) {
            [artfullMusicView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-halfView+100].active = YES;
        } else if (isLargeDeviceMusic()) {
            [artfullMusicView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-halfView+180].active = YES;
        } else {
            [artfullMusicView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-halfView+130].active = YES;
        }
    }
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
    if (isSmallDeviceMusic()) {
        self.elapsedTrack.frame = CGRectMake(elapsedTrackOrigFrame.origin.x,elapsedTrackOrigFrame.origin.y,elapsedTrackOrigFrame.size.width,elapsedTrackOrigFrame.size.height+4);
    } else {
        self.elapsedTrack.frame = CGRectMake(elapsedTrackOrigFrame.origin.x,elapsedTrackOrigFrame.origin.y,elapsedTrackOrigFrame.size.width,elapsedTrackOrigFrame.size.height+5);
    }
    self.elapsedTrack.layer.cornerRadius = self.elapsedTrack.frame.size.height/2;
    self.elapsedTrack.layer.masksToBounds = YES;
    self.elapsedTrack.clipsToBounds = YES;
    
    CGRect remainingTrackOrigFrame = self.remainingTrack.frame;
    if (isSmallDeviceMusic()) {
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
    if (isSmallDeviceMusic()) {
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
    if (self.value >= 0.995) {
        minTrackView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
        maxTrackView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    } else if (self.value <= 0.005) {
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

%ctor {
    if (![NSProcessInfo processInfo]) return;
    NSString *processName = [NSProcessInfo processInfo].processName;
    if ([processName isEqualToString:@"Music"]) {
        if (SYSTEM_VERSION_LESS_THAN(@"16.0")) %init(15Sliders);
        %init(Music);
        return;
    }
}
