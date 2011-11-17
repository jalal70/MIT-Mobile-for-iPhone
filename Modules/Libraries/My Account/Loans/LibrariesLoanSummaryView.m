#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LibrariesLoanSummaryView.h"

static NSString* kLibrariesLoanFormatString = @"You have %lu items on loan.";
static NSString* kLibrariesLoanOverdueFormatString = @"\n%lu are overdue.";

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
        self.infoLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.infoLabel.numberOfLines = 2;
        [self addSubview:self.infoLabel];
        
        
        self.renewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.renewButton setTitle:@"Renew"
                          forState:UIControlStateNormal];
        [self.renewButton setTitleColor:[UIColor lightGrayColor]
                               forState:UIControlStateDisabled];
        [self addSubview:self.renewButton];
        
        self.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 10);
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
        CGFloat buttonWidth = 75.0;
        CGRect buttonFrame = CGRectMake(CGRectGetMaxX(bounds) - buttonWidth,
                                        CGRectGetMinY(bounds),
                                        buttonWidth,
                                        31);
        
        self.renewButton.frame = buttonFrame;
        bounds.size.width -= buttonWidth;
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
        NSMutableString *infoText = [NSMutableString stringWithFormat:kLibrariesLoanFormatString, loanCount];
        
        if (overdueCount > 0)
        {
            [infoText appendFormat:kLibrariesLoanOverdueFormatString, overdueCount];
        }
        
        self.infoLabel.text = infoText;
    }

    [self setNeedsLayout];
}
@end
