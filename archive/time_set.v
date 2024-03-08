/*具有启动、停止、复位、增量的计数器   0.0~0.9 */
  
module counter
(
	clk				,    //时钟
	rst				,    //复位
	start           ,     // 启动按钮
    stop            ,      // 停止按钮
	add             ,      //增量
	seg_led_1		,    //数码管1
	seg_led_2		   //数码管2
	
);
 
	input 	clk,rst;
	input	stop,start,add;
 
	output 	[8:0]	seg_led_1,seg_led_2;
	
	
	wire		clk10h;        //10Hz时钟
// 	wire		start_pulse;   //按键消抖后信号
// 	wire        stop_pulse;
	reg         start_flag;
	reg         stop_flag;
    reg         add_flag;
    
	reg   		[6:0]   seg		[9:0];  
	reg			[3:0]	cnt_ge;      //0.1
	reg			[3:0]	cnt_shi;     //1
	
	initial 
	begin
		seg[0] = 7'h3f;	   //  0
		seg[1] = 7'h06;	   //  1
		seg[2] = 7'h5b;	   //  2
		seg[3] = 7'h4f;	   //  3
		seg[4] = 7'h66;	   //  4
		seg[5] = 7'h6d;	   //  5
		seg[6] = 7'h7d;	   //  6
		seg[7] = 7'h07;	   //  7
		seg[8] = 7'h7f;	   //  8
		seg[9] = 7'h6f;	   //  9
/*若需要显示A-F,解除此段注释即可
		seg[10]= 7'hf7;	   //  A
		seg[11]= 7'h7c;	   //  b
		seg[12]= 7'h39;    //  C
		seg[13]= 7'h5e;    //  d
		seg[14]= 7'h79;    //  E
		seg[15]= 7'h71;    //  F*/
	end
	
	// 用于分出一个10Hz的频率	
	divide #(.WIDTH(32),.N(1200000)) U1 ( 
			.clk(clk),
			.rst_n(rst),      
			.clkout(clk10h)
			);

	always @(posedge clk10h or negedge rst)
    begin
        if (!rst)
        begin
            cnt_ge <= 4'd0;
            cnt_shi <= 4'd0;
            start_flag <= 0;
            stop_flag <= 0;
            add_flag <= 0 ;
        end
        else if ((!start || start_flag) && stop )begin//计时
            start_flag <= 1;
            stop_flag <= 0;
            if (cnt_ge == 4'd9)begin//进位
                cnt_ge <= 4'd0;
                if(cnt_shi == 4'd9)
                    cnt_shi <= 4'd0;
                else
                    cnt_shi <= cnt_shi + 1;
                
                end
            else
                cnt_ge <= cnt_ge + 1;
            
            end    
        
        else if ( (!stop  || stop_flag) && start )begin//停止
			start_flag <= 0;
            stop_flag <= 1;
            if(add)
                add_flag <= 0;
            else if(!add && add_flag == 0)begin//增量
                cnt_ge <= cnt_ge + 1;
                add_flag <= 1 ;         //标志位，用于实现长按也只增加一次
                if (cnt_ge == 4'd9)begin//进位
                    cnt_ge <= 4'd0;
                    if(cnt_shi == 4'd9)
                        cnt_shi <= 4'd0;
                    else
                    cnt_shi <= cnt_shi + 1;
                    end
                end
			end
    end

    assign seg_led_2[8:0] = {2'b00,seg[cnt_ge]};//数码管显示
	assign seg_led_1[8:0] = {2'b01,seg[cnt_shi]};
   
endmodule

	