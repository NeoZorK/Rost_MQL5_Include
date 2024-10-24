//+------------------------------------------------------------------+
//|                                                  RIndicators.mqh |
//|               Copyright 2024 - 2025, \x2662 Rostyslav Shcherbyna |
//|  All info and Actions with Indicators                            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024 - 2025,\x2662 Rostyslav Shcherbyna"
#property description "\x2620 RPositions Class"
#property description " All info and Actions with Indicators  "
#property link      "\x2620 neozork@protonmail.com"
#property version   "1.00"
/*
Designed for by Open Bar Only.
Description:
 All info and Actions with Indicators,
 Strong, Fast and Efficient Using of Indicators!
 
 Main Function : Connect\GetBuffer Various Indicators as One QUERY.
 
 Prime Connection TRADING RULE < -- > SIGNAL,  not worring about middle settings
 like: ind name,buffers,
 
 For simple using with TR open\close ::: like : if TR 1 or TR 12 ->
  then connect indictor 1 + indicator 6  -> then
  -> get buffer 4 of indicator 1 and get buffer 2 of indicator 6

Ind Name
Ind Path
Ind Handle

----- DO NOT WASTE TIME -> and write in ONCE at Python -> Double Profit -> 
1) Learn Python
2) then Connect this Class to this EA -> As Example of Using Python code with MT5 
3) Extend own Future Universal Python Platform - that can work at Any Operation System on Terminal\Console : IOS\Android\MacOS\Win\UnixBased
4) NO WEB DEPENDENCIES AT ALL!!!!
5) Backtesting Fast -> even on IOS GPU -> using future ML\AI -> and other Popular words..

- Connect Indicators
- Get Buffer of Indicators
- Store Input
- Store Last Indicator Direction
- Store Last Indicator Signal
- Store Previous Indicator Direction
- Store Previous Indicator Signal
- Release from Chart Indicators
- Possibility to dynamically change Ind Input and query!

*/
