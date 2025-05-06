function dcellargin = f_to_dcellargin(argin,varargin)
%F_TO_DCELLARGIN : returns a double cell argin from single cell or string
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
arglist = {'duplicate','forced'};

% --- default input value
duplicate = 0;
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

switch forced
    %--------------------------------------------------------------------------
    case {1,'on','yes'}
        if ~iscell(argin)
            argin = {argin};
        end
        tocellargin = {};
        for i = 1:length(argin)
            if ~iscell(argin{i})
                tocellargin{i} = {argin{i}};
            else
                tocellargin{i} = argin{i};
            end
        end
    %--------------------------------------------------------------------------
    otherwise
        tocellargin = {};
        if ~iscell(argin)
            tocellargin = {{argin}};
        else
            lenargin = length(argin);
            has_cell = 0;
            for i = 1:lenargin
                has_cell = has_cell + iscell(argin{i});
            end
            if ~has_cell
                tocellargin = {argin};
                %for i = 1:lenargin
                %    tocellargin{i} = argin{i};
                %end
            else
                for i = 1:lenargin
                    if iscell(argin{i})
                        tocellargin{i} = argin{i};
                    else
                        tocellargin{i} = {argin{i}};
                    end
                end
            end
        end
end
%------------------------------------------------------------------
dcellargin = {};
if duplicate > 1
    for i = 1:duplicate
        lencell = length(tocellargin);
        for j = 1:lencell
            dcellargin{(i-1) * lencell + j} = tocellargin{j};
        end
    end
else
    dcellargin = tocellargin;
end


