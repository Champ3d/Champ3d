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

classdef HAphiElemField < VectorElemField
    properties
        parent_model
        mconductor
        Bfield
    end
    % --- Contructor
    methods
        function obj = HAphiElemField(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.Bfield {mustBeA(args.Bfield,'FaceDofBasedVectorElemField')}
            end
            % ---
            obj = obj@VectorElemField;
            % ---
            if nargin >1
                if ~isfield(args,'parent_model') || ~isfield(args,'Bfield')
                    error('#parent_model and #Bfield must be given !');
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
            %val = zeros(length(id_elem),3);
            % ---
            mu0 = 4 * pi * 1e-7;
            nu0 = 1/mu0;
            % ---
            val =+ (obj.Bfield(id_elem) * nu0);
            % ---
            if ~isempty(obj.mconductor)
                id_phydom_ = fieldnames(obj.mconductor);
                % ---
                for iec = 1:length(id_phydom_)
                    tarray = obj.mconductor.(id_phydom_{iec}).nur;
                    % ---
                    [gindex,lindex] = intersect(id_elem,tarray.parent_dom.gindex);
                    val(lindex,:) =+ (obj.Bfield(gindex) * (tarray(lindex) * nu0));
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
        function val = ivalue(obj,id_elem)
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
            nbI = obj.parent_model.parent_mesh.refelem.nbI;
            val = {};
            % ---
            mu0 = 4 * pi * 1e-7;
            nu0 = 1/mu0;
            for i = 1:nbI
                %val{i} = zeros(length(id_elem),3);
                val{i} =+ (obj.Bfield(id_elem) * nu0);
            end
            % ---
            if ~isempty(obj.mconductor)
                id_phydom_ = fieldnames(obj.mconductor);
                % ---
                for iec = 1:length(id_phydom_)
                    tarray = obj.mconductor.(id_phydom_{iec}).nur;
                    % ---
                    [gindex,lindex] = intersect(id_elem,tarray.parent_dom.gindex);
                    vcell =+ (obj.Bfield({gindex}) * (tarray(lindex) * nu0));
                end
                for i = 1:nbI
                    val{i}(lindex,:) = vcell{i};
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
        function val = gvalue(obj,id_elem)
            
        end
        % -----------------------------------------------------------------
    end
end