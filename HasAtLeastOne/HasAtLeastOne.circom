pragma circom 2.1.8;

// Create a circuit that takes an array of signals `in[n]` and
// a signal k. The circuit should return 1 if `k` is in the list
// and 0 otherwise. This circuit should work for an arbitrary
// length of `in`.
include "../node_modules/circomlib/circuits/comparators.circom";

template HasAtLeastOne(n) {
    signal input in[n];
    signal input k;
    signal output out;

    signal found[n+1];
    found[0] <== 0;
    component ise[n];
    for (var i = 0; i<n; i++){
        ise[i] = IsEqual();
        ise[i].in[0] <== in[i];
        ise[i].in[1] <== k;
        // found[i+1] = found[i] OR ise[i].out
        // So in the end found[n] = OR over all ise[i].out, Means at least one bit is set to 1
        found[i+1] <== found[i] + ise[i].out - found[i]*ise[i].out;
    }
    out <== found[n];
}

component main = HasAtLeastOne(4);
