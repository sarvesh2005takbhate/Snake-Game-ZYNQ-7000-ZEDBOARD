//our game has a display of 640x480 and each block is of 16x16 pixels with total of 40x30 blocks

module snake_moving(
	input clk,			
	input rst,			
	
	input left_press,	
	input right_press,
	input up_press,
	input down_press,
	
	output reg [1:0]snake, //snake status, 00:none 01:head 10:body 11:wall
	
	input [9:0]x_pos, //current coordinate(pixel)
	input [9:0]y_pos,

	output [5:0]head_x,
	output [5:0]head_y,
	
	input add_cube, //add length
	
	input [1:0]game_status, //input four game status
	input reward_protected,
	input reward_slowly,
	// New inputs for mines
	input [5:0] mine_x_0,
	input [5:0] mine_y_0,
	input [5:0] mine_x_1,
	input [5:0] mine_y_1,
	input [5:0] mine_x_2,
	input [5:0] mine_y_2,
	input [5:0] mine_x_3,
	input [5:0] mine_y_3,
	input [3:0] mine_active,
	input hit_mine,
	input reduce_length,
	
	output reg [7:0]cube_num, //current length
	
	output reg hit_body, //hit self
	output reg hit_wall, //hit wall
	output reg hit_min_length, // New output for minimum length reached
	input die_flash //game over
);
	
	localparam UP = 2'b00;
	localparam DOWN = 2'b01;
	localparam LEFT = 2'b10;
	localparam RIGHT = 2'b11;
	
	localparam NONE = 2'b00;
	localparam HEAD = 2'b01;
	localparam BODY = 2'b10;
	localparam WALL = 2'b11;
	localparam MINE = 2'b10; // Same as BODY but we'll handle it specially
	
	// Add game status parameters
	localparam RESTART = 2'b00;
	localparam START = 2'b01;
	localparam PLAY = 2'b10;
	localparam DIE = 2'b11;
	
	reg[31:0]cnt;
	
	wire[1:0]direct;
	reg [1:0]direct_r;
	assign direct = direct_r;
	reg[1:0]direct_next;
	
	reg change_to_left;
	reg change_to_right;
	reg change_to_up;
	reg change_to_down;
	
	reg [5:0]cube_x[29:0];
	reg [5:0]cube_y[29:0];
	reg [29:0]is_exist;
	
	reg addcube_state;
	
	assign head_x = cube_x[0];
	assign head_y = cube_y[0];
	
	parameter speedValue = 12_500_000; //speed control
	
	always @(posedge clk or negedge rst) begin		
		if(!rst)
			direct_r <= DOWN; //default direction down 
		else if(game_status == RESTART) 
		    direct_r <= DOWN;
		else
			direct_r <= direct_next;
	end

    
	always @(posedge clk or negedge rst) begin
		//default value of snake with length=3 and fixed position 
		//below we manually set the position of the snake and the length of the snake
		if(!rst) begin
			cnt <= 0;
												
			cube_x[0] <= 10;
			cube_y[0] <= 5;
					
			cube_x[1] <= 9;
			cube_y[1] <= 5;
					
			cube_x[2] <= 8;
			cube_y[2] <= 5;

			cube_x[3] <= 0;
			cube_y[3] <= 0;
					
			cube_x[4] <= 0;
			cube_y[4] <= 0;
					
			cube_x[5] <= 0;
			cube_y[5] <= 0;
					
			cube_x[6] <= 0;
			cube_y[6] <= 0;
					
			cube_x[7] <= 0;
			cube_y[7] <= 0;
					
			cube_x[8] <= 0;
			cube_y[8] <= 0;
					
			cube_x[9] <= 0;
			cube_y[9] <= 0;					
					
			cube_x[10] <= 0;
			cube_y[10] <= 0;
					
			cube_x[11] <= 0;
			cube_y[11] <= 0;
					
            cube_x[12] <= 0;
			cube_y[12] <= 0;
					
			cube_x[13] <= 0;
			cube_y[13] <= 0;
					
			cube_x[14] <= 0;
			cube_y[14] <= 0;
					
			cube_x[15] <= 0;
			cube_y[15] <= 0;

			cube_x[16] <= 0;
			cube_y[16] <= 0;
					
			cube_x[17] <= 0;
			cube_y[17] <= 0;
					
			cube_x[18] <= 0;
			cube_y[18] <= 0;
					
			cube_x[19] <= 0;
			cube_y[19] <= 0;
					
			cube_x[20] <= 0;
			cube_y[20] <= 0;
					
			cube_x[21] <= 0;
			cube_y[21] <= 0;
					
			cube_x[22] <= 0;
			cube_y[22] <= 0;
					
			cube_x[23] <= 0;
			cube_y[23] <= 0;
					
			cube_x[24] <= 0;
			cube_y[24] <= 0;
					
			cube_x[25] <= 0;
			cube_y[25] <= 0;
					
			cube_x[26] <= 0;
			cube_y[26] <= 0;
					
			cube_x[27] <= 0;
			cube_y[27] <= 0;
					
			cube_x[28] <= 0;
			cube_y[28] <= 0;
					
			cube_x[29] <= 0;
			cube_y[29] <= 0;

			hit_wall <= 0;
			hit_body <= 0;
		end		

		else if(game_status == RESTART) begin
                    cnt <= 0;
                                                    
                    cube_x[0] <= 10;
                    cube_y[0] <= 5;
                                        
                    cube_x[1] <= 9;
                    cube_y[1] <= 5;
                                        
                    cube_x[2] <= 8;
                    cube_y[2] <= 5;
                    
                    cube_x[3] <= 0;
                    cube_y[3] <= 0;
                                        
                    cube_x[4] <= 0;
                    cube_y[4] <= 0;
                                        
                    cube_x[5] <= 0;
                    cube_y[5] <= 0;
                                        
                    cube_x[6] <= 0;
                    cube_y[6] <= 0;
                                        
                    cube_x[7] <= 0;
                    cube_y[7] <= 0;
                                        
                    cube_x[8] <= 0;
                    cube_y[8] <= 0;
                                        
                    cube_x[9] <= 0;
                    cube_y[9] <= 0;
                                        
                    cube_x[10] <= 0;
                    cube_y[10] <= 0;
                                        
                    cube_x[11] <= 0;
                    cube_y[11] <= 0;
                                        
                    cube_x[12] <= 0;
                    cube_y[12] <= 0;
                                        
                    cube_x[13] <= 0;
                    cube_y[13] <= 0;
                                        
                    cube_x[14] <= 0;
                    cube_y[14] <= 0;
                                        
                    cube_x[15] <= 0;
                    cube_y[15] <= 0;

                    cube_x[16] <= 0;
                    cube_y[16] <= 0;
                                        
                    cube_x[17] <= 0;
                    cube_y[17] <= 0;
                                        
                    cube_x[18] <= 0;
                    cube_y[18] <= 0;
                                        
                    cube_x[19] <= 0;
                    cube_y[19] <= 0;
                                        
                    cube_x[20] <= 0;
                    cube_y[20] <= 0;
                                        
                    cube_x[21] <= 0;
                    cube_y[21] <= 0;
                                        
                    cube_x[22] <= 0;
                    cube_y[22] <= 0;
                                        
                    cube_x[23] <= 0;
                    cube_y[23] <= 0;
                                        
                    cube_x[24] <= 0;
                    cube_y[24] <= 0;
                                        
                    cube_x[25] <= 0;
                    cube_y[25] <= 0;
                                        
                    cube_x[26] <= 0;
                    cube_y[26] <= 0;
                                        
                    cube_x[27] <= 0;
                    cube_y[27] <= 0;
                                        
                    cube_x[28] <= 0;
                    cube_y[28] <= 0;
                                        
                    cube_x[29] <= 0;
                    cube_y[29] <= 0;
                    
                    hit_wall <= 0;
                    hit_body <= 0; // snake longest 30                             
        end
		else begin
			cnt <= cnt + 1; //count the clock cycles
			
			if(cnt >= speedValue) begin   //move 4 every second
				cnt <= 0;
				//default status play
				if(game_status == PLAY) begin
					// Wall collision detection
					if(((direct == UP && cube_y[0] == 1)|(direct == DOWN && cube_y[0] == 28)|(direct == LEFT && cube_x[0] == 1)|(direct == RIGHT && cube_x[0] == 38)) && reward_protected == 0)
					   hit_wall <= 1; //hit wall
					// Body collision detection
					else if( reward_protected == 0 &&((cube_y[0] == cube_y[1] && cube_x[0] == cube_x[1] && is_exist[1] == 1)|
							(cube_y[0] == cube_y[2] && cube_x[0] == cube_x[2] && is_exist[2] == 1)|
							(cube_y[0] == cube_y[3] && cube_x[0] == cube_x[3] && is_exist[3] == 1)|
							(cube_y[0] == cube_y[4] && cube_x[0] == cube_x[4] && is_exist[4] == 1)|
							(cube_y[0] == cube_y[5] && cube_x[0] == cube_x[5] && is_exist[5] == 1)|
							(cube_y[0] == cube_y[6] && cube_x[0] == cube_x[6] && is_exist[6] == 1)|
							(cube_y[0] == cube_y[7] && cube_x[0] == cube_x[7] && is_exist[7] == 1)|
							(cube_y[0] == cube_y[8] && cube_x[0] == cube_x[8] && is_exist[8] == 1)|
							(cube_y[0] == cube_y[9] && cube_x[0] == cube_x[9] && is_exist[9] == 1)|
							(cube_y[0] == cube_y[10] && cube_x[0] == cube_x[10] && is_exist[10] == 1)|
							(cube_y[0] == cube_y[11] && cube_x[0] == cube_x[11] && is_exist[11] == 1)|
							(cube_y[0] == cube_y[12] && cube_x[0] == cube_x[12] && is_exist[12] == 1)|
							(cube_y[0] == cube_y[13] && cube_x[0] == cube_x[13] && is_exist[13] == 1)|
							(cube_y[0] == cube_y[14] && cube_x[0] == cube_x[14] && is_exist[14] == 1)|
							(cube_y[0] == cube_y[15] && cube_x[0] == cube_x[15] && is_exist[15] == 1)|
							(cube_y[0] == cube_y[16] && cube_x[0] == cube_x[16] && is_exist[16] == 1)|
							(cube_y[0] == cube_y[17] && cube_x[0] == cube_x[17] && is_exist[17] == 1)|
							(cube_y[0] == cube_y[18] && cube_x[0] == cube_x[18] && is_exist[18] == 1)|
							(cube_y[0] == cube_y[19] && cube_x[0] == cube_x[19] && is_exist[19] == 1)|
							(cube_y[0] == cube_y[20] && cube_x[0] == cube_x[20] && is_exist[20] == 1)|
							(cube_y[0] == cube_y[21] && cube_x[0] == cube_x[21] && is_exist[21] == 1)|
							(cube_y[0] == cube_y[22] && cube_x[0] == cube_x[22] && is_exist[22] == 1)|
							(cube_y[0] == cube_y[23] && cube_x[0] == cube_x[23] && is_exist[23] == 1)|
							(cube_y[0] == cube_y[24] && cube_x[0] == cube_x[24] && is_exist[24] == 1)|
							(cube_y[0] == cube_y[25] && cube_x[0] == cube_x[25] && is_exist[25] == 1)|
							(cube_y[0] == cube_y[26] && cube_x[0] == cube_x[26] && is_exist[26] == 1)|
							(cube_y[0] == cube_y[27] && cube_x[0] == cube_x[27] && is_exist[27] == 1)|
							(cube_y[0] == cube_y[28] && cube_x[0] == cube_x[28] && is_exist[28] == 1)|
							(cube_y[0] == cube_y[29] && cube_x[0] == cube_x[29] && is_exist[29] == 1)))
							hit_body <= 1;
					else begin
						//over here it appears that each segment is following the head like a chain motion
						//each segment takes the posotion of segment infront of it.
						cube_x[1] <= cube_x[0];
						cube_y[1] <= cube_y[0];
										
						cube_x[2] <= cube_x[1];
						cube_y[2] <= cube_y[1];
										
						cube_x[3] <= cube_x[2];
						cube_y[3] <= cube_y[2];
										
						cube_x[4] <= cube_x[3];
						cube_y[4] <= cube_y[3];
										
						cube_x[5] <= cube_x[4];
						cube_y[5] <= cube_y[4];
										
						cube_x[6] <= cube_x[5];
						cube_y[6] <= cube_y[5];
										
						cube_x[7] <= cube_x[6];
						cube_y[7] <= cube_y[6];
										
						cube_x[8] <= cube_x[7];
						cube_y[8] <= cube_y[7];
										
						cube_x[9] <= cube_x[8];
						cube_y[9] <= cube_y[8];
										
						cube_x[10] <= cube_x[9];
						cube_y[10] <= cube_y[9];
										
						cube_x[11] <= cube_x[10];
						cube_y[11] <= cube_y[10];
										
						cube_x[12] <= cube_x[11];
						cube_y[12] <= cube_y[11];
										 
						cube_x[13] <= cube_x[12];
						cube_y[13] <= cube_y[12];
										
						cube_x[14] <= cube_x[13];
						cube_y[14] <= cube_y[13];
										
						cube_x[15] <= cube_x[14];
						cube_y[15] <= cube_y[14];

						cube_x[16] <= cube_x[15];
						cube_y[16] <= cube_y[15];
										
						cube_x[17] <= cube_x[16];
						cube_y[17] <= cube_y[16];
										
						cube_x[18] <= cube_x[17];
						cube_y[18] <= cube_y[17];
										
						cube_x[19] <= cube_x[18];
						cube_y[19] <= cube_y[18];
										
						cube_x[20] <= cube_x[19];
						cube_y[20] <= cube_y[19];
										
						cube_x[21] <= cube_x[20];
						cube_y[21] <= cube_y[20];
										
						cube_x[22] <= cube_x[21];
						cube_y[22] <= cube_y[21];
										
						cube_x[23] <= cube_x[22];
						cube_y[23] <= cube_y[22];
										
						cube_x[24] <= cube_x[23];
						cube_y[24] <= cube_y[23];
										
						cube_x[25] <= cube_x[24];
						cube_y[25] <= cube_y[24];
										
						cube_x[26] <= cube_x[25];
						cube_y[26] <= cube_y[25];
										
						cube_x[27] <= cube_x[26];
						cube_y[27] <= cube_y[26];
										 
						cube_x[28] <= cube_x[27];
						cube_y[28] <= cube_y[27];
										
						cube_x[29] <= cube_x[28];
						cube_y[29] <= cube_y[28];
						//now if collosion is there then we don't move the head of the snake and decrease the length
						case(direct)							
							UP:
							begin
							    if(cube_y[0] == 1 && reward_protected == 0)
									hit_wall <= 1;
								else
									cube_y[0] <= cube_y[0]-1;
							end
							DOWN:
							begin
								if(cube_y[0] == 28 && reward_protected == 0)
									hit_wall <= 1;
								else
									cube_y[0] <= cube_y[0] + 1;
							end		
							LEFT:
							begin
								if(cube_x[0] == 1 && reward_protected == 0)
									hit_wall <= 1;
								else
									cube_x[0] <= cube_x[0] - 1;											
							end
							RIGHT:
							begin
								if(cube_x[0] == 38 && reward_protected == 0)
									hit_wall <= 1;
                                else
									cube_x[0] <= cube_x[0] + 1;
							end
						endcase
					end
				end
			end
		end
	end
	//here the movement of the snake is controlled by the direction of the snake
	//we change the direction of the snake here
	always @(*) begin
		direct_next = direct;		
        case(direct)	
		    UP:
			begin
			    if(change_to_left)
				    direct_next = LEFT;
			    else if(change_to_right)
				    direct_next = RIGHT;
			    else
				    direct_next = UP;			
		    end
		    DOWN:
			begin
			    if(change_to_left)
				    direct_next = LEFT;
			    else if(change_to_right)
			        direct_next = RIGHT;
			    else
				    direct_next = DOWN;			
		    end
		    LEFT:
			begin
			    if(change_to_up)
				    direct_next = UP;
			    else if(change_to_down)
    			    direct_next = DOWN;
			    else
				    direct_next = LEFT;			
		    end
		    RIGHT:
			begin
			    if(change_to_up)
				    direct_next = UP;
			    else if(change_to_down)
				    direct_next = DOWN;
			    else
				    direct_next = RIGHT;
		    end	
	    endcase
	end
	//here initialize the directions to 1
	always @(posedge clk) begin
		if(left_press == 1)
			change_to_left <= 1;
		else if(right_press == 1)
			change_to_right <= 1;
		else if(up_press == 1)
			change_to_up <= 1;
		else if(down_press == 1)
			change_to_down <= 1;
		else begin
			change_to_left <= 0;
			change_to_right <= 0;
			change_to_up <= 0;
			change_to_down <= 0;
		end
	end
	
	always @(posedge clk or negedge rst) begin
        //here if the snake is dead then we don't want to increase the length of the snake
		//else if the apple is eaten then the length of the snake is increased by 1
		if(!rst) begin
			is_exist <= 30'd7;
			cube_num <= 3;
			addcube_state <= 0;
			hit_min_length <= 0; // Initialize the new output
		end  
		else if (game_status == RESTART) begin
		      is_exist <= 30'd7;
              cube_num <= 3;
              addcube_state <= 0;
              hit_min_length <= 0; // Reset the new output
         end
		else begin			
			case(addcube_state) //check apple == snake head
				0:
				begin
					if(add_cube) begin
						cube_num <= cube_num + 1;
						is_exist[cube_num] <= 1;
						addcube_state <= 1; //eat signal
					end						
				end
				1:
				begin
					if(!add_cube)
						addcube_state <= 0;				
				end
			endcase
			
			// Handle length reduction from mines
			if(reduce_length && cube_num > 3) begin
				cube_num <= cube_num - 1;
				is_exist[cube_num-1] <= 0;
				hit_min_length <= (cube_num == 4); // Signal if length will become 3
			end
			else begin
				hit_min_length <= 0;
			end
		end
	end
	
	always @(x_pos or y_pos ) begin	//this is only executed when the x and y position of the snake changes
		if(x_pos >= 0 && x_pos < 640 && y_pos >= 0 && y_pos < 480) begin //boundary check
			if(x_pos[9:4] == 0 | y_pos[9:4] == 0 | x_pos[9:4] == 39 | y_pos[9:4] == 29)
				snake = WALL;
			// Display mines (using BODY representation but could be different)
			else if((mine_active[0] && x_pos[9:4] == mine_x_0 && y_pos[9:4] == mine_y_0) ||
				(mine_active[1] && x_pos[9:4] == mine_x_1 && y_pos[9:4] == mine_y_1) ||
				(mine_active[2] && x_pos[9:4] == mine_x_2 && y_pos[9:4] == mine_y_2) ||
				(mine_active[3] && x_pos[9:4] == mine_x_3 && y_pos[9:4] == mine_y_3))
				snake = MINE;
			else if(x_pos[9:4] == cube_x[0] && y_pos[9:4] == cube_y[0] && is_exist[0] == 1) 
				snake = (die_flash == 1) ? HEAD : NONE;
			else if
				((x_pos[9:4] == cube_x[1] && y_pos[9:4] == cube_y[1] && is_exist[1] == 1)|
				 (x_pos[9:4] == cube_x[2] && y_pos[9:4] == cube_y[2] && is_exist[2] == 1)|
				 (x_pos[9:4] == cube_x[3] && y_pos[9:4] == cube_y[3] && is_exist[3] == 1)|
				 (x_pos[9:4] == cube_x[4] && y_pos[9:4] == cube_y[4] && is_exist[4] == 1)|
				 (x_pos[9:4] == cube_x[5] && y_pos[9:4] == cube_y[5] && is_exist[5] == 1)|
				 (x_pos[9:4] == cube_x[6] && y_pos[9:4] == cube_y[6] && is_exist[6] == 1)|
				 (x_pos[9:4] == cube_x[7] && y_pos[9:4] == cube_y[7] && is_exist[7] == 1)|
				 (x_pos[9:4] == cube_x[8] && y_pos[9:4] == cube_y[8] && is_exist[8] == 1)|
				 (x_pos[9:4] == cube_x[9] && y_pos[9:4] == cube_y[9] && is_exist[9] == 1)|
				 (x_pos[9:4] == cube_x[10] && y_pos[9:4] == cube_y[10] && is_exist[10] == 1)|
				 (x_pos[9:4] == cube_x[11] && y_pos[9:4] == cube_y[11] && is_exist[11] == 1)|
				 (x_pos[9:4] == cube_x[12] && y_pos[9:4] == cube_y[12] && is_exist[12] == 1)|
				 (x_pos[9:4] == cube_x[13] && y_pos[9:4] == cube_y[13] && is_exist[13] == 1)|
				 (x_pos[9:4] == cube_x[14] && y_pos[9:4] == cube_y[14] && is_exist[14] == 1)|
				 (x_pos[9:4] == cube_x[15] && y_pos[9:4] == cube_y[15] && is_exist[15] == 1)|
				 (x_pos[9:4] == cube_x[16] && y_pos[9:4] == cube_y[16] && is_exist[16] == 1)|
				 (x_pos[9:4] == cube_x[17] && y_pos[9:4] == cube_y[17] && is_exist[17] == 1)|
				 (x_pos[9:4] == cube_x[18] && y_pos[9:4] == cube_y[18] && is_exist[18] == 1)|
				 (x_pos[9:4] == cube_x[19] && y_pos[9:4] == cube_y[19] && is_exist[19] == 1)|
				 (x_pos[9:4] == cube_x[20] && y_pos[9:4] == cube_y[20] && is_exist[20] == 1)|
				 (x_pos[9:4] == cube_x[21] && y_pos[9:4] == cube_y[21] && is_exist[21] == 1)|
				 (x_pos[9:4] == cube_x[22] && y_pos[9:4] == cube_y[22] && is_exist[22] == 1)|
				 (x_pos[9:4] == cube_x[23] && y_pos[9:4] == cube_y[23] && is_exist[23] == 1)|
				 (x_pos[9:4] == cube_x[24] && y_pos[9:4] == cube_y[24] && is_exist[24] == 1)|
				 (x_pos[9:4] == cube_x[25] && y_pos[9:4] == cube_y[25] && is_exist[25] == 1)|
				 (x_pos[9:4] == cube_x[26] && y_pos[9:4] == cube_y[26] && is_exist[26] == 1)|
				 (x_pos[9:4] == cube_x[27] && y_pos[9:4] == cube_y[27] && is_exist[27] == 1)|
				 (x_pos[9:4] == cube_x[28] && y_pos[9:4] == cube_y[28] && is_exist[28] == 1)|
				 (x_pos[9:4] == cube_x[29] && y_pos[9:4] == cube_y[29] && is_exist[29] == 1))
				 snake = (die_flash == 1) ? BODY : NONE;
			else snake = NONE;
		end
	end
endmodule

