
module EF
#(
    parameter TAP_N     = 17, // can change, student self-define
    parameter DI_IL_W   = 2, // can change, student self-define
    parameter DI_FL_W   = 5, // can change, student self-define
    parameter DI_W      = DI_IL_W + DI_FL_W + 1,
    parameter C_IL_W    = 2, // can change, student self-define
    parameter C_FL_W    = 5, // can change, student self-define
    parameter C_W       = C_IL_W + C_FL_W + 1,
    parameter DO_IL_W   = 2, // can change, student self-define
    parameter DO_FL_W   = 5, // can change, student self-define
    parameter DO_W      = DO_IL_W + DO_FL_W + 1
)
(
    input  wire                 clk, 
    input  wire                 rst_n,
    input  wire                 valid_i,
    input  wire signed [DI_W-1:0]      data_i,
    input  wire  [TAP_N*C_W-1:0] coeff_i,
    output reg                  valid_o, // wire or reg, student self-define
    output reg  signed [DO_W-1:0]      data_o   // wire or reg, student self-define
);

// here to begin your design

reg [4:0] cnt;
reg signed [7:0] buffer [16:0];
reg signed [19:0] result;//use for accumulate
wire signed [19:0] round;
reg signed [14:0] mut;//use for storing muted data
reg signed [7:0] num_i;//use for fetch the buffer
reg signed [7:0] num_c;//use for fetch the coeff

assign round = (20'h00010 & result) + result;

always@(posedge clk or negedge rst_n)//counter now is 20 cycles
begin
	if(!rst_n) cnt <= 0;
	else if(cnt == 19) cnt <= 0;
	else if(cnt == 0 && valid_i == 1) cnt <= cnt + 1;
	else if(cnt == 0 && valid_i == 0) cnt <= cnt;
	else cnt <= cnt + 1;
end

always@(posedge clk or negedge rst_n)//buffer
begin
	if(!rst_n)
	begin
	buffer[0] <= 0;
	buffer[1] <= 0;
	buffer[2] <= 0;
	buffer[3] <= 0;
	buffer[4] <= 0;
	buffer[5] <= 0;
	buffer[6] <= 0;
	buffer[7] <= 0;
	buffer[8] <= 0;
	buffer[9] <= 0;
	buffer[10] <= 0;
	buffer[11] <= 0;
	buffer[12] <= 0;
	buffer[13] <= 0;
	buffer[14] <= 0;
	buffer[15] <= 0;
	buffer[16] <= 0;
	end
	else if(cnt == 0 && valid_i == 1) 
			begin
				buffer[0] <= data_i;
				buffer[1] <= buffer[0];
				buffer[2] <= buffer[1];
				buffer[3] <= buffer[2];
				buffer[4] <= buffer[3];
				buffer[5] <= buffer[4];
				buffer[6] <= buffer[5];
				buffer[7] <= buffer[6];
				buffer[8] <= buffer[7];
				buffer[9] <= buffer[8];
				buffer[10] <= buffer[9];
				buffer[11] <= buffer[10];
				buffer[12] <= buffer[11];
				buffer[13] <= buffer[12];
				buffer[14] <= buffer[13];
				buffer[15] <= buffer[14];
				buffer[16] <= buffer[15];
			end
	else begin
		buffer[0] <= buffer[0];
		buffer[1] <= buffer[1];
		buffer[2] <= buffer[2];
		buffer[3] <= buffer[3];
		buffer[4] <= buffer[4];
		buffer[5] <= buffer[5];
		buffer[6] <= buffer[6];
		buffer[7] <= buffer[7];
		buffer[8] <= buffer[8];
		buffer[9] <= buffer[9];
		buffer[10] <= buffer[10];
		buffer[11] <= buffer[11];
		buffer[12] <= buffer[12];
		buffer[13] <= buffer[13];
		buffer[14] <= buffer[14];
		buffer[15] <= buffer[15];
		buffer[16] <= buffer[16];
	end
end

always@(posedge clk or negedge rst_n)//result_reg
begin
	if(!rst_n) result <= 0;
	else if(cnt == 2) result <= mut;
	else if(cnt >= 3 && cnt <= 18)
		begin
			result <= result + mut;
		end
 	else result <= result;
end

always@(posedge clk or negedge rst_n)//valid_o  
begin
	if(!rst_n) valid_o <= 0;
	else if(cnt == 19) valid_o <= 1;
	else valid_o <= 0;
end

always@(posedge clk or negedge rst_n)//data_o 
begin
	if(!rst_n) data_o <= 0;
	else if(cnt == 19)//output time
		begin
			if(result[19] == 1) begin //negative
				if(result[18:12] == 7'b111_1111)//not saturated
				begin
					data_o[6:0] <= round[11:5];//cut off
					data_o[7] <= 1;
				end
				else begin//saturated
					data_o <= 8'b1000_0000;
				end
			end
			else if(result[19] == 0) begin //postive
				if(result[18:12] == 7'b000_0000)//not saturated
				begin
					data_o[6:0] <= round[11:5];//cut off
					data_o[7] <= 0;
				end
				else begin//saturated
					data_o <= 8'b0111_1111;
				end
			end
		end
	else data_o <= data_o;
end

always@(posedge clk or negedge rst_n)//mut
begin
	if(!rst_n) mut <= 0;
	//else if(cnt == 1) mut <= $signed(coeff_i[C_W*cnt+:C_W]) * data_i;
    else if(cnt >= 1 && cnt <= 17) mut <=  num_i * num_c;
    else mut <= 0;
end

always@(posedge clk or negedge rst_n)//num_i
begin
	if(!rst_n) num_i <= 0;
	else if(cnt == 0 && valid_i == 1) num_i <= data_i;
	else if(cnt >= 1 && cnt <= 16) num_i <= buffer[cnt];
	else num_i <= 0;
end

always@(posedge clk or negedge rst_n)//num_c
begin
	if(!rst_n) num_c <= 0;
	else if(cnt == 0 && valid_i == 1) num_c <= $signed(coeff_i[C_W*cnt+:C_W]);
	else if(cnt >= 1 && cnt <= 16) num_c <= $signed(coeff_i[C_W*cnt+:C_W]);
	else num_c <= 0;
end
endmodule