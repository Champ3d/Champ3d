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
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef JAphiElemField < VectorElemField
    properties
        parent_model
        econductor
        Efield
    end
    % --- Contructor
    methods
        function obj = JAphiElemField(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.Efield {mustBeA(args.Efield,'EdgeDofBasedVectorElemField')}
            end
            % ---
            obj = obj@VectorElemField;
            % ---
            if nargin >1
                if ~isfield(args,'parent_model') || ~isfield(args,'Efield')
                    error('#parent_model and #Efield must be given !');
                end
            end
            % ---
            obj <= args;
            % ---
        end
    end
    % --- get
    methods
        % -----------------------------------------------------------------
        function val = cvalue(obj,id_elem)
            % ---
            if nargin <= 1
                id_elem = 1:obj.parent_model.parent_mesh.nb_elem;
            end
            % ---
            if isempty(id_elem)
                val = [];
                return
            end
            % ---
            val = zeros(length(id_elem),3);
            % ---
            if ~isempty(obj.econductor)
                id_phydom_ = fieldnames(obj.econductor);
                % ---
                for iec = 1:length(id_phydom_)
                    tarray = obj.econductor.(id_phydom_{iec}).sigma;
                    % ---
                    [gindex,lindex] = intersect(id_elem,tarray.parent_dom.gindex);
                    val(lindex,:) =+ (obj.Efield(gindex) * tarray(lindex));
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
        function val = ivalue(obj,id_elem)
            
        end
        % -----------------------------------------------------------------
        function val = gvalue(obj,id_elem)
            
        end
        % -----------------------------------------------------------------
    end
end