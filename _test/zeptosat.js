// Generated by CoffeeScript 1.6.3
(function() {
  'NekoCSP - 2013\n\n2013 Darko Mikulic, All rights reserved';
  var SatSolver, absArr, chooseLiteral, containsEmptyArr, dpll, first, flatten, intersection, pureLiteralAssign, simplify, solve_formula, unitpropagate,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  SatSolver = (function() {
    function SatSolver(formula) {
      this.formula = formula;
    }

    SatSolver.prototype.solve = function() {
      return solve_formula(this.formula);
    };

    return SatSolver;

  })();

  dpll = function(f, r) {
    var l, t, _ref, _ref1;
    _ref = unitpropagate(f, r), f = _ref[0], r = _ref[1];
    _ref1 = pureLiteralAssign(f, r), f = _ref1[0], r = _ref1[1];
    if (!f.length) {
      return r;
    } else if (containsEmptyArr(f)) {
      return false;
    } else {
      l = chooseLiteral(f);
      t = dpll(simplify(f, l), [l].concat(r));
      if (t) {
        return t;
      } else {
        return dpll(simplify(f, -l), [-l].concat(r));
      }
    }
  };

  simplify = function(f, l) {
    var c, simplifyClause, _i, _len, _results;
    simplifyClause = function(c, l) {
      var lx, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = c.length; _i < _len; _i++) {
        lx = c[_i];
        if (lx !== -l) {
          _results.push(lx);
        }
      }
      return _results;
    };
    _results = [];
    for (_i = 0, _len = f.length; _i < _len; _i++) {
      c = f[_i];
      if (__indexOf.call(c, l) < 0) {
        _results.push(simplifyClause(c, l));
      }
    }
    return _results;
  };

  chooseLiteral = function(f) {
    var literals;
    literals = flatten(f);
    if (literals) {
      return literals[0];
    } else {
      return false;
    }
  };

  unitpropagate = function(f, r) {
    var u, x;
    u = first((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = f.length; _i < _len; _i++) {
        x = f[_i];
        if (x.length === 1) {
          _results.push(x[0]);
        }
      }
      return _results;
    })());
    if (u) {
      return unitpropagate(simplify(f, u), [u].concat(r));
    } else {
      return [f, r];
    }
  };

  pureLiteralAssign = function(f, r) {
    var c, eliminate, l, literals, nf, pure;
    literals = flatten(f).unique();
    pure = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = literals.length; _i < _len; _i++) {
        l = literals[_i];
        if (__indexOf.call(literals, -l) < 0) {
          _results.push(l);
        }
      }
      return _results;
    })();
    eliminate = function(c) {
      return intersection(pure, c).length;
    };
    nf = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = f.length; _i < _len; _i++) {
        c = f[_i];
        if (!eliminate(c)) {
          _results.push(c);
        }
      }
      return _results;
    })();
    return [nf, pure.concat(r)];
  };

  intersection = function(a, b) {
    var value, _i, _len, _ref, _results;
    if (a.length > b.length) {
      _ref = [b, a], a = _ref[0], b = _ref[1];
    }
    _results = [];
    for (_i = 0, _len = a.length; _i < _len; _i++) {
      value = a[_i];
      if (__indexOf.call(b, value) >= 0) {
        _results.push(value);
      }
    }
    return _results;
  };

  Array.prototype.unique = function() {
    var key, output, value, _i, _ref, _results;
    output = {};
    for (key = _i = 0, _ref = this.length; 0 <= _ref ? _i < _ref : _i > _ref; key = 0 <= _ref ? ++_i : --_i) {
      output[this[key]] = this[key];
    }
    _results = [];
    for (key in output) {
      value = output[key];
      _results.push(value);
    }
    return _results;
  };

  containsEmptyArr = function(arr) {
    var x;
    return ((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = arr.length; _i < _len; _i++) {
        x = arr[_i];
        if (x.length === 0) {
          _results.push(x);
        }
      }
      return _results;
    })()).length;
  };

  flatten = function(arr) {
    return [].concat.apply([], arr);
  };

  first = function(arr) {
    if (arr.length) {
      return arr[0];
    } else {
      return false;
    }
  };

  absArr = function(arr) {
    var x, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      x = arr[_i];
      _results.push(Math.abs(x));
    }
    return _results;
  };

  solve_formula = function(f) {
    var allvars, intersect, missing, result, resvars, x;
    result = dpll(f, []);
    if (result) {
      allvars = absArr(flatten(f)).unique();
      resvars = absArr(result);
      intersect = intersection(allvars, resvars);
      missing = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = allvars.length; _i < _len; _i++) {
          x = allvars[_i];
          if (__indexOf.call(intersect, x) < 0) {
            _results.push(x);
          }
        }
        return _results;
      })();
      return missing.concat(result).sort(function(a, b) {
        return Math.abs(a) - Math.abs(b);
      });
    } else {
      return result;
    }
  };

  window.SatSolver = SatSolver;

}).call(this);