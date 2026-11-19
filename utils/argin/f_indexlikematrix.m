%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2026
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
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function idmat = f_indexlikematrix(args)
    arguments
        args.idcell = 0
        args.matrixsize = [1 1]
    end
    % ---
    idc = args.idcell;
    ms = args.matrixsize;
    % ---
    if idc > 9,  idc = 9; end
    if numel(ms)==1, ms = [1 ms]; end
    ms(ms>9) = 9;
    ls = length(ms);
    % ---
    idmat = zeros(ms);
    if ls == 2
        for i = 1:ms(1)
            for j = 1:ms(2)
                idmat(i,j) = i*10 + j;
            end
        end
    elseif ls == 3
        for i = 1:ms(1)
            for j = 1:ms(2)
                for k = 1:ms(3)
                    idmat(i,j,k) = i*100 + j*10 + k;
                end
            end
        end
    elseif ls == 4
        for i = 1:ms(1)
            for j = 1:ms(2)
                for k = 1:ms(3)
                    for l = 1:ms(4)
                        idmat(i,j,k) = i*1000 + j*100 + k*10 + l;
                    end
                end
            end
        end
    else
        error("#matrixsize of size > 4 is not supported !");
    end
    % ---
    idmat = idmat + idc * 10^ls;
    % ---
end