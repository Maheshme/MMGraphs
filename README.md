# MMGraphs
##Contains:<br />
-Interactive Line<br />
-Interactive Bar<br />
-Interactive Horizontal bar<br />
-Interactive Symmetry<br />
-Interactive Scatter Plot<br />
-Multi scatter Plot<br />
-Area graph<br />
-Dynamic line<br />
-Dynamic Bar<br />
-Dynamic Scatter Plot graphs in it
  
<br />  Lightweight graphs, supports the negative plot, effective interaction.<br />

##How to use:
<br />Each graph is separate UIView component except dynamic graphs, you just need to import that and allocate using proper init, then add to subview. In dynamic graphs you need to pass what type of graph i.e.., line, bar or scatter plot.<br /> 
<br /> The interactive line is a static graph where you can see interactions using a scroll button on the x-axis. The Value will be displayed at top of graph, and plot period is 1 min. You can customise macros based on your requirment<br />
```
#define STARTING_Y                      self.frame.size.height*0.9
#define ENDING_Y                        11.0
#define STARTING_X                      self.frame.size.width*0.0
#define MAX_HEIGHT_OF_BAR               (STARTING_Y - ENDING_Y)
#define BAR_WIDTH                       40.0
#define SPACING                         10.0
```
<br />
by going into that class. These are macros so just change them at declaration. And for data in ```GraphModel.m```. <br /><br /> ```+(NSArray *)getMinuteDataFor:(int)numberOfMinutes```
<br />return your data in the array of```GraphPlotObj``` form.<br />
***This is dummy data. You need to alter method or get data inside method***
```
+(NSArray *)getDataForDays:(int)days withUpperLimit:(int)upperLimit andLowerlimit:(int)lowerLimit
{
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    components.day -= days;
    components.hour = 0;
    components.minute = 2;
    components.second = 0;
    
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    dateFormat.timeZone = [NSTimeZone systemTimeZone];
    if (days < 8)
        dateFormat.dateFormat = DATE_FORMAT_DAY;
    else
        dateFormat.dateFormat = DATE_FORMAT_MMM_DD;
    
    int64_t referenceTime = [[components date] timeIntervalSince1970];
    
    NSMutableArray *arrayOfPlotData = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < days; i++)//==> days = yourDataSource.count
    {
        GraphPlotObj *graphObj = [[GraphPlotObj alloc]init];
        graphObj.value = [GraphModel getRandomNumberInBetween:lowerLimit upper:upperLimit]; //==>Value from your data source
        graphObj.position = i;//==>Position is requried for plot, so running normal for
        graphObj.timeStamp = referenceTime + i*SECONDS_IN_A_DAY;//==>If you have data for timestamp
        graphObj.labelName = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:graphObj.timeStamp]];//==>If Label name is requried(x-axis labels)
        
        [arrayOfPlotData addObject:graphObj];
    }
    
    return (NSArray *)arrayOfPlotData;
}```

<br /> <br />Follow same for Interactive Bar, Interactive Horizontal bar, Interactive Scatter Plot, Interactive Symmetry, Multi scatter Plot. Use<br /><br /> ```+(NSArray *)getDataForDays:(int)days withUpperLimit:(int)upperLimit andLowerlimit:(int)lowerLimit``` <br /><br />method to return data for all of them.I have used a common method to generate data, you can handle by placing conditions for different graphs. But don't forget to convert your data to ```GraphPlotObj```.<br />
<br />For dynamic graphs we will trigger a timer in View controller and that will call a method in the view class, which will update graph. You can change the timer and send your required data. <br />```-(void)createTimer``` is method in view controller triggers <br />```-(void)createData```.<br /> You need to create ```GraphPlotObj``` and call<br /> ```-(void)createDataWithPlotObj:(GraphPlotObj *)plotObj```<br /> in Dynamic graph class.<br />
<br />If you want to change bar width or spacing or where the graph should start, go to class and change the macros as suggested above. Don't worry if values go negitive, both interaction and ploting are being handled. <br />
<br />*Download and play arround and check different type of interaction for diferent the graphs, there is no interacion for dyanmic graphs.*<br /><br />
##Lightweight:
<br />Tried to make it light weight, except multigraphs other graphs are ploted using one bezierpath instance, no buttons are used for interactions except in Interactive line(two buttons one on the x-axis and other on graph line).<br />
##Effective interaction:
<br />Tried to make interaction more effective. No buttons are used for interactionin bargraphs, and all graphs are made freely scrollable, no pagination is added. While for the interactive line if you need just line but not curve make curvatureFactor = 0. Then you will get line graph. If you need to increase the curvature, then increase the factor to 0.5. Play arround by changing curvatureFactor. But recommend curvatureFactor shoubd be (0 - 0.5). But if you make curvatureFactor to 0.5 the grah will be curvier, so the graph button will not stick to the graph. If there is no curvature then graph button will work correctly. Recommend curvatureFactor is 0.2 so we can get both.<br />
##Important Note:
<br/>Except for the Area graph all plots are in normal geometry by performing ```geometryFlipped = YES``` to CALayer. It is the property of CALayer where we invert the geometry of CALayer. So all the graph calluculations can be done normaly. But in the Area graph we can't afford to use that propery, beacuse here we are filling color for ploted the area, so where the graph goes and below that point. So if we geometry is flipped then the area will also be inverted. So the filling will be in the opposit direction, to avoid that we are ploting as inverted geometry. All these have been handled.<br />
##Interacive Line and Bar:
![](https://github.com/Maheshme/MMGraphs/blob/master/MMGraphs/InteractiveLineAndBAr.gif)

##Interacive Horizantal Bar and Symmetry:
![](https://github.com/Maheshme/MMGraphs/blob/master/MMGraphs/InteracriveBarAndSymmetry.gif)

##Interacive Scatter Plot:
![](https://github.com/Maheshme/MMGraphs/blob/master/MMGraphs/InteractiveScatter.gif)

##Noninteractive Multi-Scatter and Area:
![](https://github.com/Maheshme/MMGraphs/blob/master/MMGraphs/NonInteractiveScatterAndArea.gif)

##Dynamic graphs:
![](https://github.com/Maheshme/MMGraphs/blob/master/MMGraphs/Dynamic.gif)
