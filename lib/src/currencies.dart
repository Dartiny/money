// Copyright (c) 2023 LLC "LitGroup"
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished
// to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import 'package:money/money.dart';

//------------------------------------------------------------------------------
// Currencies abstract class
//------------------------------------------------------------------------------

/// Interface/base class of the currency directory.
///
/// ## Note for implementors
///
/// If you loading a list of currencies from the external source (e.g. database,
/// RESTful API) you should load the whole directory at once. Do not try
/// to call external resource per call of the [Currencies] method.
abstract class Currencies {
  static Currencies from<T extends Iterable<Currency>>(T currencies) {
    return _MapBackedCurrencies(currencies);
  }

  static Currencies aggregating<T extends Iterable<Currencies>>(T directories) {
    return _AggregatingCurrencies(directories);
  }

  Currency? findByCode(CurrencyCode code);
}

class _MapBackedCurrencies extends Currencies {
  _MapBackedCurrencies(Iterable<Currency> currencyList)
      : _currencies = {
          for (final currency in currencyList) currency.code: currency
        };

  final Map<CurrencyCode, Currency> _currencies;

  @override
  Currency? findByCode(CurrencyCode code) => _currencies[code];
}

class _AggregatingCurrencies extends Currencies {
  _AggregatingCurrencies(Iterable<Currencies> directories)
      : _directories = List.of(directories, growable: false);

  final List<Currencies> _directories;

  @override
  Currency? findByCode(CurrencyCode code) {
    return _directories
        .map((directory) => directory.findByCode(code))
        .where((code) => code != null)
        .firstOrNull;
  }
}
