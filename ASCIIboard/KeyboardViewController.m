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
#import "UIColor+Random.h"
#import "POP.h"


@implementation KeyboardViewController

#pragma mark - KeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // LOAD KLUDGE so that height can change -_-
    [self loadKludge];

    // INITS
    self.insertHistory = [[NSMutableArray alloc] init];
    self.brushImagesArray = [NSArray arrayWithObjects:
                                [UIImage imageNamed:@"pen"],
                                [UIImage imageNamed:@"pen"],
                                [UIImage imageNamed:@"pen"],
                                nil];

    // LAYOUT
    // set bg color 220, 222, 226
    [self.view setBackgroundColor:[UIColor colorWithRed:0.863 green:.8671875 blue:.8828125 alpha:1.000]];

    // setup draw sheets

    self.sheetBackground = [[UIView alloc] init];
    self.sheetBackground.backgroundColor = [UIColor randomColor];
    [self.view addSubview:self.sheetBackground];

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

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self createButtons];

    // add constraints
    [self establishConstraints];

    [self makeKeyboardHeight:ASKEY_HEIGHT];

    [self updateButtonStatus];


    MCDrawSheet *firstSheet = [self generateDrawSheet];

    // sheet constraints (they're actually not shitty)
    [self.sheetBackground mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.view);
        make.width.equalTo(firstSheet.mas_height).multipliedBy(ASKEY_WIDTH_RATIO);
        make.center.equalTo(self.view);
    }];

    [NSTimer scheduledTimerWithTimeInterval:INITIAL_SHEET_DELAY target:self selector:@selector(animateSheetInWithTimer:) userInfo:firstSheet repeats:NO];


}

- (void)createButtons
{
    // LEFT SIDE

    // BRUSH BUTTON
    self.brushButton = [[AKButton alloc] initWithImage:[UIImage imageNamed:@"pen"] andDiameter:BUTTON_HEIGHT];
    [self.brushButton addTarget:self action:@selector(brushButtonPressed:) forControlEvents:UIControlEventTouchDown];

    // ERASER BUTTON
    self.eraserButton = [[AKButton alloc] initWithImage:[UIImage imageNamed:@"eraser"] andDiameter:BUTTON_HEIGHT];
    [self.eraserButton addTarget:self action:@selector(eraserButtonPressed:) forControlEvents:UIControlEventTouchDown];

    // NEXT BUTTON
    self.nextKeyboardButton = [[AKButton alloc] initWithImage:[UIImage imageNamed:@"globe"] andDiameter:BUTTON_HEIGHT];
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];

    // RIGHT SIDE

    // ENTER BUTTON
    self.enterButton = [[AKButton alloc] initWithImage:[UIImage imageNamed:@"return"] andDiameter:BUTTON_HEIGHT];
    [self.enterButton addTarget:self action:@selector(enterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    // BACKSPACE BUTTON
    self.backspaceButton = [[AKButton alloc] initWithImage:[UIImage imageNamed:@"backspace"] andDiameter:BUTTON_HEIGHT];
    [self.backspaceButton addTarget:self action:@selector(backspaceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    // UNDO BUTTON
    self.undoButton = [[AKButton alloc] initWithImage:[UIImage imageNamed:@"undo"] andDiameter:BUTTON_HEIGHT];
    [self.undoButton addTarget:self action:@selector(undoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    // CLEAR BUTTON
    self.clearButton = [[AKButton alloc] initWithImage:[UIImage imageNamed:@"trash"] andDiameter:BUTTON_HEIGHT];
    [self.clearButton addTarget:self action:@selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];


    // ADD VIEWS TO SELF.VIEW
    [self.view addSubview:self.brushButton];
    [self.view addSubview:self.eraserButton];
    [self.view addSubview:self.nextKeyboardButton];

    [self.view addSubview:self.enterButton];
    [self.view addSubview:self.backspaceButton];
    [self.view addSubview:self.undoButton];
    [self.view addSubview:self.clearButton];
}

- (void)makeKeyboardHeight:(float)height
{
    if (_heightConstraint != nil) {
        [self.view removeConstraint:_heightConstraint];
    }

    _heightConstraint =
        [NSLayoutConstraint constraintWithItem: self.view
                                     attribute: NSLayoutAttributeHeight
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: nil
                                     attribute: NSLayoutAttributeNotAnAttribute
                                    multiplier: 0.0
                                      constant: height];
    [self.view addConstraint: _heightConstraint];
    // [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
    //     make.height.equalTo(@(height));
    //     make.width.lessThanOrEqualTo(@(1000));
    // }];

}


- (void)loadKludge
{
    if (kludge == nil) {
        kludge = [[UIView alloc] init];
        [self.view addSubview:kludge];
        kludge.translatesAutoresizingMaskIntoConstraints = NO;
        kludge.hidden = YES;

        [kludge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view.mas_left);
            make.top.equalTo(self.view);
            make.bottom.equalTo(self.view.mas_top);
        }];

    }
}

- (void)establishPortraitIPhoneConstraints
{
    // MAKE SPACERS
    UIView *spacerLeftLeft = [[UIView alloc] init];
    spacerLeftLeft.backgroundColor = [self spacerColor];
    [self.view addSubview:spacerLeftLeft];

    UIView *spacerLeftRight = [[UIView alloc] init];
    spacerLeftRight.backgroundColor = [self spacerColor];
    [self.view addSubview:spacerLeftRight];

    UIView *spacerRightLeft = [[UIView alloc] init];
    spacerRightLeft.backgroundColor = [self spacerColor];
    [self.view addSubview:spacerRightLeft];

    UIView *spacerRightRight = [[UIView alloc] init];
    spacerRightRight.backgroundColor = [self spacerColor];
    [self.view addSubview:spacerRightRight];

    [spacerLeftLeft mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.centerY.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.2f);
        make.width.greaterThanOrEqualTo(@(0));
    }];
    [spacerLeftRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(spacerLeftLeft);
        make.right.equalTo(self.sheetBackground.mas_left);
        make.centerY.equalTo(self.view);
    }];
    [spacerRightLeft mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(spacerLeftLeft);
        make.left.equalTo(self.sheetBackground.mas_right);
        make.centerY.equalTo(self.view);
    }];
    [spacerRightRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(spacerLeftLeft);
        make.right.and.centerY.equalTo(self.view);
    }];


    int numSpacers = 5;

    NSMutableArray *spacers = [[NSMutableArray alloc] initWithCapacity:numSpacers];

    for (int i = 0; i < numSpacers; ++i) {
        // need 5 spacers on the right
        UIView *spacer = [[UIView alloc] init];
        spacer.backgroundColor = [self spacerColor];
        [self.view addSubview:spacer];

        [spacers addObject:spacer];

        [spacer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view.mas_width).multipliedBy(0.1);
            if (i == 0) {
                // first
                make.centerX.equalTo(self.enterButton);
                make.height.greaterThanOrEqualTo(@(0));
                make.top.equalTo(self.view);
            } else if (i == numSpacers - 1) {
                // last
                make.height.and.centerX.equalTo(spacers[0]);
                make.bottom.equalTo(self.view);
            } else {
                // if any but the first one, inherit height and width and centerX
                make.height.and.centerX.equalTo(spacers[0]);
            }
        }];
    }


    [self.brushButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(spacerLeftLeft.mas_right);
        make.right.equalTo(spacerLeftRight.mas_left);
        make.width.equalTo(self.brushButton.mas_height);
        make.height.equalTo(@(BUTTON_HEIGHT));

        // @TODO(Shrugs)
        make.centerY.equalTo(self.enterButton);
    }];
    [self.eraserButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.height.equalTo(self.brushButton);
        make.centerY.equalTo(self.backspaceButton);
    }];
    [self.nextKeyboardButton mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.right.and.height.equalTo(self.brushButton);
        make.centerY.equalTo(self.clearButton);
    }];



    [self.enterButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(spacerRightLeft.mas_right);
        make.right.equalTo(spacerRightRight.mas_left);
        make.width.equalTo(self.enterButton.mas_height);
        make.height.equalTo(@(BUTTON_HEIGHT));

        make.top.equalTo(((UIView *)spacers[0]).mas_bottom);
        make.bottom.equalTo(((UIView *)spacers[1]).mas_top);

    }];
    [self.backspaceButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.and.width.equalTo(self.enterButton);

        make.top.equalTo(((UIView *)spacers[1]).mas_bottom);
        make.bottom.equalTo(((UIView *)spacers[2]).mas_top);
    }];
    [self.undoButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.and.width.equalTo(self.enterButton);

        make.top.equalTo(((UIView *)spacers[2]).mas_bottom);
        make.bottom.equalTo(((UIView *)spacers[3]).mas_top);
    }];
    [self.clearButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.and.width.equalTo(self.enterButton);

        make.top.equalTo(((UIView *)spacers[3]).mas_bottom);
        make.bottom.equalTo(((UIView *)spacers[4]).mas_top);
    }];

}

- (void)updateViewConstraints {

    [super updateViewConstraints];
    // [self establishConstraints];

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

#pragma mark - TextInput Delegate

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

#pragma mark - Button Handlers

- (void)brushButtonPressed:(UIButton *)sender
{

    brushMenu = [[LIVBubbleMenu alloc] initWithPoint:self.brushButton.center radius:self.brushButton.frame.size.width * 2.0f menuItems:self.brushImagesArray inView:self.view];
    brushMenu.bubbleStartAngle = 0;
    brushMenu.bubbleTotalAngle = 90;
    brushMenu.bubbleRadius = self.brushButton.frame.size.width / 2.0f;
    brushMenu.bubbleShowDelayTime = 0.1f;
    brushMenu.bubbleHideDelayTime = 0.1f;
    brushMenu.bubbleSpringBounciness = 5.0f;
    // brushMenu.bubbleSpringSpeed = 10.0f;
    brushMenu.bubblePopInDuration = 0.3f;
    brushMenu.bubblePopOutDuration = 0.3f;
    brushMenu.backgroundFadeDuration = 0.3f;
    brushMenu.backgroundAlpha = 0.3f;
    brushMenu.easyButtons = YES;
    brushMenu.delegate = self;

    [brushMenu show];
}

- (void)clearButtonPressed:(UIButton *)sender
{
    [self.currentSheet.drawView clear];
    [self updateButtonStatus];
}

- (void)eraserButtonPressed:(UIButton *)sender
{
    // change to eraser here
    self.currentSheet.drawView.drawTool = ACEDrawingToolTypeEraser;
    self.currentSheet.drawView.lineWidth = BRUSH_SIZE_MEDIUM;
    [self.currentSheet listenForGestures];
}

- (void)enterButtonPressed:(UIButton *)sender
{
    CGSize numBlocks = CGSizeMake(40, 11);
    NSString *text = [self.currentSheet.drawView.image getASCIIWithResolution:numBlocks];

    // only insert period at beginning of string if necessary
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedString = [[self.textDocumentProxy documentContextBeforeInput] stringByTrimmingCharactersInSet:charSet];
    NSLog(@"before:%@:", [self.textDocumentProxy documentContextBeforeInput]);
    NSLog(@"beforeTrimmed:%@:", trimmedString);

    // so this condition is broken because textDocumentProxy isn't behaving
    // if ((trimmedString == nil || [trimmedString isEqualToString:@""]) && [text hasPrefix:@" "]) {
    // so for now, use this
    if ([self.insertHistory count] == 0 && [text hasPrefix:@" "]) {
        // it's empty or contains only white spaces
        // therefore, strip extra white space
        text = [self removeExtraWhiteSpaceLinesFromText:text withSize:numBlocks];
        // and insert period if necessary
        text = [text stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"."];
    }
    [self.insertHistory insertObject:@([text length]) atIndex:0];
    if (text != nil) {
        [self.textDocumentProxy insertText:text];
    }
    [self updateButtonStatus];
    [self incrementSheets];
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
    [self updateButtonStatus];
}
- (void)undoButtonPressed:(UIButton *)sender
{
    [self.currentSheet.drawView undoLatestStep];
    [self updateButtonStatus];
}

- (void)updateButtonStatus
{
    self.undoButton.enabled = [self.currentSheet.drawView canUndo];
    self.backspaceButton.enabled = (BOOL)[self.insertHistory count];
}

#pragma mark - MCDrawSheet Movement

- (void)incrementSheets
{
    // moves both sheets upwards, making a new sheet after previousSheet is out of the view
    // makes currentSheet previousSheet and then makes _newSheet currentSheet
    if (self.previousSheet != nil) {
        // animate out and then reassign
        MCDrawSheet *tempSheet = self.previousSheet;
        POPSpringAnimation *anim = [self.previousSheet pop_animationForKey:@"previousSheetSlideOut"];
        if (!anim) {
            anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
        }
        anim.toValue = @(-ASKEY_HEIGHT);
        anim.velocity = @(SHEET_VELOCITY);
        anim.name = @"previousSheetSlideOut";
        anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            [tempSheet removeFromSuperview];
        };
        [tempSheet pop_addAnimation:anim forKey:@"previousSheetSlideOut"];
    }
    // now pop them into position!

    // CURRENT SHEET
    POPSpringAnimation *anim = [self.currentSheet pop_animationForKey:@"currentSheetSlideOut"];
    if (!anim) {
        anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    }
    anim.toValue = @((-self.currentSheet.frame.size.height + RELATIVE_SHEET_EXPOSED_HEIGHT * ASKEY_HEIGHT)/2);
    anim.velocity = @(SHEET_VELOCITY);
    anim.name = @"currentSheetSlideOut";
    [self.currentSheet pop_addAnimation:anim forKey:@"currentSheetSlideOut"];

    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.toValue = @(0.65);
    [self.currentSheet.layer pop_addAnimation:opacityAnimation forKey:@"opacityAnimation"];

    // NEW SHEET
    MCDrawSheet *newSheet = [self generateDrawSheet];
    [NSTimer scheduledTimerWithTimeInterval:INITIAL_SHEET_DELAY target:self selector:@selector(animateSheetInWithTimer:) userInfo:newSheet repeats:NO];

    self.enterButton.enabled = NO;

}

- (void)decrementSheets
{
    // move both sheets down, dropping currentSheet into the void
    // makes previousSheet currentSheet and then makes previousSheet nil
}

- (void)drawSheet:(MCDrawSheet *)sheet wasMovedWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{

    static CGFloat lastY = 0;

    CGPoint touchLocation = [panGestureRecognizer locationInView:self.view];

    switch ([panGestureRecognizer state]) {
        case UIGestureRecognizerStateBegan: {
            // get initial point
            lastY = touchLocation.y;

            NSLog(@"GESTURE BEGAN");
            break;
        }
        case UIGestureRecognizerStateChanged: {
            // follow finger delta on vertical axis
            CGFloat dy = touchLocation.y - lastY;
            lastY = touchLocation.y;
            self.previousSheet.center = CGPointMake(self.previousSheet.center.x, self.previousSheet.center.y + dy);
            self.currentSheet.center = CGPointMake(self.currentSheet.center.x, self.currentSheet.center.y + dy);

            NSLog(@"GESTURE CHANGED");
            break;
        }
        case UIGestureRecognizerStateEnded: {
            // if we were throwing with enough velocity in a certain direction, move to that position
            // otherwise, do position threshold to check for new position
            // move to that position with any initial velocity
            NSLog(@"GESTURE ENDED");
            NSLog(@"%@", NSStringFromCGRect(self.currentSheet.frame));
            break;
        }
        default: {
            break;
        }
    }

}

- (void)drawSheet:(MCDrawSheet *)sheet wasTappedWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    // if it was tapped at all, that means to decrement sheets
    [self decrementSheets];
}


#pragma mark - ACEDrawing View Delegate

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool;
{
    [self updateButtonStatus];
}

#pragma make - LIVBubbleMenu

//User selected a bubble
-(void)livBubbleMenu:(LIVBubbleMenu *)bubbleMenu tappedBubbleWithIndex:(NSUInteger)index {
    self.currentSheet.drawView.drawTool = ACEDrawingToolTypePen;
    switch (index) {
        case 0:
            self.currentSheet.drawView.lineWidth = BRUSH_SIZE_SMALL;
            break;
        case 1:
            self.currentSheet.drawView.lineWidth = BRUSH_SIZE_MEDIUM;
            break;
        case 2:
            self.currentSheet.drawView.lineWidth = BRUSH_SIZE_LARGE;
            break;
        default:
            self.currentSheet.drawView.lineWidth = BRUSH_SIZE_MEDIUM;
            break;
    }
}

//The bubble menu has been hidden
-(void)livBubbleMenuDidHide:(LIVBubbleMenu *)bubbleMenu {

}

#pragma mark - Utils


- (NSString *)removeExtraWhiteSpaceLinesFromText:(NSString *)text withSize:(CGSize)size
{
    NSRange range = NSMakeRange(0, size.width);
    while (YES) {
        // for each line of width size.width, discard it if it's whitespace
        if (text.length > 2*(size.width) &&
            [self stringIsWhiteSpace:[text substringWithRange:range]] &&
            [self stringIsWhiteSpace:[text substringWithRange:NSMakeRange(size.width, size.width)]]) {
            // if is whitespace, remove if next string is white space as well
            text = [text stringByReplacingCharactersInRange:range withString:@""];

        } else {
            break;
        }

    }

    return text;
}

- (BOOL)stringIsWhiteSpace:(NSString *)str
{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:charSet];
    return (trimmedString == nil || [trimmedString isEqualToString:@""]);
}

- (UIColor *)spacerColor
{
    if (DEBUG_SPACERS) {
        return [UIColor randomColor];
    } else {
        return [UIColor clearColor];
    }
}

- (MCDrawSheet *)generateDrawSheet
{

    MCDrawSheet *sheet = [[MCDrawSheet alloc] initWithFrame:CGRectMake(0,
                                                                       ASKEY_HEIGHT,
                                                                       ASKEY_HEIGHT*ASKEY_HEIGHT_FRACTION*ASKEY_WIDTH_RATIO,
                                                                       ASKEY_HEIGHT*ASKEY_HEIGHT_FRACTION)];
    sheet.delegate = self;
    sheet.drawView.lineWidth = BRUSH_SIZE_MEDIUM;
    sheet.drawView.delegate = self;
    [self.sheetBackground addSubview:sheet];
    // [sheet mas_remakeConstraints:^(MASConstraintMaker *make) {
    //     make.height.equalTo(self.view).multipliedBy(ASKEY_HEIGHT_FRACTION);
    //     make.width.equalTo(sheet.mas_height).multipliedBy(ASKEY_WIDTH_RATIO);
    //     make.centerX.equalTo(self.sheetBackground);
    // }];
    return sheet;
}

- (void)animateSheetInWithTimer:(NSTimer *)timer
{
    return [self animateSheetIn:[timer userInfo]];
}

- (void)animateSheetIn:(MCDrawSheet *)sheet
{
    // NEW SHEET
    POPSpringAnimation *inAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    inAnim.toValue = @(self.sheetBackground.center.y);
    inAnim.velocity = @(-SHEET_VELOCITY);
    inAnim.name = @"slideNewSheetIn";
    inAnim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        self.previousSheet = self.currentSheet;
        NSLog(@"%@", self.currentSheet);
        self.currentSheet = sheet;
        self.enterButton.enabled = YES;
        [self.previousSheet listenForGestures];

        [self.sheetBackground mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.view);
            make.width.equalTo(self.currentSheet.mas_height).multipliedBy(ASKEY_WIDTH_RATIO);
            make.center.equalTo(self.view);
        }];

    };
    [sheet pop_addAnimation:inAnim forKey:@"slideNewSheetIn"];
}

@end

























