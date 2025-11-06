pragma circom 2.1.8;

template Summation(n) {
    signal input in[n];
    signal input sum;

    // constrain sum === in[0] + in[1] + in[2] + ... + in[n-1]
    // this should work for any n
    signal summ[n];
    summ[0] <== in[0];
    for ( var i = 1; i < n; i++){
        summ[i] <== summ[i-1] + in[i];
    }
    sum === summ[n-1];
}

component main = Summation(8);