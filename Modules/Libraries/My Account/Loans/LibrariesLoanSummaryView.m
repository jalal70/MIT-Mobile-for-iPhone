#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LibrariesLoanSummaryView.h"
#import "UIKit+MITAdditions.h"

static NSString* kLibrariesLoanFormatString = @"You have %lu %@ on loan.";
static NSString* kLibrariesLoanOverdueFormatString = @"\n%lu %@ overdue.";

@interface LibrariesLoanSummaryView ()
@property (nonatomic, retain) UILabel* infoLabel;
@end

@implementation LibrariesLoanSummaryView
@synthesize accountDetails = _accountDetails,
            edgeInsets = _edgeInsets;
@synthesize infoLabel = _infoLabel;
@synthesize renewButton = _renewButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.infoLabel = [[[UILabel alloc] init] autorelease];
        self.infoLabel.backgroundColor = [UIColor clearColor];
        self.infoLabel.text = @"";
        self.infoLabel.textColor = [UIColor colorWithHexString:@"#404649"];
        self.infoLabel.font = [UIFont systemFontOfSize:14.0];
        self.infoLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.infoLabel.numberOfLines = 2;
        [self addSubview:self.infoLabel];
        
        
        self.renewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.renewButton setTitle:@"Renew Books…"
                          forState:UIControlStateNormal];
        [self.renewButton setTitleColor:[UIColor colorWithWhite:0.19 alpha:1.0]
                               forState:UIControlStateNormal];
        [self.renewButton setTitleColor:[UIColor lightGrayColor]
                               forState:UIControlStateDisabled];
        self.renewButton.titleLabel.font = [UIFont systemFontOfSize:14.0];

        UIImage *buttonBackground = [[UIImage imageNamed:@"global/tab2-summary-button"]
                                     stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        [self.renewButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
        self.renewButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 3.0, 0.0, -3.0);
        
        [self addSubview:self.renewButton];
        
        self.edgeInsets = UIEdgeInsetsMake(6, 10, 9, 10);
    }
    return self;
}

- (void)dealloc
{
    self.infoLabel = nil;
    self.accountDetails = nil;

    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, self.edgeInsets);
    
    {
        CGFloat buttonWidth = 118.0;
        CGFloat buttonHeight = 35.0;
        CGRect buttonFrame = self.renewButton.frame;

        buttonFrame.origin.x = CGRectGetMaxX(bounds) - buttonWidth;
        buttonFrame.origin.y = floor((CGRectGetHeight(self.bounds) - buttonHeight) / 2.0);
        buttonFrame.size.width = buttonWidth;
        buttonFrame.size.height = buttonHeight;
        self.renewButton.frame = buttonFrame;
        
        bounds.size.width -= CGRectGetWidth(self.renewButton.frame);
    }
    
    {
        CGRect titleFrame = bounds;
        titleFrame.size = [self.infoLabel.text sizeWithFont:self.infoLabel.font
                                          constrainedToSize:bounds.size
                                              lineBreakMode:self.infoLabel.lineBreakMode];
        self.infoLabel.frame = titleFrame;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat width = size.width - (self.edgeInsets.left + self.edgeInsets.right);
    
    CGSize contentSize = [self.infoLabel.text sizeWithFont:self.infoLabel.font
                                 constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                       lineBreakMode:self.infoLabel.lineBreakMode];

    contentSize.height = MAX(contentSize.height, 31);
    contentSize.height += (self.edgeInsets.top + self.edgeInsets.bottom);
    return contentSize;
}

- (void)setAccountDetails:(NSDictionary *)accountDetails
{
    [_accountDetails release];
    _accountDetails = [accountDetails retain];

    NSUInteger loanCount = [[accountDetails objectForKey:@"total"] unsignedIntegerValue];
    NSUInteger overdueCount = [[accountDetails objectForKey:@"overdue"] unsignedIntegerValue];
    
    if (loanCount == 0)
    {
        self.infoLabel.text = @"";
    }
    else
    {
        NSMutableString *infoText = [NSMutableString stringWithFormat:kLibrariesLoanFormatString, loanCount, ((loanCount == 1) ? @"item" : @"items")];
        
        if (overdueCount > 0)
        {
            [infoText appendFormat:kLibrariesLoanOverdueFormatString, overdueCount, ((overdueCount == 1) ? @"is" : @"are")];
        }
        
        self.infoLabel.text = infoText;
    }

    [self setNeedsLayout];
}
@end
