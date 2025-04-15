h = input('Inserisci il numero di squadre: ');
n = h/2;
schedule = {};

for i = 1:2*n-1
    s = 2;
    schedule{i,1} = [i, 2*n];
    for a = 1:2*n-1
        for b = 1:2*n-1
            if (mod(a+b,2*n-1) == 2*i && a < b) | (mod(a+b,2*n-1) == 2*i-2*n+1 && a < b) && s <= n
                schedule{i,s} = [a, b];
                s = s+1;
            elseif 2*i == 2*(2*n-1) && a+b == 2*n-1  && s <= n
                schedule{i,s} = [a, b];
                s = s+1;
           end
       
        end
    end
end
for i = 1:2*n-1
    fprintf('Giornata %d:\n', i);
    for j = 1:n
        fprintf('%d vs %d', schedule{i,j}(1), schedule{i,j}(2));
        fprintf('\n')
    end
end