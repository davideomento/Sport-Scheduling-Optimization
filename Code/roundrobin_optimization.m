clear all
%% Dati del problema
tic
n = 8; % Numero di squadre
numeri = 1:n;
M = n*(n-1)/2; % Numero di partite
R = n-1; % Numero di round

%Creazione di tutte le partite
partite = {};
k = 1;
for i = 1:n-1
    for j = i+1:n
        coppia = [numeri(i), numeri(j)];
        partite{k} = coppia;
        k = k+1;
    end
end

% Definizione dell'insieme Mi
Mi = zeros(n, n-1);
for k = 1:n
    s = 1;
    for i = 1:length(partite)
        if ismember(k, partite{i})
            Mi(k, s) = i;
            s = s+1;
        end
    end
end
% Costi delle partite per ogni round
c = randi(10, M, R); % Genera costi casuali da 1 a 10

%% Creazione del modello MILP
model = optimproblem('ObjectiveSense', 'minimize');

% Variabili binarie xm,r per rappresentare se la partita m è giocata nel round r
x = optimvar('x', M, R, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);

% Funzione obiettivo
objective = sum(sum(c .* x));
model.Objective = objective;

% Ogni squadra affronta tutte le altre squadre esattamente una volta
for m = 1:M
    model.Constraints.(sprintf('con_team%d', m)) = sum(x(m, :)) == 1;
end

% Vincolo: Ogni squadra gioca esattamente una partita per turno
for i = 1:n
    for r = 1:R
        matches_played_by_team = Mi(i, :);
        model.Constraints.(sprintf('con_team%d_round%d', i, r)) = sum(x(matches_played_by_team, r)) == 1;
    end
end

%% Risoluzione del modello
solver = 'intlinprog'; % Puoi cambiare il solver se necessario
[solution, fval, exitflag] = solve(model, 'Solver', solver);
x_sol = solution.x;
if exitflag == 1
    for r = 1:R
    fprintf('Giornata %d: \n', r)
        for m = 1:M
            if x_sol(m, r) == 0
            else
                fprintf('%d vs %d, ', partite{m}(1), partite{m}(2));
            end
        end
        fprintf('\n');
    end
    disp(['Costo ottimizzato: ', num2str(fval)]);
else
    disp('Nessuna soluzione trovata.');
end
toc

h = n/2;
for i = 1:2*h-1
    s = 2;
    schedule{i,1} = [i, 2*h];
    for a = 1:2*h-1
        for b = 1:2*h-1
            if (mod(a+b,2*h-1) == 2*i && a < b) | (mod(a+b,2*h-1) == 2*i-2*h+1 && a < b) && s <= h
                schedule{i,s} = [a, b];
                s = s+1;
            elseif 2*i == 2*(2*h-1) && a+b == 2*h-1  && s <= h
                schedule{i,s} = [a, b];
                s = s+1;
           end
       end
    end
end
new_Matrix = zeros(M, R);
for a = 1:n-1
    for b = 1:n/2
        elemento_riferimento = schedule{a, b};
        indice_trovato = 0;
        for idx = 1:length(partite)
            if isequal(partite{idx}, elemento_riferimento)
                indice_trovato = idx;
                new_Matrix(idx, a) = 1;
                break; % Esci dal ciclo se trovi l'elemento
            end
        end
    end
end
fprintf('Costo calendario generato con circle method:')
disp(sum(sum(c .* new_Matrix)))