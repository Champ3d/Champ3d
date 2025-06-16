function f_display(varargin)
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

%--------------------------------------------------------------------------
fprintf('----- \n');
for i = 1:length(varargin)
    info = varargin{i};
    if isa(info,'char')
        fprintf([info '\n']);
    elseif isa(info,'cell')
        for j = 1:length(info)
            subinfo = info{j};
            if isa(subinfo,'char')
                fprintf([subinfo ' ']);
            elseif isa(subinfo,'numeric')
                sizesub = size(subinfo);
                if numel(subinfo) == 1
                    fprintf([num2str(subinfo) ' ']);
                elseif length(sizesub) <= 2
                    if sizesub(1) == 1
                        disp(subinfo);
                    elseif sizesub(2) == 1
                        disp(subinfo.');
                    else
                        disp(subinfo);
                    end
                else
                    disp(subinfo);
                end
            end
        end
    else
        disp(info);
    end
end
fprintf('----- \n');
%--------------------------------------------------------------------------