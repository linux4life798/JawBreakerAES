// AES Block Sizes:
// 16, 24, or 32 bytes
// 128, 192, 256 bits
// AES-128, AES-192, or AES-256 modes

typedef enum logic [1:0] {WAIT, PHASE1, PHASE2, DONE} aes_state_t;

typedef logic [4-1:0][4-1:0][8-1:0] block128_t;

/* Should Probably Facilitate The Common AES Phase Modules Here */

module JB_AES_128Block(blockin, blockout);
    input logic [128-1:0] blockin;
    output block128_t blockout;

    assign blockout = blockin;
endmodule


module JB_AES_ShiftRows(blockin, blockout);
    input  block128_t blockin;
    output block128_t blockout;

    /* Preform The Rotations */
    always_comb begin
        blockout[0] = {blockin[0]}; // rotate none
        blockout[1] = {blockin[1][2:0], blockin[1][3]}; // rotate once
        blockout[2] = {blockin[2][1:0], blockin[1][3], blockin[1][2]};
        blockout[3] = {blockin[2][0], blockin[1][3], blockin[1][2], blockin[1][1]};
    end
endmodule

module JB_AES_SubBytes(blockin, blockout);
    input  block128_t blockin;
    output block128_t blockout;

    /* Preform The Rotations */
    //TODO: Fill In SubBytes
    assign blockout = blockin;
endmodule

module JB_AES_MixColumns(blockin, blockout);
    input  block128_t blockin;
    output block128_t blockout;

    /* Preform The Rotations */
    //TODO: Fill In MixColumns
    assign blockout = blockin;
endmodule

module JB_AES_AddRoundKey(roundkey, blockin, blockout);
    input  block128_t roundkey;
    input  block128_t blockin;
    output block128_t blockout;

    assign blockout = blockin ^ roundkey;
endmodule

/* Higher Level Modules */

module JB_AES_FirstRound(roundkey, blockin, blockout);
    input  block128_t roundkey;
    input  block128_t blockin;
    output block128_t blockout;

    JB_AES_AddRoundKey(roundkey, blockin, blockout);
endmodule

module JB_AES_Round(roundkey, blockin, blockout);
    input  block128_t roundkey;
    input  block128_t blockin;
    output block128_t blockout;

    // TODO: Implement standard round here
    assign blockout = blockin ^ roundkey;
endmodule

module JB_AES_LastRound(roundkey, blockin, blockout);
    input  block128_t roundkey;
    input  block128_t blockin;
    output block128_t blockout;

    // TODO: Implement last round here
    assign blockout = blockin ^ roundkey;
endmodule

// module JB_AES_LastRound(key, blockin, blockout) begin
    
// end

module JB_AES_Encrypt(clk, nRst, nStart, nDone, key, blockin, blockout);
    parameter BLOCK_WIDTH = 128; // 128, 192, or 256
    input  logic clk, nRst;
    input  logic nStart;
    output logic nDone;
    input  logic [BLOCK_WIDTH-1:0]  key;
    input  logic [BLOCK_WIDTH-1:0]  blockin;  // unencrypted block in
    output logic [BLOCK_WIDTH-1:0]  blockout; // enrypted block out

    /* AES Internal State */
    aes_state_t state;

    // super safe XOR encryption
    assign blockout = blockin ^ key;

    assign nDone = !(state == DONE);

    /* Add a clk cycle nDone delay */
    always_ff @(posedge clk, negedge nRst) begin
        if(~nRst)
            state <= WAIT;
        else
            case(state)
                // wait for nStart to go low
                WAIT:   state <= nStart ? WAIT:PHASE1;
                PHASE1: state <= PHASE2;
                PHASE2: state <= DONE;
                DONE:   state <= WAIT;
            endcase
    end

endmodule

module JB_AES_Decrypt(clk, nRst, nStart, nDone, key, blockin, blockout);
    parameter BLOCK_WIDTH = 128; // 128, 192, or 256
    input  logic clk, nRst;
    input  logic nStart;
    output logic nDone;
    input  logic [BLOCK_WIDTH-1:0]  key;
    input  logic [BLOCK_WIDTH-1:0]  blockin;  // encrypted block in
    output logic [BLOCK_WIDTH-1:0]  blockout; // unencrypted block out

    /* AES Internal State */
    aes_state_t state;

    // super safe XOR encryption
    assign blockout = blockin ^ key;

    assign nDone = !(state == DONE);

    /* Add a clk cycle nDone delay */
    always_ff @(posedge clk, negedge nRst) begin
        if(~nRst)
            state <= WAIT;
        else
            case(state)
                // wait for nStart to go low
                WAIT:   state <= nStart ? WAIT:PHASE1;
                PHASE1: state <= PHASE2;
                PHASE2: state <= DONE;
                DONE:   state <= WAIT;
            endcase
    end
endmodule
