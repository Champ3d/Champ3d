function data_out = f_addtostruct(data_in,data_out,varargin)
% F_ADDTOSTRUCT adds (all) sub_structs of data_in into data_out.
%--------------------------------------------------------------------------
% FIXED INPUT
% data_in : input struct
% data_out : output struct
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'sub_struct' : field name to add to output
%--------------------------------------------------------------------------
% OUTPUT
% data_out : output struct with sub_structs of input added
%--------------------------------------------------------------------------
% EXAMPLE
% data_out = F_ADDTOSTRUCT(data_in,data_out);
%     --> data_out.all_sub_structs = data_in.all_sub_structs
% data_out = F_ADDTOSTRUCT(data_in,data_out,'sub_struct');
%     --> data_out.sub_struct = data_in.sub_struct
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

if nargin > 2
    if isfield(data_in,varargin{1})
        things = varargin{1};
    else
        things = fieldnames(data_in); % copy everthing
    end
else
    things = fieldnames(data_in); % copy everthing
end

for i = 1:length(things)
    data_out.(things{i}) =data_in.(things{i});
end

end


