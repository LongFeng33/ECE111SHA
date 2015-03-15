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
input	nreset;		 // Initializes the SHA1_hash module
input	start_hash;	 // Tells SHA1_hash to start hashing the given frame
input [31:0] message_addr; 
// Starting address of the messagetext frame
// i.e., specifies from where SHA1_hash must read the messagetext frame
input	[31:0] message_size;	 // Length of the message in bytes
output [159:0] hash; // hash results
input  [31:0] port_A_data_out;// read data from the dpsram (messagetext)
output [31:0] port_A_data_in; // write data to the dpsram (ciphertext)
output [15:0] port_A_addr;// address of dpsram being read/written 
output  port_A_clk;   // clock to dpsram (drive this with the input clk) 
output  port_A_we;  // read/write selector for dpsram
output  done; // done is a signal to indicate that hash  is complete

reg [3:0] state;
reg [31:0] padding_size;
reg [7:0] outloop;
reg [15:0] read_addr; 
reg [31:0] input_word;
reg [31:0] w [0:15];
reg [6:0] n;

reg [31:0] h0 = 32'h67452301;
reg [31:0] h1 = 32'hEFCDAB89;
reg [31:0] h2 = 32'h98BADCFE;
reg [31:0] h3 = 32'h10325476;
reg [31:0] h4 = 32'hC3D2E1F0;
reg [31:0] f;
reg [31:0] k;
reg [31:0] temp;
reg [31:0] a;
reg [31:0] b;
reg [31:0] c;
reg [31:0] d;
reg [31:0] e;

parameter IDLE = 0;
parameter READ = 1;
parameter COMPUTE = 2;

assign port_A_clk = clk;
assign port_A_we = 0;
assign port_A_addr = read_addr;
assign hash = {h0, h1, h2, h3, h4};


function [31:0] changeEndian; // transform data from the memory to big-endian form (default: little)
    input [31:0] value;
    changeEndian = {value[7:0], value[15:8], value[23:16], value[31:24]};
endfunction


always @(posedge clk or negedge nreset)begin
	if(!nreset)begin
		state <= IDLE; 
		n <= 8'h0;
	end
	else begin
		case(state)
			IDLE: begin
				if(start_hash)begin
					state <= READ;
					read_addr <= message_addr[15:0];
				end
			end
			READ: begin
				state <= COMPUTE;
				read_addr <= read_addr+4;
			end
			COMPUTE: begin
				if(n < 16) begin
				state <= READ;
				w[n] = changeEndian(port_A_data_out);
				end else begin
				state <= COMPUTE; 
				w[n%16] = w[(n-3)%16] ^ w[(n-8)%16] ^ w[(n-14)%16] ^ w[(n-16)%16];
           			w[n%16] = (w[n%16] << 1) | (w[n%16] >> 31);
 				end
$display("w[%d] = %x\n", n, w[n%16]);
				if (n <= 19) begin
                			f = (b & c) | ((b ^ 32'hFFFFFFFF) & d);
                			k = 32'h5A827999;
            			end else if (n<=39) begin
                			f = b ^ c ^ d;
                			k = 32'h6ED9EBA1;
            			end else if (n<=59) begin
                			f = (b & c) | (b & d) | (c & d);
               				k = 32'h8F1BBCDC;
            			end else begin
                			f = b ^ c ^ d;
                			k = 32'hCA62C1D6;
            			end

            			temp = ((a << 5)|(a >> 27)) + f + e + k + w[n];
            			e = d;
            			d = c;
            			c = ((b << 30)|(b >> 2));
            			b = a;
            			a = temp;

				n = n + 1;
			end
		endcase
	end
end


endmodule

