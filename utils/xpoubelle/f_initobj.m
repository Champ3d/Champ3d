%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
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