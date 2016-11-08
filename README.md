# TorQ-Finance-Starter-Pack
An example production ready market data capture system, using randomly generated financial data.  This is installed on top of the base TorQ package, and includes a version of [kdb+tick](http://code.kx.com/wsvn/code/kx/kdb+tick).

## Set Up 

Assuming that the [free 32 bit version of kdb+](http://kx.com/software-download.php) is already set up and available from the command prompt as q, then:

1. Download a zip of the latest version of [TorQ](https://github.com/AquaQAnalytics/TorQ/archive/master.zip)
2. Download a zip of [this starter pack](https://github.com/AquaQAnalytics/TorQ-Finance-Starter-Pack/archive/master.zip)
3. Unzip TorQ
4. Unzip the starter pack over the top (this will replace some files)
5. Run the appropriate starts script: start_torq_demo.bat for Windows, start_torq_demo.sh for Linux and start_torq_demo_osx.sh for Mac OS X. 

For more information on how to configure and get started, read [this document](https://github.com/AquaQAnalytics/TorQ-Finance-Starter-Pack/blob/master/AquaQTorQFinanceStarterPack.pdf?raw=true).  You will need to make some modifications if you wish to send emails from the system. 

## Release Notes

- **1.0.1, July 2015**:
  * Added Chained Tickerplant process

- **1.1.0, October 2015**:
  * REQUIRES TORQ 2.2.0
  * Added compatibility with $KDBAPPCONFIG in TorQ 2.2.0 Release
- **1.2.0, April 2016**:
  * REQUIRES TORQ 2.5.0
  * Removed u.q
  * Moved all config directory into appconfig
- **1.2.1, September 2016**:
  * REQUIRES TORQ 2.6.2
  * added broadcast functionality to u.q
  * added sortslave functionality
- **1.3.0, November 2016**:
  * REQUIRES TORQ 2.7.0
  * Removed kdb+ tick code
  * Moved KDBBASEPORT assignment to setenv.sh
  * Feed process uses timer library
