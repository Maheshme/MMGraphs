# MMGraphs
Contains<br />
<br /> 1)Interactive Line
<br /> 2)Interactive Bar
<br /> 3)Interactive Horizontal bar
<br /> 4)Interactive Symmetry
<br /> 5)Interactive Scattert Plot
<br /> 6)Multi scatter Plot
<br /> 7)Area graph
<br /> 8)Dynamic line
<br /> 9)Dynamic Bar
<br /> 10)Dynamic Scattert Plot graphs in it
  
<br />  Light weight graphs, supports negitive plot, effective interaction.<br />

**How to use:** 
<br />Each graph is seperate UIView component except dynamic graphs, u just need to import that and allocate using proper init, then add to subview. In dynamic graphs u need to pass what type of graph i.e.., line, bar or scatter plot.<br /> 
<br /> Interactive line is static graph where u can see interactions using a scroll button on x-axis. Value will be displayed at top of graph, and plot intraval is 1 min. You can customize like** MAX_X_AXIS_LABELS, TIME_INTERVAL, STARTING_Y, ENDING_Y, STARTING_X** by going in to that class. These are macros so just change them at declaration. And for data in **GraphModel.m** <br />**+(NSArray *)getMinuteDataFor:(int)numberOfMinutes**, return your data in array of **GraphPlotObj** form.<br />
<br /> Follow same for Interactive Bar, Interactive Horizontal bar, Interactive Scattert Plot, Interactive Symmetry, Multi scatter Plot. Use **+(NSArray *)getDataForDays:(int)days withUpperLimit:(int)upperLimit andLowerlimit:(int)lowerLimit** method to return data for all of them.<br />
<br />If you want to change bar width or spacing or wher the graph should start, go to class and change the macros as suggested above. <br />
<br />I have used common method to generate data, u can handle by placing conditions for different graphs. But dont forget convert your data to **GraphPlotObj**.<br />
<br />Download and play arround and check different type of interaction for diferent graphs. There is no interacion for dyanmic graphs.<br /><br />
**Light weight:** 
<br />Tried to make it light weight, except multi graphs other graphs are ploted using one bezierpath instance, no buttons are used for interactions except in Interactive line(two buttons one on x-axis and other on graph line).<br />
