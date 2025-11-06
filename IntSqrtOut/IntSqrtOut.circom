pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Be sure to solve IntSqrt before solving this 
// puzzle. Your goal is to compute the square root
// in the provided function, then constrain the answer
// to be true using your work from the previous puzzle.
// You can use the Bablyonian/Heron's or Newton's
// method to compute the integer square root. Remember,
// this is not the modular square root.


function intSqrtFloor(x) {
    // compute the floor of the
    // integer square root

    /**
        Imagine a rectangle with area `n`:
        ```
        Area = n
        Width = x (our guess)
        Height = n/x

        If x > √n:  then n/x < √n
        If x < √n:  then n/x > √n

        Average: (x + n/x) / 2 gets closer to √n!
        ```
    */
    if (x == 0 || x == 1) return x;
    
    var guess = x; 
    // Babylonian iteration
    for (var i = 0; i < 30; i++) {
        var new_guess = (guess + x \ guess) \ 2;
        
        if (new_guess >= guess) {
            return guess;  // Converged
        }
        
        guess = new_guess;
    }
    return guess;
}

template IntSqrtOut(n) {
    signal input in;
    signal output out;

    out <-- intSqrtFloor(in);
    log(out);
    // constrain out using your
    // work from IntSqrt

    // Input overflow check
    component n2b_sqrt = Num2Bits(125);
    n2b_sqrt.in <== in;
    // 2^125, why 125 
    // if 126 then gte.in[0] <== (in + 1) * (in + 1) will be gte.in[0] = 2**252, which is 253 bit long but the GreaterThan circuit is accepting 252 bit long numbers only.

    component lte = LessEqThan(n);
    lte.in[0] <== out * out;
    lte.in[1] <== in;

    component gte = GreaterThan(n);
    gte.in[0] <== (out + 1) * (out + 1);
    gte.in[1] <== in;

    lte.out * gte.out === 1; // lte.out AND gte.out
}

component main = IntSqrtOut(252);
