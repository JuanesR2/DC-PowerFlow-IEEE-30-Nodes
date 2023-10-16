function flujo_de_carga_DC(P, V)
    # Calcular las corrientes
    I = P ./ V

    # Calcular el flujo de carga DC
    N = length(P)
    flujo_DC = zeros(N, N)

    for i in 1:N
        for j in 1:N
            if i != j
                flujo_DC[i, j] = (V[i] - V[j]) / Z[i, j]
            end
        end
    end

    return I, flujo_DC
end

# Datos de ejemplo para 10 nodos
P = [100.0, 80.0, 120.0, 90.0, 110.0, 95.0, 105.0, 115.0, 100.0, 90.0]  # Potencia generada en MW
V = [500.0, 485.0, 490.0, 480.0, 495.0, 480.0, 485.0, 490.0, 500.0, 480.0]  # Voltaje en kV

# Impedancias de las líneas de transmisión (ficticias)
Z = [
    [0.0, 0.1, 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.1, 0.0, 0.15, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.2, 0.15, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.25, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.25, 0.0, 0.1, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.1, 0.0, 0.15, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.0, 0.2, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.0, 0.1, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.0, 0.15],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.0]
]

# Calcular el flujo de carga DC
I, flujo_DC = flujo_de_carga_DC(P, V)

# Imprimir resultados
println("Corrientes en los nodos:")
for i in 1:length(P)
    println("Nodo $i: $(round(I[i], digits=2)) A")
end

println("\nFlujo de carga DC entre nodos:")
for i in 1:length(P)
    for j in 1:length(P)
        if i != j
            println("Nodo $i a Nodo $j: $(round(flujo_DC[i, j], digits=2)) MW")
        end
    end
end
