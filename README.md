# 🚀 Rost_MQL5_Include

A comprehensive collection of MQL5 include files for MetaTrader 5 Expert Advisors and Indicators, providing advanced trading functionality, position management, risk control, and technical analysis tools.

## 👨‍💻 About Me

**NeoZorK** (Rostyslav Shcherbyna) is a professional MQL5 developer with extensive experience in algorithmic trading and financial markets. Specializing in creating robust, efficient, and feature-rich trading systems for MetaTrader 5 platform.

🔗 [LinkedIn Profile](https://www.linkedin.com/in/rostyslav-sh-) - Connect with me for professional networking and collaboration opportunities in algorithmic trading development.

## 📋 Overview

This repository contains a comprehensive set of MQL5 include files designed to work with `SCHR_Global.mq5` Expert Advisor. These include files provide modular, reusable functionality for various trading operations, making it easy to build sophisticated trading systems.

## ⚙️ Include Files Functionality

### 🎯 Core Position Management

#### `RPositions.mqh` - Advanced Position Management
- **Universal position handling** for both Netting and Hedging accounts
- **Comprehensive position calculations** including count, profit/loss, weighted averages
- **Multiple closing strategies** with 52 different close type triggers
- **Position limits management** (total, buy, sell, group limits)
- **TTL (Time To Live) closing** with configurable time-based exit strategies
- **Group position management** for parent-child position relationships
- **Dynamic array management** for efficient memory usage
- **FIFO closing support** for regulatory compliance

#### `RAddVolume.mqh` - Position Volume Management
- **Hedging account support** for adding volume to existing positions
- **Martin volume strategies** with configurable multipliers
- **Default volume management** for consistent position sizing
- **Spread protection** with maximum spread limits
- **Automatic position grouping** and relationship tracking
- **Volume limit controls** to prevent excessive exposure
- **Support position management** with automatic comment parsing

#### `RClose.mqh` - Advanced Position Closing
- **Multiple closing strategies** (profit, loss, group-based)
- **Three measurement types**: Money, Points, Percentage from Balance
- **Flexible closing rules** for BUYs, SELLs, or Total positions
- **Group-based closing** for related position management
- **TTL closing support** with time-based exit conditions
- **Statistics tracking** for all closing operations
- **Configurable closing parameters** for different market conditions

### Risk Management & Protection

#### `RAccProtect.mqh` - Account Protection System
- **Negative balance protection** with automatic expert removal
- **Virtual StopOut levels** in both money and percentage terms
- **Automatic position closure** before expert removal
- **Real-time balance monitoring** with configurable thresholds
- **Equity protection** with customizable limits
- **Emergency shutdown** capabilities for risk management

#### `RMarginLimit.mqh` - Margin Management
- **Symbol-specific margin limits** with percentage controls
- **Free margin monitoring** from current equity
- **Used margin tracking** with real-time updates
- **Automatic position blocking** when limits are exceeded
- **Configurable margin thresholds** for different risk profiles

#### `RFee.mqh` - Commission & Fee Management
- **Netting account support** for fee calculations
- **Transaction type detection** (open, close, add, reverse)
- **Automatic fee withdrawal** using TesterWithdrawal()
- **Virtual fee tracking** for strategy analysis
- **Position volume-based** fee calculations
- **Real-time fee monitoring** and reporting

### Trading Strategy Components

#### `RTrailing.mqh` - Advanced Trailing Stop System
- **7 different trailing types** including server SL and virtual trailing
- **Individual position trailing** with separate controls
- **Group-based trailing** for related positions
- **BUY/SELL specific trailing** with independent parameters
- **Summary trailing** for overall position management
- **Speed-based trailing** with configurable movement thresholds
- **Fast window closing** for quick profit taking

#### `RSingleMartin.mqh` - Single Position Martin Strategy
- **Single position management** with Martin volume progression
- **Multiple combination types** (Fast, Pyramid 2, Pyramid 3)
- **Balance-based progression** with automatic resets
- **Volume limit controls** to prevent excessive exposure
- **Signal combination management** for complex strategies

#### `RDynCmpd.mqh` - Dynamic Compounding System
- **Static compounding** based on initial balance
- **Dynamic compounding** based on current balance
- **Percentage-based volume** calculations from account
- **Broker limit compliance** with automatic adjustments
- **Volume step management** for different instruments
- **Risk coefficient controls** for compounding speed

### Utility & Support Classes

#### `RDynArrManage.mqh` - Dynamic Array Management
- **Automatic memory management** for position arrays
- **Configurable reserve sizes** with minimum and maximum limits
- **Dynamic scaling** based on position count changes
- **Memory optimization** for large position counts
- **Performance monitoring** with automatic adjustments

#### `ROnOpenPrice.mqh` - New Bar Detection
- **Efficient new bar detection** for Open Bar strategies
- **Tick-based or bar-based** calculation modes
- **Memory-efficient implementation** with minimal overhead
- **Real-time bar monitoring** for strategy execution

#### `RNotify.mqh` - Notification System
- **Alert notifications** with customizable content
- **Push notifications** with rate limiting compliance
- **Account information display** (broker, server, holder)
- **Trade mode indicators** (Demo/Real/Contest)
- **FIFO account detection** for regulatory compliance

#### `RIndicators.mqh` - Indicator Management
- **Universal indicator connection** and management
- **Buffer access** for multiple indicator data
- **Dynamic input management** for strategy adaptation
- **Performance optimization** for real-time trading
- **Multi-indicator support** for complex strategies

### Data Export & Analysis

#### `RExportData.mqh` - Data Export System
- **CSV export functionality** for strategy analysis
- **Indicator data export** with OHLCV information
- **Custom buffer selection** for specific data needs
- **Automatic file naming** with symbol and timeframe
- **Performance monitoring** with export timing

#### `RSAbilityIndex.mqh` - Strategy Performance Analysis
- **7-layer analysis** (2, 5, 20, 50, 100, 500, 1000 bars)
- **Maximum profit/loss tracking** for signal evaluation
- **Risk assessment** with configurable thresholds
- **Win rate calculations** with relative performance metrics
- **Signal frequency analysis** for strategy optimization
- **Performance benchmarking** across different timeframes

## Dependencies

This include library requires the following external repositories:

- **[RExperts](https://github.com/NeoZorK/RExperts)** - Expert Advisor implementations and examples
- **[RIndicators](https://github.com/NeoZorK/RIndicators)** - Technical indicators and analysis tools

## Quick Start Guide

### Prerequisites

1. **MetaTrader 5** with MQL5 support
2. **MQL5 Editor** for code compilation
3. **Access to RExperts and RIndicators repositories**

### Installation

1. **Clone this repository** to your MetaTrader 5 `Include` folder:
   ```
   C:\Users\[Username]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Include\
   ```

2. **Clone RExperts repository** to your `Experts` folder:
   ```
   C:\Users\[Username]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Experts\
   ```

3. **Clone RIndicators repository** to your `Indicators` folder:
   ```
   C:\Users\[Username]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Indicators\
   ```

### Basic Usage Example

```mql5
#include <RInclude\RPositions.mqh>
#include <RInclude\RAccProtect.mqh>
#include <RInclude\RTrailing.mqh>

// Initialize classes
RPositions positions;
RAccProtect accountProtection;
RTrail trailing;

void OnInit()
{
    // Initialize position management
    STRUCT_INIT_POSITIONS posInit = {
        .magic = 12345,
        .pair = _Symbol,
        .order_type_filling = ORDER_FILLING_FOK,
        .total_pos_limit = 10,
        .total_buy_pos_count_limit = 5,
        .total_sell_pos_count_limit = 5,
        .total_groups_count_limit = 3
    };
    positions.Init(posInit);
    
    // Initialize account protection
    STRUCT_INIT_ACCPROTECT accInit = {
        .pair = _Symbol,
        .magic = 12345,
        .Order_Type_Filling = ORDER_FILLING_FOK,
        .VSO_Level_inMoney = 1000,
        .VSO_Level_inPcnt = 20,
        .NB_RemoveExpert = true,
        .NB_CloseAllPositions = true,
        .VSO_RemoveExpert = true,
        .VSO_CloseAllPositions = true
    };
    accountProtection.Init(accInit);
    
    // Initialize trailing system
    STRUCT_INIT_TRAILING trailInit = {
        .pair = _Symbol,
        .magic = 12345,
        .EachPos_distance_pts = 50,
        .EachPos_trail_type = EachPos_Virt,
        .EachPos_VirtTrail_Speed = 10
    };
    trailing.Init(trailInit);
}

void OnTick()
{
    // Account protection check (first line of code)
    accountProtection.AccProtection();
    
    // Your trading logic here
    // ...
    
    // Position management
    if(positions.Total_Pos_Count_Exceeds())
    {
        Print("Position limit reached");
        return;
    }
    
    // Trailing management
    STRUCT_PARENT_POS parentList[];
    trailing.Trailing(parentList);
}
```

### Advanced Features

#### Position Grouping
```mql5
// Create parent position with comment "&Parent&"
positions.OpenMarketOrder(0.1, BUY, 50, 100, "&Parent&");

// Support positions will be automatically marked
// with comments like "&123456789&1", "&123456789&2"
```

#### Dynamic Compounding
```mql5
#include <RInclude\RDynCmpd.mqh>

RDynCmpd compounding;
STRUCT_INIT_DYNCMPD compInit = {
    .pair = _Symbol,
    .default_volume = 0.01,
    .max_volume = 1.0,
    .magic = 12345,
    .pcnt_from_account = 5,
    .cmpd_break_koef = 100,
    .cmpd_type = CMPD_STATIC
};
compounding.Init(compInit);

double newVolume = 0.01;
if(compounding.Adjust_Static_CompoundVolume(0.01, newVolume))
{
    Print("New volume: ", newVolume);
}
```

#### Risk Management
```mql5
// Check margin limits before opening positions
if(!marginLimit.Pass_Margin_pcnt_Limit())
{
    Print("Margin limit exceeded");
    return;
}

// Monitor account protection
accountProtection.AccProtection();
```

## Configuration

### Key Parameters

- **Magic Numbers**: Unique identifiers for each expert instance
- **Position Limits**: Maximum number of positions, groups, and direction-specific limits
- **Risk Parameters**: Stop loss, take profit, and margin thresholds
- **Trailing Settings**: Distance, speed, and type configurations
- **Volume Management**: Default volumes, Martin multipliers, and compounding settings

### Best Practices

1. **Always initialize account protection** first in OnTick()
2. **Use appropriate magic numbers** for different strategies
3. **Set reasonable position limits** based on account size
4. **Monitor margin usage** to prevent account issues
5. **Test thoroughly** in strategy tester before live trading

## Performance Considerations

- **Open Bar Only**: Most classes are designed for Open Bar strategies
- **Memory Management**: Dynamic arrays automatically optimize memory usage
- **Efficient Calculations**: Minimized redundant calculations in loops
- **Error Handling**: Comprehensive error checking and logging

## Support & Contributing

For support, questions, or contributions:

- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Join GitHub Discussions for community support
- **Contributions**: Pull requests are welcome for improvements and bug fixes

## License

MIT License

Copyright (c) 2020-2025 NeoZorK (Rostyslav Shcherbyna)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Disclaimer

This software is for educational and research purposes. Trading involves substantial risk of loss and is not suitable for all investors. Past performance does not guarantee future results. Always test thoroughly in a demo environment before using with real money.

---

## 📞 Contacts

**Author:** Shcherbyna Rostyslav  
   
**Documentation Version:** 1.0  
**Last Updated:** 2025

⚠️ **Warning:** Trading on financial markets involves high risks. Use these experts at your own risk.
