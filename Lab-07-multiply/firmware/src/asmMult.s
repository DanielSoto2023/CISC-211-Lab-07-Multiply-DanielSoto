/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Daniel Soto"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
.if 0
    /* profs test code. */
    mov r0,r0
.endif
    
    /** note to profs: asmMult.s solution is in Canvas at:
     *    Canvas Files->
     *        Lab Files and Coding Examples->
     *            Lab 8 Multiply
     * Use it to test the C test code */
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    LDR R6,=0 /*Setting the values to 0*/
    LDR r7,=a_Multiplicand
    LDR r8,=b_Multiplier
    STR r6,[r7]
    STR r6,[r8]
    LDR r7,=rng_Error
    LDR r8,=a_Sign
    STR r6,[r7]
    STR r6,[r8]
    LDR r7,=b_Sign
    LDR r8,=prod_Is_Neg
    STR r6,[r7]
    STR r6,[r8]
    LDR r7,=a_Abs
    LDR r8,=b_Abs
    STR r6,[r7]
    STR r6,[r8]
    LDR r7,=init_Product
    LDR r8,=final_Product
    STR r6,[r7]
    STR r6,[r8]
    
    LDR r7,=a_Multiplicand
    LDR r8,=b_Multiplier
    STR r0,[r7]
    STR r1,[r8]
    
    
    /*Redundant reversing of two's compliment to check if it exceeds the 16 bit limit
    for input because I can't think of another way*/
    BAL signBit
    errorCheck:
    LDR r10,=1
    LDR r3, =32767 /*Check error*/
    LDR r8,=32768
    CMP r10,r5
    BEQ errorANeg /* Branches to convert 2's comp to normal to check if larger than 16b*/
    LDR r1,=a_Multiplicand
    LDR r1,[r1]
    CMP r1,r3
    BGT errorcase
    afterErrorANeg:
    CMP r10,r6
    BEQ errorBNeg  /* Branches to convert 2's comp to normal to check if larger than 16b*/
    LDR r1,=b_Multiplier
    LDR r1,[r1]
    CMP r1,r3
    BGT errorcase
    afterErrorBNeg:
    BAL afterErrorCheck
    
    errorANeg:
    LDR r1,=a_Multiplicand
    LDR r1,[r1]
    NEG r1,r1
    CMP r1,r8
    BGT errorcase
    BAL afterErrorANeg
    
    errorBNeg:
    LDR r1,=b_Multiplier
    LDR r1,[r1]
    NEG r1,r1
    CMP r1,r8
    BGT errorcase
    BAL afterErrorBNeg
    
    
    signBit:
    LDR r3,=0x80000000 /*Extrect the 15th bit (Sign bit), Since the input is sign extended
    when I thought the input would be 0x0000FFFF as the maximum 2's comp negative number*/
    LDR r1,=a_Multiplicand
    LDR r1,[r1]
    LDR r2,=b_Multiplier
    LDR r2,[r2]
    AND r5,r1,r3 /*A*/
    AND r6,r2,r3 /*B*/
    
    LSR r5,r5,31 /* to get the sign bit to the LSB then store the sign bit*/
    LSR r6,r6,31
    BAL errorCheck
    afterErrorCheck:
    LDR r3,=a_Sign
    LDR r4,=b_Sign
    STR r5,[r3]
    STR r6,[r4]
    
    EOR r10,r5,r6
    LDR r3,=prod_Is_Neg
    STR r10,[r3] /* Check if result negative or not*/
    
    /*R5 = A sign, R6 = B_Sign*/
    LDR r1,=1 /*Check sign bit then do absolute value if its negative*/
    CMP r5,r1
    BEQ AbsoluteA
    LDR r1,=a_Multiplicand
    LDR r1,[r1]
    LDR r2,=a_Abs
    STR r1,[r2]
    PastAbsoluteA:
    LDR r1,=1
    CMP r6,r1
    BEQ AbsoluteB
    LDR r1,=b_Multiplier
    LDR r1,[r1]
    LDR r2,=b_Abs
    STR r1,[r2]
    PastAbsoluteB:
    BAL setup
    
    AbsoluteA:/*Reverses Two Compliment*/
    LDR r1,=a_Multiplicand
    LDR r1,[r1]
    NEG r1,r1
    LDR r2,=a_Abs
    STR r1,[r2]
    BAL PastAbsoluteA
    
    AbsoluteB: /*Same as above*/
    LDR r1,=b_Multiplier
    LDR r1,[r1]
    NEG r1,r1
    LDR r2,=b_Abs
    STR r1,[r2]
    BAL PastAbsoluteB
   
    setup: /*Setup*/
    LDR r3,=a_Abs
    LDR r4,=b_Abs
    LDR r0,[r3] /*Initilization*/
    LDR r1,[r4]
    LDR r9,=1
    LDR r10,=0
    LDR r11, =0x00000001
    LDR r3,=0
    
    loop:
    CMP r1,r10 /*Check if multiplier is 0*/
    BEQ beforedone
    AND r4,r11,r1 /*Mask out every bit except LSB then if it is not 0 add to result*/
    CMP r4,r10
    BEQ shift
    ADD r3,r3,r0
    
    shift: /*Shift plier and cand*/
    LSR r1,r1,1
    LSL r0,r0,1
    BAL loop
    
    beforedone: /*Formatting the output by putting it into respective adresses and registers*/
    LDR r10,=init_Product
    STR r3,[r10]
    LDR r11,=prod_Is_Neg
    LDR r11,[r11]
    LDR r10,=1
    CMP r11,r10
    BEQ compliment
    LDR r11,=final_Product
    STR r3,[r11]
    MOV r0,r3
    BAL done
    
    compliment: /*Take the compliment if the product is negative*/
    NEG r3,r3
    LDR r11,=final_Product
    STR r3,[r11]
    MOV r0,r3
    MOV r3,0 /*Check if final product is zero*/
    CMP r0,r3
    BEQ zeroCheck
    BAL done
    
    zeroCheck: /*If the final product is 0 then change prod is neg to 0*/
    LDR r1,=prod_Is_Neg
    LDR r2,=0
    STR r2,[r1]
    BAL done
    
    errorcase: /*Error case*/
    LDR r5,=rng_Error
    LDR r6,=1
    LDR r0,=0
    STR r6,[r5]
    BAL done
     
    
    
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 

screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




