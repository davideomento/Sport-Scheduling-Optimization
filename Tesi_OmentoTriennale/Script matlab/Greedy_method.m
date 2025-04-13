% n = input('Inserisci il numero di squadre: ');
n = 6;
numeri = 1:n;
too_many = false;
partite = {};
schedule = cell(n-1, n/2);
for i = 1:n-1
    for j = 1:n/2
        schedule{i, j} = [0, 0];  % Converti il valore numerico 0 in cella
    end
end
k = 1;
for i = 1:n-1
    for j = i+1:n
        coppia = [numeri(i), numeri(j)];
        partite{k} = coppia;
        k = k+1;
    end
end
s = 1;
z = 1;

for i = 1:length(partite)
    matrix = cell2mat(schedule);
    count = 0;
    while true
        shouldExit = false;
        
        for b = z:n/2
            for a = s:n-1

                if ~ismember(partite{i}(1), matrix(a, :)) && ~ismember(partite{i}(2), matrix(a, :)) && isequal(schedule{a, b}, [0, 0])
                    schedule{a, b} = partite{i};
                    partite{i} = [0, 0];
                    shouldExit = true;  % Imposta la variabile di controllo
                    s = a;
                    z = b;
                    if a == n-1 && b == n/2
                        s = 1;
                        z = 1;
                    end
                    if a == n-1 && b ~= n/2
                        s = 1;
                        z =  z + 1;
                    end
                    
                    break;
                end
                
                
            end
            if shouldExit
                break;  % Uscita dal ciclo esterno
            end

           count = count+1;
        end
        if count > (n-1)*n/2
            too_many = true;
            break;
        end
        if shouldExit
            shouldExit = false;
            break;  % Uscita dal ciclo esterno
        end
        if a == n-1 && b == n/2
             s = 1;
             z = 1;
        end
    end
end
if too_many
    fprintf('Troppe squadre\n');
else
    disp(schedule);
end
k = 1;
partite_rimaste = {};
for i = 1:length(partite)
    if ~isequal(partite{i}, [0,0])
        partite_rimaste{k} = partite{i};
        k = k + 1;
    end
end