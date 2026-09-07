module debounce #(
    parameter LIMITE_ESTABILIDADE = 16'd50000
)(
    input wire clk,
    input wire botao_bruto,
    output reg botao_filtrado
);

reg [15:0] contador_estabilidade;
reg leitura_anterior;

initial begin
    contador_estabilidade = 16'd0;
    leitura_anterior = 1'b1;
    botao_filtrado = 1'b1;
end

always @(posedge clk) begin
    if (botao_bruto == leitura_anterior) begin
        if (contador_estabilidade < LIMITE_ESTABILIDADE)
            contador_estabilidade <= contador_estabilidade + 1'b1;
        else
            botao_filtrado <= leitura_anterior;
    end else begin
        contador_estabilidade <= 16'd0;
    end
    leitura_anterior <= botao_bruto;
end

endmodule