class Test {
  static void runParametrized(List<Map<String, dynamic>> parametersSeries, Function test) {
    for (final Map<String, dynamic> parameters in parametersSeries) {
      Function.apply(test, <dynamic>[], symbolizeKeys(parameters));
    }
  }

  static Map<Symbol, dynamic> symbolizeKeys(Map<String, dynamic> map) {
    final Map<Symbol, dynamic> result = <Symbol, dynamic>{};
    map.forEach((String k, dynamic v) {
      result[Symbol(k)] = v;
    });
    return result;
  }
}
