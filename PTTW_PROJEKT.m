%% Menu g��wne
disp('Witamy w projekcie z PTTW - Koder i Dekoder splotowy');
disp('Autorzy - Rados�aw Jarzynka & Krzysztof Owczarek');
disp('Wybierz tryb pracy:')
disp('(1) - Zakodowanie pliku')
disp('(2) - Dekodowanie pliku (hard)')
disp('(3) - Dekodowanie pliku (unquantized)')

%% Wczytanie pliku
chosenMode = input('Wybierz tryb:');
while (chosenMode ~= 1 && chosenMode ~= 2 && chosenMode ~= 3 && chosenMode ~= 4 && chosenMode ~= 5)
    chosenMode = input('Wpisano z�� warto��, wybierz ponownie:');
end
disp('Wpisz nazw� pliku z danymi')
filename = input('Wspierany format to znaki 0 lub 1 oddzielone znakiem nowej linii (\\n): ', 's');
fileId = fopen(filename);
while fileId == -1
    filename = input('Wpisz poprawn� nazw� pliku: ', 's');
    fileId = fopen(filename);
end
data_array = fscanf(fileId ,'%d');

%% Utworzenie trellis
trel =  poly2trellis([5],[23 35 0]);
% trackback - do dekodowania, zwykle 3-krotno�� enkodera (u nas 1/3 wi�c 3*3 = 9)
tblen = 1; 
%% enkodowanie/dekodowanie
switch chosenMode
    case 1
        result = convenc(data_array,trel);
    case 2
        % je�eli jest z�a d�ugo�� danych (nie jest podzielna przez 3)
        % appendujemy zera by si� kod nie wywali�
        while (mod(size(data_array), 3) ~= 0)
            data_array = [data_array; 0];
        end
        result = vitdec(data_array,trel,tblen,'cont','hard');
        %usuwamy pierwszy element (przez trackback jest on zerowy)
        result = result(2:length(result));
        result = [result; 0];
    case 3
        while (mod(size(data_array), 3) ~= 0)
            data_array = [data_array; 0];
            result = [result; 0];
        end
        ucode = 1-2*data_array;
        result = vitdec(ucode',trel,tblen,'cont','unquant');
        result = result(2:length(result));
        result = [result; 0];
    case 4
        H = comm.TurboEncoder(trel, (size(data_array):-1:1));
        result = H.step(data_array);
    case 5
        size = input('Dlugość ciagu wejsciowego/interleaver size:');
        H = comm.TurboDecoder(trel, (size:-1:1));
        result = H.step(data_array);
    otherwise
        disp('Wybrano z�y tryb!');
end

edit result.txt
resultFileID = fopen('result.txt','w');
fprintf(resultFileID,'%d\n',result);
fclose(resultFileID);
disp('Zrobione!')
