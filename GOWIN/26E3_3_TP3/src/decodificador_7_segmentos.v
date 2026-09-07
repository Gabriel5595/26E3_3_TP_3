module decodificador_7_segmentos (
    input wire [3:0] valor,
    output reg [6:0] segmentos_ativos
);

always @(*) begin
    case (valor)
        4'h0: segmentos_ativos = 7'b1111110;
        4'h1: segmentos_ativos = 7'b0110000;
        4'h2: segmentos_ativos = 7'b1101101;
        4'h3: segmentos_ativos = 7'b1111001;
        4'h4: segmentos_ativos = 7'b0110011;
        4'h5: segmentos_ativos = 7'b1011011;
        4'h6: segmentos_ativos = 7'b1011111;
        4'h7: segmentos_ativos = 7'b1110000;
        4'h8: segmentos_ativos = 7'b1111111;
        4'h9: segmentos_ativos = 7'b1111011;
        4'hA: segmentos_ativos = 7'b1110111;
        4'hB: segmentos_ativos = 7'b0011111;
        4'hC: segmentos_ativos = 7'b1001110;
        4'hD: segmentos_ativos = 7'b0111101;
        4'hE: segmentos_ativos = 7'b1001111;
        default: segmentos_ativos = 7'b1000111;
    endcase
end

endmodule