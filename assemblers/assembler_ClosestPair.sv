// creates machine code from assembly script
module compile_ClosestPair;
													  
string       line;
logic[7:0]   line_hex[16];
logic[7:0]   char[16];
logic[4:0]   arg;
logic[31:0]  num;
logic[7:0]   rest[10];
string       charw;
typedef enum {PUSH, POP, ADD, ABS, AND, LT, HALT, CLEAR, BEQ, LDR, STR, READ, WRITE, SL, SR, TBD, EMPTYLINE} inst;
inst         mach;
initial begin  :iloop
  static integer field_id  = $fopen("ClosestPair.txt","r");
  static integer mach_code = $fopen("binOutput.txt","w");
  if (!field_id) 
    $display("rats - can't open");
  else forever begin	 :floop
    while(!$feof(field_id)) 
      #10ns if($fgets(line, field_id)) begin
        $write(line);
	for(int j=0; j<=8; j++) begin  
          char[j] = line.getc(j);
        end
        // 47: slash; 32: space; 10: line feed, 23: #
	if(char[0]!=23 || char[0]!=10) begin  :non_empty_line
           $display("char0%h char1%h char2%h char3%s char4%s",char[0],char[1],char[2], char[3],char[4]);
	 case({char[0],char[1]})
            //only need to match the first two characters of each instruction is enough to 
            //identify the instruction 
            //rest get the rest of the string,doesn't include the "space" between instruction and immediate  
	    'h50_55:    begin mach = PUSH; rest[0:3] = char[5:8]; end
        'h50_4F:    begin mach = POP; rest[0:4] = char[4:8]; end
	    'h41_44:    begin mach = ADD; rest[0:4] = char[4:8]; end
 	    'h41_42:    begin mach = ABS; rest[0:4] = char[4:8]; end
        'h41_4E:    begin mach = AND; rest[0] = "&"; end 
        'h58_4F:    begin mach = AND; rest[0] = "^"; end //XOR instruction
        'h53_55:    begin mach = AND; rest[0] = "-"; end //SUB instruction
        'h4C_54:    begin mach = LT; rest[0:5] = char[3:8]; end
        'h48_41: 	begin mach = HALT;  rest[0:3] = char[5:8]; end
        'h43_4C: 	begin mach = CLEAR; rest[0:2] = char[6:8]; end
        'h42_45: 	begin mach = BEQ; rest[0:4] = char[4:8]; end
        'h4C_44:	begin mach = LDR; rest[0:4] = char[4:8]; end
        'h53_54:	begin mach = STR; rest[0:4] = char[4:8]; end
        'h52_45:    begin mach = READ; rest[0:3] = char[5:8]; end
        'h57_52: 	begin mach = WRITE; rest[0:2] = char[6:8]; end
        'h53_4C:    begin mach = SL; rest[0:5] = char[3:8]; end
        'h53_52:    begin mach = SR; rest[0:5] = char[3:8]; end
	   'h54_42: 	begin mach = TBD; rest[0:4] = char[4:8]; end
	  default:  	begin mach = EMPTYLINE; rest[0] = " "; end
          endcase
        case(rest[0])
          //30: '0', then it is 0x__, an immediate
          'h30: begin 
	     //$display("In 'h30, rest0:%s rest1:%s rest2:%s rest3:%s",rest[0],rest[1],rest[2], rest[3]);
             charw = "00";
             for(int j=0; j<2; j++) begin  
               charw.putc(j, rest[j+2]);
             end
             arg = charw.atohex();
           end                
           
          //72:'r', then it is register
          'h72: begin 
	     //$display("In 'h72, rest0:%s rest1:%s rest2:%s rest3:%s",rest[0],rest[1],rest[2], rest[3]);
             charw = "00";
             for(int j=0; j<2; j++) begin  
               charw.putc(j, rest[j+1]);
             end
             //$display("before atobin:%b",charw);
             arg = charw.atohex();
             //$display("after atobin, binary form:%b, hexadecimal form", arg, arg);
          end
          
          //26: '&', then function code is 0
          'h26: arg = 'b00000;
                               
          //5E: '^', then function code is 1
          'h5E: arg = 'b00001;
          //2D: '-', then function code is 2
          'h2D: arg = 'b00010;        
          default: arg = '0;
        endcase
         /* if( mach == EMPTYLINE)begin
            $fdisplay(mach_code,""); 
	  end */
          if (mach != EMPTYLINE) begin
            $fdisplay(mach_code,"%b_%b  // %s",mach[3:0],arg,mach);
          end
        end		  :non_empty_line
		else $display("char[0]==47");
	  end
	#10ns;
	$fclose(field_id);
	$fclose(mach_code);
	$fclose(mach);
	$stop;
  end		:floop
end		    :iloop
endmodule