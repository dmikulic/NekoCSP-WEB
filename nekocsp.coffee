'''
NekoCSP - 2013

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


class Problem
    constructor: () ->
        @sat_var_counter = 1

        @csp_variables =  {}
        @sat_variables =  {}

        @constraints =    []
        @cnf_formula =    []

        @sat_solution =   []
        @csp_solution =   {}

    convert: () ->
        init_sat_variables(this)
        at_least_one(this)
        at_most_one(this)
        convert_consraints(this)

    solve: () ->
        console.log "Starting CSP conversion..."
        this.convert()
        console.log "CSP conversion finished"
        sat = new SatSolver(this.cnf_formula)
        console.log "Starting SAT solving..."
        s = sat.solve()
        console.log "SAT solving finished"
        if not s
            false
        else
            this.sat_solution = s
            find_solution(this)

    alldifferent: (li) ->
        pairs = combinations(li, 2)
        genfunc = (a,b) -> "new Function('#{a}','#{b}', 'return #{a} != #{b};');"
        for x in pairs
            this.constraints.push(eval(genfunc x...))

    isequal: (variable, value) ->
        genfunc = (a,b) -> "new Function('#{a}', 'return #{a} == #{b};');"
        this.constraints.push(eval(genfunc(variable,value)))

##############


init_sat_variables = (p) ->
    for v of p.csp_variables
        var_len = p.csp_variables[v].length
        p.sat_variables[v] = [p.sat_var_counter..p.sat_var_counter + var_len - 1]
        p.sat_var_counter += var_len

at_least_one = (p) ->
    for v of p.csp_variables
        p.cnf_formula.push(p.sat_variables[v])

at_most_one = (p) ->
    for v of p.csp_variables
        for c in combinations(p.sat_variables[v], 2)
            p.cnf_formula.push((-x for x in c))


convert_consraints = (p) ->
    for f in p.constraints
        fvars = getParams(f)
        fdoms = (p.csp_variables[var_name] for var_name in fvars)

        doms_product = []
        addProduct = (x...) -> doms_product.push(x)
        lazyProduct(fdoms, addProduct)

        for values in doms_product
            issat = f values...
            if not issat
                idxs     = (p.csp_variables[v[0]].indexOf(v[1]) for v in zip(fvars, values))
                sat_vars = (p.sat_variables[v[0]][v[1]] for v in zip(fvars,idxs))
                clause   = (-x for x in sat_vars)
                p.cnf_formula.push(clause)


###################  utility functions  #####################

reg = /\(([\s\S]*?)\)/

getParams = (func) -> 
    if func.length
        params = reg.exec(func)[1].split(',')
        (x.trim() for x in params)
    else
        []

combinations = (xs, m) ->
    if m == 0
        [[]]
    else if xs.length == 0
        []
    else
        f = (xs[..0].concat(a) for a in combinations(xs[1..], m-1))
        s = combinations(xs[1..], m)
        f.concat(s)


zip = (arr1, arr2) -> ([arr1[x], arr2[x]] for x in [0..Math.min(arr1.length, arr2.length)-1])

## Inline JavaScript - fast implementation of a Cartesian product
## taken from: http://jsperf.com/lazy-cartesian-product/26
lazyProduct = `function (sets,f,context){
    if (!context) context=this;
    var p=[],max=sets.length-1,lens=[];
    for (var i=sets.length;i--;) lens[i]=sets[i].length;
    function dive(d){
        var a=sets[d], len=lens[d];
        if (d==max) for (var i=0;i<len;++i) p[d]=a[i], f.apply(context,p);
        else        for (var i=0;i<len;++i) p[d]=a[i], dive(d+1);
        p.pop();
    }
    dive(0);
}`

###################


find_solution = (p) ->
    positive = (x for x in p.sat_solution when x > 0)
    for sol in positive
        for key, vals of p.sat_variables
            if sol in vals
                idx = vals.indexOf(sol)
                p.csp_solution[key] = p.csp_variables[key][idx]
    p.csp_solution

    


window.Problem = Problem


###
p = new Problem

p.csp_variables['x'] = [2,3,4,5,6]

p.csp_variables['y'] = [2,3,4,5,6]

p.constraints = [
    (x, y) -> x + y <= 7,
    (x, y) -> x == 3 and y == 4,
]

p.convert()
p.sat_solution = [-1,2,-3,-4,-5,-6,-7,8,-9,-10]

find_solution(p)

console.log p.csp_solution
###
