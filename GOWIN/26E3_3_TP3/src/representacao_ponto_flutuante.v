module representacao_ponto_flutuante #(
    parameter LARGURA_EXPOENTE = 4,
    parameter LARGURA_MANTISSA = 11
)(
    input wire empacotar,
    input wire sinal_entrada,
    input wire [LARGURA_EXPOENTE-1:0] expoente_entrada,
    input wire [LARGURA_MANTISSA-1:0] mantissa_entrada,
    input wire [LARGURA_EXPOENTE+LARGURA_MANTISSA:0] palavra_entrada,
    output reg [LARGURA_EXPOENTE+LARGURA_MANTISSA:0] palavra_saida,
    output reg sinal_saida,
    output reg [LARGURA_EXPOENTE-1:0] expoente_saida,
    output reg [LARGURA_MANTISSA-1:0] mantissa_saida
);

always @(*) begin
    if (empacotar) begin
        palavra_saida = {sinal_entrada, expoente_entrada, mantissa_entrada};
        sinal_saida = sinal_entrada;
        expoente_saida = expoente_entrada;
        mantissa_saida = mantissa_entrada;
    end else begin
        palavra_saida = palavra_entrada;
        sinal_saida = palavra_entrada[LARGURA_EXPOENTE+LARGURA_MANTISSA];
        expoente_saida = palavra_entrada[LARGURA_EXPOENTE+LARGURA_MANTISSA-1 -: LARGURA_EXPOENTE];
        mantissa_saida = palavra_entrada[LARGURA_MANTISSA-1:0];
    end
end

endmodule