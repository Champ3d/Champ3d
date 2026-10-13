function color = f_color(ccode)
%
% ccode = 1 -> 15 : color code
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% from https://fr.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html
allcode = {'cyan','green','blue','red','magenta','yellow','black',...
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



