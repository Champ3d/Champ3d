%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
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

function [array_type,nb_elem,dimension] = f_arraytype(parameter_array)
%--------------------------------------------------------------------------
% parameter_array comes from Parameter.getvalue
% f_parraytype returns the type of this array
% which may correspond to a 'scalar', 'vector' or 'tensor' parameter
%--------------------------------------------------------------------------
arguments
    parameter_array {mustBeNumeric}
end
% ---
if isempty(parameter_array)
    array_type = '';
    nb_elem = [];
    dimension = [];
    return
end
% ---
if numel(parameter_array) == 1
    array_type = 'scalar';
    nb_elem = 1;
    dimension = 1;
    return
end
% ---
if numel(parameter_array) == 3
    array_type = 'scalar';
    nb_elem = 1;
    dimension = 1;
    return
end
% ---
x = squeeze(parameter_array);
sx = size(x);
lensx = length(sx);
% ---
if lensx > 3
    array_type = '4+dimensional';
    return
end
% ---
if lensx == 3
    array_type = 'tensor';
    return
end
% ---
if lensx == 2
    s1 = sx(1);
    s2 = sx(2);
    if s1 == s2
        if s1 == 1
            array_type = 'scalar';
        else
            array_type = 'tensor';
        end
    elseif s1 < s2
        if s1 == 1
            if s2 > 3
                array_type = 'scalar';
            else
                array_type = {'scalar','vector'};
            end
        else
            array_type = 'vector';
        end
    else
        if s2 == 1
            if s1 > 3
                array_type = 'scalar';
            else
                array_type = {'scalar','vector'};
            end
        else
            array_type = 'vector';
        end
    end
    % ---
    return
end
% ---
if lensx == 3
    s1 = sx(1);
    s2 = sx(2);
    s3 = sx(3);
    % ---
    if s1 == s2 && s2 == s3
        if s1 <= 3
            array_type = 'tensor';
        else
            array_type = '4+dimensional';
        end
    else
        if s1 == s2
            ielem = 3;
            % ---
            if s1 <= 3
                array_type = 'tensor';
            else
                array_type = '4+dimensional';
            end
        elseif s1 == s3
            ielem = 2;
            % ---
            if s1 <= 3
                array_type = 'tensor';
            else
                array_type = '4+dimensional';
            end
        elseif s2 == s3
            ielem = 1;
            % ---
            if s2 <= 3
                array_type = 'tensor';
            else
                array_type = '4+dimensional';
            end
        else
            [~,ielem] = max(sx);
            array_type = '4+dimensional';
        end
        % ---
        ix = [1 2 3];
        ix(ielem) = [];
        ix = [ielem ix];
        colx = permute(x,ix);
    end
    % ---
    return
end