'''
ZeptoSAT - 2013

Copyright (C) 2013 Darko Mikulic

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'''

class SatSolver
    constructor: (formula) ->
        @formula = formula

    solve: () ->
        solve_formula(this.formula)


dpll = (f,r) ->
    [f, r] = unitpropagate(f, r)
    [f, r] = pureLiteralAssign(f, r)
    if not f.length
        r
    else if containsEmptyArr(f)
        false
    else
        l = chooseLiteral(f)
        t = dpll(simplify(f,l), [l].concat(r))
        if t then t else dpll(simplify(f,-l), [-l].concat(r))


simplify = (f, l) ->
    simplifyClause = (c, l) -> (lx for lx in c when lx isnt -l)
    (simplifyClause(c,l) for c in f when l not in c)


chooseLiteral = (f) ->
    literals = flatten(f)
    if literals then literals[0] else false


unitpropagate = (f,r) ->
    u = first((x[0] for x in f when x.length is 1))
    if u
        unitpropagate(simplify(f,u), [u].concat(r))
    else
        [f,r]

pureLiteralAssign = (f,r) ->
    literals = flatten(f).unique()
    pure = (l for l in literals when -l not in literals)
    eliminate = (c) -> intersection(pure, c).length
    nf = (c for c in f when not eliminate(c))
    [nf, pure.concat(r)]

###################  utility functions  #####################

intersection = (a, b) ->
  [a, b] = [b, a] if a.length > b.length
  value for value in a when value in b

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

containsEmptyArr = (arr) -> (x for x in arr when x.length is 0).length

flatten = (arr) -> [].concat.apply([],arr)

first = (arr) -> if arr.length then arr[0] else false

absArr = (arr) -> (Math.abs(x) for x in arr)


##################


solve_formula = (f) ->
    result = dpll(f, [])
    if result
        allvars = absArr(flatten(f)).unique()
        resvars = absArr(result)
        intersect = intersection(allvars, resvars)
        missing = (x for x in allvars when x not in intersect)
        missing.concat(result).sort((a,b) -> Math.abs(a)-Math.abs(b))
    else
        result

window.SatSolver = SatSolver

#### TESTING
#### proba = [[1, 2, -3], [3, -4], [-1]]
#### console.log  solve_formula(proba)