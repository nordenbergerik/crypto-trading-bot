# Crypto Trading Bot

A small Haskell-based crypto trading prototype focused on BTC/USDT market data, strategy evaluation, and backtesting. The project was built to explore event-driven trading logic, moving-average signals, and basic portfolio accounting in a strongly typed functional language.

## What this project does

- Connects to live Binance trade data via WebSockets
- Tracks price history and computes moving-average-based trading signals
- Supports a simple trading loop with balance and wallet updates
- Includes a backtesting path using historical CSV market data
- Calculates portfolio ROI against the starting balance

## Project status

This is a prototype / learning project rather than a production trading system. It is intended to demonstrate functional programming, market-data processing, and strategy experimentation.

## Tech stack

- Haskell
- Stack
- Binance WebSocket API
- CSV-based historical data analysis
- Hspec for test coverage

## Quick start

### Run the app

```bash
stack exec -- crypto-trading-bot-exe
```

When prompted:

- Enter `l` for live trading
- Enter `b` for backtesting

### Run tests

```bash
stack test
```

## Example workflow

1. Start the app.
2. Choose live mode or backtest mode.
3. The bot reads incoming BTC/USDT trade data and evaluates the strategy.
4. Portfolio balance, wallet position, and ROI are printed during execution.

