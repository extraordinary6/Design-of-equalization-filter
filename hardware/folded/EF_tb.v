`timescale 1ns/100ps
//author: Huang Chaofan
//function: Equalization filter
//version 23/4/5:  create

module EF_tb;

    parameter TAP_N     = 17; // can change, student self-define
    parameter DI_IL_W   = 2; // can change, student self-define
    parameter DI_FL_W   = 5; // can change, student self-define
    parameter DI_W      = DI_IL_W + DI_FL_W + 1;
    parameter C_IL_W    = 2; // can change, student self-define
    parameter C_FL_W    = 5; // can change, student self-define
    parameter C_W       = C_IL_W + C_FL_W + 1;
    parameter DO_IL_W   = 2; // can change, student self-define
    parameter DO_FL_W   = 5; // can change, student self-define
    parameter DO_W      = DO_IL_W + DO_FL_W + 1;

reg clk, rst_n, valid_i;
reg signed [DI_W-1:0] data_i;
reg [TAP_N*C_W-1:0] coeff_i;
wire valid_o;
wire signed [DO_W-1:0]  data_o;
EF myef(.clk(clk), .rst_n(rst_n), .valid_i(valid_i), .data_i(data_i), .coeff_i(coeff_i), 
		.valid_o(valid_o), .data_o(data_o));

reg [4:0] cnt;
reg signed [7:0] mem [0:9999];
reg [14:0] which;
integer file;

initial begin
rst_n <= 0;
clk <= 0;
file = $fopen("output_h.txt", "w");
$readmemb("data.txt", mem);
#10 rst_n <= 1;

coeff_i[C_W-1:0] <= 1*32;
coeff_i[C_W*2-1:C_W] <= -0.9*32;
coeff_i[C_W*3-1:C_W*2] <= 0.01*32;
coeff_i[C_W*4-1:C_W*3] <= 0.711*32;
coeff_i[C_W*5-1:C_W*4] <= -0.6479*32;
coeff_i[C_W*6-1:C_W*5] <= 0.01431*32;
coeff_i[C_W*7-1:C_W*6] <= 0.505441*32;
coeff_i[C_W*8-1:C_W*7] <= -0.4663449*32;
coeff_i[C_W*9-1:C_W*8] <= 0.01535761*32;
coeff_i[C_W*10-1:C_W*9]<= 0.359254071*32;
coeff_i[C_W*11-1:C_W*10] <= -0.335614752*32;
coeff_i[C_W*12-1:C_W*11] <= 0.01465002*32;
coeff_i[C_W*13-1:C_W*12] <= 0.255306784*32;
coeff_i[C_W*14-1:C_W*13] <= -0.241496121*32;
coeff_i[C_W*15-1:C_W*14] <= 0.013101082*32;
coeff_i[C_W*16-1:C_W*15] <= 0.181405923*32;
coeff_i[C_W*17-1:C_W*16] <= -0.173746196*32;
end

always begin
  #10 clk <= ~clk;
end

always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) cnt <= 0;
	else if(cnt == 19) cnt <= 0;
    else cnt <= cnt + 1;
end

always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) which <= 1;
	else if(cnt == 19) which <= which + 1;
    else which <= which;
end

always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) valid_i <= 1;
	else if(cnt == 19) valid_i <= 1;
	else valid_i <= 0;
end

always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n) data_i <= mem[0];
	else if(cnt == 19) data_i <= mem[which];
    else data_i <= data_i;
end

always @ (posedge clk or negedge rst_n)
begin
	if(which == 10002) $stop;
end

always @ (posedge clk or negedge rst_n)
begin
	if(valid_o)  $fdisplay(file, "%b", data_o);
end
endmodule

