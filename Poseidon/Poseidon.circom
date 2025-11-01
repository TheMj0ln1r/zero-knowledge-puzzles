pragma circom 2.1.4;


// Go through the circomlib library and import the poseidon hashing template using node_modules
// Input 4 variables,namely,'a','b','c','d' , and output variable 'out' .
// Now , hash all the 4 inputs using poseidon and output it . 

include "../node_modules/circomlib/circuits/poseidon.circom";

template poseidon() {

   // Your Code here.. 
   signal input a;
   signal input b;
   signal input c;
   signal input d;
   signal output out;

   component pose = Poseidon(4); // Passing the argument. I think, the array size is needs to be known at compile time????
   a ==> pose.inputs[0];
   b ==> pose.inputs[1];
   c ==> pose.inputs[2];
   d ==> pose.inputs[3];

   pose.out ==> out;
}

component main = poseidon();