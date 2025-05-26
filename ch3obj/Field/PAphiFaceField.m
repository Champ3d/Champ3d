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

classdef PAphiFaceField < ScalarFaceField
    properties
        parent_model
        sibc
        Efield
        Jfield
    end
    % --- Contructor
    methods
        function obj = PAphiFaceField(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.Efield {mustBeA(args.Efield,'EdgeDofBasedVectorFaceField')}
                args.Jfield {mustBeA(args.Jfield,'JAphiFaceField')}
            end
            % ---
            obj = obj@ScalarFaceField;
            % ---
            if nargin >1
                if ~isfield(args,'parent_model') || ~isfield(args,'Efield') || ~isfield(args,'Jfield')
                    error('#parent_model, #Efield, #Jfield must be given !');
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
        function val = cvalue(obj,id_face)
            % ---
            if nargin <= 1
                id_face = 1:obj.parent_model.parent_mesh.nb_face;
            end
            % ---
            if isempty(id_face)
                val = [];
                return
            end
            % ---
            val = zeros(length(id_face),2);
            % ---
            if ~isempty(obj.sibc)
                id_phydom_ = fieldnames(obj.sibc);
                % ---
                for iec = 1:length(id_phydom_)
                    tarray = obj.sibc.(id_phydom_{iec}).skindepth;
                    % ---
                    [gindex,lindex] = intersect(id_face,tarray.parent_dom.gindex);
                    % ---
                    E = obj.Efield.cvalue(id_face);
                    J = obj.Jfield.cvalue(id_face);
                    EJconj = real(Array.dot(E,conj(J)));
                    % ---
                    val(lindex,:) = obj.Efield.cmultiply(tarray,gindex);
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
        function val = ivalue(obj,id_elem)
            % ---
            % E = obj.Efield.cvalue(id_elem);
            % Jconj = VectorArray.conjugate(obj.Jfield.cvalue(id_elem));
            % val = Array.dot(E,conj(J));
            % ---
        end
        % -----------------------------------------------------------------
        function val = gvalue(obj,id_elem)
            
        end
        % -----------------------------------------------------------------
    end
end