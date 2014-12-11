//
//  KeyboardViewController.m
//  ASCIIboard
//
//  Created by Matt Condon on 9/22/14.
//  Copyright (c) 2014 Shrugs. All rights reserved.
//

#import "KeyboardViewController.h"
#import "Masonry.h"
#import "UIImage+ASCII.h"
#import <LIVBubbleMenu/LIVBubbleMenu.h>

#define BRUSH_SIZE_SMALL 8.0f
#define BRUSH_SIZE_MEDIUM 11.0f
#define BRUSH_SIZE_LARGE 15.0f

#define ASCIIBOARD_LANDSCAPE_HEIGHT 203
#define ASCIIBOARD_PORTRAIT_HEIGHT 256


@interface KeyboardViewController () <LIVBubbleButtonDelegate>
{
    LIVBubbleMenu *brushMenu;
}



@property (nonatomic, strong) UIButton    *brushButton;
@property (nonatomic, strong) UIButton    *nextKeyboardButton;
@property (nonatomic, strong) UIButton    *clearButton;
@property (nonatomic, strong) UIButton    *enterButton;
@property (nonatomic, strong) UIButton    *backspaceButton;
// @property (nonatomic, strong) UIButton    *undoButton;
@property (nonatomic, strong) UIImageView *drawImage;
@property (nonatomic) float brushSize;

@property (nonatomic, retain) NSArray *brushImagesArray;


// array of characters that were inserted (I should use a queue for this)
@property (nonatomic, strong) NSMutableArray *insertHistory;
// array of lines drawn that they can undo
@property (nonatomic, strong) NSMutableArray *drawHistory;

@end

@implementation KeyboardViewController

- (void)viewDidLoad {
    NSLog(@"VIEW DID LOAD");

    [super viewDidLoad];

    // set bg color
    [self.view setBackgroundColor:[UIColor whiteColor]];

    // setup draw image
    self.drawImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.drawImage setBackgroundColor:[UIColor whiteColor]];
    self.drawImage.layer.masksToBounds = NO;
    self.drawImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.drawImage.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.drawImage.layer.shadowOpacity = 0.5f;
    self.drawImage.layer.shadowRadius = 5.0f;
    [self.view addSubview:self.drawImage];

    [self.drawImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.view);
        make.width.equalTo(self.drawImage.mas_height).multipliedBy(0.9);
        make.center.equalTo(self.view);
    }];

    // set up top border thing
    UIView *borderView = [[UIView alloc] init];
    [borderView setBackgroundColor:[UIColor blackColor]];
    borderView.alpha = 0.1f;
    [self.view addSubview:borderView];

    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(1.0f));
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
    }];

    // NEXT BUTTON
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextKeyboardButton setImage:[UIImage imageNamed:@"Globe-Button-Up.png"] forState:UIControlStateNormal];
    [self.nextKeyboardButton setImage:[UIImage imageNamed:@"Globe-Button-Down.png"] forState:UIControlStateHighlighted];
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];

    // BRUSH BUTTON
    self.brushButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.brushButton setImage:[UIImage imageNamed:@"Edit-Button-Up.png"] forState:UIControlStateNormal];
    [self.brushButton setImage:[UIImage imageNamed:@"Edit-Button-Down.png"] forState:UIControlStateHighlighted];
    [self.brushButton addTarget:self action:@selector(brushButtonPressed:) forControlEvents:UIControlEventTouchDown];

    // CLEAR BUTTON
    self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clearButton setImage:[UIImage imageNamed:@"Clear-Button-Up.png"] forState:UIControlStateNormal];
    [self.clearButton setImage:[UIImage imageNamed:@"Clear-Button-Down.png"] forState:UIControlStateHighlighted];
    [self.clearButton addTarget:self action:@selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    // ENTER BUTTON
    self.enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.enterButton setImage:[UIImage imageNamed:@"Up-Button-Up.png"] forState:UIControlStateNormal];
    [self.enterButton setImage:[UIImage imageNamed:@"Up-Button-Down.png"] forState:UIControlStateHighlighted];
    [self.enterButton addTarget:self action:@selector(enterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    // BACKSPACE BUTTON
    self.backspaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backspaceButton setImage:[UIImage imageNamed:@"Delete-Button-Up.png"] forState:UIControlStateNormal];
    [self.backspaceButton setImage:[UIImage imageNamed:@"Delete-Button-Down.png"] forState:UIControlStateHighlighted];
    [self.backspaceButton addTarget:self action:@selector(backspaceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    // UNDO BUTTON
    // self.undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // [self.undoButton setImage:[UIImage imageNamed:@"Undo-Button-Up.png"] forState:UIControlStateNormal];
    // [self.undoButton setImage:[UIImage imageNamed:@"Undo-Button-Down.png"] forState:UIControlStateHighlighted];
    // [self.undoButton addTarget:self action:@selector(undoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.nextKeyboardButton];
    [self.view addSubview:self.brushButton];
    [self.view addSubview:self.clearButton];
    [self.view addSubview:self.enterButton];
    [self.view addSubview:self.backspaceButton];
    // [self.view addSubview:self.undoButton];

    [self establishConstraints];

    self.insertHistory = [[NSMutableArray alloc] init];
    self.brushSize = 10.0;

    self.brushImagesArray = [NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"Brush-Button-Up-1.png"],
                                 [UIImage imageNamed:@"Brush-Button-Up-2.png"],
                                 [UIImage imageNamed:@"Brush-Button-Up-3.png"],
                                 nil];

}

- (void)establishPortraitIPhoneConstraints
{
    [self.brushButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.view.mas_height).multipliedBy(0.25*0.95);
        make.width.equalTo(self.brushButton.mas_height);
        make.left.equalTo(self.view).offset(2);
        make.top.equalTo(self.view).offset(2);
    }];
    [self.nextKeyboardButton mas_remakeConstraints:^(MASConstraintMaker *make){
        make.height.equalTo(self.view.mas_height).multipliedBy(0.25*0.95);
        make.width.equalTo(self.nextKeyboardButton.mas_height);
        make.left.equalTo(self.view.mas_left).offset(2);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [self.enterButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.view.mas_height).multipliedBy(0.25*0.95);
        make.width.equalTo(self.enterButton.mas_height);
        make.right.equalTo(self.view).offset(-2);
        make.top.equalTo(self.view).offset(2);
    }];
    [self.backspaceButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.view.mas_height).multipliedBy(0.25*0.95);
        make.width.equalTo(self.backspaceButton.mas_height);
        make.right.equalTo(self.enterButton.mas_right);
        make.top.equalTo(self.enterButton.mas_bottom).offset(2);
    }];
    // [self.undoButton mas_remakeConstraints:^(MASConstraintMaker *make) {
    //     make.height.equalTo(self.view.mas_height).multipliedBy(0.25*0.95);
    //     make.width.equalTo(self.undoButton.mas_height);
    //     make.right.equalTo(self.clearButton.mas_right);
    //     make.bottom.equalTo(self.clearButton.mas_top).offset(-2);
    // }];
    [self.clearButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.view.mas_height).multipliedBy(0.25*0.95);
        make.width.equalTo(self.clearButton.mas_height);
        make.right.equalTo(self.enterButton.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

- (void)updateViewConstraints {

    [super updateViewConstraints];

    // Add custom view sizing constraints here
    // if (self.view.frame.size.width == 0 || self.view.frame.size.height == 0) {
    //     return;
    // }

    NSLog(@"UPDATE VIEW CONSTRAINTS");
    [self establishConstraints];


}

- (void)establishConstraints
{
    // @TODO(Shrugs) make iphone only?
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSLog(@"[DEBUG] determineKeyboardNib: Enter iPad");
        // iPad
        if (self.view.frame.size.width > 1000) {
            NSLog(@"[DEBUG] determineKeyboardNib: Enter iPad Landscape");
            // landscape
            NSLog(@"IPAD LANDSCAPE");
        } else {
            NSLog(@"[DEBUG] determineKeyboardNib: Enter iPad Portrait");
            // portrait
            NSLog(@"IPAD PORTRAIT");
        }
    } else {
        // iPhone
        if (self.view.frame.size.width > 500){
            // landscape
            [self advanceToNextInputMode];
        } else if (self.view.frame.size.width > 450){
            NSLog(@"[DEBUG] determineKeyboardNib: Enter iPhone 4 Portrait");
            // portrait
            [self establishPortraitIPhoneConstraints];
        } else {
            // NSLog(@"[DEBUG] determineKeyboardNib: Enter iPhone 5 Portrait");
            [self establishPortraitIPhoneConstraints];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

// -(void)viewDidLayoutSubviews
// {
//     NSLog(@"LAYING OUT SUBVIEWS");

//     [super viewWillLayoutSubviews];
// }

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.

    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)brushButtonPressed:(UIButton *)sender
{
    NSLog(@"%@", NSStringFromCGPoint(self.brushButton.center));

    brushMenu = [[LIVBubbleMenu alloc] initWithPoint:self.brushButton.center radius:75.0f menuItems:self.brushImagesArray inView:self.view];
   brushMenu.bubbleStartAngle = 0;
   brushMenu.bubbleEndAngle = 90;
    brushMenu.bubbleRadius = self.brushButton.frame.size.width / 2.0f;
    brushMenu.menuRadius = self.brushButton.frame.size.width * 2.0f;
    brushMenu.bubbleShowDelayTime = 0.1f;
    brushMenu.bubbleHideDelayTime = 0.1f;
    brushMenu.bubbleSpringBounciness = 5.0f;
    // brushMenu.bubbleSpringSpeed = 10.0f;
    brushMenu.bubblePopInDuration = 0.3f;
    brushMenu.bubblePopOutDuration = 0.3f;
    brushMenu.backgroundFadeDuration = 0.3f;
    brushMenu.backgroundAlpha = 0.3f;
    brushMenu.delegate = self;
    [brushMenu show];
}

- (void)clearButtonPressed:(UIButton *)sender
{
    self.drawImage.image = nil;
}

- (void)enterButtonPressed:(UIButton *)sender
{
    NSString *text = [self.drawImage.image getASCII];
    [self.insertHistory insertObject:@([text length]) atIndex:0];
    [self.textDocumentProxy insertText:text];
}

- (void)backspaceButtonPressed:(UIButton *)sender
{
    if ([self.insertHistory count]) {
        NSNumber *lastTextCount = [self.insertHistory objectAtIndex:0];
        [self.insertHistory removeObjectAtIndex:0];
        for (int i = 0; i < [lastTextCount intValue]; i++) {
            [self.textDocumentProxy deleteBackward];
        }
    }
}
// - (void)undoButtonPressed:(UIButton *)sender
// {
//     NSLog(@"UNDO");
// }


#pragma Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.drawImage];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.drawImage];

    UIGraphicsBeginImageContext(self.drawImage.frame.size);
    [self.drawImage.image drawInRect:CGRectMake(0, 0, self.drawImage.frame.size.width, self.drawImage.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brushSize);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);

    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.drawImage setAlpha:1.0];
    UIGraphicsEndImageContext();

    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.drawImage.frame.size);
        [self.drawImage.image drawInRect:CGRectMake(0, 0, self.drawImage.frame.size.width, self.drawImage.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brushSize);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.drawImage setAlpha:1.0];
        UIGraphicsEndImageContext();
    }

}


#pragma LIVBubbleMenu

//User selected a bubble
-(void)livBubbleMenu:(LIVBubbleMenu *)bubbleMenu tappedBubbleWithIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            self.brushSize = BRUSH_SIZE_SMALL;
            break;
        case 1:
            self.brushSize = BRUSH_SIZE_MEDIUM;
            break;
        case 2:
            self.brushSize = BRUSH_SIZE_LARGE;
            break;
        default:
            self.brushSize = BRUSH_SIZE_MEDIUM;
            break;
    }
}

//The bubble menu has been hidden
-(void)livBubbleMenuDidHide:(LIVBubbleMenu *)bubbleMenu {
    NSLog(@"LIVBubbleMenu has been hidden");
}



@end
























