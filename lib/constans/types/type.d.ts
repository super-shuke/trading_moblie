// --- Ticker Mapping ---

export interface ThirdPartyTicker {
  s: string; // symbol
  p: string; // priceChange
  P: string; // priceChangePercent
  w: string; // weightedAvgPrice
  c: string; // lastPrice
  Q: string; // lastQty
  o: string; // openPrice
  h: string; // highPrice
  l: string; // lowPrice
  v: string; // volume
  q: string; // quoteVolume
  O: number; // openTime
  C: number; // closeTime
  F: number; // firstId
  L: number; // lastId
  n: number; // count
}


// 1. 为第三方数据定义一个接口，增强代码可读性和类型安全
interface ThirdPartyTrade {
  s: string;      // Symbol
  p: string;      // Price
  q: string;      // Quantity
  T: number;      // Trade time (timestamp)
  m: boolean;     // Is buyer maker
  [key: string]: any;
}
