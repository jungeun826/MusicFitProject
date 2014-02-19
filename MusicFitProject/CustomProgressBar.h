/*
 * YLProgressBar.h
 *
 * Copyright 2012-2013 Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

typedef NS_ENUM (NSUInteger, YLProgressBarBehavior){
    /**
     * The default behavior of a progress bar. This mode is identical to the
     * UIProgressView.
     */
    YLProgressBarBehaviorDefault       = 0,
    /**
     * The indeterminate behavior display the stripes when the progress value
     * is equal to 0 only. This mode is helpful when percentage is not yet
     * known, but will be known shortly.
     */
    YLProgressBarBehaviorIndeterminate = 1,
    /**
     * The waiting behavior display the stripes when the progress value is
     * equal to 1 only.
     */
    YLProgressBarBehaviorWaiting       = 2,
};

/**
 * The display mode of the indicator text.
 */
typedef NS_ENUM (NSUInteger, YLProgressBarIndicatorTextDisplayMode){
    /**
     * The indicator text is not displayed.
     */
    YLProgressBarIndicatorTextDisplayModeNone      = 0,
    /**
     * The indicator text is displayed over the track bar and below the
     * progress bar.
     */
    YLProgressBarIndicatorTextDisplayModeTrack     = 1,
    /**
     * The indicator text is diplayed over the progress bar.
     */
    YLProgressBarIndicatorTextDisplayModeProgress  = 2,
};

@interface CustomProgressBar : UIView

@property (atomic, assign) CGFloat  progress;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@property (nonatomic, assign) YLProgressBarBehavior behavior; //UI_APPEARANCE_SELECTOR;
@property (nonatomic, getter = isStripesAnimated) BOOL  stripesAnimated;
@property (nonatomic, assign) NSInteger stripesWidth; //UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *stripesColor; //UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL hideStripes;
@property (nonatomic, strong) NSArray   *progressTintColors; //UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor   *progressTintColor; //UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor   *trackTintColor; //UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UILabel *indicatorTextLabel;
@property (nonatomic, assign) YLProgressBarIndicatorTextDisplayMode indicatorTextDisplayMode; //UI_APPEARANCE_SELECTOR;

@end
