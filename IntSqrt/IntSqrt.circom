pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Create a circuit that is satisfied if
// in[0] is the floor of the integer
// sqrt of in[1]. For example:
// 
// int[2, 5] accept
// int[2, 5] accept
// int[2, 9] reject
// int[3, 9] accept
//
// If b is the integer square root of a, then
// the following must be true:
//
// (b - 1)(b - 1) < a
// (b + 1)(b + 1) > a
// 
// be careful when verifying that you 
// handle the corner case of overflowing the 
// finite field. You should validate integer
// square roots, not modular square roots

template IntSqrt(n) {
    signal input in[2];

    /// Overflow check
   /**
    n = 252
    max in[1] = 2^252 - 1
    max in[0] = 2^126 - 1
    max in[0]^2 = (2^126 - 1) * (2^126 - 1) ≈ 2^252;

    Field size p ≈ 2^254 (BN128 curve)
    So overflow is NOT an issue unless in[0] is 126 bit long.

    If in[0] = 2^128 - 1 (128 bit long)
    in[0]^2 = (2^128 - 1) * (2^128 - 1) ≈ 2^256 which is > p

    Now the computation is done mod p means the values will be wraped around.
    Like this,
    ((2**128)-1) * ((2**128)-1) should be equal to `115792089237316195423570985008687907852589419931798687112530834793049593217025` in normal arithmetic
    but mod p it becomes `6350874878119819312338956282401532410528162663560392320966563075034087161851` which is accepted by the sqrt logic. 
    But if we wanted them to not to wrap around, we would need to add extra constraints.
    */

    component n2b_sqrt = Num2Bits(125);
    n2b_sqrt.in <== in[0];
    // 2^125, why 125 
    // if 126 then gte.in[0] <== (in[0] + 1) * (in[0] + 1) will be gte.in[0] = 2**252, which is 253 bit long but the GreaterThan circuit is accepting 252 bit long numbers only.


    component lte = LessEqThan(n);
    lte.in[0] <== in[0] * in[0];
    lte.in[1] <== in[1];

    component gte = GreaterThan(n);
    gte.in[0] <== (in[0] + 1) * (in[0] + 1);
    gte.in[1] <== in[1];

    lte.out * gte.out === 1; // lte.out AND gte.out

}

component main = IntSqrt(252);
