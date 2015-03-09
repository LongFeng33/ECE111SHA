module SHA1_hash (       
	clk, 		
	nreset, 	
	start_hash,  
	message_addr,	
	message_size, 	
	hash, 	
	done, 		
	port_A_clk,
        port_A_data_in,
        port_A_data_out,
        port_A_addr,
        port_A_we
	);
input	clk;
input	nreset; // Initializes the SHA1_hash module
input	start_hash; // Tells SHA1_hash to start hashing the given frame
input [31:0] message_addr; 
// Starting address of the messagetext frame
// i.e., specifies from where SHA1_hash must read the messagetext frame
input	reg[31:0] message_size; // Length of the message in bytes
output [159:0] hash; // hash results
input [31:0] port_A_data_out; // read data from the dpsram (messagetext)
output [31:0] port_A_data_in; // write data to the dpsram (ciphertext)
output [15:0] port_A_addr;// address of dpsram being read/written 
output  port_A_clk;// clock to dpsram (drive this with the input clk) 
output  port_A_we;// read/write selector for dpsram
output	done; // done is a signal to indicate that hash  is complete

reg [3:0] state;
reg [31:0] padding_size;
reg [7:0] k;
reg [7:0] j;
reg [7:0] i;
reg [7:0] outloop;
reg [31:0] F[0:79];

reg [31:0] h0 = 32'h67452301;
reg [31:0] h1 = 32'hEFCDAB89;
reg [31:0] h2 = 32'h98BADCFE;
reg [31:0] h3 = 32'h10325476;
reg [31:0] h4 = 32'hC3D2E1F0;

parameter IDLE = 0;
parameter PADDING = 1;
parameter COMPUTE = 2;

hash = {h0, h1, h2, h3, h4};

always @(posedge clk or negedge nreset)begin
	if(!nreset)begin
		state <= IDLE; 
	end
	else begin
		case(state)
			IDLE: begin
				if(start_hash)begin
					state <= PADDING;
				end
			end
			PADDING: begin
				if ((message_length + 1) % 64 <= 56)
					padding_size = (message_size/64)*64 + 56; 
				else
					padding_size = (message_size/64+1)*64 + 56;
				//TODO: decide whether to write everything to dpsram or keep the paddings in an array
				outloop = padding_size/64;
			end
			COMPUTE: begin
				
			end
	end

end


endmodule