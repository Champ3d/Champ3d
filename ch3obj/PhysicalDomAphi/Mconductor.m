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
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Mconductor < PhysicalDom
    properties
        mur
        % ---
        matrix
    end
    % ---
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_model','id_dom3d','mur','parameter_dependency_search'};
        end
    end
    % --- Contructor
    methods
        function obj = Mconductor(args)
            arguments
                args.id
                args.parent_model
                args.id_dom3d
                args.mur
                args.parameter_dependency_search ...
                    {mustBeMember(args.parameter_dependency_search,{'by_coordinates','by_id_dom'})} ...
                    = 'by_id_dom'
            end
            % ---
            obj = obj@PhysicalDom;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            Mconductor.setup(obj);
        end
    end

    % --- setup
    methods (Static)
        function setup(obj)
            % --- call utility methods
            obj.set_parameter;
            obj.get_geodom;
            obj.dom.is_defining_obj_of(obj);
            % --- Initialization
            obj.matrix.gid_elem = [];
            obj.matrix.nu0nurwfwf = [];
            obj.matrix.nur_array = [];
            obj.matrix.mur_array = [];
            % ---
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            obj.setup_done = 0;
            Mconductor.setup(obj);
        end
    end
    % --- build
    methods
        function build(obj)
            % ---
            dom = obj.dom;
            parent_mesh = dom.parent_mesh;
            gid_elem = dom.gid_elem;
            % ---
            mu0 = 4 * pi * 1e-7;
            nu0 = 1/mu0;
            % ---
            mur_array = obj.mur.getvalue('in_dom',dom);
            nur_array = obj.mur.get_inverse('in_dom',dom);
            nu0nur = nu0 .* nur_array;
            %--------------------------------------------------------------
            % --- check changes
            is_changed = 1;
            if isequal(mur_array,obj.matrix.mur_array) && ...
               isequal(gid_elem,obj.matrix.gid_elem)
                is_changed = 0;
            end
            %--------------------------------------------------------------
            if ~is_changed && obj.build_done == 1
                return
            end
            %--------------------------------------------------------------
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.nur_array = nur_array;
            obj.matrix.mur_array = mur_array;
            %--------------------------------------------------------------
            % local nu0nurwfwf matrix
            lmatrix = parent_mesh.cwfwf('id_elem',gid_elem,'coefficient',nu0nur);
            %--------------------------------------------------------------
            id_elem_nomesh = obj.parent_model.matrix.id_elem_nomesh;
            id_face_in_elem = obj.parent_model.parent_mesh.meshds.id_face_in_elem;
            nb_face = obj.parent_model.parent_mesh.nb_face;
            nbFa_inEl = obj.parent_model.parent_mesh.refelem.nbFa_inEl;
            %--------------------------------------------------------------
            gid_elem = obj.matrix.gid_elem;
            %--------------------------------------------------------------
            [~,id_] = intersect(gid_elem,id_elem_nomesh);
            gid_elem(id_) = [];
            lmatrix(id_,:,:) = [];
            %--------------------------------------------------------------
            % global elementary nu0nurwfwf matrix
            nu0nurwfwf = sparse(nb_face,nb_face);
            %--------------------------------------------------------------
            for i = 1:nbFa_inEl
                for j = i+1 : nbFa_inEl
                    nu0nurwfwf = nu0nurwfwf + ...
                        sparse(id_face_in_elem(i,gid_elem),id_face_in_elem(j,gid_elem),...
                        lmatrix(:,i,j),nb_face,nb_face);
                end
            end
            % ---
            nu0nurwfwf = nu0nurwfwf + nu0nurwfwf.';
            % ---
            for i = 1:nbFa_inEl
                nu0nurwfwf = nu0nurwfwf + ...
                    sparse(id_face_in_elem(i,gid_elem),id_face_in_elem(i,gid_elem),...
                    lmatrix(:,i,i),nb_face,nb_face);
            end
            %--------------------------------------------------------------
            obj.matrix.nu0nurwfwf = nu0nurwfwf;
            % ---
            obj.build_done = 1;
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            %--------------------------------------------------------------
            obj.parent_model.matrix.nu0nurwfwf = ...
                obj.parent_model.matrix.nu0nurwfwf + obj.matrix.nu0nurwfwf;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_elem_mcon = ...
                [obj.parent_model.matrix.id_elem_mcon obj.matrix.gid_elem];
            %--------------------------------------------------------------
        end
    end
end