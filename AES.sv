// AES Block Sizes:
// 16, 24, or 32 bytes
// 128, 192, 256 bits
// AES-128, AES-192, or AES-256 modes

typedef enum logic [1:0] {WAIT, PHASE1, PHASE2, DONE} aes_state_t;

/* Using C style array indices to match typical AES implementations */
typedef logic [0:4-1][0:4-1][8-1:0] block128_t;

typedef logic [7:0] roundconstants_t [0:9];

module JB_AES_RoundConstants(roundconstants);
    output roundconstants_t roundconstants;
    assign roundconstants = '{
        8'h01, 8'h02, 8'h04, 8'h08, 8'h10, 8'h20, 8'h40, 8'h80, 8'h1b, 8'h36
    };
endmodule

/* Should Probably Facilitate The Common AES Phase Modules Here */

/**
 * This simply labels the bit stream with the packed block_t type
 */
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
        blockout[1] = {blockin[1][1:3], blockin[1][0]}; // rotate once
        blockout[2] = {blockin[2][2:3], blockin[2][0:1]};
        blockout[3] = {blockin[3][3], blockin[3][0:2]};
    end
endmodule

module JB_AES_SubBytes(blockin, blockout);
    input  block128_t blockin;
    output block128_t blockout;

   logic [0:15][0:15][7:0] s_box;
   assign s_box[0] = {8'h63,8'h7c,8'h77,8'h7b,8'hf2,8'h6b,8'h6f,8'hc5,8'h30,8'h01,8'h67,8'h2b,8'hfe,8'hd7,8'hab,8'h76};
   assign s_box[1] = {8'hca,8'h82,8'hc9,8'h7d,8'hfa,8'h59,8'h47,8'hf0,8'had,8'hd4,8'ha2,8'haf,8'h9c,8'ha4,8'h72,8'hc0};
   assign s_box[2] = {8'hb7,8'hfd,8'h93,8'h26,8'h36,8'h3f,8'hf7,8'hcc,8'h34,8'ha5,8'he5,8'hf1,8'h71,8'hd8,8'h31,8'h15};
   assign s_box[3] = {8'h04,8'hc7,8'h23,8'hc3,8'h18,8'h96,8'h05,8'h9a,8'h07,8'h12,8'h80,8'he2,8'heb,8'h27,8'hb2,8'h75};
   assign s_box[4] = {8'h09,8'h83,8'h2c,8'h1a,8'h1b,8'h6e,8'h5a,8'ha0,8'h52,8'h3b,8'hd6,8'hb3,8'h29,8'he3,8'h2f,8'h84};
   assign s_box[5] = {8'h53,8'hd1,8'h00,8'hed,8'h20,8'hfc,8'hb1,8'h5b,8'h6a,8'hcb,8'hbe,8'h39,8'h4a,8'h4c,8'h58,8'hcf};
   assign s_box[6] = {8'hd0,8'hef,8'haa,8'hfb,8'h43,8'h4d,8'h33,8'h85,8'h45,8'hf9,8'h02,8'h7f,8'h50,8'h3c,8'h9f,8'ha8};
   assign s_box[7] = {8'h51,8'ha3,8'h40,8'h8f,8'h92,8'h9d,8'h38,8'hf5,8'hbc,8'hb6,8'hda,8'h21,8'h10,8'hff,8'hf3,8'hd2};
   assign s_box[8] = {8'hcd,8'h0c,8'h13,8'hec,8'h5f,8'h97,8'h44,8'h17,8'hc4,8'ha7,8'h7e,8'h3d,8'h64,8'h5d,8'h19,8'h73};
   assign s_box[9] = {8'h60,8'h81,8'h4f,8'hdc,8'h22,8'h2a,8'h90,8'h88,8'h46,8'hee,8'hb8,8'h14,8'hde,8'h5e,8'h0b,8'hdb};
   assign s_box[10] = {8'he0,8'h32,8'h3a,8'h0a,8'h49,8'h06,8'h24,8'h5c,8'hc2,8'hd3,8'hac,8'h62,8'h91,8'h95,8'he4,8'h79};
   assign s_box[11] = {8'he7,8'hc8,8'h37,8'h6d,8'h8d,8'hd5,8'h4e,8'ha9,8'h6c,8'h56,8'hf4,8'hea,8'h65,8'h7a,8'hae,8'h08};
   assign s_box[12] = {8'hba,8'h78,8'h25,8'h2e,8'h1c,8'ha6,8'hb4,8'hc6,8'he8,8'hdd,8'h74,8'h1f,8'h4b,8'hbd,8'h8b,8'h8a};
   assign s_box[13] = {8'h70,8'h3e,8'hb5,8'h66,8'h48,8'h03,8'hf6,8'h0e,8'h61,8'h35,8'h57,8'hb9,8'h86,8'hc1,8'h1d,8'h9e};
   assign s_box[14] = {8'he1,8'hf8,8'h98,8'h11,8'h69,8'hd9,8'h8e,8'h94,8'h9b,8'h1e,8'h87,8'he9,8'hce,8'h55,8'h28,8'hdf};
   assign s_box[15] = {8'h8c,8'ha1,8'h89,8'h0d,8'hbf,8'he6,8'h42,8'h68,8'h41,8'h99,8'h2d,8'h0f,8'hb0,8'h54,8'hbb,8'h16};


   always_comb begin
      for (int i = 0; i < 4; i++) begin
         for (int j = 0; j < 4; j++) begin
            blockout[i][j] = s_box[blockin[i][j][7:4]][blockin[i][j][3:0]];
         end
      end
   end
endmodule

module JB_AES_MixColumns(blockin, blockout);
    input  block128_t blockin;
    output block128_t blockout;

   logic [0:15][0:15][7:0] gt_2,gt_3;
   logic [0:3][0:3][1:0] mds_mat;

   //Multiply by 2 Lookup table
   assign gt_2[0] = {8'h00,8'h02,8'h04,8'h06,8'h08,8'h0a,8'h0c,8'h0e,8'h10,8'h12,8'h14,8'h16,8'h18,8'h1a,8'h1c,8'h1e};
   assign gt_2[1] = {8'h20,8'h22,8'h24,8'h26,8'h28,8'h2a,8'h2c,8'h2e,8'h30,8'h32,8'h34,8'h36,8'h38,8'h3a,8'h3c,8'h3e};
   assign gt_2[2] = {8'h40,8'h42,8'h44,8'h46,8'h48,8'h4a,8'h4c,8'h4e,8'h50,8'h52,8'h54,8'h56,8'h58,8'h5a,8'h5c,8'h5e};
   assign gt_2[3] = {8'h60,8'h62,8'h64,8'h66,8'h68,8'h6a,8'h6c,8'h6e,8'h70,8'h72,8'h74,8'h76,8'h78,8'h7a,8'h7c,8'h7e};
   assign gt_2[4] = {8'h80,8'h82,8'h84,8'h86,8'h88,8'h8a,8'h8c,8'h8e,8'h90,8'h92,8'h94,8'h96,8'h98,8'h9a,8'h9c,8'h9e};
   assign gt_2[5] = {8'ha0,8'ha2,8'ha4,8'ha6,8'ha8,8'haa,8'hac,8'hae,8'hb0,8'hb2,8'hb4,8'hb6,8'hb8,8'hba,8'hbc,8'hbe};
   assign gt_2[6] = {8'hc0,8'hc2,8'hc4,8'hc6,8'hc8,8'hca,8'hcc,8'hce,8'hd0,8'hd2,8'hd4,8'hd6,8'hd8,8'hda,8'hdc,8'hde};
   assign gt_2[7] = {8'he0,8'he2,8'he4,8'he6,8'he8,8'hea,8'hec,8'hee,8'hf0,8'hf2,8'hf4,8'hf6,8'hf8,8'hfa,8'hfc,8'hfe};
   assign gt_2[8] = {8'h1b,8'h19,8'h1f,8'h1d,8'h13,8'h11,8'h17,8'h15,8'h0b,8'h09,8'h0f,8'h0d,8'h03,8'h01,8'h07,8'h05};
   assign gt_2[9] = {8'h3b,8'h39,8'h3f,8'h3d,8'h33,8'h31,8'h37,8'h35,8'h2b,8'h29,8'h2f,8'h2d,8'h23,8'h21,8'h27,8'h25};
   assign gt_2[10] = {8'h5b,8'h59,8'h5f,8'h5d,8'h53,8'h51,8'h57,8'h55,8'h4b,8'h49,8'h4f,8'h4d,8'h43,8'h41,8'h47,8'h45};
   assign gt_2[11] = {8'h7b,8'h79,8'h7f,8'h7d,8'h73,8'h71,8'h77,8'h75,8'h6b,8'h69,8'h6f,8'h6d,8'h63,8'h61,8'h67,8'h65};
   assign gt_2[12] = {8'h9b,8'h99,8'h9f,8'h9d,8'h93,8'h91,8'h97,8'h95,8'h8b,8'h89,8'h8f,8'h8d,8'h83,8'h81,8'h87,8'h85};
   assign gt_2[13] = {8'hbb,8'hb9,8'hbf,8'hbd,8'hb3,8'hb1,8'hb7,8'hb5,8'hab,8'ha9,8'haf,8'had,8'ha3,8'ha1,8'ha7,8'ha5};
   assign gt_2[14] = {8'hdb,8'hd9,8'hdf,8'hdd,8'hd3,8'hd1,8'hd7,8'hd5,8'hcb,8'hc9,8'hcf,8'hcd,8'hc3,8'hc1,8'hc7,8'hc5};
   assign gt_2[15] = {8'hfb,8'hf9,8'hff,8'hfd,8'hf3,8'hf1,8'hf7,8'hf5,8'heb,8'he9,8'hef,8'hed,8'he3,8'he1,8'he7,8'he5};

   //Multiply by 3 Lookup table
   assign gt_3[0] = {8'h00,8'h03,8'h06,8'h05,8'h0c,8'h0f,8'h0a,8'h09,8'h18,8'h1b,8'h1e,8'h1d,8'h14,8'h17,8'h12,8'h11};
   assign gt_3[1] = {8'h30,8'h33,8'h36,8'h35,8'h3c,8'h3f,8'h3a,8'h39,8'h28,8'h2b,8'h2e,8'h2d,8'h24,8'h27,8'h22,8'h21};
   assign gt_3[2] = {8'h60,8'h63,8'h66,8'h65,8'h6c,8'h6f,8'h6a,8'h69,8'h78,8'h7b,8'h7e,8'h7d,8'h74,8'h77,8'h72,8'h71};
   assign gt_3[3] = {8'h50,8'h53,8'h56,8'h55,8'h5c,8'h5f,8'h5a,8'h59,8'h48,8'h4b,8'h4e,8'h4d,8'h44,8'h47,8'h42,8'h41};
   assign gt_3[4] = {8'hc0,8'hc3,8'hc6,8'hc5,8'hcc,8'hcf,8'hca,8'hc9,8'hd8,8'hdb,8'hde,8'hdd,8'hd4,8'hd7,8'hd2,8'hd1};
   assign gt_3[5] = {8'hf0,8'hf3,8'hf6,8'hf5,8'hfc,8'hff,8'hfa,8'hf9,8'he8,8'heb,8'hee,8'hed,8'he4,8'he7,8'he2,8'he1};
   assign gt_3[6] = {8'ha0,8'ha3,8'ha6,8'ha5,8'hac,8'haf,8'haa,8'ha9,8'hb8,8'hbb,8'hbe,8'hbd,8'hb4,8'hb7,8'hb2,8'hb1};
   assign gt_3[7] = {8'h90,8'h93,8'h96,8'h95,8'h9c,8'h9f,8'h9a,8'h99,8'h88,8'h8b,8'h8e,8'h8d,8'h84,8'h87,8'h82,8'h81};
   assign gt_3[8] = {8'h9b,8'h98,8'h9d,8'h9e,8'h97,8'h94,8'h91,8'h92,8'h83,8'h80,8'h85,8'h86,8'h8f,8'h8c,8'h89,8'h8a};
   assign gt_3[9] = {8'hab,8'ha8,8'had,8'hae,8'ha7,8'ha4,8'ha1,8'ha2,8'hb3,8'hb0,8'hb5,8'hb6,8'hbf,8'hbc,8'hb9,8'hba};
   assign gt_3[10] = {8'hfb,8'hf8,8'hfd,8'hfe,8'hf7,8'hf4,8'hf1,8'hf2,8'he3,8'he0,8'he5,8'he6,8'hef,8'hec,8'he9,8'hea};
   assign gt_3[11] = {8'hcb,8'hc8,8'hcd,8'hce,8'hc7,8'hc4,8'hc1,8'hc2,8'hd3,8'hd0,8'hd5,8'hd6,8'hdf,8'hdc,8'hd9,8'hda};
   assign gt_3[12] = {8'h5b,8'h58,8'h5d,8'h5e,8'h57,8'h54,8'h51,8'h52,8'h43,8'h40,8'h45,8'h46,8'h4f,8'h4c,8'h49,8'h4a};
   assign gt_3[13] = {8'h6b,8'h68,8'h6d,8'h6e,8'h67,8'h64,8'h61,8'h62,8'h73,8'h70,8'h75,8'h76,8'h7f,8'h7c,8'h79,8'h7a};
   assign gt_3[14] = {8'h3b,8'h38,8'h3d,8'h3e,8'h37,8'h34,8'h31,8'h32,8'h23,8'h20,8'h25,8'h26,8'h2f,8'h2c,8'h29,8'h2a};
   assign gt_3[15] = {8'h0b,8'h08,8'h0d,8'h0e,8'h07,8'h04,8'h01,8'h02,8'h13,8'h10,8'h15,8'h16,8'h1f,8'h1c,8'h19,8'h1a};

   assign mds_mat[0] = {2'd2,2'd3,2'd1,2'd1};
   assign mds_mat[1] = {2'd1,2'd2,2'd3,2'd1};
   assign mds_mat[2] = {2'd1,2'd1,2'd2,2'd3};
   assign mds_mat[3] = {2'd3,2'd1,2'd1,2'd2};

   logic [3:0][3:0][7:0] cur_col; //current column of block
  // logic [3:0][3:0][7:0] mult_sum_block;

   logic [3:0][0:3][0:3][7:0] mult_block_mc; // values before xoring

   always_comb begin
      for (int col = 0;  col < 4; col++) begin //iterate over each column

         for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
               if(mds_mat[i][j] == 2'd2) begin
                  mult_block_mc[col][i][j] = gt_2[blockin[j][col][7:4]][blockin[j][col][3:0]];
               end else if(mds_mat[i][j] == 2'd3) begin
                  mult_block_mc[col][i][j] = gt_3[blockin[j][col][7:4]][blockin[j][col][3:0]];
               end else begin
                   mult_block_mc[col][i][j] = blockin[j][col];
               end
            end
         end

         //Converts Mult Block Matrix into column vectors and generates final output
         for (int k = 0; k < 4; k++) begin //iterate over row of mult_block_mat
            blockout[k][col]  =  mult_block_mc[col][k][0];
            for (int m = 1; m < 4; m++) begin
               blockout[k][col]  =   mult_block_mc[col][k][m] ^ blockout[k][col];
            end
         end

      end
   end

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
