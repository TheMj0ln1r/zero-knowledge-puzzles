pragma circom 2.1.4;

template IsZero() {
   signal input in;
   signal output out;
   signal inv;

   // For every non-zero there exists an inverse in Fp
   inv <-- in!=0 ? 1/in : 0;

   /*
      in * inv == out
      out == 1
      can be written as in * inv == out == 1
      in * inv = 1
      out = (in * inv) - 1
      can be out = -in * inv + 1

      Ultimately this forcing the out to be 1 if the inv existed(in!=0) and the inv is actually correct.

   */
   out <== -in * inv +1;
   
   /*
      if the in!=0 and the inv computation and out is constrained by the above constraint, 
      what if in = 0?
      if in = 0, the out should be 1

      we can write the constraint as 
      in * out = 0, if the in=0 the out can be anything (we don't need to care about the correct inverse calcultation at all)

      But this constaint is additionally constraining that the inv is also correctly computed.
      In the case, in!=0,
      The the constraint 2 (in*out = 0) forces the out to be zero. The out will will only become zero when the in actually have the correct inv.
   */
   in * out === 0;

}

template IsEqual(){
   signal input in[2];
   signal output out;

   // using the IsZero template
   component isz = IsZero();
   // if a - b == 0 then, a == b
   in[1] - in[0] ==> isz.in;
   isz.out ==> out;
}

// Input 3 values using 'a'(array of length 3) and check if they all are equal.
// Return using signal 'c'.
template Equality() {
   // Your Code Here..
   signal input a[3];
   signal output c;

   component ise1 = IsEqual();
   a[0] ==> ise1.in[0];
   a[1] ==> ise1.in[1];

   component ise2 = IsEqual();
   a[1] ==> ise2.in[0];
   a[2] ==> ise2.in[1];

   // a * b = c ; If both a and b are 1 then only c=1, if atleast one of a or b is zero then c=0
   ise1.out * ise2.out ==> c;
}
component main = Equality();

////////////// A BAD Circuit ///////

// template Equality() {
//    // Your Code Here..
//    signal input a[3];
//    signal output c;
//    signal aisb;
//    signal bisc;
//    signal temp;
//    aisb <-- a[0]==a[1]? 1: 0;
//    bisc <-- a[1]==a[2]? 1: 0;
//    temp <-- aisb && bisc;
//    c <== temp;
// }
