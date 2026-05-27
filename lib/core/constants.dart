class AppConstants {
  static const String baseUrl = 'http://10.75.163.32:5000/api';
  static const String wsUrl = 'ws://10.75.163.32:5000';

  static const Map<String, int> lotSizes = {
    '^NSEI': 25,
    '^NSEBANK': 15,
    '^BSESN': 10,
  };

  static const List<String> indexSymbols = [
    '^NSEI',
    '^NSEBANK',
    '^BSESN',
    '^CNXIT',
    'NIFTY_MIDCAP_100.NS',
    '^CNXPHARMA',
  ];
}
