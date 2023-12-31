#import "Shared.h"

BOOL isSmallDeviceSB() {
    if ([UIScreen mainScreen].nativeBounds.size.width <= 750) return YES;
    return NO;
}

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
    if (isSmallDeviceSB()) {
        self.elapsedTrack.frame = CGRectMake(elapsedTrackOrigFrame.origin.x,elapsedTrackOrigFrame.origin.y,elapsedTrackOrigFrame.size.width,elapsedTrackOrigFrame.size.height+4);
    } else {
        self.elapsedTrack.frame = CGRectMake(elapsedTrackOrigFrame.origin.x,elapsedTrackOrigFrame.origin.y,elapsedTrackOrigFrame.size.width,elapsedTrackOrigFrame.size.height+5);
    }
    self.elapsedTrack.layer.masksToBounds = YES;
    self.elapsedTrack.layer.cornerRadius = self.elapsedTrack.frame.size.height/2;
    self.elapsedTrack.clipsToBounds = YES;
    
    CGRect remainingTrackOrigFrame = self.remainingTrack.frame;
    if (isSmallDeviceSB()) {
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
    
    if (elapsedTimeFactor <= 0.005) {
        self.elapsedTrack.layer.maskedCorners = self.elapsedTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
        self.remainingTrack.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    } else if (elapsedTimeFactor >= 0.995) {
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
    if (isSmallDeviceSB()) {
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
    if ([processName isEqualToString:@"SpringBoard"]) {
        if (SYSTEM_VERSION_LESS_THAN(@"16.0")) %init(SpringBoard);
        return;
    }
}
