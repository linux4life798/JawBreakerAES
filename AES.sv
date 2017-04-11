// AES Block Sizes:
// 16, 24, or 32 bytes
// 128, 192, 256 bits
// AES-128, AES-192, or AES-256 modes

typedef enum logic [1:0] {WAIT, PHASE1, PHASE2, DONE} aes_state_t;

/* Should Probably Facilitate The Common AES Phase Modules Here */

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