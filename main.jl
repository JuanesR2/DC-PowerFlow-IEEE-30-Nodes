using DataFrames
using CSV
using Plots

# Se crea la función load_data para cargar los datos del csv y convertirlos en dataframes
function load_data()
    # Importando los datos y creando los DataFrames
    lines = DataFrame(CSV.File("lines.csv"))
    nodes = DataFrame(CSV.File("nodes.csv"))
    num_nodes = maximum(vcat(lines.From, lines.To))
    num_lines = size(lines, 1)
    
    return lines, nodes, num_lines, num_nodes
end

# Función create_Ykm para calcular Ykm
function create_Ykm(lines)
    num_nodes = maximum(vcat(lines.From, lines.To))
    num_lines = size(lines, 1)
    
    Ykm = zeros(num_nodes, num_nodes)
    
    for i in 1:num_lines
        k = lines.From[i]
        m = lines.To[i]
        y_km =  1 / (lines.x_pu[i])
        Ykm[k, m] = Ykm[k, m] - y_km
        Ykm[m, k] = Ykm[m, k] - y_km
        Ykm[k, k] = Ykm[k, k] + y_km
        Ykm[m, m] = Ykm[m, m] + y_km
    end
    return Ykm
end

# Función create_P_vector para calcular P
function create_P_vector(lines, nodes)
    num_nodes = maximum(vcat(lines.From, lines.To))
    P = zeros(num_nodes)
    Sbase = 100
    for i in 1:num_nodes
        Pd = nodes.Load_MW[i]
        Pg = nodes.Generation_MW[i]
        P[i] = Pg - Pd
    end
    P = P / Sbase
    return P
end

# Función DC_power_flow para realizar el flujo de potencia DC
function DC_power_flow(Ykm, P, nlines, nnodes, lines)
    slack = 1
    dslack = 0
    num_lines = nlines
    num_nodes = nnodes
    Ykm = Ykm
    P = P
    nodos = setdiff(1:num_nodes, slack)
    Ykm1 = Ykm[nodos, nodos]
    P = P[nodos]
    d = zeros(num_nodes)
    d = Ykm1 \ P
    pf = zeros(num_lines)
    d = pushfirst!(d, dslack)
    for i in 1:num_lines
        k = lines.From[i]
        m = lines.To[i]
        pf[i] = (d[k] - d[m]) / lines.x_pu[i]
    end
    return d, pf
end

# Función Contingency para analizar contingencias
function Contingency(nlines, Ykm, P, nnodes, lines)
    num_conting = nlines
    Ykm1 = create_Ykm(lines)
    P = P
    almacenamiento = zeros(num_conting, nlines)
    
    dref, pfref = DC_power_flow(Ykm, P, nlines, nnodes, lines)
    almacenamiento = []

    for j in 1:num_conting
        k = lines.From[j]
        m = lines.To[j]
        Ykm1[k, m] = 0
        Ykm1[m, k] = 0
        df, pf = DC_power_flow(Ykm1, P, nlines, nnodes, lines)
        push!(almacenamiento, pf)
    end
    # Ranking
    almrank = []
    for k in 1:num_conting
        for i in 1:num_conting
            rank = sqrt((almacenamiento[k][i] / pfref[k])^2)
            push!(almrank, rank)
        end
    end
    # Se crea el ciclo for para descomponer el vector de 1681 datos en 41 vectores de 41 datos cada uno
    for i in 1:num_conting
        almrank[i] = almrank[(i - 1) * num_conting + 1:i * num_conting]
    end

    return almacenamiento, almrank
end

function main()
    lines, nodes, nlines, nnodes = load_data()
    Ykm = create_Ykm(lines)
    P = create_P_vector(lines, nodes)    
    dref, pfref = DC_power_flow(Ykm, P, nlines, nnodes, lines)
    println("  ")
    print("El flujo de potencia en operación normal en las líneas es: ", pfref)
    println("  ")
    pfconting, rank = Contingency(nlines, Ykm, P, nnodes, lines)
    println("  ")
    for i in 1:nlines
        k = lines.From[i]
        m = lines.To[i] 
        println("  ") 
        println("El flujo de potencia ante contingencia en la línea $i del nodo $k al $m es: ", pfconting[i])
    end
    println("  ")
    x = 0
    # Se crea el ciclo para clasificar las líneas más críticas según el índice correspondiente a cada contingencia
    for j in 1:nlines
        k = lines.From[j]
        m = lines.To[j] 
        indice_ordenado = sortperm(rank[j])
        num_lineas_criticas = 5
        lineas_criticas = indice_ordenado[end - num_lineas_criticas + 1:end]
        println("  ")
        println("Las $num_lineas_criticas líneas más críticas ante contingencia en la línea $j del nodo $k al $m son:")
        println("  ")
       
        for i in lineas_criticas
            k = lines.From[i]
            m = lines.To[i] 
            println("Línea $i del nodo $k al $m - Índice de Contingencia: ", rank[j][i])
        end
    end
    
    return nothing
end
