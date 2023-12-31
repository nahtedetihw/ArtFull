#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface _UIBackdropView : UIView
-(id)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3 ;
@property (assign,nonatomic) BOOL blurRadiusSetOnce;
@property (assign,nonatomic) double _blurRadius;
@property (nonatomic,copy) NSString * _blurQuality;
@property (nonatomic, retain) UIView *effectView;
-(id)initWithSettings:(id)arg1 ;
@end

@interface _UIBackdropViewSettings : NSObject
@property (nonatomic,retain) UIColor * colorTint;
+(id)settingsForStyle:(long long)arg1 ;
@end

@interface _TtC11MusicCoreUI15PassthroughView : UIView
- (void)applyGradientMaskToView:(UIView *)view;
- (void)setArtfullConstraints;
@end

@interface MusicNowPlayingControlsViewController : UIViewController
- (void)applyGradientMaskToView:(UIView *)view;
- (void)applyArtfullView;
- (void)applyArtfullViewOniPad;
@end

@interface _TtC16MusicApplication21NowPlayingContentView : UIView
@end

@interface MusicArtworkComponentImageView : UIImageView
@end

@interface _TtC16MusicApplication25ArtworkComponentImageView : UIImageView
@end

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

@interface _TtC12NowPlayingUI21NowPlayingContentView : UIView
@end

@interface _TtC12NowPlayingUI25ArtworkComponentImageView : UIImageView
@end

@interface _TtC12NowPlayingUI17PlayerTimeControl : UIControl
@property (nonatomic) CGFloat accessibilityTotalDuration;
@property (nonatomic) CGFloat accessibilityElapsedDuration;
@property (nonatomic) UIView *elapsedTrack;
@property (nonatomic) UIView *remainingTrack;
@property (nonatomic) UIView *bufferTrack;
@property (nonatomic) UIView *knobView;
@property (nonatomic) UIView *accessibilityKnobView;
@property (nonatomic) CGFloat value;
@property (nonatomic) CGFloat minimumValue;
@property (nonatomic) CGFloat maximumValue;
- (void)adjustSizeOfTrack;
- (void)animateTrackToLarge;
- (void)animateTrackToSmall;
@end

@interface _TtC12NowPlayingUI16VolumeSlider_iOS : UISlider
@property (nonatomic) UIView *thumbView;
- (void)adjustSizeOfTrack;
- (void)animateTrackToLarge;
- (void)animateTrackToSmall;
@end
