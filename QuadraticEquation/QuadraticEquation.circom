pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/comparators.circom";

// Create a Quadratic Equation( ax^2 + bx + c ) verifier using the below data.
// Use comparators.circom lib to compare results if equal

template QuadraticEquation() {
    signal input x;     // x value
    signal input a;     // coeffecient of x^2
    signal input b;     // coeffecient of x 
    signal input c;     // constant c in equation
    signal input res;   // Expected result of the equation
    signal output out;  // If res is correct , then return 1 , else 0 . 

    // your code here
    signal x_squared; // intermidate signal for x^2, not an input.
    x_squared <== x * x;

    signal a_x_squared; // intermidate signal for a*x^2
    a_x_squared <== a * x_squared;

    signal computed_res; // intermidate signal for computed result
    computed_res <== a_x_squared + b * x + c; // At most one multiplication per constraint

    component isEqual = IsEqual(); 
    isEqual.in[0] <== computed_res;
    isEqual.in[1] <== res;
    isEqual.out ==> out; // output 1 if equal , else 0
}

component main  = QuadraticEquation();



