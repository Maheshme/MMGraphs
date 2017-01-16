# MMGraphs
##Contains:<br />
-Interactive Line
-Interactive Bar
-Interactive Horizontal bar
-Interactive Symmetry
-Interactive Scattert Plot
-Multi scatter Plot
-Area graph
-Dynamic line
-Dynamic Bar
-Dynamic Scattert Plot graphs in it
  
<br />  Light weight graphs, supports negitive plot, effective interaction.<br />

##How to use:
<br />Each graph is seperate UIView component except dynamic graphs, u just need to import that and allocate using proper init, then add to subview. In dynamic graphs u need to pass what type of graph i.e.., line, bar or scatter plot.<br /> 
<br /> Interactive line is static graph where u can see interactions using a scroll button on x-axis. Value will be displayed at top of graph, and plot intraval is 1 min. You can customize like ```MAX_X_AXIS_LABELS, TIME_INTERVAL, STARTING_Y, ENDING_Y, STARTING_X```by going in to that class. These are macros so just change them at declaration. And for data in ```GraphModel.m``` <br />```+(NSArray *)getMinuteDataFor:(int)numberOfMinutes```, return your data in array of```GraphPlotObj``` form.<br />
<br /> Follow same for Interactive Bar, Interactive Horizontal bar, Interactive Scattert Plot, Interactive Symmetry, Multi scatter Plot. Use<br /> ```+(NSArray *)getDataForDays:(int)days withUpperLimit:(int)upperLimit andLowerlimit:(int)lowerLimit``` <br />method to return data for all of them.I have used common method to generate data, u can handle by placing conditions for different graphs. But don't forget convert your data to ```GraphPlotObj```.<br />
<br />If you want to change bar width or spacing or wher the graph should start, go to class and change the macros as suggested above. Don't worry if vales go negitive, both interaction and ploting are being handled :+1:. <br />
<br />*Download and play arround and check different type of interaction for diferent graphs, there is no interacion for dyanmic graphs.*<br /><br />
##Light weight:
<br />Tried to make it light weight, except multi graphs other graphs are ploted using one bezierpath instance, no buttons are used for interactions except in Interactive line(two buttons one on x-axis and other on graph line).<br />
##Effective interaction:
<br />Tried to make interaction more effective. No buttons are used for interactionin bargraphs, and all graphs are made freely scrollable, no pagination is added. While for interactive line if u need just line but not curve make curvatureFactor = 0. Then u will get line graph. If u need to increase the curvature, then increase the factor to 0.5. Play arround by changing curvatureFactor. But recommend curvatureFactor shoubd be (0 - 0.5). But if u make curvatureFactor to 0.5 grah will be more curvy, so the graph button will not stick to graph. If there is no curvature then graph button will work correctly. Recommend curvatureFactor is 0.2 so we can get both.<br />
##Important Note:
<br/>Except Area graph all are ploted in normal geometry by making ```geometryFlipped = YES```. It is property of CALayer where we invert the geometry of CALayer. So all the graph calluculations can be done normaly. But in Area graph we can't afford to use that propery, beacuse here we are filling color for ploted area, so where the graph goes and below that point. So if we geometry is flipped then area will also be inverted. So the filling will be in opposit direction, to avoid that we are ploting as inverted geometry. All these have been handled.<br />
