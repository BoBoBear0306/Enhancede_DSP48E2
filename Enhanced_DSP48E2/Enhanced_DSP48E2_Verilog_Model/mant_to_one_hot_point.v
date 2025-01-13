module mant_to_one_hot_point #(
parameter   DATA_WIDTH=17 
)(
input        [3:0]                            mant,
output       [DATA_WIDTH-1:0]   one_hot_point    
);
reg       [3:0]                    mant_reg ;

reg       [DATA_WIDTH-1:0]        one_hot_point_reg;    

always @(*) begin
mant_reg          = mant          ;

end

always @(*) begin
        case (mant_reg)
            4'd0 : begin 
                one_hot_point_reg   =17'h0;
            end            
            4'd1 : begin 
                one_hot_point_reg   =17'h1;
            end 
            4'd2 : begin 
                one_hot_point_reg   =17'h2;
            end 
            4'd3 : begin 
                one_hot_point_reg   =17'h4;
            end 
            4'd4 : begin 
                one_hot_point_reg   =17'h8 ;
            end 
            4'd5 : begin 
                one_hot_point_reg   =17'h10;
            end 
            4'd6 : begin 
                one_hot_point_reg   =17'h20;
            end 
            4'd7 : begin 
                one_hot_point_reg   =17'h40 ;
            end 
            4'd8 : begin 
                one_hot_point_reg   =17'h80 ;
            end
            4'd9 : begin 
                one_hot_point_reg   =17'h100 ;
            end
            4'd10: begin 
                one_hot_point_reg   =17'h200 ;
            end 
            4'd11: begin 
                one_hot_point_reg   =17'h400 ;
            end 
            4'd12: begin 
                one_hot_point_reg   =17'h800;
            end 
            4'd13: begin 
                one_hot_point_reg   =17'h1000 ;
            end 
            4'd14: begin 
                one_hot_point_reg   =17'h2000 ;
            end 
            4'd15: begin 
                one_hot_point_reg   =17'h4000 ;
            end 
            default: begin 
                one_hot_point_reg   =17'h0000 ;
            end 
        endcase
end


assign one_hot_point=one_hot_point_reg;


endmodule