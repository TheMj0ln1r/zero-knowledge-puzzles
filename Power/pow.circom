pragma circom 2.1.4;

// Create a circuit which takes an input 'a',(array of length 2 ) , then  implement power modulo 
// and return it using output 'c'.

// HINT: Non Quadratic constraints are not allowed. 
include "../node_modules/circomlib/circuits/comparators.circom";


template Pow() {
   
   // Your Code here.. 
   signal input a[2];
   signal output c;
   
   var MAX_EXP = 10;
   // computing a[0]^0..,a[0]^a[1]...,a[0]^10
   signal pro[MAX_EXP+1];
   pro[0] <== 1;
   for (var i = 0; i < MAX_EXP; i++){
      pro[i+1] <== pro[i] * a[0];
   }

   // Selecting the correct power a[0]^a[1]
   signal select[MAX_EXP+1];
   component isEqual[MAX_EXP+1]; // one component can be used once. So, to compare in each iteration of loop, defining an array of components
   for (var i = 0; i <= MAX_EXP; i++) {
      isEqual[i] = IsEqual();
      isEqual[i].in[0] <== i;
      isEqual[i].in[1] <== a[1];
      select[i] <== isEqual[i].out * pro[i]; // select array will now have a actual power and rest of all the entries as 0.
   }
   // Finding the sum of elements of select array will be the final required power
   signal sum[MAX_EXP + 1];
   sum[0] <== select[0];
   for (var i = 0; i < MAX_EXP; i++){
      sum[i+1] <== sum[i] + select[i+1];
   }
   c <== sum[MAX_EXP];
}

component main = Pow();