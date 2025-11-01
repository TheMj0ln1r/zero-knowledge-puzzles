pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/comparators.circom";


/*
    Given a 4x4 sudoku board with array signal input "question" and "solution", check if the solution is correct.

    "question" is a 16 length array. Example: [0,4,0,0,0,0,1,0,0,0,0,3,2,0,0,0] == [0, 4, 0, 0]
                                                                                   [0, 0, 1, 0]
                                                                                   [0, 0, 0, 3]
                                                                                   [2, 0, 0, 0]

    "solution" is a 16 length array. Example: [1,4,3,2,3,2,1,4,4,1,2,3,2,3,4,1] == [1, 4, 3, 2]
                                                                                   [3, 2, 1, 4]
                                                                                   [4, 1, 2, 3]
                                                                                   [2, 3, 4, 1]

    "out" is the signal output of the circuit. "out" is 1 if the solution is correct, otherwise 0.                                                                               
*/


template Sudoku () { 
    // Question Setup 
    signal input  question[16];
    signal input solution[16];
    signal output out;
    
    // Checking if the question is valid
    for(var v = 0; v < 16; v++){
        log(solution[v],question[v]);
        assert(question[v] == solution[v] || question[v] == 0);
    }
    
    var m = 0 ;
    component row1[4];
    for(var q = 0; q < 4; q++){
        row1[m] = IsEqual();
        row1[m].in[0]  <== question[q];
        row1[m].in[1] <== 0;
        m++;
    }
    3 === row1[3].out + row1[2].out + row1[1].out + row1[0].out; // Checking each row has exactly 3 zeros

    m = 0;
    component row2[4];
    for(var q = 4; q < 8; q++){
        row2[m] = IsEqual();
        row2[m].in[0]  <== question[q];
        row2[m].in[1] <== 0;
        m++;
    }
    3 === row2[3].out + row2[2].out + row2[1].out + row2[0].out; // Checking each row has exactly 3 zeros

    m = 0;
    component row3[4];
    for(var q = 8; q < 12; q++){
        row3[m] = IsEqual();
        row3[m].in[0]  <== question[q];
        row3[m].in[1] <== 0;
        m++;
    }
    3 === row3[3].out + row3[2].out + row3[1].out + row3[0].out; // Checking each row has exactly 3 zeros

    m = 0;
    component row4[4];
    for(var q = 12; q < 16; q++){
        row4[m] = IsEqual();
        row4[m].in[0]  <== question[q];
        row4[m].in[1] <== 0;
        m++;
    }
    3 === row4[3].out + row4[2].out + row4[1].out + row4[0].out; // Checking each row has exactly 3 zeros

    // Write your solution from here.. Good Luck!

    /// Input range checks
    component gte[16];
    component lte[16];
    signal range_check[17];
    m = 0;
    range_check[m] <== 0;
    for(var i = 0; i < 16; i++) {
        gte[i] = GreaterEqThan(252);
        gte[i].in[0] <== solution[i];
        gte[i].in[1] <== 1;
        
        lte[i] = LessEqThan(252);
        lte[i].in[0] <== solution[i];
        lte[i].in[1] <== 4;
        range_check[m+1] <== range_check[m] + (lte[i].out * gte[i].out);
        m++;
    }
    component range_check_eq = IsEqual();
    range_check_eq.in[0] <== range_check[16];
    range_check_eq.in[1] <== 16;
    
    /// Sum checks for each row

    // Sum checks for row 1
    m = 0;
    signal sum1[4];
    sum1[m] <== solution[0];
    for(var q = 1; q < 4; q++){
        sum1[m+1] <== sum1[m] + solution[q];
        m++;
    }
    component rs_eq1 = IsEqual();
    rs_eq1.in[0] <== sum1[3];
    rs_eq1.in[1] <== 10;

    // Sum checks for row 2
    m = 0;
    signal sum2[4];
    sum2[m] <== solution[4];
    for(var q = 5; q < 8; q++){
        sum2[m+1] <== sum2[m] + solution[q];
        m++;
    }
    component rs_eq2 = IsEqual();
    rs_eq2.in[0] <== sum2[3];
    rs_eq2.in[1] <== 10;

    // Sum checks for row 3
    m = 0;
    signal sum3[4];
    sum3[m] <== solution[8];
    for(var q = 9; q < 12; q++){
        sum3[m+1] <== sum3[m] + solution[q];
        m++;
    }
    component rs_eq3 = IsEqual();
    rs_eq3.in[0] <== sum3[3];
    rs_eq3.in[1] <== 10;

    // Sum checks for row 4
    m = 0;
    signal sum4[4];
    sum4[m] <== solution[12];
    for(var q = 13; q < 16; q++){
        sum4[m+1] <== sum4[m] + solution[q];
        m++;
    }
    component rs_eq4 = IsEqual();
    rs_eq4.in[0] <== sum4[3];
    rs_eq4.in[1] <== 10;

    // Row sum checks
    signal row_sum;
    row_sum <== rs_eq1.out + rs_eq2.out + rs_eq3.out + rs_eq4.out;
    component row_sum_eq = IsEqual();
    row_sum_eq.in[0] <== row_sum;
    row_sum_eq.in[1] <== 4;


    /// Uniqueness checks for each row

    // Uniqueness checks for row1
    // (a,b) pairs: (0,1),(0,2),(0,3),(1,2),(1,3),(2,3)
    component neq1[6];
    m = 0;
    signal r1_unq[7];
    r1_unq[m] <== 0;
    for(var a = 0; a < 4; a++){
        for(var b = a + 1; b < 4; b++){
            neq1[m] = IsEqual();
            neq1[m].in[0] <== solution[a];
            neq1[m].in[1] <== solution[b];
            r1_unq[m+1] <== r1_unq[m] + (1 - neq1[m].out);
            m++;
        }
    }
    component r1_unq_eq = IsEqual();
    r1_unq_eq.in[0] <== r1_unq[6];
    r1_unq_eq.in[1] <== 6;

    // Uniqueness checks for row2
    // (a,b) pairs: (4,5),(4,6),(4,7),(5,6),(5,7),(6,7)
    component neq2[6];
    m = 0;
    signal r2_unq[7];
    r2_unq[m] <== 0;
    for(var a = 4; a < 8; a++){
        for(var b = a + 1; b < 8; b++){
            neq2[m] = IsEqual();
            neq2[m].in[0] <== solution[a];
            neq2[m].in[1] <== solution[b];
            r2_unq[m+1] <== r2_unq[m] + (1 - neq2[m].out);
            m++;
        }
    }
    component r2_unq_eq = IsEqual();
    r2_unq_eq.in[0] <== r2_unq[6];
    r2_unq_eq.in[1] <== 6;

    // Uniqueness checks for row3
    // (a,b) pairs: (8,9),(8,10),(8,11),(9,10),(9,11),(10,11)
    component neq3[6];
    m = 0;
    signal r3_unq[7];
    r3_unq[m] <== 0;
    for(var a = 8; a < 12; a++){
        for(var b = a + 1; b < 12; b++){
            neq3[m] = IsEqual();
            neq3[m].in[0] <== solution[a];
            neq3[m].in[1] <== solution[b];
            r3_unq[m+1] <== r3_unq[m] + (1 - neq3[m].out);
            m++;
        }
    }
    component r3_unq_eq = IsEqual();
    r3_unq_eq.in[0] <== r3_unq[6];
    r3_unq_eq.in[1] <== 6;

    // Uniqueness checks for row4
    // (a,b) pairs: (12,13),(12,14),(12,15),(13,14),(13,15),(14,15)
    component neq4[6];
    m = 0;
    signal r4_unq[7];
    r4_unq[m] <== 0;
    for(var a = 12; a < 16; a++){
        for(var b = a + 1; b < 16; b++){
            neq4[m] = IsEqual();
            neq4[m].in[0] <== solution[a];
            neq4[m].in[1] <== solution[b];
            r4_unq[m+1] <== r4_unq[m] + (1 - neq4[m].out);
            m++;
        }
    }
    component r4_unq_eq = IsEqual();
    r4_unq_eq.in[0] <== r4_unq[6];
    r4_unq_eq.in[1] <== 6;

    // Final Uniqueness checks for rows
    signal row_unq_sum;
    row_unq_sum <== r1_unq_eq.out + r2_unq_eq.out + r3_unq_eq.out + r4_unq_eq.out;
    component row_unq_sum_eq = IsEqual();
    row_unq_sum_eq.in[0] <== row_unq_sum;
    row_unq_sum_eq.in[1] <== 4;



    /// Sum checks for each column

    // Sum checks for column 1
    m = 0;
    signal sum5[4];
    sum5[m] <== solution[0];
    for(var q = 4; q < 16; q+=4){
        sum5[m+1] <== sum5[m] + solution[q];
        m++;
    }
    component cs_eq1 = IsEqual();
    cs_eq1.in[0] <== sum5[3];
    cs_eq1.in[1] <== 10;

    // Sum checks for column 2
    m = 0;
    signal sum6[4];
    sum6[m] <== solution[1];
    for(var q = 5; q < 16; q+=4){
        sum6[m+1] <== sum6[m] + solution[q];
        m++;
    }
    component cs_eq2 = IsEqual();
    cs_eq2.in[0] <== sum6[3];
    cs_eq2.in[1] <== 10;

    // Sum checks for column 3
    m = 0;
    signal sum7[4];
    sum7[m] <== solution[2];
    for(var q = 6; q < 16; q+=4){
        sum7[m+1] <== sum7[m] + solution[q];
        m++;
    }
    component cs_eq3 = IsEqual();
    cs_eq3.in[0] <== sum7[3];
    cs_eq3.in[1] <== 10;

    // Sum checks for column 4
    m = 0;
    signal sum8[4];
    sum8[m] <== solution[3];
    for(var q = 7; q < 16; q+=4){
        sum8[m+1] <== sum8[m] + solution[q];
        m++;
    }
    component cs_eq4 = IsEqual();
    cs_eq4.in[0] <== sum8[3];
    cs_eq4.in[1] <== 10;

    //Column sum checks
    signal col_sum;
    col_sum <== cs_eq1.out + cs_eq2.out + cs_eq3.out + cs_eq4.out;
    component col_sum_eq = IsEqual();
    col_sum_eq.in[0] <== col_sum;
    col_sum_eq.in[1] <== 4;

    /// Uniqueness checks for columns

    // Uniqueness checks for column1
    // (a,b) pairs: (0,4),(0,8),(0,12),(4,8),(4,12),(8,12)
    component cneq1[6];
    m = 0;
    signal c1_unq[7];
    c1_unq[m] <== 0;
    for(var a = 0; a < 16; a+=4){
        for(var b = a + 4; b < 16; b+=4){
            cneq1[m] = IsEqual();
            cneq1[m].in[0] <== solution[a];
            cneq1[m].in[1] <== solution[b];
            c1_unq[m+1] <== c1_unq[m] + (1 - cneq1[m].out);
            m++;
        }
    }
    component c1_unq_eq = IsEqual();
    c1_unq_eq.in[0] <== c1_unq[6];
    c1_unq_eq.in[1] <== 6;


    // Uniqueness checks for column2
    // (a,b) pairs: (1,5),(1,9),(1,13),(5,9),(5,13),(9,13)
    component cneq2[6];
    m = 0;
    signal c2_unq[7];
    c2_unq[m] <== 0;
    for(var a = 1; a < 16; a+=4){
        for(var b = a + 4; b < 16; b+=4){
            cneq2[m] = IsEqual();
            cneq2[m].in[0] <== solution[a];
            cneq2[m].in[1] <== solution[b];
            c2_unq[m+1] <== c2_unq[m] + (1 - cneq2[m].out);
            m++;
        }
    }
    component c2_unq_eq = IsEqual();
    c2_unq_eq.in[0] <== c2_unq[6];
    c2_unq_eq.in[1] <== 6;

    // Uniqueness checks for column3
    // (a,b) pairs: (2,6),(2,10),(2,14),(6,10),(6,14),(10,14)
    component cneq3[6];
    m = 0;
    signal c3_unq[7];
    c3_unq[m] <== 0;
    for(var a = 2; a < 16; a+=4){
        for(var b = a + 4; b < 16; b+=4){
            cneq3[m] = IsEqual();
            cneq3[m].in[0] <== solution[a];
            cneq3[m].in[1] <== solution[b];
            c3_unq[m+1] <== c3_unq[m] + (1 - cneq3[m].out);
            m++;
        }
    }
    component c3_unq_eq = IsEqual();
    c3_unq_eq.in[0] <== c3_unq[6];
    c3_unq_eq.in[1] <== 6;

    // Uniqueness checks for column4
    // (a,b) pairs: (3,7),(3,11),(3,15),(7,11),(7,15),(11,15)
    component cneq4[6];
    m = 0;
    signal c4_unq[7];
    c4_unq[m] <== 0;
    for(var a = 3; a < 16; a+=4){
        for(var b = a + 4; b < 16; b+=4){
            cneq4[m] = IsEqual();
            cneq4[m].in[0] <== solution[a];
            cneq4[m].in[1] <== solution[b];
            c4_unq[m+1] <== c4_unq[m] + (1 - cneq4[m].out);
            m++;
        }
    }
    component c4_unq_eq = IsEqual();
    c4_unq_eq.in[0] <== c4_unq[6];
    c4_unq_eq.in[1] <== 6;

    // Final Uniqueness checks for columns
    signal col_unq_sum;
    col_unq_sum <== c1_unq_eq.out + c2_unq_eq.out + c3_unq_eq.out + c4_unq_eq.out;
    component col_unq_sum_eq = IsEqual();
    col_unq_sum_eq.in[0] <== col_unq_sum;
    col_unq_sum_eq.in[1] <== 4;

    //////////// 2x2 box checks /////////////

    /// Box 1 checks
    // Entries: solution[0],solution[1],solution[4],solution[5]
    var box1_indices[4]; // Why in this way, Because signal x <== solution[box1_indices[i]]; gives error. Chained array lookups (like solution[arr[i]]) don't work because the compiler can't inline them.
    box1_indices[0] = 0;
    box1_indices[1] = 1;
    box1_indices[2] = 4;
    box1_indices[3] = 5;
    // sum check
    m = 0;
    signal box1_sum[4];
    box1_sum[m] <== solution[box1_indices[0]];
    for (var i = 1; i < 4; i++){
        box1_sum[m+1] <== box1_sum[m] + solution[box1_indices[i]];
        m++;
    }
    component box1_sum_eq = IsEqual();
    box1_sum_eq.in[0] <== box1_sum[3];
    box1_sum_eq.in[1] <== 10;

    /// Box 2 checks
    // Entries: solution[2],solution[3],solution[6],solution[7]
    var box2_indices[4];
    box2_indices[0] = 2;
    box2_indices[1] = 3;
    box2_indices[2] = 6;
    box2_indices[3] = 7;
    // sum check
    m = 0;
    signal box2_sum[4];
    box2_sum[m] <== solution[box2_indices[0]];
    for (var i = 1; i < 4; i++){
        box2_sum[m+1] <== box2_sum[m] + solution[box2_indices[i]];
        m++;
    }
    component box2_sum_eq = IsEqual();
    box2_sum_eq.in[0] <== box2_sum[3];
    box2_sum_eq.in[1] <== 10;

    /// Box 3 checks
    // Entries: solution[8],solution[9],solution[12],solution[13]
    var box3_indices[4];
    box3_indices[0] = 8;
    box3_indices[1] = 9;
    box3_indices[2] = 12;
    box3_indices[3] = 13;
    // sum check
    m = 0;
    signal box3_sum[4];
    box3_sum[m] <== solution[box3_indices[0]];
    for (var i = 1; i < 4; i++){
        box3_sum[m+1] <== box3_sum[m] + solution[box3_indices[i]];
        m++;
    }
    component box3_sum_eq = IsEqual();
    box3_sum_eq.in[0] <== box3_sum[3];
    box3_sum_eq.in[1] <== 10;

    /// Box 4 checks
    // Entries: solution[10],solution[11],solution[14],solution[15]
    var box4_indices[4];
    box4_indices[0] = 10;
    box4_indices[1] = 11;
    box4_indices[2] = 14;
    box4_indices[3] = 15;
    // sum check
    m = 0;
    signal box4_sum[4];
    box4_sum[m] <== solution[box4_indices[0]];
    for (var i = 1; i < 4; i++){
        box4_sum[m+1] <== box4_sum[m] + solution[box4_indices[i]];
        m++;
    }
    component box4_sum_eq = IsEqual();
    box4_sum_eq.in[0] <== box4_sum[3];
    box4_sum_eq.in[1] <== 10;

    // Final Box sum checks
    signal box_sum;
    box_sum <== box1_sum_eq.out + box2_sum_eq.out + box3_sum_eq.out + box4_sum_eq.out;
    component box_sum_eq = IsEqual();
    box_sum_eq.in[0] <== box_sum;
    box_sum_eq.in[1] <== 4;

    /// Uniqueness checks for boxes 

    // Box 1 uniqueness checks
    // box1_indices = [0,1,4,5]; // Already defined above
    component box1_neq[6];
    m = 0;
    signal box1_unq[7];
    box1_unq[m] <== 0;
    for(var i = 0; i < 4; i++){
        for(var j = i + 1; j < 4; j++){
            box1_neq[m] = IsEqual();
            box1_neq[m].in[0] <== solution[box1_indices[i]];
            box1_neq[m].in[1] <== solution[box1_indices[j]];
            box1_unq[m+1] <== box1_unq[m] + (1 - box1_neq[m].out);
            m++;
        }
    }
    component box1_unq_eq = IsEqual();
    box1_unq_eq.in[0] <== box1_unq[6];
    box1_unq_eq.in[1] <== 6;

    // Box 2 uniqueness checks
    // box2_indices = [2,3,6,7]; // Already defined above
    component box2_neq[6];
    m = 0;
    signal box2_unq[7];
    box2_unq[m] <== 0;
    for(var i = 0; i < 4; i++){
        for(var j = i + 1; j < 4; j++){
            box2_neq[m] = IsEqual();
            box2_neq[m].in[0] <== solution[box2_indices[i]];
            box2_neq[m].in[1] <== solution[box2_indices[j]];
            box2_unq[m+1] <== box2_unq[m] + (1 - box2_neq[m].out);
            m++;
        }
    }
    component box2_unq_eq = IsEqual();
    box2_unq_eq.in[0] <== box2_unq[6];
    box2_unq_eq.in[1] <== 6;

    // Box 3 uniqueness checks
    // box3_indices = [8,9,12,13]; // Already defined above
    component box3_neq[6];
    m = 0;
    signal box3_unq[7];
    box3_unq[m] <== 0;
    for(var i = 0; i < 4; i++){
        for(var j = i + 1; j < 4; j++){
            box3_neq[m] = IsEqual();
            box3_neq[m].in[0] <== solution[box3_indices[i]];
            box3_neq[m].in[1] <== solution[box3_indices[j]];
            box3_unq[m+1] <== box3_unq[m] + (1 - box3_neq[m].out);
            m++;
        }
    }
    component box3_unq_eq = IsEqual();
    box3_unq_eq.in[0] <== box3_unq[6];
    box3_unq_eq.in[1] <== 6;

    // Box 4 uniqueness checks
    // box4_indices = [10,11,14,15]; // Already defined above
    component box4_neq[6];
    m = 0;
    signal box4_unq[7];
    box4_unq[m] <== 0;
    for(var i = 0; i < 4; i++){
        for(var j = i + 1; j < 4; j++){
            box4_neq[m] = IsEqual();
            box4_neq[m].in[0] <== solution[box4_indices[i]];
            box4_neq[m].in[1] <== solution[box4_indices[j]];
            box4_unq[m+1] <== box4_unq[m] + (1 - box4_neq[m].out);
            m++;
        }
    }
    component box4_unq_eq = IsEqual();
    box4_unq_eq.in[0] <== box4_unq[6];
    box4_unq_eq.in[1] <== 6;

    // Final Uniqueness checks for boxes
    signal box_unq_sum;
    box_unq_sum <== box1_unq_eq.out + box2_unq_eq.out + box3_unq_eq.out + box4_unq_eq.out;
    component box_unq_sum_eq = IsEqual();
    box_unq_sum_eq.in[0] <== box_unq_sum;
    box_unq_sum_eq.in[1] <== 4;

    // Final output
    signal row_checks;
    row_checks <== row_sum_eq.out * row_unq_sum_eq.out;
    signal col_checks;
    col_checks <== col_sum_eq.out * col_unq_sum_eq.out;
    signal box_checks;
    box_checks <== box_sum_eq.out * box_unq_sum_eq.out;

    signal intermediate1;
    intermediate1 <== row_checks * col_checks;
    signal intermediate2;
    intermediate2 <== box_checks * range_check_eq.out;
    out <== intermediate1 * intermediate2;
}

component main = Sudoku(); 
// @todo : Make generic for n x n sudoku