function wordsout = splitSentence(text)

voc = generateVoc();
words = strsplit(text,' ');
wordsout = [];
if ~iscell(words)
    wordsout{1} = words;
    return;
end;

for i = 1 : length(words)
    wordsout_i = getwords(words{i}, {',', '!', ';', '.', '?', '(', ')'});
    wordsout = [wordsout, wordsout_i];
end;

wordsout = mergewords(wordsout, voc);



function wordsout = getwords(word, chrs)

wordsout = [];
    p = [];
    for i = 1 : length(chrs)
       p_i = findstr(chrs{i}, word);
       p = union(p, p_i);
    end;
    if isempty(p) && length(word)==1
        wordsout{end+1} = word;
        return;
    end;
    [u,v] = sort(p, 'ascend');
    p = u;
    prev = 1;
    for j = 1 : length(p)
        w = word(prev : p(j) - 1);
        prev = p(j) + 1;
        if ~isempty(w)
           wordsout{end+1} = w;
        end;
        wordsout{end+1} = word(p(j));
    end;
    if prev < length(word)
        wordsout{end+1} = word(prev:end);
    end;
    
    
function voc = generateVoc()

voc = [];
voc(end+1).words = {'traffic', 'light'};


function wordsout = mergewords(words, voc)

wordsout = [];
words_lower = words;
for i = 1 : length(words)
   words_lower{i} = lower(words{i});    
end;
i = 1;

while i <= length(words)
    matched = 0;
    for j = 1 : length(voc)
        phrase = voc(j).words;
        n = length(phrase);
        if i + n-1 <= length(words)
            str = words_lower(i:i+n-1);
            ismatch = 1;
            for k = 1 : n
                if ~strcmp(str{k}, phrase{k})
                    ismatch = 0;
                end;
            end;
            if ismatch
                str = [];
                for k = 1 : n
                    str = [str ' ' words{i+k-1}];
                end;
                wordsout{end+1} = str;
                i = i + n - 1;
                matched = 1;
            end;
        end;
    end;
    if matched==0
        wordsout{end+1} = words{i};
    end;
    i = i + 1;
end;