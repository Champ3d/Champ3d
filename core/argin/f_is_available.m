%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function [res, available_args] = f_is_available(args,field_name)
arguments
    args struct = []
    field_name = []
end

% ---
if nargin < 1
    res = 0;
    return
end
% ---
if isempty(args)
    res = 0;
    return
end
% ---
if isempty(field_name)
    field_name = fieldnames(args);
end
% ---
field_name = f_to_scellargin(field_name);
% ---
res = 1;
available_args = [];
for i = 1:length(field_name)
    if isfield(args,field_name{i})
        if isempty(args.(field_name{i}))
            res = 0;
            args = rmfield(args,field_name{i});
        else
            available_args.(field_name{i}) = args.(field_name{i});
        end
    else
        res = 0;
    end
end
