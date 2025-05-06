function f_chlogo()
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

%c3name = '$\overrightarrow{champ}{3d}$';
c3name = 'Champ3d';
texpos = get(gca, 'OuterPosition');
hold on;
t = text(texpos(1),texpos(2)+1.00, c3name, ...
     'FontSize',12, ...
     'FontWeight','bold',...
     'Interpreter','tex',...
     'Units','normalized', ...
     'VerticalAlignment', 'baseline', ...
     'HorizontalAlignment', 'left');
% ---
t.BackgroundColor = 0.3 .* ones(1,3);
t.Color = 'cyan';
t.FontName = 'Helvetica';
t.FontAngle = 'normal';
t.Margin = 1;
% ---
t.EdgeColor = 'none';


