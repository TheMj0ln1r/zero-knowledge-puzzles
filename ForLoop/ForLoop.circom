pragma circom 2.1.4;

// Input : 'a',array of length 2 .
// Output : 'c 
// Using a forLoop , add a[0] and a[1] , 4 times in a row .

template ForLoop() {

// Your Code here..
    signal input a[2];
    signal output c;

    signal sum[5]
    sum[0] <== a[0];
    for (var i = 0; i < 4; i++) {
        sum[i+1] <== sum[i] + a[1];
    }
    c <== sum[4];

}  

component main = ForLoop();
