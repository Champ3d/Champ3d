function f_display(varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
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