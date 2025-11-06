pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Create a circuit that is satisfied if `numerator`,
// `denominator`, `quotient`, and `remainder` represent
// a valid integer division. You will need a comparison check, so
// we've already imported the library and set n to be 252 bits.
//
// Hint: integer division in Circom is `\`.
// `/` is modular division
// `%` is integer modulus

template IntDiv(n) {
    signal input numerator;
    signal input denominator;
    signal input quotient;
    signal input remainder;

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

    // Ensure that: remainder < denominator
    component islt = LessThan(n);
    islt.in[0] <== remainder;
    islt.in[1] <== denominator;
    islt.out === 1;

    // Ensure that: numerator = denominator * quotient + remainder
    signal computed_numerator;
    computed_numerator <== denominator * quotient + remainder;
    computed_numerator === numerator;

}

component main = IntDiv(252);
