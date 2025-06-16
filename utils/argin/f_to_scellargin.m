function scellargin = f_to_scellargin(argin,varargin)
%F_TO_SCELLARGIN : returns a single cell argin from double cell or string
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

% --- valid argument list (to be updated each time modifying function)
arglist = {'forced'};

% --- default input value
forced = 0;
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if ~iscell(argin)
    argin = {argin};
end
%--------------------------------------------------------------------------
k = 0;
scellargin = {};
for i = 1:length(argin)
    if iscell(argin{i})
        for j = 1:length(argin{i})
            if iscell(argin{i}{j})
                for m = 1:length(argin{i}{j})
                    if iscell(argin{i}{j}{m})
                        error([mfilename() ' : cell structure too profond !'])
                    else
                        k = k + 1;
                        scellargin{k} = argin{i}{j}{m};
                    end
                end
            else
                k = k + 1;
                scellargin{k} = argin{i}{j};
            end
        end
    else
        k = k + 1;
        scellargin{k} = argin{i};
    end
end





