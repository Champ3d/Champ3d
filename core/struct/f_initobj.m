%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function obj = f_initobj(obj,args)
arguments
    obj
    args.property_name = []
    args.field_names = []
    args.init_value = []
end
% ---
if ~isempty(args.property_name)
    if isprop(obj,args.property_name)
        field_names = f_to_scellargin(args.field_names);
        for i = 1:length(field_names)
            fn = field_names{i};
            obj.(args.property_name).(fn) = args.init_value;
        end
    end
end