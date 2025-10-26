//+------------------------------------------------------------------+
//|                                                   FBO_Helper.mq5 |
//|                                      Fake Breakout Helper v2.04  |
//+------------------------------------------------------------------+
#property copyright "FBO Helper Indicator"
#property link      ""
#property version   "2.04"
#property indicator_chart_window
#property indicator_plots 0

//+------------------------------------------------------------------+
//| Enumerations                                                      |
//+------------------------------------------------------------------+
enum ENUM_CALC_MODE
{
   CALC_AUTO,      // Auto
   CALC_MANUAL     // Manual
};
//+------------------------------------------------------------------+
//| SL Auto Mode Enum                                                |
//+------------------------------------------------------------------+
enum ENUM_SL_AUTO_MODE
{
   SL_AUTO_MODE_CANDLE,   // Based on Candle
   SL_AUTO_MODE_ATR       // Based on ATR
};

//+------------------------------------------------------------------+
//| Input Parameters - Stop Loss Manual                             |
//+------------------------------------------------------------------+
input group "=== Stop Loss Manual ==="
input int            InpManualStopLoss = 30000;            // Manual StopLoss (Points)
input int            InpManualBreakout = 10000;            // Manual Breakout (Points)

//+------------------------------------------------------------------+
//| Input Parameters - Stop Loss Auto                               |
//+------------------------------------------------------------------+
input group "=== Stop Loss Auto ==="
input ENUM_CALC_MODE InpCalculationMode = CALC_AUTO;       // Calculation Mode
input ENUM_SL_AUTO_MODE InpSLAutoMode = SL_AUTO_MODE_ATR;  // SL Auto Mode
input int            InpATRPeriod = 78;                    // Candle Count / ATR Period
input double         InpSLMultiplier = 1.0;                // Multiplier

//+------------------------------------------------------------------+
//| Input Parameters - Highlight Settings                            |
//+------------------------------------------------------------------+
input group "=== Highlight Settings ==="
input int            InpHighlightCandlesBefore = 1;        // Highlight Candles Before
input int            InpHighlightCandlesAfter = 1;         // Highlight Candles After
input color          InpHighlightColor = 10288896;         // Highlight Color

//+------------------------------------------------------------------+
//| Input Parameters - High Line Settings                            |
//+------------------------------------------------------------------+
input group "=== High Line Settings ==="
input color          InpHighLineColor = 5573631;           // High Line Color
input int            InpHighLineWidth = 1;                 // High Line Width
input ENUM_LINE_STYLE InpHighLineStyle = STYLE_SOLID;      // High Line Style

//+------------------------------------------------------------------+
//| Input Parameters - Low Line Settings                             |
//+------------------------------------------------------------------+
input group "=== Low Line Settings ==="
input color          InpLowLineColor = 51976;               // Low Line Color
input int            InpLowLineWidth = 1;                  // Low Line Width
input ENUM_LINE_STYLE InpLowLineStyle = STYLE_SOLID;       // Low Line Style

//+------------------------------------------------------------------+
//| Input Parameters - Line Drawing Settings                         |
//+------------------------------------------------------------------+
input group "=== Line Drawing Settings ==="
input int            InpMagnetCandleRange = 3;             // Magnet Candle Range

//+------------------------------------------------------------------+
//| Double Shadow Behavior Enum                                      |
//+------------------------------------------------------------------+
enum ENUM_DOUBLE_SHADOW_MODE
{
   DOUBLE_SHADOW_IGNORE,     // Ignore (Default)
   DOUBLE_SHADOW_BOTH,       // Mark Both High and Low
   DOUBLE_SHADOW_LARGER      // Mark Only Larger Shadow
};

//+------------------------------------------------------------------+
//| Input Parameters - Auto Detection (Unmitigated Levels)          |
//+------------------------------------------------------------------+
input group "=== Auto-Detection: Unmitigated Levels ==="
input int            InpLookbackCandles = 200;             // Lookback Candles
input int            InpSwingLeftBars = 1;                 // Swing Left Bars
input int            InpSwingRightBars = 1;                // Swing Right Bars
input int            InpValidationCount = 5;               // Last N Swings to Validate (0=disable)
input int            InpMinShadowSize = 0;                 // Min Pin Bar Shadow Size in Points (0=disable)
input ENUM_DOUBLE_SHADOW_MODE InpDoubleShadowMode = DOUBLE_SHADOW_IGNORE; // Double Shadow Behavior
input int            InpMergeProximity = 200;              // Merge Proximity (Points)

//+------------------------------------------------------------------+
//| Input Parameters - Fibonacci Settings                            |
//+------------------------------------------------------------------+
input group "=== Fibonacci Settings ==="
input color          InpFiboLineColorBuy = 51976;          // Fibo Line Color (Buy)
input color          InpFiboLineColorSell = 5573631;       // Fibo Line Color (Sell)
input color          InpFiboLineColorRecoveryBuy = 5573631;// Recovery Fibo Color (Buy becomes Sell)
input color          InpFiboLineColorRecoverySell = 51976; // Recovery Fibo Color (Sell becomes Buy)
input int            InpFiboLength = 5;                    // Fibo Length (Candles)
input int            InpFiboFirstOffset = 1;               // First Fibo Offset (Candles)
input int            InpFiboSubsequentOffset = 5;          // Subsequent Fibo Offset (Candles)
input bool           InpUpdateFiboLabelsOnSL = true;       // Update Fibo Labels on SL

//+------------------------------------------------------------------+
//| Input Parameters - Fibo Labels Sell (Initial)                    |
//+------------------------------------------------------------------+
input group "=== Fibo Labels Sell (Initial) ==="
input string         InpFiboSellLevel3Label = "tp";        // Level 3 Label
input string         InpFiboSellLevel1Label = "entry";     // Level 1 Label
input string         InpFiboSellLevel0Label = "sl";        // Level 0 Label
input string         InpFiboSellLevelMinus2Label = "rc.tp"; // Level -2 Label

//+------------------------------------------------------------------+
//| Input Parameters - Fibo Labels Sell (Recovery)                   |
//+------------------------------------------------------------------+
input group "=== Fibo Labels Sell (Recovery) ==="
input string         InpFiboSellLevel1LabelRecov = "rc.entry"; // Level 1 Label (Recovery)
input string         InpFiboSellLevel0LabelRecov = "rc.sl";  // Level 0 Label (Recovery)

//+------------------------------------------------------------------+
//| Input Parameters - Fibo Labels Buy (Initial)                     |
//+------------------------------------------------------------------+
input group "=== Fibo Labels Buy (Initial) ==="
input string         InpFiboBuyLevel3Label = "rc.tp";      // Level 3 Label
input string         InpFiboBuyLevel1Label = "sl";         // Level 1 Label
input string         InpFiboBuyLevel0Label = "entry";      // Level 0 Label
input string         InpFiboBuyLevelMinus2Label = "tp";    // Level -2 Label

//+------------------------------------------------------------------+
//| Input Parameters - Fibo Labels Buy (Recovery)                    |
//+------------------------------------------------------------------+
input group "=== Fibo Labels Buy (Recovery) ==="
input string         InpFiboBuyLevel1LabelRecov = "rc.sl";    // Level 1 Label (Recovery)
input string         InpFiboBuyLevel0LabelRecov = "rc.entry"; // Level 0 Label (Recovery)

//+------------------------------------------------------------------+
//| Input Parameters - Auto Mode Settings                            |
//+------------------------------------------------------------------+
input group "=== Auto Mode Settings ==="
input bool           InpUseSpread = true;                    // Use Spread for Entry/SL Monitoring

//+------------------------------------------------------------------+
//| Input Parameters - Timer Settings                                |
//+------------------------------------------------------------------+
input group "=== Timer Settings ==="
input bool           InpEnableTimer = true;                // Enable Timer
input int            InpTimerDuration = 40;                // Timer Duration (Seconds)
input ENUM_BASE_CORNER InpTimerCorner = CORNER_RIGHT_UPPER;// Timer Anchor Corner
input int            InpTimerX = 68;                       // Timer X Position
input int            InpTimerY = 612;                      // Timer Y Position
input int            InpTimerFontSize = 15;                // Timer Font Size (Icon + Number)
input color          InpTimerColorDefault = 4737096;       // Timer Color (Default)
input color          InpTimerColorArmed = 45055;           // Timer Color (Armed)
input color          InpTimerColorActiveHigh = 5573631;    // Timer Color (Active > 10s)
input color          InpTimerColorActiveLow = 51976;       // Timer Color (Active <= 10s)

//+------------------------------------------------------------------+
//| Input Parameters - Timeframe Warning                             |
//+------------------------------------------------------------------+
input group "=== Timeframe Warning Settings ==="
input bool           InpEnableTimeframeWarning = true;     // Enable Timeframe Warning
input ENUM_TIMEFRAMES InpWarningTimeframe = PERIOD_M5;     // Warning Timeframe
input string         InpWarningText = "WARNING: Timeframe is not M5!"; // Warning Text
input int            InpWarningX = 40;                     // Warning X Position
input int            InpWarningY = 40;                     // Warning Y Position
input int            InpWarningFontSize = 10;              // Warning Font Size
input color          InpWarningColor = 5573631;            // Warning Font Color

//+------------------------------------------------------------------+
//| Input Parameters - Symbol Warning (NEW)                          |
//+------------------------------------------------------------------+
input group "=== Symbol Warning Settings ==="
input bool           InpEnableSymbolWarning = true;        // Enable Symbol Warning
input string         InpWarningSymbol = "US30";            // Warning Symbol (e.g., US30, GDAXI, NAS100)
input string         InpSymbolWarningText = "WARNING: Symbol is not US30!"; // Symbol Warning Text
input int            InpSymbolWarningX = 40;               // Symbol Warning X Position
input int            InpSymbolWarningY = 70;               // Symbol Warning Y Position (below timeframe warning)
input int            InpSymbolWarningFontSize = 10;        // Symbol Warning Font Size
input color          InpSymbolWarningColor = 5573631;      // Symbol Warning Font Color

//+------------------------------------------------------------------+
//| Input Parameters - Motivational Alert Settings (NEW)             |
//+------------------------------------------------------------------+
input group "=== Motivational Alert Settings ==="
input bool           InpEnableAlerts = true;               // Enable Motivational Alerts
input string         InpAlertTextWin = "🔥 BOOM!";         // Win Text (use '|' for newline)
input string         InpAlertTextRecov = "🚀 EPIC RECOVERY!"; // Recovery Win Text (use '|' for newline)
input string         InpAlertTextLoss = "💎 DISCIPLINE MEDAL! Tomorrow is yours."; // Loss Text (use '|' for newline)

//+------------------------------------------------------------------+
//| Input Parameters - UI Panel Settings                             |
//+------------------------------------------------------------------+
input group "=== UI Panel Settings ==="
input ENUM_BASE_CORNER InpPanelCorner = CORNER_RIGHT_UPPER; // Panel Anchor Corner
input int            InpPanelPaddingX = 125;               // Panel Padding X (from corner)
input int            InpPanelPaddingY = 450;               // Panel Padding Y (from corner)
input int            InpButtonWidth = 100;                 // Button Width
input int            InpButtonHeight = 35;                 // Button Height
input int            InpButtonSpacingH = 5;                // Button Horizontal Spacing
input int            InpButtonSpacingV = 5;                // Button Vertical Spacing
input color          InpButtonColorNormal = 4737096;       // Button Color (Normal)
input color          InpButtonColorPressed = 16777215;     // Button Color (Pressed)
input color          InpButtonColorActive = 16766720;      // Button Color (Active)
input color          InpButtonTextColor = 16777215;        // Button Text Color
input int            InpButtonFontSize = 8;                // Button Font Size

//+------------------------------------------------------------------+
//| Input Parameters - Display Text Settings                         |
//+------------------------------------------------------------------+
input group "=== Display Text Settings ==="
input ENUM_BASE_CORNER InpTextCorner = CORNER_RIGHT_UPPER; // Text Anchor Corner
input int            InpTextX = 230;                       // Text X Position
input int            InpTextY = 616;                       // Text Y Position
input color          InpTextColor = 4737096;               // Text Color
input int            InpTextFontSize = 8;                  // Text Font Size

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
// UI Button Names
string g_btnHigh = "FBO_BTN_HIGH";
string g_btnLow = "FBO_BTN_LOW";
string g_btnBuyFibo = "FBO_BTN_BUY_FIBO";
string g_btnSellFibo = "FBO_BTN_SELL_FIBO";
string g_btnStart = "FBO_BTN_START";
string g_btnReset = "FBO_BTN_RESET";
string g_btnAutoDetect = "FBO_BTN_AUTO_DETECT";
string g_btnMerge = "FBO_BTN_MERGE";
// UI Label Names
string g_lblStopLoss = "FBO_LBL_SL";
string g_lblBreakout = "FBO_LBL_BO";
string g_lblTimer = "FBO_LBL_TIMER";
string g_lblWarning = "FBO_LBL_WARNING";
string g_lblSymbolWarning = "FBO_LBL_SYM_WARNING"; 

// Button States
bool g_isHighActive = false;
bool g_isLowActive = false;
bool g_isUIClick = false; // Flag to distinguish UI clicks from chart clicks

// Auto-Detection State
datetime g_lastDetectionTime = 0;
string g_autoLinePrefix = "FBO_AUTO_";

// Line Management
string g_linePrefix = "FBO_LINE_";
string g_boxPrefix = "FBO_BOX_";
string g_fiboPrefix = "FBO_FIBO_";
int g_lineCounter = 0;
int g_boxCounter = 0;
int g_fiboCounter = 0;
// Line History for Undo
string g_lineHistory[];
int g_lineHistoryCount = 0;

// Manual Fibo click tracking
int g_manualFiboCount_Buy = 0;
int g_manualFiboCount_Sell = 0;
string g_manualUsedLines_Buy[];
string g_manualUsedLines_Sell[];

// Calculated Values
int g_calculatedSL = 0;
int g_calculatedBreakout = 0;
// Trade States
enum ENUM_TRADE_STATE
{
   TRADE_STATE_NONE,              // No trade
   TRADE_STATE_BREAKOUT,          // Breakout occurred, waiting for entry
   TRADE_STATE_ACTIVE,            // Trade is active
   TRADE_STATE_RECOVERY          // Recovery trade is active
};
// Fibonacci Tracking Structure
struct FiboInfo
{
   string fiboName;
   string lineName;
   bool isLocked;
   double entryPrice;
   double slPrice;
   double tpPrice;
   int    offsetCandles;
};

// Auto Mode State
bool g_autoModeActive = false;
FiboInfo g_primaryFibo;           // First fibo (broken line)
FiboInfo g_secondaryFibo;         // Second fibo (next line)
bool g_isBuySetup = false;        // true = Buy (Low broken), false = Sell (High broken)
ENUM_TRADE_STATE g_tradeState = TRADE_STATE_NONE;
datetime g_tradeActivationTime = 0;
string g_lastHighlightBoxName = ""; // To track the last highlight box

string g_lastAutoLine1 = "";
string g_lastAutoLine2 = "";

// Timer
int g_timerSeconds = 0;           // This is now just the remaining duration
bool g_tradeActive = false;       // "timer is running"

// Breakout Tracking
struct BreakoutInfo
{
   string lineName;
   bool breakoutOccurred;
   datetime breakoutTime;
   int breakoutBar;
};
BreakoutInfo g_breakoutHistory[];

// Helper struct for sorting lines
struct LinePrice
{
   string name;
   double price;
};

//+------------------------------------------------------------------+
//| Forward Declarations                                             |
//+------------------------------------------------------------------+
void ProcessInitialState();
void CheckInitialBreakout();
void ProcessBreakoutState();
void DrawNextSecondaryFibo();
void ProcessActiveState();
void ProcessRecoveryState();
bool IsLineBreakoutProcessed(string lineName);
void ResetManualFiboTracking();
string FindNextNearestLine(string lineType, string &usedLines[]);
void RemoveLineFromHistory(string lineName);
void CheckSymbolWarning();
void SetTimerState(ENUM_TRADE_STATE state);
void FindTwoSequentialLines(string &line1, string &line2);
void ShowAlertMessage(int type);
// Auto-Detection Functions
void DetectUnmitigatedLevels();
bool IsSwingHigh(int bar);
bool IsSwingLow(int bar);
bool IsUnmitigated(double price, bool isHigh, int fromBar);
bool IsPinBar(int bar, bool &isHighPinBar, bool &isLowPinBar);
bool HasConsumedLevelAfter(int barIndex);
void MergeNearbyLevels();
// Cleanup Functions
void CleanAllExceptActiveTrade();


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Create UI Panel (Buttons only)
   CreateUIPanel();
   // Create Timer Label (if enabled)
   if(InpEnableTimer)
   {
      CreateTextLabel(g_lblTimer, "--", InpTimerX, InpTimerY, InpTimerCorner);
      ObjectSetInteger(0, g_lblTimer, OBJPROP_FONTSIZE, InpTimerFontSize);
      ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, InpTimerColorDefault); // Default state
   }
   
   // Create SL/Breakout Labels
   CreateTextLabel(g_lblStopLoss, "Stop loss: 0", InpTextX, InpTextY, InpTextCorner);
   CreateTextLabel(g_lblBreakout, "Breakout: 0", InpTextX, InpTextY + 20, InpTextCorner); 

   // Display calculated values (populates the labels created above)
   UpdateCalculatedValues();
   // Check timeframe warning
   CheckTimeframeWarning();
   
   // Check symbol warning
   CheckSymbolWarning();
   // Enable chart events
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Always delete UI
   DeleteUIPanel();
   if(reason == REASON_REMOVE)
   {
      // Full cleanup when indicator is removed
      CleanAllObjects();
   }
   else if(reason == REASON_CHARTCHANGE || reason == REASON_PARAMETERS)
   {
      // On reload, parameter change, or timeframe change:
      // Only clean calculated objects. Preserve manual lines.
      CleanAllBoxes();
      CleanAllFibos();
      ResetAutoMode(); // Reset state machine
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   // Update calculated values in auto mode
   if(InpCalculationMode == CALC_AUTO)
   {
      UpdateCalculatedValues();
   }

   // Check for breakouts (Manual mode)
   if(!g_autoModeActive)
   {
      CheckBreakouts();
   }

   // Auto mode logic
   if(g_autoModeActive)
   {
      ProcessAutoMode();
   }

   // Update timer if active
   if(g_tradeActive && InpEnableTimer)
   {
      UpdateTimer();
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // Handle mouse click events
   if(id == CHARTEVENT_CLICK)
   {
      if(g_isUIClick)
      {
         g_isUIClick = false; 
         return;             
      }
      
      int x = (int)lparam;
      int y = (int)dparam;

      if(g_isHighActive || g_isLowActive)
      {
         HandleLineDrawing(x, y);
      }
   }

   // Handle object click events
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      g_isUIClick = true;
      HandleButtonClick(sparam);
   }

   // Handle keyboard events
   if(id == CHARTEVENT_KEYDOWN)
   {
      HandleKeyPress((int)lparam);
   }
}

//+------------------------------------------------------------------+
//| Create UI Panel                                                  |
//+------------------------------------------------------------------+
void CreateUIPanel()
{
   int x = InpPanelPaddingX;
   int y = InpPanelPaddingY;

   int w = InpButtonWidth;
   int h = InpButtonHeight;
   int spacingH = InpButtonSpacingH;
   int spacingV = InpButtonSpacingV;

   int buttonStartY = y;

   int col1X = x;
   int col2X = x + w + spacingH;

   // Row 1: High | S.Fibo
   CreateButton(g_btnHigh, "High", col1X, buttonStartY, w, h, InpPanelCorner);
   CreateButton(g_btnSellFibo, "S.Fibo", col2X, buttonStartY, w, h, InpPanelCorner);

   // Row 2: Low | B.Fibo
   int row2Y = buttonStartY + h + spacingV;
   CreateButton(g_btnLow, "Low", col1X, row2Y, w, h, InpPanelCorner);
   CreateButton(g_btnBuyFibo, "B.Fibo", col2X, row2Y, w, h, InpPanelCorner);

   // Row 3: LHD | MRG
   int row3Y = row2Y + h + spacingV;
   CreateButton(g_btnAutoDetect, "LHD", col1X, row3Y, w, h, InpPanelCorner);
   CreateButton(g_btnMerge, "MRG", col2X, row3Y, w, h, InpPanelCorner);

   // Row 4: Start | Reset
   int row4Y = row3Y + h + spacingV;
   CreateButton(g_btnStart, "Start", col1X, row4Y, w, h, InpPanelCorner);
   CreateButton(g_btnReset, "Reset", col2X, row4Y, w, h, InpPanelCorner);

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Delete UI Panel                                                  |
//+------------------------------------------------------------------+
void DeleteUIPanel()
{
   ObjectDelete(0, g_btnHigh);
   ObjectDelete(0, g_btnLow);
   ObjectDelete(0, g_btnBuyFibo);
   ObjectDelete(0, g_btnSellFibo);
   ObjectDelete(0, g_btnStart);
   ObjectDelete(0, g_btnMerge);
   ObjectDelete(0, g_btnReset);
   ObjectDelete(0, g_btnAutoDetect);
   ObjectDelete(0, g_lblStopLoss);
   ObjectDelete(0, g_lblBreakout);
   ObjectDelete(0, g_lblTimer);
   ObjectDelete(0, g_lblWarning);
   ObjectDelete(0, g_lblSymbolWarning);
}

//+------------------------------------------------------------------+
//| Create Button                                                    |
//+------------------------------------------------------------------+
void CreateButton(string name, string text, int x, int y, int w, int h, ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER)
{
   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, InpButtonColorNormal);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpButtonTextColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpButtonFontSize);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| Create Text Label                                               |
//+------------------------------------------------------------------+
void CreateTextLabel(string name, string text, int x, int y, ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpTextColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpTextFontSize);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| Update Button State                                             |
//+------------------------------------------------------------------+
void UpdateButtonState(string name, bool active)
{
   if(active)
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, InpButtonColorActive);
   else
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, InpButtonColorNormal);

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Handle Button Click                                             |
//+------------------------------------------------------------------+
void HandleButtonClick(string clickedObject)
{
   // High button
   if(clickedObject == g_btnHigh)
   {
      g_isHighActive = !g_isHighActive;
      ObjectSetInteger(0, g_btnHigh, OBJPROP_STATE, g_isHighActive);
      UpdateButtonState(g_btnHigh, g_isHighActive);

      if(g_isHighActive && g_isLowActive)
      {
         g_isLowActive = false;
         ObjectSetInteger(0, g_btnLow, OBJPROP_STATE, false);
         UpdateButtonState(g_btnLow, false);
      }
   }
   // Low button
   else if(clickedObject == g_btnLow)
   {
      g_isLowActive = !g_isLowActive;
      ObjectSetInteger(0, g_btnLow, OBJPROP_STATE, g_isLowActive);
      UpdateButtonState(g_btnLow, g_isLowActive);

      if(g_isLowActive && g_isHighActive)
      {
         g_isHighActive = false;
         ObjectSetInteger(0, g_btnHigh, OBJPROP_STATE, false);
         UpdateButtonState(g_btnHigh, false);
      }
   }
   // Start button
   else if(clickedObject == g_btnStart)
   {
      g_autoModeActive = !g_autoModeActive;
      ObjectSetInteger(0, g_btnStart, OBJPROP_STATE, g_autoModeActive);
      UpdateButtonState(g_btnStart, g_autoModeActive);

      if(g_autoModeActive)
      {
         ResetAutoMode();
         if(g_isHighActive)
         {
            g_isHighActive = false;
            ObjectSetInteger(0, g_btnHigh, OBJPROP_STATE, false);
            UpdateButtonState(g_btnHigh, false);
         }
         if(g_isLowActive)
         {
            g_isLowActive = false;
            ObjectSetInteger(0, g_btnLow, OBJPROP_STATE, false);
            UpdateButtonState(g_btnLow, false);
         }
      }
      else
      {
         ResetAutoMode();
      }
   }
   // Buy Fibo button
   else if(clickedObject == g_btnBuyFibo)
   {
      ObjectSetInteger(0, g_btnBuyFibo, OBJPROP_STATE, false);
      if(g_autoModeActive) Alert("This button is disabled in Auto mode");
      else DrawManualFibo(true); // true for Buy
   }
   // Sell Fibo button
   else if(clickedObject == g_btnSellFibo)
   {
      ObjectSetInteger(0, g_btnSellFibo, OBJPROP_STATE, false);
      if(g_autoModeActive) Alert("This button is disabled in Auto mode");
      else DrawManualFibo(false); // false for Sell
   }
   // Reset button
   else if(clickedObject == g_btnReset)
   {
      ObjectSetInteger(0, g_btnReset, OBJPROP_STATE, false);
      ResetIndicator();
   }
   // Auto-Detect button (LHD)
   else if(clickedObject == g_btnAutoDetect)
   {
      ObjectSetInteger(0, g_btnAutoDetect, OBJPROP_STATE, false);
      DetectUnmitigatedLevels();
   }
   // Merge button (MRG)
   else if(clickedObject == g_btnMerge)
   {
      ObjectSetInteger(0, g_btnMerge, OBJPROP_STATE, false);
      MergeNearbyLevels(); // Merge nearby levels
   }

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Handle Line Drawing (Magnetic Mode)                             |
//+------------------------------------------------------------------+
void HandleLineDrawing(int x, int y)
{
   int subwindow;
   datetime clickTime;
   double price;
   if(!ChartXYToTimePrice(0, x, y, subwindow, clickTime, price))
      return;

   int centerBar = (int)Bars(_Symbol, _Period, clickTime, TimeCurrent());
   if(centerBar <= 0)
      return;
   centerBar--; 

   int halfRange = InpMagnetCandleRange / 2;
   int startBar = centerBar - halfRange;
   int endBar = centerBar + halfRange;
   if(startBar < 0)
      startBar = 0;
   if(g_isHighActive)
   {
      double highestHigh = -1e100;
      datetime highestTime = 0;
      for(int i = endBar; i >= startBar; i--)
      {
         double high = iHigh(_Symbol, _Period, i);
         if(high > highestHigh)
         {
            highestHigh = high;
            highestTime = iTime(_Symbol, _Period, i);
         }
      }
      if(highestHigh > -1e100) DrawHighLine(highestHigh, highestTime);
   }
   else if(g_isLowActive)
   {
      double lowestLow = 1e100;
      datetime lowestTime = 0;

      for(int i = endBar; i >= startBar; i--)
      {
         double low = iLow(_Symbol, _Period, i);
         if(low < lowestLow)
         {
            lowestLow = low;
            lowestTime = iTime(_Symbol, _Period, i);
         }
      }
      if(lowestLow < 1e100) DrawLowLine(lowestLow, lowestTime);
   }
}

//+------------------------------------------------------------------+
//| Draw High Line                                                   |
//+------------------------------------------------------------------+
void DrawHighLine(double price, datetime time)
{
   string lineName = g_linePrefix + "HIGH_" + IntegerToString(g_lineCounter++);
   ObjectCreate(0, lineName, OBJ_HLINE, 0, time, price);
   ObjectSetInteger(0, lineName, OBJPROP_COLOR, InpHighLineColor);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, InpHighLineWidth);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE, InpHighLineStyle);
   ObjectSetInteger(0, lineName, OBJPROP_BACK, false);
   ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, true);

   ArrayResize(g_lineHistory, g_lineHistoryCount + 1);
   g_lineHistory[g_lineHistoryCount++] = lineName;

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Draw Low Line                                                    |
//+------------------------------------------------------------------+
void DrawLowLine(double price, datetime time)
{
   string lineName = g_linePrefix + "LOW_" + IntegerToString(g_lineCounter++);
   ObjectCreate(0, lineName, OBJ_HLINE, 0, time, price);
   ObjectSetInteger(0, lineName, OBJPROP_COLOR, InpLowLineColor);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, InpLowLineWidth);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE, InpLowLineStyle);
   ObjectSetInteger(0, lineName, OBJPROP_BACK, false);
   ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, true);

   ArrayResize(g_lineHistory, g_lineHistoryCount + 1);
   g_lineHistory[g_lineHistoryCount++] = lineName;

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Clean All Lines                                                  |
//+------------------------------------------------------------------+
void CleanAllLines()
{
   for(int i = ObjectsTotal(0, 0, OBJ_HLINE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_HLINE);
      ObjectDelete(0, name);
   }
   
   ArrayResize(g_lineHistory, 0);
   g_lineHistoryCount = 0;
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Clean All Boxes                                                  |
//+------------------------------------------------------------------+
void CleanAllBoxes()
{
   for(int i = ObjectsTotal(0, 0, OBJ_RECTANGLE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_RECTANGLE);
      ObjectDelete(0, name); 
   }
   
   ArrayResize(g_breakoutHistory, 0);
   g_lastHighlightBoxName = "";
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Clean All Fibos                                                  |
//+------------------------------------------------------------------+
void CleanAllFibos()
{
   for(int i = ObjectsTotal(0, 0, OBJ_FIBO) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_FIBO);
      ObjectDelete(0, name);
   }
   
   ResetManualFiboTracking();
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Clean All Objects                                                |
//+------------------------------------------------------------------+
void CleanAllObjects()
{
   // This is a full clean (now Super-Clean)
   CleanAllLines();
   CleanAllBoxes();
   CleanAllFibos();
}

//+------------------------------------------------------------------+
//| Reset Auto Mode State                                            |
//+------------------------------------------------------------------+
void ResetAutoMode()
{
   // Reset state machine
   g_tradeState = TRADE_STATE_NONE;
   g_tradeActive = false;
   g_tradeActivationTime = 0;
   SetTimerState(TRADE_STATE_NONE);
   // Reset fibo tracking
   g_primaryFibo.fiboName = "";
   g_primaryFibo.lineName = "";
   g_primaryFibo.isLocked = false;
   g_primaryFibo.entryPrice = 0;
   g_primaryFibo.slPrice = 0;
   g_primaryFibo.tpPrice = 0;
   g_primaryFibo.offsetCandles = 0;

   g_secondaryFibo.fiboName = "";
   g_secondaryFibo.lineName = "";
   g_secondaryFibo.isLocked = false;
   g_secondaryFibo.entryPrice = 0;
   g_secondaryFibo.slPrice = 0;
   g_secondaryFibo.tpPrice = 0;
   g_secondaryFibo.offsetCandles = 0;

   g_isBuySetup = false;
   g_lastAutoLine1 = "";
   g_lastAutoLine2 = "";
}

//+------------------------------------------------------------------+
//| Delete ALL Chart Objects (Complete Reset)                        |
//+------------------------------------------------------------------+
void DeleteAllChartObjects()
{
   // Delete ALL Horizontal Lines
   for(int i = ObjectsTotal(0, 0, OBJ_HLINE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_HLINE);
      ObjectDelete(0, name);
   }

   // Delete ALL Trend Lines
   for(int i = ObjectsTotal(0, 0, OBJ_TREND) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_TREND);
      ObjectDelete(0, name);
   }

   // Delete ALL Vertical Lines
   for(int i = ObjectsTotal(0, 0, OBJ_VLINE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_VLINE);
      ObjectDelete(0, name);
   }

   // Delete ALL Rectangles/Boxes
   for(int i = ObjectsTotal(0, 0, OBJ_RECTANGLE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_RECTANGLE);
      ObjectDelete(0, name);
   }

   // Delete ALL Fibonacci Retracements
   for(int i = ObjectsTotal(0, 0, OBJ_FIBO) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_FIBO);
      ObjectDelete(0, name);
   }

   // Reset line history
   ArrayResize(g_lineHistory, 0);
   g_lineHistoryCount = 0;

   // Reset manual fibo tracking
   ResetManualFiboTracking();
}

//+------------------------------------------------------------------+
//| Clean All Objects Except Active Trade                            |
//+------------------------------------------------------------------+
void CleanAllExceptActiveTrade()
{
   // Delete all Horizontal Lines EXCEPT the primary fibo line
   for(int i = ObjectsTotal(0, 0, OBJ_HLINE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_HLINE);
      if(name != g_primaryFibo.lineName)
         ObjectDelete(0, name);
   }

   // Delete all Fibonacci Retracements EXCEPT the primary fibo
   for(int i = ObjectsTotal(0, 0, OBJ_FIBO) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_FIBO);
      if(name != g_primaryFibo.fiboName)
         ObjectDelete(0, name);
   }

   // Delete all Rectangles/Boxes EXCEPT the current highlight
   for(int i = ObjectsTotal(0, 0, OBJ_RECTANGLE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_RECTANGLE);
      if(name != g_lastHighlightBoxName)
         ObjectDelete(0, name);
   }

   // Delete ALL Trend Lines
   for(int i = ObjectsTotal(0, 0, OBJ_TREND) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_TREND);
      ObjectDelete(0, name);
   }

   // Delete ALL Vertical Lines
   for(int i = ObjectsTotal(0, 0, OBJ_VLINE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_VLINE);
      ObjectDelete(0, name);
   }

   // Clear line history except for the primary fibo line
   int newSize = 0;
   if(g_primaryFibo.lineName != "")
   {
      // Keep only the primary line in history
      g_lineHistory[0] = g_primaryFibo.lineName;
      newSize = 1;
   }
   ArrayResize(g_lineHistory, newSize);
   g_lineHistoryCount = newSize;
}

//+------------------------------------------------------------------+
//| Reset Entire Indicator                                           |
//+------------------------------------------------------------------+
void ResetIndicator()
{
   // Delete ALL objects on chart (not just FBO_* ones)
   DeleteAllChartObjects();

   // Reset auto mode (resets state, timer, fibo tracking, line memory)
   ResetAutoMode();

   // Reset button states
   g_isHighActive = false;
   g_isLowActive = false;
   g_autoModeActive = false;

   ObjectSetInteger(0, g_btnHigh, OBJPROP_STATE, false);
   UpdateButtonState(g_btnHigh, false);

   ObjectSetInteger(0, g_btnLow, OBJPROP_STATE, false);
   UpdateButtonState(g_btnLow, false);

   ObjectSetInteger(0, g_btnStart, OBJPROP_STATE, false);
   UpdateButtonState(g_btnStart, false);

   ObjectSetInteger(0, g_btnReset, OBJPROP_BGCOLOR, InpButtonColorNormal);

   // Reset counters
   g_lineCounter = 0;
   g_boxCounter = 0;
   g_fiboCounter = 0;

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Update Calculated Values                                         |
//+------------------------------------------------------------------+
void UpdateCalculatedValues()
{
   if(InpCalculationMode == CALC_MANUAL)
   {
      g_calculatedSL = InpManualStopLoss;
      g_calculatedBreakout = InpManualBreakout;
   }
   else // CALC_AUTO
   {
      double avgSize = 0;
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

      if(InpSLAutoMode == SL_AUTO_MODE_CANDLE)
      {
         // Based on Candle: Average High-Low range
         double totalSize = 0;
         int bars = InpATRPeriod;

         for(int i = 1; i <= bars; i++)
         {
            double high = iHigh(_Symbol, _Period, i);
            double low = iLow(_Symbol, _Period, i);
            totalSize += (high - low);
         }

         avgSize = totalSize / bars;
      }
      else // SL_AUTO_MODE_ATR
      {
         // Based on ATR
         int atr_handle = iATR(_Symbol, _Period, InpATRPeriod);
         if(atr_handle != INVALID_HANDLE)
         {
            double atr_buffer[];
            ArraySetAsSeries(atr_buffer, true);

            if(CopyBuffer(atr_handle, 0, 0, 1, atr_buffer) > 0)
            {
               avgSize = atr_buffer[0];
            }

            IndicatorRelease(atr_handle);
         }

         // Fallback to Candle mode if ATR failed
         if(avgSize == 0)
         {
            double totalSize = 0;
            int bars = InpATRPeriod;

            for(int i = 1; i <= bars; i++)
            {
               double high = iHigh(_Symbol, _Period, i);
               double low = iLow(_Symbol, _Period, i);
               totalSize += (high - low);
            }

            avgSize = totalSize / bars;
         }
      }

      g_calculatedSL = (int)MathRound((avgSize / point) * InpSLMultiplier);
      g_calculatedBreakout = (int)MathRound(g_calculatedSL / 3.0);
   }

   ObjectSetString(0, g_lblStopLoss, OBJPROP_TEXT, "Stop loss: " + IntegerToString(g_calculatedSL));
   ObjectSetString(0, g_lblBreakout, OBJPROP_TEXT, "Breakout: " + IntegerToString(g_calculatedBreakout));
}

//+------------------------------------------------------------------+
//| Check Timeframe Warning                                          |
//+------------------------------------------------------------------+
void CheckTimeframeWarning()
{
   if(!InpEnableTimeframeWarning)
   {
      ObjectDelete(0, g_lblWarning); // Delete if disabled
      return;
   }

   if(_Period != InpWarningTimeframe)
   {
      if(ObjectFind(0, g_lblWarning) < 0)
      {
         CreateTextLabel(g_lblWarning, InpWarningText, InpWarningX, InpWarningY);
      }
      ObjectSetInteger(0, g_lblWarning, OBJPROP_COLOR, InpWarningColor);
      ObjectSetInteger(0, g_lblWarning, OBJPROP_FONTSIZE, InpWarningFontSize);
   }
   else
   {
      ObjectDelete(0, g_lblWarning);
   }
}

//+------------------------------------------------------------------+
//| Check Symbol Warning                                             |
//+------------------------------------------------------------------+
void CheckSymbolWarning()
{
   if(!InpEnableSymbolWarning)
   {
      ObjectDelete(0, g_lblSymbolWarning); // Delete if disabled
      return;
   }

   if(StringFind(_Symbol, InpWarningSymbol, 0) == -1)
   {
      if(ObjectFind(0, g_lblSymbolWarning) < 0)
      {
         CreateTextLabel(g_lblSymbolWarning, InpSymbolWarningText, InpSymbolWarningX, InpSymbolWarningY);
      }
      ObjectSetInteger(0, g_lblSymbolWarning, OBJPROP_COLOR, InpSymbolWarningColor);
      ObjectSetInteger(0, g_lblSymbolWarning, OBJPROP_FONTSIZE, InpSymbolWarningFontSize);
   }
   else
   {
      ObjectDelete(0, g_lblSymbolWarning);
   }
}

//+------------------------------------------------------------------+
//| Check Breakouts (For Manual Mode)                                |
//+------------------------------------------------------------------+
void CheckBreakouts()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int breakoutPoints = g_calculatedBreakout;
   for(int i = 0; i < g_lineHistoryCount; i++)
   {
      string lineName = g_lineHistory[i];
      if(ObjectFind(0, lineName) < 0)
         continue;
      if(IsLineBreakoutProcessed(lineName))
      {
         continue;
      }

      double linePrice = ObjectGetDouble(0, lineName, OBJPROP_PRICE);
      bool isHighLine = (StringFind(lineName, "HIGH") >= 0);
      bool isLowLine = (StringFind(lineName, "LOW") >= 0);

      if(isHighLine)
      {
         if(bid >= linePrice + (breakoutPoints * point))
         {
            CreateBreakoutHighlight(lineName, linePrice, true);
         }
      }
      else if(isLowLine)
      {
         if(bid <= linePrice - (breakoutPoints * point))
         {
            CreateBreakoutHighlight(lineName, linePrice, false);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Create Breakout Highlight Box                                   |
//+------------------------------------------------------------------+
void CreateBreakoutHighlight(string lineName, double linePrice, bool isHigh)
{
   int currentBar = 0;
   datetime currentTime = iTime(_Symbol, _Period, currentBar);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int breakoutPoints = g_calculatedBreakout;

   double priceTop, priceBottom;
   if(isHigh)
   {
      priceBottom = linePrice;
      priceTop = linePrice + (breakoutPoints * point);
   }
   else
   {
      priceTop = linePrice;
      priceBottom = linePrice - (breakoutPoints * point);
   }

   datetime timeStart = iTime(_Symbol, _Period, currentBar + InpHighlightCandlesBefore);
   datetime timeEnd = iTime(_Symbol, _Period, 0) + (PeriodSeconds() * InpHighlightCandlesAfter);
   if(timeEnd <= timeStart)
   {
      timeEnd = timeStart + PeriodSeconds();
   }

   string boxName = g_boxPrefix + IntegerToString(g_boxCounter++);

   ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, timeStart, priceTop, timeEnd, priceBottom);
   ObjectSetInteger(0, boxName, OBJPROP_COLOR, InpHighlightColor);
   ObjectSetInteger(0, boxName, OBJPROP_FILL, true);
   ObjectSetInteger(0, boxName, OBJPROP_BACK, true);
   ObjectSetInteger(0, boxName, OBJPROP_SELECTABLE, false);

   int size = ArraySize(g_breakoutHistory);
   ArrayResize(g_breakoutHistory, size + 1);
   g_breakoutHistory[size].lineName = lineName;
   g_breakoutHistory[size].breakoutOccurred = true;
   g_breakoutHistory[size].breakoutTime = currentTime;
   g_breakoutHistory[size].breakoutBar = currentBar;
   
   g_lastHighlightBoxName = boxName; 

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Process Auto Mode                                                |
//+------------------------------------------------------------------+
void ProcessAutoMode()
{
   if(!g_autoModeActive)
      return;
   switch(g_tradeState)
   {
      case TRADE_STATE_NONE:
         ProcessInitialState();
         break;
      case TRADE_STATE_BREAKOUT:
         ProcessBreakoutState();
         break;
      case TRADE_STATE_ACTIVE:
         ProcessActiveState();
         break;
      case TRADE_STATE_RECOVERY:
         ProcessRecoveryState();
         break;
   }
}

//+------------------------------------------------------------------+
//| Draw Manual Fibo                                                 |
//+------------------------------------------------------------------+
void DrawManualFibo(bool isBuy)
{
   // FBO Logic:
   // isBuy = true (Buy Fibo) -> looks for "LOW" lines
   // isBuy = false (Sell Fibo) -> looks for "HIGH" lines
   string targetLineType = isBuy ? "LOW" : "HIGH";

   int clickCount = isBuy ? g_manualFiboCount_Buy : g_manualFiboCount_Sell;

   string lineName = "";
   if(isBuy)
      lineName = FindNextNearestLine(targetLineType, g_manualUsedLines_Buy);
   else
      lineName = FindNextNearestLine(targetLineType, g_manualUsedLines_Sell);
      
   if(lineName == "")
   {
      Alert("No more " + targetLineType + " lines found!");
      if(clickCount == 0)
         return;
      if(isBuy)
      {
         g_manualFiboCount_Buy = 0;
         ArrayResize(g_manualUsedLines_Buy, 0);
      }
      else
      {
         g_manualFiboCount_Sell = 0;
         ArrayResize(g_manualUsedLines_Sell, 0);
      }
      return;
   }

   if(isBuy)
   {
      int size = ArraySize(g_manualUsedLines_Buy);
      ArrayResize(g_manualUsedLines_Buy, size + 1);
      g_manualUsedLines_Buy[size] = lineName;
   }
   else
   {
      int size = ArraySize(g_manualUsedLines_Sell);
      ArrayResize(g_manualUsedLines_Sell, size + 1);
      g_manualUsedLines_Sell[size] = lineName;
   }

   int offset;
   if(clickCount == 0)
   {
      offset = InpFiboFirstOffset;
   }
   else
   {
      offset = InpFiboFirstOffset + (clickCount * InpFiboSubsequentOffset);
   }

   double linePrice = ObjectGetDouble(0, lineName, OBJPROP_PRICE);
   
   DrawFibonacci(linePrice, isBuy, false, offset); 

   if(isBuy)
      g_manualFiboCount_Buy++;
   else
      g_manualFiboCount_Sell++;
}

//+------------------------------------------------------------------+
//| Draw Fibonacci                                                   |
//+------------------------------------------------------------------+
// FBO Logic (v2.01):
// isBuy = true  (Buy Fibo / on Low Line) -> Lvl 0=SL, Lvl 1=Entry
// isBuy = false (Sell Fibo / on High Line) -> Lvl 0=Entry, Lvl 1=SL
string DrawFibonacci(double linePrice, bool isBuy, bool isRecovery, int offsetCandles)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int slPoints = g_calculatedSL;

   double level0, level1, level3, levelMinus2;

   if(isBuy) // --- BUY FIBO LOGIC ---
   {
      // Buy Fibo levels (for Low Line)
      level0 = linePrice - (slPoints / 2.0) * point;      // sl
      level1 = linePrice + (slPoints / 2.0) * point;      // entry
      level3 = level1 + (slPoints * 2.0) * point;      // tp
      levelMinus2 = level0 - (slPoints * 2.0) * point;   // rc.tp
   }
   else // --- SELL FIBO LOGIC ---
   {
      // Sell Fibo levels (for High Line)
      level0 = linePrice - (slPoints / 2.0) * point;      // entry
      level1 = linePrice + (slPoints / 2.0) * point;      // sl
      level3 = level1 + (slPoints * 2.0) * point;      // rc.tp
      levelMinus2 = level0 - (slPoints * 2.0) * point;   // tp
   }

   string fiboName = g_fiboPrefix + (isBuy ? "BUY_" : "SELL_") + IntegerToString(g_fiboCounter++);
   datetime now = iTime(_Symbol, _Period, 0);
   long periodSeconds = PeriodSeconds();
   
   datetime timeStart = (datetime)(now + (offsetCandles * periodSeconds));
   datetime timeEnd = (datetime)(timeStart + (InpFiboLength * periodSeconds));
 
   ObjectCreate(0, fiboName, OBJ_FIBO, 0, timeStart, level0, timeEnd, level1);
   
   color fiboColor = isBuy ? InpFiboLineColorBuy : InpFiboLineColorSell; 
   
   ObjectSetInteger(0, fiboName, OBJPROP_COLOR, fiboColor);
   ObjectSetInteger(0, fiboName, OBJPROP_BACK, false);
   ObjectSetInteger(0, fiboName, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, fiboName, OBJPROP_RAY_RIGHT, false); 
   
   // Main line style (0-1)
   ObjectSetInteger(0, fiboName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, fiboName, OBJPROP_STYLE, STYLE_DOT);
   
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELS, 4);

   
   // Level 0 (SL for Buy, Entry for Sell)
   ObjectSetDouble(0, fiboName, OBJPROP_LEVELVALUE, 0, 0.0);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 0, fiboColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELWIDTH, 0, 1);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELSTYLE, 0, STYLE_SOLID);
   if(isBuy){ // Is Buy Setup
      if(isRecovery) ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 0, InpFiboBuyLevel0LabelRecov);
      else ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 0, InpFiboBuyLevel0Label);
   } else { // Is Sell Setup
      if(isRecovery) ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 0, InpFiboSellLevel0LabelRecov);
      else ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 0, InpFiboSellLevel0Label);
   }

   // Level 1 (Entry for Buy, SL for Sell)
   ObjectSetDouble(0, fiboName, OBJPROP_LEVELVALUE, 1, 1.0);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 1, fiboColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELWIDTH, 1, 1);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELSTYLE, 1, STYLE_SOLID);
   if(isBuy){ // Is Buy Setup
      if(isRecovery) ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 1, InpFiboBuyLevel1LabelRecov);
      else ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 1, InpFiboBuyLevel1Label);
   } else { // Is Sell Setup
      if(isRecovery) ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 1, InpFiboSellLevel1LabelRecov);
      else ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 1, InpFiboSellLevel1Label);
   }

   // Level 3
   ObjectSetDouble(0, fiboName, OBJPROP_LEVELVALUE, 2, 3.0);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 2, fiboColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELWIDTH, 2, 1);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELSTYLE, 2, STYLE_SOLID);
   ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 2, isBuy ? InpFiboBuyLevel3Label : InpFiboSellLevel3Label);
   
   // Level -2
   ObjectSetDouble(0, fiboName, OBJPROP_LEVELVALUE, 3, -2.0);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 3, fiboColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELWIDTH, 3, 1);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELSTYLE, 3, STYLE_SOLID);
   ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 3, isBuy ? InpFiboBuyLevelMinus2Label : InpFiboSellLevelMinus2Label);

   ChartRedraw();
   return fiboName;
}

//+------------------------------------------------------------------+
//| Find Two Sequential Lines by Price                               |
//+------------------------------------------------------------------+
void FindTwoSequentialLines(string &line1, string &line2)
{
   line1 = "";
   line2 = "";
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   // 1. Find the closest High line and closest Low line
   double distHigh = 1e100, distLow = 1e100;
   string closestHigh = "", closestLow = "";

   for(int i = 0; i < g_lineHistoryCount; i++)
   {
      string lineName = g_lineHistory[i];
      if(ObjectFind(0, lineName) < 0) continue;
      
      double linePrice = ObjectGetDouble(0, lineName, OBJPROP_PRICE);
      double distance = MathAbs(currentPrice - linePrice);
      if(StringFind(lineName, "HIGH") >= 0)
      {
         if(distance < distHigh) { distHigh = distance; closestHigh = lineName; }
      }
      else if(StringFind(lineName, "LOW") >= 0)
      {
         if(distance < distLow) { distLow = distance; closestLow = lineName; }
      }
   }

   // 2. Determine setup type (High or Low)
   if(closestHigh == "" && closestLow == "") return; // No lines found
   
   bool useHigh = (distHigh < distLow);
   string lineType = useHigh ? "HIGH" : "LOW";
   
   // FBO Logic: High lines = Sell setup (false), Low lines = Buy setup (true)
   g_isBuySetup = useHigh ? false : true; 

   // 3. Populate array with all lines of the chosen type
   LinePrice lines[];
   int count = 0;
   for(int i = 0; i < g_lineHistoryCount; i++)
   {
      string lineName = g_lineHistory[i];
      if(ObjectFind(0, lineName) < 0 || StringFind(lineName, lineType) < 0)
         continue;
      ArrayResize(lines, count + 1);
      lines[count].name = lineName;
      lines[count].price = ObjectGetDouble(0, lineName, OBJPROP_PRICE);
      count++;
   }

   if(count == 0) return; // No lines of this type found

   // 4. Sort the array by price
   for(int i = 0; i < count - 1; i++)
   {
      for(int j = 0; j < count - i - 1; j++)
      {
         bool shouldSwap = false;
         if(useHigh) // Sort High lines Ascending (lowest price first)
         {
            if(lines[j].price > lines[j+1].price) shouldSwap = true;
         }
         else // Sort Low lines Descending (highest price first)
         {
            if(lines[j].price < lines[j+1].price) shouldSwap = true;
         }
         
         if(shouldSwap)
         {
            LinePrice temp = lines[j];
            lines[j] = lines[j+1];
            lines[j+1] = temp;
         }
      }
   }

   // 5. Return the first two sequential lines
   if(count > 0) line1 = lines[0].name;
   if(count > 1) line2 = lines[1].name;
}


//+------------------------------------------------------------------+
//| Delete Opposite Lines and Fibos                                 |
//+------------------------------------------------------------------+
void DeleteOppositeType(bool isHighLineBreak)
{
   // FBO Logic:
   // isHighLineBreak = true (Sell Setup) -> Keep HIGH lines, Delete LOW lines
   string typeToDelete = isHighLineBreak ? "LOW" : "HIGH";
   
   // isHighLineBreak = true (Sell Setup) -> Keep SELL_FIBO, Delete BUY_FIBO
   string fiboTypeToDelete = isHighLineBreak ? "FBO_FIBO_BUY" : "FBO_FBO_SELL";

   for(int i = g_lineHistoryCount - 1; i >= 0; i--)
   {
      string lineName = g_lineHistory[i];
      if(StringFind(lineName, typeToDelete) >= 0)
      {
         ObjectDelete(0, lineName);
         RemoveLineFromHistory(lineName); 
      }
   }

   for(int i = ObjectsTotal(0, 0, OBJ_FIBO) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_FIBO);
      if(StringFind(name, fiboTypeToDelete) >= 0)
         ObjectDelete(0, name);
   }

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Process Initial State - Draw 2 Fibos on Sequential Lines         |
//+------------------------------------------------------------------+
void ProcessInitialState()
{
   string line1, line2;
   FindTwoSequentialLines(line1, line2); 

   if(line1 == "") return; // No lines found

   if(line1 != g_lastAutoLine1 || line2 != g_lastAutoLine2)
   {
      if(g_primaryFibo.fiboName != "") ObjectDelete(0, g_primaryFibo.fiboName);
      if(g_secondaryFibo.fiboName != "") ObjectDelete(0, g_secondaryFibo.fiboName);

      // g_isBuySetup is set inside FindTwoSequentialLines
      double line1Price = ObjectGetDouble(0, line1, OBJPROP_PRICE);
      g_primaryFibo.offsetCandles = InpFiboFirstOffset;
      
      g_primaryFibo.fiboName = DrawFibonacci(line1Price, g_isBuySetup, false, g_primaryFibo.offsetCandles);
      g_primaryFibo.lineName = line1;
      g_primaryFibo.isLocked = false;

      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      int slPoints = g_calculatedSL;
      
      // FBO Logic (matches DrawFibonacci v2.01)
      if(g_isBuySetup){ // Buy Fibo
         g_primaryFibo.slPrice = line1Price - (slPoints / 2.0) * point;
         g_primaryFibo.entryPrice = line1Price + (slPoints / 2.0) * point;
         g_primaryFibo.tpPrice = g_primaryFibo.entryPrice + (slPoints * 2.0) * point;
      } else { // Sell Fibo
         g_primaryFibo.entryPrice = line1Price - (slPoints / 2.0) * point;
         g_primaryFibo.slPrice = line1Price + (slPoints / 2.0) * point;
         g_primaryFibo.tpPrice = g_primaryFibo.entryPrice - (slPoints * 2.0) * point;
      }

      if(line2 != "")
      {
         double line2Price = ObjectGetDouble(0, line2, OBJPROP_PRICE);
         int offset = InpFiboFirstOffset + InpFiboSubsequentOffset;
         g_secondaryFibo.offsetCandles = offset;
         
         g_secondaryFibo.fiboName = DrawFibonacci(line2Price, g_isBuySetup, false, g_secondaryFibo.offsetCandles);
         g_secondaryFibo.lineName = line2;
         g_secondaryFibo.isLocked = false;
         
         if(g_isBuySetup){ // Buy Fibo
            g_secondaryFibo.slPrice = line2Price - (slPoints / 2.0) * point;
            g_secondaryFibo.entryPrice = line2Price + (slPoints / 2.0) * point;
            g_secondaryFibo.tpPrice = g_secondaryFibo.entryPrice + (slPoints * 2.0) * point;
         } else { // Sell Fibo
            g_secondaryFibo.entryPrice = line2Price - (slPoints / 2.0) * point;
            g_secondaryFibo.slPrice = line2Price + (slPoints / 2.0) * point;
            g_secondaryFibo.tpPrice = g_secondaryFibo.entryPrice - (slPoints * 2.0) * point;
         }
      } else {
         g_secondaryFibo.fiboName = "";
         g_secondaryFibo.lineName = "";
         g_secondaryFibo.offsetCandles = 0;
      }

      g_lastAutoLine1 = line1; 
      g_lastAutoLine2 = line2;
   }
   CheckInitialBreakout();
}

//+------------------------------------------------------------------+
//| Check for Breakout in Initial State                             |
//+------------------------------------------------------------------+
void CheckInitialBreakout()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int breakoutPoints = g_calculatedBreakout;
   if(g_primaryFibo.lineName != "" && ObjectFind(0, g_primaryFibo.lineName) >= 0)
   {
      if(!IsLineBreakoutProcessed(g_primaryFibo.lineName))
      {
         double linePrice = ObjectGetDouble(0, g_primaryFibo.lineName, OBJPROP_PRICE);
         bool isHighLine = (StringFind(g_primaryFibo.lineName, "HIGH") >= 0);
         bool breakoutOccurred = false;
         if((isHighLine && bid >= linePrice + (breakoutPoints * point)) || 
            (!isHighLine && bid <= linePrice - (breakoutPoints * point)))
         {
            breakoutOccurred = true;
         }

         if(breakoutOccurred)
         {
            CreateBreakoutHighlight(g_primaryFibo.lineName, linePrice, isHighLine);
            DeleteOppositeType(isHighLine); 
            
            g_isBuySetup = !isHighLine; 
            
            g_tradeState = TRADE_STATE_BREAKOUT;
            SetTimerState(g_tradeState); 
            g_primaryFibo.isLocked = true;
            return;
         }
      }
   }

   if(g_secondaryFibo.lineName != "" && ObjectFind(0, g_secondaryFibo.lineName) >= 0)
   {
      if(!IsLineBreakoutProcessed(g_secondaryFibo.lineName))
      {
         double linePrice = ObjectGetDouble(0, g_secondaryFibo.lineName, OBJPROP_PRICE);
         bool isHighLine = (StringFind(g_secondaryFibo.lineName, "HIGH") >= 0);
         bool breakoutOccurred = false;
         if((isHighLine && bid >= linePrice + (breakoutPoints * point)) || 
            (!isHighLine && bid <= linePrice - (breakoutPoints * point)))
         {
            breakoutOccurred = true;
         }

         if(breakoutOccurred)
         {
            CreateBreakoutHighlight(g_secondaryFibo.lineName, linePrice, isHighLine);
            ObjectDelete(0, g_primaryFibo.fiboName);
            if(g_primaryFibo.lineName != "" && ObjectFind(0, g_primaryFibo.lineName) >= 0)
            {
               ObjectDelete(0, g_primaryFibo.lineName);
               RemoveLineFromHistory(g_primaryFibo.lineName);
            }
            
            DeleteOppositeType(isHighLine);
            g_primaryFibo = g_secondaryFibo;
            g_secondaryFibo.fiboName = ""; g_secondaryFibo.lineName = "";
            
            g_isBuySetup = !isHighLine; 
            
            g_tradeState = TRADE_STATE_BREAKOUT;
            SetTimerState(g_tradeState); 
            g_primaryFibo.isLocked = true;
            DrawNextSecondaryFibo();
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Process Breakout State - Wait for Entry or Next Breakout        |
//+------------------------------------------------------------------+
void ProcessBreakoutState()
{
   if(g_primaryFibo.fiboName == "") return;

   double currentPrice;
   if(InpUseSpread)
   {
      currentPrice = g_isBuySetup ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }
   else
   {
      currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }

   bool entryReached = false;

   if((g_isBuySetup && currentPrice >= g_primaryFibo.entryPrice) || 
      (!g_isBuySetup && currentPrice <= g_primaryFibo.entryPrice))
   {
      entryReached = true;
   }

   if(entryReached)
   {
      if(g_secondaryFibo.fiboName != "" && ObjectFind(0, g_secondaryFibo.fiboName) >= 0)
      {
         ObjectDelete(0, g_secondaryFibo.fiboName);
         
         if(g_secondaryFibo.lineName != "" && ObjectFind(0, g_secondaryFibo.lineName) >= 0)
         {
            ObjectDelete(0, g_secondaryFibo.lineName);
            RemoveLineFromHistory(g_secondaryFibo.lineName);
         }
         
         g_secondaryFibo.fiboName = "";
         g_secondaryFibo.lineName = "";
         g_secondaryFibo.offsetCandles = 0;
      }

      g_tradeState = TRADE_STATE_ACTIVE;
      SetTimerState(g_tradeState);

      // Clean all objects except active trade's line, fibo, and highlight
      CleanAllExceptActiveTrade();

      g_tradeActivationTime = TimeCurrent();
      g_tradeActive = true; 
      if(InpEnableTimer) g_timerSeconds = InpTimerDuration; 
      return;
   }

   if(g_secondaryFibo.lineName != "" && ObjectFind(0, g_secondaryFibo.lineName) >= 0)
   {
      if(!IsLineBreakoutProcessed(g_secondaryFibo.lineName))
      {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         int breakoutPoints = g_calculatedBreakout;
         double linePrice = ObjectGetDouble(0, g_secondaryFibo.lineName, OBJPROP_PRICE);
         bool isHighLine = (StringFind(g_secondaryFibo.lineName, "HIGH") >= 0);
         bool breakoutOccurred = false;
         if((isHighLine && bid >= linePrice + (breakoutPoints * point)) || 
            (!isHighLine && bid <= linePrice - (breakoutPoints * point)))
         {
            breakoutOccurred = true;
         }

         if(breakoutOccurred)
         {
            if(g_lastHighlightBoxName != "") ObjectDelete(0, g_lastHighlightBoxName);
            CreateBreakoutHighlight(g_secondaryFibo.lineName, linePrice, isHighLine);
            ObjectDelete(0, g_primaryFibo.fiboName);

            if(g_primaryFibo.lineName != "" && ObjectFind(0, g_primaryFibo.lineName) >= 0)
            {
               ObjectDelete(0, g_primaryFibo.lineName);
               RemoveLineFromHistory(g_primaryFibo.lineName);
            }
            
            g_primaryFibo = g_secondaryFibo;
            g_secondaryFibo.fiboName = ""; g_secondaryFibo.lineName = "";
            g_secondaryFibo.offsetCandles = 0;
            g_primaryFibo.isLocked = true;
            
            SetTimerState(g_tradeState); 
            DrawNextSecondaryFibo();
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Draw Next Secondary Fibo                                        |
//+------------------------------------------------------------------+
void DrawNextSecondaryFibo()
{
   string lineType = g_isBuySetup ? "LOW" : "HIGH"; 
   double primaryLinePrice = ObjectGetDouble(0, g_primaryFibo.lineName, OBJPROP_PRICE);
   string nextLine = "";
   double minDistance = 1e100;
   
   for(int i = 0; i < g_lineHistoryCount; i++)
   {
      string lineName = g_lineHistory[i];
      if(ObjectFind(0, lineName) < 0 || StringFind(lineName, lineType) < 0 || 
         lineName == g_primaryFibo.lineName || IsLineBreakoutProcessed(lineName))
         continue;
         
      double linePrice = ObjectGetDouble(0, lineName, OBJPROP_PRICE);
      
      bool correctDirection = (g_isBuySetup && linePrice < primaryLinePrice) || 
                              (!g_isBuySetup && linePrice > primaryLinePrice); 
      
      if(correctDirection)
      {
         double distance = MathAbs(linePrice - primaryLinePrice);
         if(distance < minDistance)
         {
            minDistance = distance;
            nextLine = lineName;
         }
      }
   }

   if(nextLine != "")
   {
      double linePrice = ObjectGetDouble(0, nextLine, OBJPROP_PRICE);
      int offset = g_primaryFibo.offsetCandles + InpFiboSubsequentOffset;
      g_secondaryFibo.offsetCandles = offset;
      
      g_secondaryFibo.fiboName = DrawFibonacci(linePrice, g_isBuySetup, false, g_secondaryFibo.offsetCandles);
      g_secondaryFibo.lineName = nextLine;
      g_secondaryFibo.isLocked = false;

      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      int slPoints = g_calculatedSL;
      
      if(g_isBuySetup){ // Buy Fibo
         g_secondaryFibo.slPrice = linePrice - (slPoints / 2.0) * point;
         g_secondaryFibo.entryPrice = linePrice + (slPoints / 2.0) * point;
         g_secondaryFibo.tpPrice = g_secondaryFibo.entryPrice + (slPoints * 2.0) * point;
      } else { // Sell Fibo
         g_secondaryFibo.entryPrice = linePrice - (slPoints / 2.0) * point;
         g_secondaryFibo.slPrice = linePrice + (slPoints / 2.0) * point;
         g_secondaryFibo.tpPrice = g_secondaryFibo.entryPrice - (slPoints * 2.0) * point;
      }
   }
}

//+------------------------------------------------------------------+
//| Process Active State - Monitor SL/TP                            |
//+------------------------------------------------------------------+
void ProcessActiveState()
{
   if(g_tradeActive == false) return; 

   double slCheckPrice;
   if(InpUseSpread)
   {
      slCheckPrice = g_isBuySetup ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }
   else
   {
      slCheckPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }

   bool slHit = false;
   if((g_isBuySetup && slCheckPrice <= g_primaryFibo.slPrice) || 
      (!g_isBuySetup && slCheckPrice >= g_primaryFibo.slPrice)) 
   {
      slHit = true;
   }

   if(slHit)
   {
      g_tradeState = TRADE_STATE_RECOVERY;
      SetTimerState(g_tradeState); 
      
      if(InpUpdateFiboLabelsOnSL && g_primaryFibo.fiboName != "")
      {
         UpdateFiboLabelsToRecovery(g_primaryFibo.fiboName, g_isBuySetup);
      }
      
      if(InpEnableTimer)
      {
         g_timerSeconds = InpTimerDuration; 
         g_tradeActivationTime = TimeCurrent();
      }
      return; 
   }

   double tpCheckPrice;
   if(InpUseSpread)
   {
      tpCheckPrice = g_isBuySetup ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   }
   else
   {
      tpCheckPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }

   bool tpHit = false;
   if((g_isBuySetup && tpCheckPrice >= g_primaryFibo.tpPrice) || 
      (!g_isBuySetup && tpCheckPrice <= g_primaryFibo.tpPrice)) 
   {
      tpHit = true;
   }

   if(tpHit)
   {
      g_tradeActive = false; 
      g_tradeState = TRADE_STATE_NONE; 
      SetTimerState(g_tradeState); 
      ShowAlertMessage(1); 
   }
}

//+------------------------------------------------------------------+
//| Process Recovery State - Monitor Recovery SL/TP                 |
//+------------------------------------------------------------------+
void ProcessRecoveryState()
{
   if(g_tradeActive == false) return; 

   double recoverySL = g_primaryFibo.entryPrice; 

   double slCheckPrice;
   if(InpUseSpread)
   {
      slCheckPrice = g_isBuySetup ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   }
   else
   {
      slCheckPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }

   bool slHit = false;
   if((g_isBuySetup && slCheckPrice >= recoverySL) || 
      (!g_isBuySetup && slCheckPrice <= recoverySL)) 
   {
      slHit = true;
   }
   if(slHit)
   {
      g_tradeActive = false; 
      g_tradeState = TRADE_STATE_NONE; 
      SetTimerState(g_tradeState); 
      ShowAlertMessage(3); 
      return;
   }

   double recoveryEntry = g_primaryFibo.slPrice;
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int slPoints = g_calculatedSL;
   double recoveryTP;
   
   if(g_isBuySetup) 
      recoveryTP = recoveryEntry - (slPoints * 2.0) * point;
   else 
      recoveryTP = recoveryEntry + (slPoints * 2.0) * point;
      
   double tpCheckPrice;
   if(InpUseSpread)
   {
      tpCheckPrice = g_isBuySetup ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }
   else
   {
      tpCheckPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }

   bool tpHit = false;
   if((g_isBuySetup && tpCheckPrice <= recoveryTP) || 
      (!g_isBuySetup && tpCheckPrice >= recoveryTP)) 
   {
      tpHit = true;
   }
   if(tpHit)
   {
      g_tradeActive = false; 
      g_tradeState = TRADE_STATE_NONE; 
      SetTimerState(g_tradeState); 
      ShowAlertMessage(2); 
   }
}

//+------------------------------------------------------------------+
//| Helper function to check if a line breakout is already recorded  |
//+------------------------------------------------------------------+
bool IsLineBreakoutProcessed(string lineName)
{
   for(int i = 0; i < ArraySize(g_breakoutHistory); i++)
   {
      if(g_breakoutHistory[i].lineName == lineName)
      {
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Handle Key Press                                                 |
//+------------------------------------------------------------------+
void HandleKeyPress(int key)
{
   if(key == 72 || key == 104) // H or h
   {
      g_isHighActive = !g_isHighActive;
      ObjectSetInteger(0, g_btnHigh, OBJPROP_STATE, g_isHighActive);
      UpdateButtonState(g_btnHigh, g_isHighActive);
      if(g_isHighActive && g_isLowActive)
      {
         g_isLowActive = false;
         ObjectSetInteger(0, g_btnLow, OBJPROP_STATE, false);
         UpdateButtonState(g_btnLow, false);
      }
      ChartRedraw();
   }
   else if(key == 76 || key == 108) // L or l
   {
      g_isLowActive = !g_isLowActive;
      ObjectSetInteger(0, g_btnLow, OBJPROP_STATE, g_isLowActive);
      UpdateButtonState(g_btnLow, g_isLowActive);
      if(g_isLowActive && g_isHighActive)
      {
         g_isHighActive = false;
         ObjectSetInteger(0, g_btnHigh, OBJPROP_STATE, false);
         UpdateButtonState(g_btnHigh, false);
      }
      ChartRedraw();
   }
}

//+------------------------------------------------------------------+
//| Update Fibo Labels to Recovery                                  |
//+------------------------------------------------------------------+
void UpdateFiboLabelsToRecovery(string fiboName, bool isBuy)
{
   ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 0, isBuy ? InpFiboBuyLevel0LabelRecov : InpFiboSellLevel0LabelRecov);
   ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 1, isBuy ? InpFiboBuyLevel1LabelRecov : InpFiboSellLevel1LabelRecov);

   color recoveryColor = isBuy ? InpFiboLineColorRecoveryBuy : InpFiboLineColorRecoverySell;
   
   ObjectSetInteger(0, fiboName, OBJPROP_COLOR, recoveryColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 0, recoveryColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 1, recoveryColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 2, recoveryColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 3, recoveryColor);

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Update Timer                                                     |
//+------------------------------------------------------------------+
void UpdateTimer()
{
   if(!InpEnableTimer || !g_tradeActive)
   {
      if(ObjectFind(0, g_lblTimer) >= 0)
      {
          ObjectSetString(0, g_lblTimer, OBJPROP_TEXT, "--");
          ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, InpTimerColorDefault);
      }
      return;
   }

   int elapsed = (int)(TimeCurrent() - g_tradeActivationTime);
   int remaining = InpTimerDuration - elapsed;
   if(remaining < 0) remaining = 0;
   
   if(ObjectFind(0, g_lblTimer) < 0) return;
   
   string timerText = StringFormat("%d", remaining);
   ObjectSetString(0, g_lblTimer, OBJPROP_TEXT, timerText);

   if(remaining > 10)
   {
      ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, InpTimerColorActiveHigh);
   }
   else
   {
      ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, InpTimerColorActiveLow);
   }

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Set Timer State Display                                          |
//+------------------------------------------------------------------+
void SetTimerState(ENUM_TRADE_STATE state)
{
   if(!InpEnableTimer || ObjectFind(0, g_lblTimer) < 0)
      return;
      
   switch(state)
   {
      case TRADE_STATE_NONE:
         ObjectSetString(0, g_lblTimer, OBJPROP_TEXT, "--");
         ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, InpTimerColorDefault);
         break;
         
      case TRADE_STATE_BREAKOUT:
         ObjectSetString(0, g_lblTimer, OBJPROP_TEXT, "--");
         ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, InpTimerColorArmed);
         break;

      case TRADE_STATE_ACTIVE:
      case TRADE_STATE_RECOVERY:
         ObjectSetString(0, g_lblTimer, OBJPROP_TEXT, IntegerToString(InpTimerDuration));
         ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, InpTimerColorActiveHigh);
         break;
   }
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| *** DELETED (v2.04): Set Fibo Active/Inactive Style *** |
//+------------------------------------------------------------------+
// This function was removed as the logic is no longer needed.
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Show Motivational Alert and Highlight Reset                      |
//+------------------------------------------------------------------+
void ShowAlertMessage(int type)
{
   if(!InpEnableAlerts)
   {
      ObjectSetInteger(0, g_btnReset, OBJPROP_BGCOLOR, InpButtonColorActive);
      ChartRedraw();
      return;
   }

   string msg = "";
   switch(type)
   {
      case 1: // Primary TP Hit
         msg = InpAlertTextWin;
         break;
      case 2: // Recovery TP Hit
         msg = InpAlertTextRecov;
         break;
      case 3: // Recovery SL Hit
         msg = InpAlertTextLoss;
         break;
   }
   
   StringReplace(msg, "|", "\n");
   
   if(msg != "")
   {
      Alert(msg);
   }
   
   // Highlight Reset Button
   ObjectSetInteger(0, g_btnReset, OBJPROP_BGCOLOR, InpButtonColorActive);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| *** NEW (v2.03): Helper to remove line from history array *** |
//+------------------------------------------------------------------+
void RemoveLineFromHistory(string lineNameToRemove)
{
   int indexToRemove = -1;
   // Find the line in the history
   for(int i = 0; i < g_lineHistoryCount; i++)
   {
      if(g_lineHistory[i] == lineNameToRemove)
      {
         indexToRemove = i;
         break;
      }
   }

   // If found, shift elements to remove it
   if(indexToRemove != -1)
   {
      for(int i = indexToRemove; i < g_lineHistoryCount - 1; i++)
      {
         g_lineHistory[i] = g_lineHistory[i + 1];
      }
      g_lineHistoryCount--;
      ArrayResize(g_lineHistory, g_lineHistoryCount);
   }
}

//+------------------------------------------------------------------+
//| Reset Manual Fibo Tracking                                       |
//+------------------------------------------------------------------+
void ResetManualFiboTracking()
{
   g_manualFiboCount_Buy = 0;
   g_manualFiboCount_Sell = 0;
   ArrayResize(g_manualUsedLines_Buy, 0);
   ArrayResize(g_manualUsedLines_Sell, 0);
}

//+------------------------------------------------------------------+
//| Find Next Nearest Line (for Manual Fibo)                         |
//+------------------------------------------------------------------+
string FindNextNearestLine(string lineType, string &usedLines[])
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   LinePrice lines[]; // Re-using LinePrice struct
   int count = 0;
   
   for(int i = 0; i < g_lineHistoryCount; i++)
   {
      string lineName = g_lineHistory[i];
      if(ObjectFind(0, lineName) < 0 || StringFind(lineName, lineType) < 0)
         continue;
         
      bool isUsed = false;
      for(int j = 0; j < ArraySize(usedLines); j++)
      {
         if(usedLines[j] == lineName)
         {
            isUsed = true;
            break;
         }
      }
      if(isUsed)
         continue;
         
      ArrayResize(lines, count + 1);
      lines[count].name = lineName;
      lines[count].price = MathAbs(currentPrice - ObjectGetDouble(0, lineName, OBJPROP_PRICE)); // Store distance here
      count++;
   }

   if(count == 0)
      return "";
      
   // Sort by distance (price field is used for distance)
   for(int i = 0; i < count - 1; i++)
   {
      for(int j = 0; j < count - i - 1; j++)
      {
         if(lines[j].price > lines[j + 1].price)
         {
            LinePrice temp = lines[j];
            lines[j] = lines[j + 1];
            lines[j + 1] = temp;
         }
      }
   }

   return lines[0].name;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Auto-Detection: Main Function                                    |
//+------------------------------------------------------------------+
void DetectUnmitigatedLevels()
{
   // Remove old auto-detected lines
   for(int i = ObjectsTotal(0, 0, OBJ_HLINE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_HLINE);
      if(StringFind(name, g_autoLinePrefix) >= 0)
      {
         ObjectDelete(0, name);
         RemoveLineFromHistory(name);
      }
   }

   struct LevelCandidate
   {
      int barIndex;
      double price;
      bool isHigh;
   };

   LevelCandidate candidates[];
   int candidateCount = 0;

   int barsToCheck = MathMin(InpLookbackCandles, Bars(_Symbol, _Period) - InpSwingLeftBars - InpSwingRightBars);

   // Collect all swing highs, lows, and pin bars
   for(int i = InpSwingRightBars; i < barsToCheck; i++)
   {
      bool addedHigh = false;
      bool addedLow = false;

      // Check for swing high/low
      if(IsSwingHigh(i))
      {
         double swingPrice = iHigh(_Symbol, _Period, i);
         if(IsUnmitigated(swingPrice, true, i))
         {
            ArrayResize(candidates, candidateCount + 1);
            candidates[candidateCount].barIndex = i;
            candidates[candidateCount].price = swingPrice;
            candidates[candidateCount].isHigh = true;
            candidateCount++;
            addedHigh = true;
         }
      }

      if(IsSwingLow(i))
      {
         double swingPrice = iLow(_Symbol, _Period, i);
         if(IsUnmitigated(swingPrice, false, i))
         {
            ArrayResize(candidates, candidateCount + 1);
            candidates[candidateCount].barIndex = i;
            candidates[candidateCount].price = swingPrice;
            candidates[candidateCount].isHigh = false;
            candidateCount++;
            addedLow = true;
         }
      }

      // Check for pin bars (if not already added as swing)
      bool isHighPinBar = false;
      bool isLowPinBar = false;

      if(IsPinBar(i, isHighPinBar, isLowPinBar))
      {
         if(isHighPinBar && !addedHigh)
         {
            double pinPrice = iHigh(_Symbol, _Period, i);
            if(IsUnmitigated(pinPrice, true, i))
            {
               ArrayResize(candidates, candidateCount + 1);
               candidates[candidateCount].barIndex = i;
               candidates[candidateCount].price = pinPrice;
               candidates[candidateCount].isHigh = true;
               candidateCount++;
            }
         }

         if(isLowPinBar && !addedLow)
         {
            double pinPrice = iLow(_Symbol, _Period, i);
            if(IsUnmitigated(pinPrice, false, i))
            {
               ArrayResize(candidates, candidateCount + 1);
               candidates[candidateCount].barIndex = i;
               candidates[candidateCount].price = pinPrice;
               candidates[candidateCount].isHigh = false;
               candidateCount++;
            }
         }
      }
   }

   // Apply validation filter to last N candidates
   int validationStart = (InpValidationCount > 0 && candidateCount > InpValidationCount)
                         ? candidateCount - InpValidationCount : 0;

   // Draw validated levels
   for(int i = 0; i < candidateCount; i++)
   {
      bool shouldDraw = true;

      // Apply validation only to last N
      if(i >= validationStart && InpValidationCount > 0)
      {
         if(!HasConsumedLevelAfter(candidates[i].barIndex))
            shouldDraw = false;
      }

      if(shouldDraw)
      {
         datetime swingTime = iTime(_Symbol, _Period, candidates[i].barIndex);
         string lineName = g_autoLinePrefix + (candidates[i].isHigh ? "HIGH_" : "LOW_") + IntegerToString(candidates[i].barIndex);

         ObjectCreate(0, lineName, OBJ_HLINE, 0, swingTime, candidates[i].price);
         ObjectSetInteger(0, lineName, OBJPROP_COLOR, candidates[i].isHigh ? InpHighLineColor : InpLowLineColor);
         ObjectSetInteger(0, lineName, OBJPROP_WIDTH, candidates[i].isHigh ? InpHighLineWidth : InpLowLineWidth);
         ObjectSetInteger(0, lineName, OBJPROP_STYLE, candidates[i].isHigh ? InpHighLineStyle : InpLowLineStyle);
         ObjectSetInteger(0, lineName, OBJPROP_BACK, false);
         ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, true);
         ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, true);

         ArrayResize(g_lineHistory, g_lineHistoryCount + 1);
         g_lineHistory[g_lineHistoryCount++] = lineName;
      }
   }

   ChartRedraw();
   g_lastDetectionTime = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Check if bar is a Swing High                                     |
//+------------------------------------------------------------------+
bool IsSwingHigh(int bar)
{
   double centerHigh = iHigh(_Symbol, _Period, bar);
   
   // Check left bars
   for(int i = 1; i <= InpSwingLeftBars; i++)
   {
      if(iHigh(_Symbol, _Period, bar + i) >= centerHigh)
         return false;
   }
   
   // Check right bars
   for(int i = 1; i <= InpSwingRightBars; i++)
   {
      if(iHigh(_Symbol, _Period, bar - i) > centerHigh)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if bar is a Swing Low                                      |
//+------------------------------------------------------------------+
bool IsSwingLow(int bar)
{
   double centerLow = iLow(_Symbol, _Period, bar);
   
   // Check left bars
   for(int i = 1; i <= InpSwingLeftBars; i++)
   {
      if(iLow(_Symbol, _Period, bar + i) <= centerLow)
         return false;
   }
   
   // Check right bars
   for(int i = 1; i <= InpSwingRightBars; i++)
   {
      if(iLow(_Symbol, _Period, bar - i) < centerLow)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if level is still unmitigated (not crossed by price)      |
//+------------------------------------------------------------------+
bool IsUnmitigated(double price, bool isHigh, int fromBar)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   // Check all bars from the swing to current
   for(int i = fromBar - 1; i >= 0; i--)
   {
      if(isHigh)
      {
         // For High level, check if price went above it (even by 1 tick)
         if(iHigh(_Symbol, _Period, i) > price + point)
            return false; // Level was mitigated (broken)
      }
      else
      {
         // For Low level, check if price went below it (even by 1 tick)
         if(iLow(_Symbol, _Period, i) < price - point)
            return false; // Level was mitigated (broken)
      }
   }

   return true; // Level is still unmitigated
}

//+------------------------------------------------------------------+
//| Check if bar is a Pin Bar with large shadow(s)                  |
//+------------------------------------------------------------------+
bool IsPinBar(int bar, bool &isHighPinBar, bool &isLowPinBar)
{
   isHighPinBar = false;
   isLowPinBar = false;

   if(InpMinShadowSize <= 0)
      return false;

   double open = iOpen(_Symbol, _Period, bar);
   double close = iClose(_Symbol, _Period, bar);
   double high = iHigh(_Symbol, _Period, bar);
   double low = iLow(_Symbol, _Period, bar);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   double bodyHigh = MathMax(open, close);
   double bodyLow = MathMin(open, close);

   double upperShadow = high - bodyHigh;
   double lowerShadow = bodyLow - low;

   double minShadowPrice = InpMinShadowSize * point;

   if(upperShadow >= minShadowPrice)
      isHighPinBar = true;

   if(lowerShadow >= minShadowPrice)
      isLowPinBar = true;

   if(InpDoubleShadowMode == DOUBLE_SHADOW_IGNORE && isHighPinBar && isLowPinBar)
   {
      isHighPinBar = false;
      isLowPinBar = false;
      return false;
   }

   if(InpDoubleShadowMode == DOUBLE_SHADOW_LARGER && isHighPinBar && isLowPinBar)
   {
      if(upperShadow > lowerShadow)
         isLowPinBar = false;
      else
         isHighPinBar = false;
   }

   return (isHighPinBar || isLowPinBar);
}

//+------------------------------------------------------------------+
//| Check if any level was consumed after this bar formed           |
//+------------------------------------------------------------------+
bool HasConsumedLevelAfter(int barIndex)
{
   if(InpValidationCount <= 0)
      return true;

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   bool foundAnySwing = false;

   // Check bars AFTER this bar formed (from barIndex-1 down to 0)
   for(int i = barIndex - 1; i >= MathMax(0, barIndex - 100); i--)
   {
      // Check if this bar i was a swing high or low
      if(IsSwingHigh(i))
      {
         foundAnySwing = true;
         double levelPrice = iHigh(_Symbol, _Period, i);

         // Check if this high was consumed after it formed
         for(int j = i - 1; j >= 0; j--)
         {
            if(iHigh(_Symbol, _Period, j) > levelPrice + point)
               return true; // Found a consumed high after barIndex
         }
      }

      if(IsSwingLow(i))
      {
         foundAnySwing = true;
         double levelPrice = iLow(_Symbol, _Period, i);

         // Check if this low was consumed after it formed
         for(int j = i - 1; j >= 0; j--)
         {
            if(iLow(_Symbol, _Period, j) < levelPrice - point)
               return true; // Found a consumed low after barIndex
         }
      }
   }

   // If no swings found after this bar, return false
   return false;
}

//+------------------------------------------------------------------+
//| Merge Nearby Levels - Keep Closest to Current Price             |
//+------------------------------------------------------------------+
void MergeNearbyLevels()
{
   double proximity = InpMergeProximity * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   // Arrays to store highs and lows
   struct LevelInfo
   {
      string name;
      double price;
      double distanceToPrice;
   };

   LevelInfo highs[];
   LevelInfo lows[];
   int highCount = 0;
   int lowCount = 0;

   // Collect all horizontal lines
   for(int i = ObjectsTotal(0, 0, OBJ_HLINE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_HLINE);
      double price = ObjectGetDouble(0, name, OBJPROP_PRICE);

      // Determine if it's a high or low based on position relative to current price
      if(price > currentPrice)
      {
         // It's a high (resistance)
         ArrayResize(highs, highCount + 1);
         highs[highCount].name = name;
         highs[highCount].price = price;
         highs[highCount].distanceToPrice = price - currentPrice;
         highCount++;
      }
      else
      {
         // It's a low (support)
         ArrayResize(lows, lowCount + 1);
         lows[lowCount].name = name;
         lows[lowCount].price = price;
         lows[lowCount].distanceToPrice = currentPrice - price;
         lowCount++;
      }
   }

   // Merge nearby highs - keep the lowest (closest to price)
   for(int i = 0; i < highCount; i++)
   {
      if(highs[i].name == "") continue; // Already deleted

      for(int j = i + 1; j < highCount; j++)
      {
         if(highs[j].name == "") continue; // Already deleted

         // Check if they are close to each other
         if(MathAbs(highs[i].price - highs[j].price) <= proximity)
         {
            // Delete the one that's farther from current price (higher price)
            if(highs[i].price > highs[j].price)
            {
               ObjectDelete(0, highs[i].name);
               RemoveLineFromHistory(highs[i].name);
               highs[i].name = "";
               break;
            }
            else
            {
               ObjectDelete(0, highs[j].name);
               RemoveLineFromHistory(highs[j].name);
               highs[j].name = "";
            }
         }
      }
   }

   // Merge nearby lows - keep the highest (closest to price)
   for(int i = 0; i < lowCount; i++)
   {
      if(lows[i].name == "") continue; // Already deleted

      for(int j = i + 1; j < lowCount; j++)
      {
         if(lows[j].name == "") continue; // Already deleted

         // Check if they are close to each other
         if(MathAbs(lows[i].price - lows[j].price) <= proximity)
         {
            // Delete the one that's farther from current price (lower price)
            if(lows[i].price < lows[j].price)
            {
               ObjectDelete(0, lows[i].name);
               RemoveLineFromHistory(lows[i].name);
               lows[i].name = "";
               break;
            }
            else
            {
               ObjectDelete(0, lows[j].name);
               RemoveLineFromHistory(lows[j].name);
               lows[j].name = "";
            }
         }
      }
   }

   ChartRedraw();
}
//+------------------------------------------------------------------+
