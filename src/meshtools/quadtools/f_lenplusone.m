function leny_plus_one = f_lenplusone(y)

if isempty(y)
    leny_plus_one = 1;
else
    leny_plus_one = length(y) + 1;
end