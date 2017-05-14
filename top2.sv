module top(input logic CLOCK_50);

// Put in some real FPGA connections here

endmodule

module testbench2();
	// AES Block Size
	parameter BLOCK_WIDTH = 128;

	logic clk, rst;
	logic dStart, dDone;
	logic [BLOCK_WIDTH-1:0] key;
	logic [BLOCK_WIDTH-1:0] plainin, cipherout, cipherin, plainout;

	JB_AES_Encrypt_Pipe #(.BLOCK_WIDTH(BLOCK_WIDTH))
		eDut (.clk(clk), .nRst(rst),
			  .key(key), .blockin(plainin), .blockout(cipherout));

	JB_AES_Decrypt #(.BLOCK_WIDTH(BLOCK_WIDTH))
		dDut (.clk(clk), .nRst(rst),
			  .nStart(dStart), .nDone(dDone),
			  .key(key), .blockin(cipherin), .blockout(plainout));

    logic [0:3][0:3][7:0] state_block, key_block_in;
    assign state_block = {{8'h33,8'h88,8'h31,8'he0},
                    {8'h43,8'h5a,8'h31,8'h37},
                    {8'hf6,8'h30,8'h98,8'h07},
                    {8'ha8,8'h8d,8'ha2,8'h34}};

    always_comb begin
        key_block_in[0] = {8'h2b,8'h28,8'hab,8'h09};		
		key_block_in[1] = {8'h7e,8'hae,8'hf7,8'hcf};
		key_block_in[2] = {8'h15,8'hd2,8'h15,8'h4f};
		key_block_in[3] = {8'h16,8'ha6,8'h88,8'h3c};
    end

	// Simiulation Clock Source
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	// Exercise the modules
	initial begin
		// $monitor("key=%8.8d, p-in=%8.8d, c-out=%8.8d, c-in=%8.8d, p-out=%8.8d",
		// 		 key,
		// 		 plainin, cipherout, cipherin, plainout);

		// Setup Initial State
		rst    <= 1;
		dStart <= 1;

		key      <= 0;
		plainin  <= 0;
		cipherin <= 0;

		$display("# Reset Start");
		rst <= 0;
		@(posedge clk)
		rst <= 1;
		@(posedge clk)
		$display("# Reset Complete");

		/* Start Encryption */
		$display("# Starting Encryption");
		key     <= 128'd27;
        key <= key_block_in;
		// plainin <= 128'h52;
        plainin <= state_block;
		@(posedge clk)
        $display("time=%8.8d", $time);
        $display("key = %h, c-in = %h", key, plainin);
        $display("c-out = %h", cipherout);
        $display("c-out = %h", cipherout);
        @(posedge clk)
        $display("c-out = %h", cipherout);
        @(posedge clk)
        $display("c-out = %h", cipherout);
        @(posedge clk)
        $display("c-out = %h", cipherout);
        @(posedge clk)
        $display("c-out = %h", cipherout);
        @(posedge clk)
        $display("c-out = %h", cipherout);
        @(posedge clk)
        $display("c-out = %h", cipherout);
        @(posedge clk)
        $display("c-out = %h", cipherout);
        @(posedge clk)
        $display("c-out = %h", cipherout);
        @(posedge clk)
        $display("c-out = %h", cipherout);
        @(posedge clk)
        $display("c-out = %h", cipherout);

        $finish;


		/* Wait for Encryption Done */
		cipherin <= cipherout;
		$display("# Encryption Done");
		@(posedge clk)

		/* Start Decryption */
		$display("# Starting Decryption");
		key     <= 128'd27;
		dStart  <= 0;
		$display("time=%8.8d: dStart = %b", $time, dStart);
		@(posedge clk)

		dStart  <= 1;
		@(posedge clk)

		/* Wait for Decryption Done */
		@(negedge dDone)
		$display("time=%8.8d: dDone = %b", $time, dDone);
		$display("# Decryption Done");


		/* Let Simulation Run To Checkout End Behavior */
		#50000;
		$finish;
	end
endmodule
