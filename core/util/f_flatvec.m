function [vout, return_position_list, return_len_list] = f_flatvec(vin,varargin)
% F_FLATVEC 
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
arglist = {'position'};

% --- default input value
position = 1; % index of the dimension

%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
lenlist_o = size(vin);
positionlist_o = 1:length(lenlist_o);
len_position = lenlist_o(position);
% ---
positionlist_new = positionlist_o;
positionlist_new(position) = [];
positionlist_new = [position positionlist_new];
lenlist_new = lenlist_o(positionlist_new);
vout = reshape(permute(vin,positionlist_new),len_position,[]);
% ---
return_position_list = positionlist_new;
return_len_list = lenlist_new;

end



