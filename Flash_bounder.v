module Flash_bounder(clk, rst_n, flick, LED);

input wire clk, rst_n, flick;

output reg [15:0]LED;

reg [1:0]operation;

integer N, i;

//operation mode
parameter IDLE 		  =  2'b00;
parameter UP	      =  2'B01;
parameter DOWN 		  =  2'b10;
parameter KICK_BACK	  =  2'b11;

//States
parameter INIT            =  6'b000001;
parameter ZERO_TO_FIVE    =  6'b000010;
parameter OFF_TO_ZERO     =  6'b000100;
parameter ZERO_TO_TEN     =  6'b001000;
parameter OFF_TO_FOUR     =  6'b010000;
parameter FOUR_TO_FIFTEEN = 6'B100000;

parameter SIZE         =  6;

reg [SIZE - 1: 0] state;
reg [SIZE - 1: 0] next_state;

// Change state block
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		state <=  INIT;	
	end
	else begin
		state <= next_state;
	end
end

// Operation on N block
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		N <= -1;
	end
	else begin
		if(operation == UP) begin
			N <= N + 1;
		end
		else if(operation == IDLE) begin
			N <= N;
		end
		else begin
			N <= N - 1;
		end
	end
end

//FSM block
always @(state or operation)
begin
	case(state)
	INIT: begin
		if(operation == UP) begin
			next_state = ZERO_TO_FIVE;
		end
		else begin
			next_state = INIT;
		end
	end
	
	ZERO_TO_FIVE: begin
		if(operation == UP) begin
			next_state = ZERO_TO_FIVE;
		end
		else begin
			next_state = OFF_TO_ZERO;
		end
	end
	
	OFF_TO_ZERO: begin
		if(operation == DOWN) begin
			next_state = OFF_TO_ZERO;
		end
		else begin
			next_state = ZERO_TO_TEN;
		end
	end
	
	ZERO_TO_TEN: begin
		if(operation == KICK_BACK) begin
			next_state = OFF_TO_ZERO;
		end
		else if(operation == DOWN) begin
			next_state = OFF_TO_FOUR;
		end
		else begin
			next_state = ZERO_TO_TEN;
		end
	end
	
	OFF_TO_FOUR: begin
		if(operation == DOWN) begin
			next_state = OFF_TO_FOUR;
		end
		else begin
			next_state = FOUR_TO_FIFTEEN;
		end
	end
	
	FOUR_TO_FIFTEEN: begin
		if(operation == KICK_BACK) begin
			next_state = OFF_TO_FOUR;
		end
		else if(operation == DOWN) begin
			next_state = INIT;	
		end
		else begin
			next_state = FOUR_TO_FIFTEEN;
		end
	end
	
	default: next_state = INIT;
	
	endcase
end

//Logic block
always @(state or flick or N) begin
	operation = 2'b00; //IDLE

	case(state)
	INIT: begin
		if(N >= 0) operation = DOWN;
		else if(flick) operation = UP;
		else operation = IDLE;
	end
	
	ZERO_TO_FIVE: begin
		if(N < 5) operation = UP;
		else operation = DOWN;
	end
	
	OFF_TO_ZERO: begin
		if(N >= 0) operation = DOWN;
		else operation = UP;
	end
	
	ZERO_TO_TEN: begin
		if(flick && (N == 5 || N == 10)) operation = KICK_BACK;
		else if(N == 10) operation = DOWN;
		else operation = UP;
	end
	
	OFF_TO_FOUR: begin
		if(N > 4) operation = DOWN;
		else operation = UP;
	end
	
	FOUR_TO_FIFTEEN: begin
		if(flick && (N == 5 || N == 10)) operation = KICK_BACK;
		else if(N == 15) operation = DOWN;
		else operation = UP;
	end
	
	default: operation = IDLE;

	endcase
end

//Decode block
always @(N)
begin
	if(N == -1) 
		for(i = 0; i < 16 ; i = i + 1)
		begin
			LED[i] = 0;
		end
	else
		for( i = 0; i < 16 ; i = i + 1)
		begin
			if(i <= N) LED[i] = 1'b1;
			else LED[i] = 1'b0;
		end
end

endmodule