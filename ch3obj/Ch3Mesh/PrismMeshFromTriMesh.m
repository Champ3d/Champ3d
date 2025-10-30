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

classdef PrismMeshFromTriMesh < PrismMesh
    properties
        parent_mesh1d
        parent_mesh2d
        id_zline
    end
    properties (Access = private)
        build_done = 0
        % ---
        build_meshds_done = 0;
        build_discrete_done = 0;
        build_intkit_done = 0;
        build_prokit_done = 0;
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','node','elem','parent_mesh1d','parent_mesh2d', ...
                        'id_zline'};
        end
    end
    % --- Constructors
    methods
        function obj = PrismMeshFromTriMesh(args)
            arguments
                % --- super
                args.id
                args.node
                args.elem
                % --- sub
                args.parent_mesh1d
                args.parent_mesh2d
                args.id_zline
            end
            % ---
            obj@PrismMesh;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            PrismMeshFromTriMesh.setup(obj);
            % ---
        end
    end

    % --- setup/reset/build/
    methods (Static)
        % -----------------------------------------------------------------
        function obj = setup(obj)
            % ---
            obj.build_done = 0;
            % ---
            obj.build_meshds_done = 0;
            obj.build_discrete_done = 0;
            obj.build_intkit_done = 0;
            obj.build_prokit_done = 0;
            % ---
            if isempty(obj.parent_mesh2d) || isempty(obj.id_zline)
                return
            end
            % ---
            if isempty(obj.parent_mesh1d)
                if isprop(obj.parent_mesh2d,'parent_mesh')
                    obj.parent_mesh1d = obj.parent_mesh2d.parent_mesh;
                end
            end
            % ---
            obj.parent_mesh2d.is_defining_obj_of(obj);
            if obj.parent_mesh2d.parent_mesh ~= obj.parent_mesh1d
                obj.parent_mesh1d.is_defining_obj_of(obj);
            end
            %--------------------------------------------------------------
            obj.id_zline = f_to_scellargin(obj.id_zline);
            % ---
            all_id_line = fieldnames(obj.parent_mesh1d.dom);
            %--------------------------------------------------------------
            zline = [];
            for i = 1:length(obj.id_zline)
                id = obj.id_zline{i};
                valid_id = f_validid(id,all_id_line);
                for j = 1:length(valid_id)
                    % ---
                    dom1d = obj.parent_mesh1d.dom.(valid_id{j});
                    % dom1d.is_defining_obj_of(obj);
                    % ---
                    zline = [zline dom1d];
                end
            end
            % ---
            zdiv   = [];
            nb_layer = 0;
            codeidz = [];
            for i = 1:length(zline)
                %-----
                zl = zline(i);
                %-----
                z = zl.node;
                zdiv = [zdiv z];
                %-----
                nbz = length(z);
                nb_layer = nb_layer + nbz;
                %-----
                % ---
                codeidz = [codeidz zl.elem_code .* ones(1,nbz)];
            end
            %--------------------------------------------------------------
            % setup vertices (nodes) in 3D
            % ---
            mesh2d = obj.parent_mesh2d;
            % ---
            nbNode2D = mesh2d.nb_node;
            nb_node  = nbNode2D*(nb_layer+1);
            node_ = zeros(3,nb_node);
            node_(1:2,:) = repmat(mesh2d.node,1,nb_layer+1);
            for i = 1:nb_layer
               node_(3,i*nbNode2D+1:(i+1)*nbNode2D) = sum(zdiv(1:i)) .* ones(1,nbNode2D);
            end
            %--------------------------------------------------------------
            % setup volume elements (elem) in 3D
            nbElem2D = mesh2d.nb_elem;
            nb_elem = nbElem2D * nb_layer;
            elem_ = zeros(6, nb_elem);
            elem_code_ = zeros(1, nb_elem);
            % ---
            elem2d = [mesh2d.elem(1,:); ...
                      mesh2d.elem(2,:); ...
                      mesh2d.elem(3,:)];
            % ---
            ie0 = 0;
            for k = 1:nb_layer	% k : current layer
                % ---------------------------------------------------------
                elem_(1:3,ie0+1 : ie0+nbElem2D) = elem2d + nbNode2D * (k-1);
                elem_(4:6,ie0+1 : ie0+nbElem2D) = elem2d + nbNode2D *  k;
                % ---------------------------------------------------------
                % elem code --> encoded id (id_x, id_y, id_layer)
                elem_code_(1,ie0+1 : ie0+nbElem2D) = mesh2d.elem_code .* codeidz(k);
                % go to the next layer
                ie0 = ie0 + nbElem2D;
            end
            %--------------------------------------------------------------
            celem_ = mean(reshape(node_(:,elem_(1:6,:)),3,6,nb_elem),2);
            celem_ = squeeze(celem_);
            %--------------------------------------------------------------
            face_ = f_face(elem_,'elem_type','prism');
            nb_face = size(face_,2);
            cface_   = zeros(3,nb_face);
            id_tria = find(face_(4,:) == 0);
            id_quad = setdiff(1:nb_face,id_tria);
            cface_(:,id_tria) = mean(reshape(node_(:,face_(1:3,id_tria)),3,3,length(id_tria)),2);
            cface_(:,id_quad) = mean(reshape(node_(:,face_(1:4,id_quad)),3,4,length(id_quad)),2);
            %--------------------------------------------------------------
            edge_ = f_edge(elem_,'elem_type','prism');
            nb_edge = size(edge_,2);
            cedge_ = mean(reshape(node_(:,edge_(1:2,:)),3,2,nb_edge),2);
            cedge_ = squeeze(cedge_);
            %--------------------------------------------------------------
            obj.node = node_;
            obj.elem = elem_;
            obj.elem_code = elem_code_;
            obj.edge = edge_;
            obj.face = face_;
            obj.celem = celem_;
            obj.cedge = cedge_;
            obj.cface = cface_;
            % ---
            obj.velem = f_volume(node_,elem_,'elem_type',obj.elem_type);
            obj.sface = f_area(node_,face_);
            obj.ledge = f_ledge(node_,edge_);
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            PrismMeshFromTriMesh.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    methods
        function build(obj)
            % ---
            if obj.build_done
                return
            end
            % ---
            if ~obj.build_meshds_done
                obj.build_meshds;
                obj.build_meshds_done = 1;
            end
            if ~obj.build_discrete_done
                obj.build_discrete;
                obj.build_discrete_done = 1;
            end
            if ~obj.build_intkit_done
                obj.build_intkit;
                obj.build_intkit_done = 1;
            end
            % ---
            obj.build_done = 1;
            % ---
        end
    end
end
