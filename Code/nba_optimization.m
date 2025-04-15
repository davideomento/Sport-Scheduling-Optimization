%% Inizializzazione dati
% Imposta il percorso del tuo file Excel
clear all
n = 30;
baseFolder = fileparts(mfilename('fullpath'));
nomeFile = fullfile(baseFolder, 'dataset', 'nba_schedule23-24.xlsx');

% Imposta la data di inizio
dataInizio = datenum('Tue, Oct 18, 2022', 'ddd, mmm dd, yyyy');

% Carica i dati dal file Excel
[numeri, testi, dati] = xlsread(nomeFile);

% Ottieni nomi unici delle squadre dai dati
squadre = unique([dati(2:end, 3); dati(2:end, 5)]);

% Ordina i nomi delle squadre in ordine alfabetico
squadre = sort(squadre);

% Crea una mappa per associare i nomi delle squadre agli indici
mappaSquadre = containers.Map(squadre, 1:length(squadre));

% Inizializza il dizionario delle partite
match_days = containers.Map('KeyType', 'int32', 'ValueType', 'any');

% Inizializza il contatore dei giorni
giornoDiGioco = 1;
match_indices = {};
% Estrai gli indici delle squadre e memorizzali nel dizionario delle partite
for i = 2:size(dati, 1) % Inizia dalla seconda riga (ignora l'header)
    dataPartita = datenum(dati{i, 1}, 'ddd, mmm dd, yyyy');
    
    % Calcola il giorno di gioco in base al numero di giorni passati dalla data di inizio
    giornoDiGioco = dataPartita - dataInizio + 1;
    
    squadraCasa = mappaSquadre(dati{i, 5});
    squadraOspite = mappaSquadre(dati{i, 3});
    
    partita = [squadraCasa, squadraOspite];
    match_indices{i-1} = partita;
    
    if isKey(match_days, giornoDiGioco)
        match_days(giornoDiGioco) = [match_days(giornoDiGioco); partita];
    else
        match_days(giornoDiGioco) = partita;
    end
    
    % Incrementa il contatore dei giorni
    giornoDiGioco = giornoDiGioco + 1;
end
p = giornoDiGioco-1;
no_game_days = [];
k = 1;
for i = 1:p
    if isKey(match_days, i)
    else
        match_days(i) = [0, 0];
        no_game_days(k) = i;
        k = k+1;
    end
end

keys = match_days.keys;
% Tabella delle distanze
delta = 1.6*[
    0,     1000,  750,   250,   590,   550,   720,   1400,  600,   2300,  700,   450,   2100,  2150,  340,   660,   720,   950,   420,   750,   900,   440,   660,   1700,  2300,  2100,  950,   800,   1600,  550;
    1000,  0,     215,   530,   750,   575,   1100,  1600,  600,   2150,  1950,  725,   2150,  2400,  880,   940,   850,   1200,  1100,  800,   1350,  950,   95,    2400,  2500,  2400,  2100,  1050,  2100,  385;
    750,   215,   0,     530,   330,   190,   220,   2100,  610,   2200,  1190,  715,   2240,  2320,  1055,  1080,  210,   930,   860,   200,   1150,  950,   95,    2050,  2120,  2150,  1840,  340,   1850,  330;
    250,   530,   530,   0,     570,   450,   780,   1550,  580,   2200,  850,   600,   1930,  2040,  590,   650,   590,   850,   610,   660,   1240,  440,   95,    2230,  2310,  2170,  1430,  750,   2120,  410;
    590,   750,   330,   570,   0,     345,   660,   1250,  615,   2050,  760,   355,   2000,  2080,  610,   1130,  660,   1050,  780,   835,   1180,  555,   205,   1900,  1970,  1990,  1690,  465,   1670,  430;
    550,   575,   190,   450,   345,   0,     470,   1900,  480,   2120,  1030,  520,   2070,  2150,  770,   1080,  165,   820,   670,   635,   1020,  645,   95,    1950,  2020,  2050,  1740,  395,   1740,  300;
    720,   1100,  220,   780,   660,   470,   0,     1300,  1700,  2000,  900,   520,   1900,  2000,  970,   1320,  470,   1000,  900,   850,   1240,  435,   330,   2250,  2330,  2230,  1530,  800,   1530,  660;
    1400,  1600,  2100,  1550,  1250,  1900,  1300,  0,     1100,  2600,  1000,  1220,  1400,  1800,  350,   1600,  1450,  1450,  1150,  1400,  1300,  1150,  2110,  1200,  1270,  1230,  1780,  1350,  1920,  1200;
    600,   600,   610,   580,   615,   480,   1700,  1100,  0,     1800,  1300,  520,   1260,  1340,  770,   1020,  570,   1120,  910,   960,   1650,  810,   190,   1800,  1870,  1800,  1500,  570,   1560,  510;
    2300,  2150,  2200,  2200,  2050,  2120,  2000,  2600,  1800,  0,     1980,  2100,  340,   430,   1850,  1350,  2100,  1790,  1930,  2140,  1840,  2050,  2240,  860,   1120,  2070,  300,   2170,  500,   2240;
    700,   1950,  1190,  850,   760,   1030,  900,   1000,  1300,  1980,  0,     590,   1520,  1600,  800,   1540,  1200,  1360,  1190,  1350,  1830,  1000,  760,   1870,  1950,  1870,  1170,  1560,  1170,  850;
    450,   725,   715,   600,   355,   520,   520,   1220,  520,   2100,  590,   0,     2070,  2150,  780,   1000,  610,   990,   700,   780,   1420,  335,   275,   1990,  2060,  2100,  1800,  520,   1800,  435;
    2100,  2150,  2240,  1930,  2000,  2070,  1900,  1400,  1260,  340,   1520,  2070,  0,     110,   1520,  1930,  2020,  1950,  1840,  1850,  1980,  2180,  2190,  860,   930,   2090,  300,   2190,  410,   2100;
    2150,  2400,  2320,  2040,  2080,  2150,  2000,  1800,  1340,  430,   1600,  2150,  110,   0,     1580,  2030,  2080,  2020,  1920,  1900,  2000,  2070,  2200,  1150,  1200,  2100,  200,   2200,  310,   2150;
    340,   880,   1055,  590,   610,   770,   970,   350,   770,   1850,  800,   780,   1520,  1580,  0,     1140,  920,   890,   920,   1050,  1610,  675,   1050,  1740,  1810,  1740,  1040,  630,   1980,  430;
    660,   940,   1080,  650,   1130,  1080,  1320,  1600,  1020,  1350,  1540,  1000,  1930,  2030,  1140,  0,     980,   390,   980,   990,   890,   510,   950,   1590,  1670,  1660,  960,   390,   1610,  760;
    720,   850,   570,   590,   660,   165,   470,   1450,  570,   2100,  1200,  610,   2020,  2080,  920,   980,   0,     850,   710,   610,   1110,  500,   240,   1870,  1940,  1970,  1670,  490,   1670,  260;
    950,   1200,  1120,  850,   1050,  820,   1000,  1450,  1120,  1790,  1360,  990,   1950,  2020,  890,   390,   850,   0,     920,   1100,  860,   250,   780,   1730,  1810,  1800,  1500,  530,   1530,  710;
    420,   1100,  910,   610,   780,   670,   900,   1150,  910,   1930,  1190,  700,   1840,  1920,  920,   980,   710,   920,   0,     750,   1660,  810,   315,   1980,  2050,  2040,  1740,  580,   1740,  450;
    750,   800,   960,   660,   835,   635,   850,   1400,  960,   2140,  1350,  780,   1850,  1900,  1050,  990,   610,   1100,  750,   0,     1360,  510,   260,   2150,  2220,  2150,  1850,  660,   1850,  410;
    900,   1350,  1650,  1240,  1180,  1020,  1240,  1840,  1650,  1840,  1830,  1420,  1980,  2000,  1610,  890,   1110,  860,   1660,  1360,  0,     1230,  1070,  2070,  2150,  2090,  1390,  1900,  1380,  1350;
    440,   950,   810,   440,   555,   645,   435,   2050,  810,   2050,  1000,  335,   2180,  2070,  675,   510,   500,   250,   810,   510,   1230,  0,     275,   2070,  2150,  2170,  1870,  690,   1870,  375;
    660,   95,    190,    95,    205,    95,    330,    2240,  190,    1850,  760,   275,   2190,  2200,  1050,  950,   240,   780,   315,   260,   1070,  275,   0,     2000,  2070,  2100,  1810,  225,   1810,  370;
    1700,  2400,  2050,  2230,  1900,  1950,  2250,  860,   1800,  1120,  1870,  1990,  860,   1150,  1740,  1590,  1870,  1730,  1980,  2150,  2070,  2070,  2000,  0,     160,   80,    940,   600,   1050,  1960;
    2300,  2500,  2120,  2310,  1970,  2020,  2330,  1120,  1870,  2450,  1950,  2060,  930,   1200,  1810,  1670,  1940,  1810,  2050,  2220,  2150,  2150,  2070,  160,   0,     80,    850,   560,   970,   2130;
    2100,  2400,  2150,  2170,  1990,  2050,  2230,  2070,  1800,  2150,  1870,  2100,  2090,  2100,  1740,  1660,  1970,  1800,  2040,  2150,  2090,  2170,  2100,  80,    80,    0,     890,   480,   1010,  2050;
    950,   2100,  1840,  1430,  1690,  1740,  1530,  1230,  1500,  300,   1170,  1800,  300,   200,   1040,  960,   1670,  1500,  1740,  1850,  1390,  1870,  1810,  940,   850,   890,   0,     1600,  330,   1840;
    800,   1050,  340,   750,   465,   395,   800,   1780,  570,   2170,  1560,  520,   2190,  2200,  630,   390,   490,   530,   580,   660,   1900,  690,   225,   600,   560,   480,   1600,  0,     1630,  100;
    1600,  2100,  1850,  2120,  1670,  1740,  1530,  1920,  1560,  500,   1170,  1800,  410,   310,   1980,  1610,  1670,  1530,  1740,  1850,  1380,  1870,  1810,  1050,  970,   1010,  330,   1630,  0,     2000;
    550    260    330     410    430     300     660     1200    510    2240    850     435     2100    2150    430     760     260     410     450     410     410     1350    375     370    1960    2130    2050    1840    100    2000;
];
teams = containers.Map(...
    {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ...
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20, ...
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30}, ...
    {'Atlanta Hawks', 'Boston Celtics', 'Brooklyn Nets', 'Charlotte Hornets', 'Chicago Bulls', ...
    'Cleveland Cavaliers', 'Dallas Mavericks', 'Denver Nuggets', 'Detroit Pistons', 'Golden State Warriors', ...
    'Houston Rockets', 'Indiana Pacers', 'LA Clippers', 'Los Angeles Lakers', 'Memphis Grizzlies', ...
    'Miami Heat', 'Milwaukee Bucks', 'Minnesota Timberwolves', 'New Orleans Pelicans', 'New York Knicks', ...
    'Oklahoma City Thunder', 'Orlando Magic', 'Philadelphia 76ers', 'Phoenix Suns', 'Portland Trail Blazers', ...
    'Sacramento Kings', 'San Antonio Spurs', 'Toronto Raptors', 'Utah Jazz', 'Washington Wizards'});

u = length(dati)-1;

num_squadre = n;
num_giorni = p;

% Inizializza la cella schedule
schedule = cell(num_squadre, num_giorni);
keys2 = match_days.keys;
% Riempire la cella schedule con i vettori delle partite per ciascuna squadra
for i = 1:length(keys2)    
    partite_giorno = match_days(i);
    
    for squadra = 1:num_squadre
        [row_indices, col_indices] = find(match_days(i) == squadra);
        vector = match_days(i);
        partite_squadra = vector(row_indices, :);
        
        if isempty(partite_squadra)
            schedule{squadra, i} = [0 0];
        else
            schedule{squadra, i} = partite_squadra;
        end
    end
end
% Calcolo del vettore travel
travel = zeros(n, 1);
q = 0;
w = 0;
for i = 1:n
    l_i = 0;
    q = i;
    for j = 1:p
        k = schedule{i, j};
        if ~isequal(k, [0, 0])
            vector = schedule{i, j};
            w = vector(1);
            l_i = l_i+delta(q, w);
            q = w;
        end
    end
    travel(i) = l_i;
end

%% Implementazione algoritmo
tic
schedule_iniz = schedule;
num_iterations = 10000;
best_travel = travel; % Inizializza il miglior vettore travel con quello attuale
best_schedule = schedule; % Inizializza la migliore schedule con quella attuale
for iteration = 1:num_iterations
    schedule_iniz = best_schedule;
    schedule = schedule_iniz;

    % Scegli casualmente un giorno
    day1 = randi(num_giorni);
    
    % Scegli casualmente una squadra
    team1 = randi(num_squadre);
    
    
    temp = schedule{team1, day1};
    if isequal(temp, [0, 0])
        continue
    end
    if temp(1) == team1
        team2 = temp(2);
    else
        team2 = temp(1);
    end

    jPosizione = 0;
    % Cerca il vettore nella cella schedule con i dati invertiti rispetto
    % al vettore temp
    vettore_da_cercare = [temp(2), temp(1)];
    
    trovato = false;
    for j_1 = 1:p
       if isequal(schedule{temp(1), j_1}, vettore_da_cercare)
            jPosizione = j_1;
            trovato = true;
            break; % Esci dal ciclo interno
        end
    end
    % Scambio squadra in casa e in trasferta 
    if trovato
        schedule{team1, day1} = [temp(2), temp(1)];
        schedule{team2, day1} = [temp(2), temp(1)];
        schedule{team1, jPosizione} = [temp(1), temp(2)];
        schedule{team2, jPosizione} = [temp(1), temp(2)];
    else
        best_schedule = schedule_iniz;
        continue
    end

    
    % Calcolo nuova distanza
    new_travel = zeros(n, 1);
    q = 0;
    w = 0;
    for i = 1:n
        l_i = 0;
        q = i;
        for j = 1:p
            k = schedule{i, j};
            if ~isequal(k, [0, 0])
                vector = schedule{i, j};
                w = vector(1);
                l_i = l_i+delta(q, w);
                q = w;
            end
        end
        new_travel(i) = l_i;
    end
    % Se il nuovo travel è migliore, accetta lo scambio altrimenti ripristina la configurazione precedente
    if (sum(new_travel) < sum(best_travel))
        best_travel = new_travel;
        best_schedule = schedule;
    else

        best_schedule = schedule_iniz;
    end
end
toc
fprintf('Distanza non ottimizzata:')
disp(sum(travel));
fprintf('Distanza ottimizzata:')
disp(sum(best_travel));
fprintf('Riduzione percentuale:')
red = ((sum(travel)-sum(best_travel))/sum(travel))*100;
disp(red);
for i = 1:n
    c = 0;
    for j = 1:p
        t = schedule{i,j};
        if t(1) == i
            c = c+1;
        end
    end
    c;
end