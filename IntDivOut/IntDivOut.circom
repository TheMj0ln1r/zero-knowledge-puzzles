pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Use the same constraints from IntDiv, but this
// time assign the quotient in `out`. You still need
// to apply the same constraints as IntDiv

template IntDivOut(n) {
    signal input numerator;
    signal input denominator;
    signal output out;

    // ADD RANGE CHECKS to prevent overflow
    component n2b_numerator = Num2Bits(n);
    n2b_numerator.in <== numerator;

    component n2b_denominator = Num2Bits(n/2);
    n2b_denominator.in <== denominator;

    component n2b_quotient = Num2Bits(n/2);
    n2b_quotient.in <== quotient;
    // No need of remainder which we check for remainder < denominator
    

    // Ensure that: denominator != 0
    component isz = IsZero();
    isz.in <== denominator;
    isz.out === 0;

    // quotient = numerator \ denominator
    signal quotient;
    signal remainder;
    quotient <-- numerator \ denominator;
    remainder <-- numerator % denominator;

    // Ensure that: remainder < denominator
    component islt = LessThan(n);
    islt.in[0] <== remainder;
    islt.in[1] <== denominator;
    islt.out === 1;

    // Ensure that: numerator = denominator * quotient + remainder
    signal computed_numerator;
    computed_numerator <== denominator * quotient + remainder;
    computed_numerator === numerator;

    out <== quotient;
}

component main = IntDivOut(252);
