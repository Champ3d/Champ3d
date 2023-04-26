function color = f_color(ccode)
%
% ccode = 1 -> 15 : color code
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% from https://fr.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html
allcode = {'red','green','blue','cyan','magenta','yellow','black','white',...
            [0 0.4470 0.7410], ...
            [0.8500 0.3250 0.0980], ...
            [0.9290 0.6940 0.1250], ...
            [0.4940 0.1840 0.5560], ...
            [0.4660 0.6740 0.1880], ...
            [0.3010 0.7450 0.9330], ...
            [0.6350 0.0780 0.1840] };

if isnumeric(ccode)
    if ccode <= length(allcode)
        color = allcode{ccode};
    else
        color = allcode{11};
    end
else
    color = ccode;
end



