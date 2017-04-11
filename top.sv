module top(input logic CLOCK_50);

// Put in some real FPGA connections here

endmodule

module testbench();
	// AES Block Size
	parameter BLOCK_WIDTH = 128;

	logic clk, rst;
	logic eStart, dStart, eDone, dDone;
	logic [BLOCK_WIDTH-1:0] key;
	logic [BLOCK_WIDTH-1:0] plainin, cipherout, cipherin, plainout;

	JB_AES_Encrypt #(.BLOCK_WIDTH(BLOCK_WIDTH))
		eDut (.clk(clk), .nRst(rst),
			  .nStart(eStart), .nDone(eDone),
			  .key(key), .blockin(plainin), .blockout(cipherout));

	JB_AES_Decrypt #(.BLOCK_WIDTH(BLOCK_WIDTH))
		dDut (.clk(clk), .nRst(rst),
			  .nStart(dStart), .nDone(dDone),
			  .key(key), .blockin(cipherin), .blockout(plainout));

	// Simiulation Clock Source
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	// Exercise the modules
	initial begin
		$monitor("eStart=%b, eDone=%b, key=%8.8d, p-in=%8.8d, c-out=%8.8d, c-in=%8.8d, p-out=%8.8d",
				 eStart, eDone,
				 key,
				 plainin, cipherout, cipherin, plainout);

		// Setup Initial State
		rst    <= 1;
		eStart <= 1;
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
		plainin <= 128'h52;
		eStart  <= 0;
		$display("time=%8.8d: eStart = %b", $time, eStart);
		@(posedge clk)

		eStart  <= 1;
		@(posedge clk)

		/* Wait for Encryption Done */
		@(negedge eDone)
		cipherin <= cipherout;
		$display("time=%8.8d: eDone = %b", $time, eDone);
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
		//$monitor("dut.line = %d", dut.line);
		$finish;
	end
endmodule
