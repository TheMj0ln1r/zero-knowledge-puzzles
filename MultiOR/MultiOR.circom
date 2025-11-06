pragma circom 2.1.8;
// Write a circuit that returns true when at least one
// element is 1. It should return false if all elements
// are 0. It should be unsatisfiable if any of the inputs
// are not 0 or not 1.

template MultiOR(n) {
    signal input in[n];
    signal output out;

    for (var i = 0; i<n; i++) {
        in[i]*(in[i] - 1) === 0;
    }
    signal found[n];
    found[0] <== in[0];
    for (var i = 1; i < n; i++){
        found[i] <== found[i-1] + in[i] - found[i-1]*in[i];
    }
    out <== found[n-1];
}

component main = MultiOR(4);
