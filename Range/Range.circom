pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/bitify.circom";
// In this exercise , we will learn how to check the range of a private variable and prove that 
// it is within the range . 

// For example we can prove that a certain person's income is within the range
// Declare 3 input signals `a`, `lowerbound` and `upperbound`.
// If 'a' is within the range, output 1 , else output 0 using 'out'

// Writing own comparator templates
template MyLessThan(n){ // n is number of bits
    signal input in[2]; // a,b
    signal output out; // 1 if a < b else 0
    assert(n <= 252); // asserts checks the condition at construction time.
    
    /**
        2^n requires n + 1 bits to represent it.
            For example , 2^3 = 8 , which requires 4 bits to represent it : 1000
        2^(n-1) requires n bits to represent it.
            For example , 2^3 - 1 = 7 , which requires 3 bits to represent it : 111
        2^(n-1) is half of 2^n
            For example , 2^3 = 8 , half of it is 4 , which is 100 in binary.
        2^n -1 requires n bits to represent it. And it isthe maximum number that can be represented with n bits.
            For example , 2^3 - 1 = 7 , which requires 3 bits to represent it : 111

        We can call 2^(n-1) as the mid value. With this we can check that a n bit number is less than or greater than 2^(n-1) . 
        - Since the 2^(n-1) is the smallestt n bit number with the MSB as 1 , any n bit number less than it will have MSB as 0.
        - Any n bit number greater than or equal to 2^(n-1) will have MSB as 1.
        - So we can check the MSB of the n bit representation of the number to determine if it is less than or greater than 2^(n-1).

        Using this we can build a model,
        Lambda = 2^(n-1) + (a-b) 
        if a < b , then (a-b) is negative , so Lambda < 2^(n-1) , so MSB of Lambda is 0
        if a >= b , then (a-b) is positive , so Lambda >= 2^(n-1) , so MSB of Lambda is 1

        Also, here we should constraint that, a and b are atmost n-1 bit numbers.
    **/            
    component num2Bits0 = Num2Bits(n+1); // Since we are taking n+1 bits representation, now the midpoint is 2^n. This will enables us to take a,b as n bit numbers.
    num2Bits0.in <== (1 << n) + (in[0] - in[1]); // Lambda = 2^n + (a-b) which is equivalent to `in[0]+ (1<<n) - in[1]` from comparators.circom
    /** num2Bits0.out[n] is MSB of n+1 bit representation.
        If MSB is 0 , then a < b , so out = 1
        If MSB is 1 , then a >= b , so out = 0
     **/
    out <== 1 - num2Bits0.out[n];
}

template MyLessThanOrEqual(n){
    signal input in[2]; // a,b
    signal output out; // 1 if a <= b else 0
    component lessThan = MyLessThan(n);
    lessThan.in[0] <== in[0];
    lessThan.in[1] <== in[1] + 1; // a <= b is equivalent to a < (b+1)
    out <== lessThan.out;
}

template MyGreaterThan(n){
    signal input in[2]; // a,b
    signal output out; // 1 if a > b else 0
    component lessThan = MyLessThan(n);
    lessThan.in[0] <== in[1]; // a > b is equivalent to b < a
    lessThan.in[1] <== in[0]; 
    out <== lessThan.out;
}

template MyGreaterThanOrEqual(n){
    signal input in[2]; // a,b
    signal output out; // 1 if a >= b else 0
    component lessThan = MyLessThan(n);
    lessThan.in[0] <== in[1];
    lessThan.in[1] <== in[0] + 1; // a >= b is equivalent to b < (a+1)
    out <== lessThan.out;
}



template Range(n) {
    // your code here
   signal input a;
   signal input lowerbound;
   signal input upperbound;
   signal output out;

    component gte_lower = MyGreaterThanOrEqual(n);
    component lte_upper = MyLessThanOrEqual(n);
    gte_lower.in[0] <== a;
    gte_lower.in[1] <== lowerbound;

    lte_upper.in[0] <== a;
    lte_upper.in[1] <== upperbound;
    out <== gte_lower.out * lte_upper.out;
}
component main  = Range(252);