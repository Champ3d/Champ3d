function color = f_color(ccode)
%
% ccode = 1 -> 15 : color code
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% from https://fr.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html
allcode = {'cyan','green','blue','red','magenta','yellow','black','white',...
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
        color = allcode{mod(ccode,length(allcode)) + 1};
    end
else
    color = ccode;
end



