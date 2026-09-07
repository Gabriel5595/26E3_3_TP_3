module decodificador_7_segmentos (
    input wire [3:0] valor,
    output reg [6:0] segmentos_ativos
);

always @(*) begin
    case (valor)
        4'h0: segmentos_ativos = 7'b0111111;
        4'h1: segmentos_ativos = 7'b0000110;
        4'h2: segmentos_ativos = 7'b1011011;
        4'h3: segmentos_ativos = 7'b1001111;
        4'h4: segmentos_ativos = 7'b1100110;
        4'h5: segmentos_ativos = 7'b1101101;
        4'h6: segmentos_ativos = 7'b1111101;
        4'h7: segmentos_ativos = 7'b0000111;
        4'h8: segmentos_ativos = 7'b1111111;
        4'h9: segmentos_ativos = 7'b1101111;
        4'hA: segmentos_ativos = 7'b1110111;
        4'hB: segmentos_ativos = 7'b1111100;
        4'hC: segmentos_ativos = 7'b0111001;
        4'hD: segmentos_ativos = 7'b1011110;
        4'hE: segmentos_ativos = 7'b1111001;
        default: segmentos_ativos = 7'b1110001;
    endcase
end

endmodule