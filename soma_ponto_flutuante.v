module soma_ponto_flutuante #(
    parameter LARGURA_EXPOENTE = 4,
    parameter LARGURA_MANTISSA = 11
)(
    input wire modo_subtracao,
    input wire sinal_a,
    input wire [LARGURA_EXPOENTE-1:0] expoente_a,
    input wire [LARGURA_MANTISSA-1:0] mantissa_a,
    input wire sinal_b,
    input wire [LARGURA_EXPOENTE-1:0] expoente_b,
    input wire [LARGURA_MANTISSA-1:0] mantissa_b,
    output reg sinal_resultado,
    output reg [LARGURA_EXPOENTE-1:0] expoente_resultado,
    output reg [LARGURA_MANTISSA-1:0] mantissa_resultado
);

reg sinal_b_efetivo;
reg signed [LARGURA_EXPOENTE:0] diferenca_expoente;
reg [LARGURA_EXPOENTE-1:0] deslocamento;
reg [LARGURA_MANTISSA-1:0] mantissa_a_alinhada;
reg [LARGURA_MANTISSA-1:0] mantissa_b_alinhada;
reg [LARGURA_EXPOENTE-1:0] expoente_alinhado;
reg [LARGURA_MANTISSA:0] mantissa_soma;

always @(*) begin
    sinal_b_efetivo = modo_subtracao ? ~sinal_b : sinal_b;

    diferenca_expoente = $signed({1'b0, expoente_a}) - $signed({1'b0, expoente_b});

    if (diferenca_expoente >= 0) begin
        deslocamento = diferenca_expoente[LARGURA_EXPOENTE-1:0];
        expoente_alinhado = expoente_a;
        mantissa_a_alinhada = mantissa_a;
        mantissa_b_alinhada = mantissa_b >> deslocamento;
    end else begin
        deslocamento = (-diferenca_expoente);
        expoente_alinhado = expoente_b;
        mantissa_b_alinhada = mantissa_b;
        mantissa_a_alinhada = mantissa_a >> deslocamento;
    end

    if (sinal_a == sinal_b_efetivo) begin
        mantissa_soma = mantissa_a_alinhada + mantissa_b_alinhada;
        sinal_resultado = sinal_a;
        if (mantissa_soma[LARGURA_MANTISSA]) begin
            mantissa_resultado = mantissa_soma[LARGURA_MANTISSA:1];
            expoente_resultado = expoente_alinhado + 1'b1;
        end else begin
            mantissa_resultado = mantissa_soma[LARGURA_MANTISSA-1:0];
            expoente_resultado = expoente_alinhado;
        end
    end else begin
        expoente_resultado = expoente_alinhado;
        if (mantissa_a_alinhada >= mantissa_b_alinhada) begin
            mantissa_resultado = mantissa_a_alinhada - mantissa_b_alinhada;
            sinal_resultado = sinal_a;
        end else begin
            mantissa_resultado = mantissa_b_alinhada - mantissa_a_alinhada;
            sinal_resultado = sinal_b_efetivo;
        end
        if (mantissa_resultado == {LARGURA_MANTISSA{1'b0}})
            sinal_resultado = 1'b0;
    end
end

endmodule