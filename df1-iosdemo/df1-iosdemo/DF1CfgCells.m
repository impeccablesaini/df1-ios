#define DF_LEVEL 0
#import "DF1Lib.h"
#import "Utility.h"
#import "NSData+Conversion.h"
#import "DF1CfgCells.h"

#define PAD_LEFT 20
#define PAD_TOP 5

//
// base class for config related cells
//
@implementation DF1CfgCell

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
      withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self==nil) return self;
    self.cfg = ucfg;
    self.height = 20; // default
    return self;
}

-(void) modifyChange:(NSMutableDictionary*) c
{
    // to be overwritten
}
@end


// editable name config cell
@implementation DF1CfgCellName
@synthesize height,nameLabel,nameField;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
      withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil)
        return self; 

    self.height = 50;
    // Initialization code
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:16];
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.text = @"Device Name";

    self.nameField = [[UITextField alloc] init];
    self.nameField.delegate = self;
    NSString *defaultName = [self.cfg objectForKey:CFG_NAME];
    self.nameField.placeholder = (defaultName==nil) ? @"DF1" : defaultName;
    [self.nameField addTarget:self action:@selector(handleTextFieldEdit:) forControlEvents:UIControlEventEditingDidEnd];
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.nameField];
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    // CGRect contentRect = self.contentView.bounds;
    // CGFloat boundsX = contentRect.origin.x;
    // CGFloat width = self.contentView.bounds.size.width;
    // CGRect fr;
    self.nameLabel.frame = CGRectMake(PAD_LEFT,     PAD_TOP, 110, 45);
    self.nameField.frame = CGRectMake(PAD_LEFT+130, PAD_TOP, 200, 45);
}

-(void) modifyChange:(NSMutableDictionary*) c
{
    [c setValue:self.nameField.text forKey:CFG_NAME];
}

-(void) handleTextFieldEdit:(UITextField*) sender
{
    [self modifyChange:self.cfg];
    [sender resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField==self.nameField)
        [self.nameField resignFirstResponder];
    return NO;
}

@end


// 2,4,8G range selector
@interface DF1CfgCellRange ()
{
    NSUInteger accSliderValue;
}
@end

@implementation DF1CfgCellRange

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil)
        return self;
    
    self.cfg = ucfg;
    self.height = 50;
    // Initialization code
    self.accRangeLabel = [[UILabel alloc] init];
    self.accRangeLabel.font = [UIFont boldSystemFontOfSize:16];
    self.accRangeLabel.textAlignment = NSTextAlignmentLeft;
    
    // self.accRangeLabel.text = @"G Range";
    self.accRangeSlider = [[UISlider alloc] init];
    self.accRangeSlider.continuous = true;
    [self.accRangeSlider setMinimumValue:2];
    [self.accRangeSlider setMaximumValue:8];
    
    [self.accRangeSlider addTarget:self action:@selector(accSliderChanged:)
               forControlEvents:UIControlEventValueChanged];
    accSliderValue = 2;
    if ([self.cfg objectForKey:CFG_XYZ8_RANGE]!=nil) {
        NSNumber *n = (NSNumber*) [self.cfg objectForKey:CFG_XYZ8_RANGE];
        accSliderValue = [n intValue];
    }
    self.accRangeLabel.text = [[NSString alloc] initWithFormat:@"Range %dG",accSliderValue];

    [self.contentView addSubview:self.accRangeLabel];
    [self.contentView addSubview:self.accRangeSlider];
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    // CGRect contentRect = self.contentView.bounds;
    // CGFloat boundsX = contentRect.origin.x;
    // CGFloat width = self.contentView.bounds.size.width;
    // CGRect fr;
    // fr = CGRectMake(boundsX + 120, 35+35+35+35, 180,40);
    // self.accRangeSlider.frame = fr;
    self.accRangeLabel.frame = CGRectMake(PAD_LEFT,      PAD_TOP, 110, 45);
    self.accRangeSlider.frame = CGRectMake(PAD_LEFT+130, PAD_TOP, 150, 45);
}

-(void) modifyChange:(NSMutableDictionary*) c
{
    [c setValue:[NSNumber numberWithInteger:accSliderValue] forKey:CFG_XYZ8_RANGE];
}

-(void) accSliderChanged:(UITextField*) sender
{
    NSUInteger index = (NSUInteger)(self.accRangeSlider.value + 0.5); // Round the number.
    if     (2<index && index<3)  { index = 2; }
    else if(3<=index && index<6) { index = 4; }
    else if(6<=index)            { index = 8; }
    
    if(accSliderValue != index)
    {
        //[self.parent.df modifyRange:index];
    }
    [self.accRangeSlider setValue:index animated:NO];
    self.accRangeLabel.text = [[NSString alloc] initWithFormat:@"Range %dG",index];
    accSliderValue = index;

    [self modifyChange:self.cfg];
    [sender resignFirstResponder];
}

@end



@interface DF1CfgCellTap ()
{
    NSUInteger accThsValuePrevious;
    NSUInteger accTmltValuePrevious;
}
@end
@implementation DF1CfgCellTap

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
  withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return self;
    self.cfg = ucfg;
    self.height = 140;
    accThsValuePrevious = 0;
    
    self.accLabel = [[UILabel alloc] init];
    self.accLabel.textAlignment = NSTextAlignmentRight;
    self.accLabel.font = [UIFont systemFontOfSize:16];
    self.accLabel.textColor = [UIColor grayColor];
    self.accLabel.backgroundColor = [UIColor clearColor];
    
    self.accValueTap = [[UILabel alloc] init];
    self.accValueTap.font = [UIFont systemFontOfSize:18];
    
    self.accThsLabel = [[UILabel alloc] init];
    self.accThsLabel.font = [UIFont systemFontOfSize:14];
    self.accThsLabel.text = @"Threshhold";
    self.accThsSlider = [[UISlider alloc] init];
    self.accThsSlider.continuous = true;
    [self.accThsSlider setMinimumValue:0];
    [self.accThsSlider setMaximumValue:31];
    [self.accThsSlider addTarget:self action:@selector(accThsChanged:)
                forControlEvents:UIControlEventValueChanged];
    
    self.accTmltLabel = [[UILabel alloc] init];
    self.accTmltLabel.font = [UIFont systemFontOfSize:14];
    self.accTmltLabel.text = @"Tmlt";
    self.accTmltSlider = [[UISlider alloc] init];
    self.accTmltSlider.continuous = true;
    [self.accTmltSlider setMinimumValue:1];
    [self.accTmltSlider setMaximumValue:20];
    [self.accTmltSlider addTarget:self action:@selector(accTmltChanged:)
                 forControlEvents:UIControlEventValueChanged];
    if([self.cfg objectForKey:CFG_TAP_TMLT])
    {
        float value = [[self.cfg objectForKey:CFG_TAP_TMLT] floatValue];
        [self.accTmltSlider setValue:(NSUInteger)value animated:YES];
        self.accTmltLabel.text = [[NSString alloc] initWithFormat:@"Tmlt %.0fms",10*value];
    }

    
    [self.contentView addSubview:self.accLabel];
    [self.contentView addSubview:self.accValueTap];
    [self.contentView addSubview:self.accThsLabel];
    [self.contentView addSubview:self.accThsSlider];
    [self.contentView addSubview:self.accTmltLabel];
    [self.contentView addSubview:self.accTmltSlider];
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    CGRect fr;
    
    fr = CGRectMake(boundsX + 5, 5, width-50, 25);
    self.accLabel.frame = fr;
    
    fr = CGRectMake(boundsX + 30, 5, 100, 25);
    self.accValueTap.frame = fr;
    
    // self.accRangeLabel.frame = CGRectMake(PAD_LEFT,      PAD_TOP, 110, 45);
    // self.accRangeSlider.frame = CGRectMake(PAD_LEFT+130, PAD_TOP, 150, 45);
    self.accThsLabel.frame  = CGRectMake(PAD_LEFT,     PAD_TOP,  110, 45);
    self.accThsSlider.frame = CGRectMake(PAD_LEFT+130, PAD_TOP, 150,45);
    
    self.accTmltLabel.frame  = CGRectMake(PAD_LEFT,    PAD_TOP+35,  110, 45);
    self.accTmltSlider.frame = CGRectMake(PAD_LEFT+130,PAD_TOP+35, 150,45);
}

-(IBAction) accThsChanged:(UISlider*)sender
{
    NSUInteger index = (NSUInteger)(self.accThsSlider.value);
    float gvalue = (float) index * 0.063f;
    DF_DBG(@"accThs gvalue %.4f",gvalue);
    if(index != accThsValuePrevious)
    {
        // notice we are changing all 3 threshholds
        [self.cfg setValue:[NSNumber numberWithFloat:gvalue] forKey:CFG_TAP_THSZ];
        [self.cfg setValue:[NSNumber numberWithFloat:gvalue] forKey:CFG_TAP_THSY];
        [self.cfg setValue:[NSNumber numberWithFloat:gvalue] forKey:CFG_TAP_THSX];
    }
    // [self.accRangeSlider setValue:index animated:YES];
    self.accThsLabel.text = [[NSString alloc] initWithFormat:@"Thresh %.3fG",gvalue];
    accThsValuePrevious = index;
}

-(IBAction) accTmltChanged:(UISlider*)sender
{
    NSUInteger msec10 = (NSUInteger) self.accTmltSlider.value;
    float msec = (float) msec10 * 10.0f;
    DF_DBG(@"accTmlt %.0f", msec);
    if(msec10 != accTmltValuePrevious)
    {
        // notice we are changing all 3 threshholds
        [self.cfg setValue:[NSNumber numberWithFloat:msec10] forKey:CFG_TAP_TMLT];
    }
    self.accTmltLabel.text = [[NSString alloc] initWithFormat:@"Tmlt %.0fms",msec];
    accTmltValuePrevious = msec10;
}

@end




@implementation DF1CfgCellAuto
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil)
        return self;
    self.cfg = ucfg;
    self.height = 30;
    return self;
}
-(void) layoutSubviews
{
    [super layoutSubviews];
}
@end


@implementation DF1CfgCellBatt
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil)
        return self;
    self.cfg = ucfg;
    self.height = 30;
    return self;
}
-(void) layoutSubviews
{
    [super layoutSubviews];
}
@end


@implementation DF1CfgCellProx
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil)
        return self;
    self.cfg = ucfg;
    self.height = 30;
    return self;
}
-(void) layoutSubviews
{
    [super layoutSubviews];
}
@end
