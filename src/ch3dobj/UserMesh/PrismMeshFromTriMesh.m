%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef PrismMeshFromTriMesh < PrismMesh

    % --- Properties
    properties
        id_zline
    end

    % --- Dependent Properties
    properties (Dependent = true)

    end

    % --- Constructors
    methods
        function obj = PrismMeshFromTriMesh(args)
            arguments
                % --- super
                args.node = []
                args.elem = []
                % --- sub
                args.parent_mesh = []
                args.id_zline = []
            end
            % --- super
            obj = obj@PrismMesh;
            obj <= args;
            % ---
            if ~isempty(obj.parent_mesh) && ~isempty(obj.id_zline)
                obj.build;
            end
        end
    end

    % --- Methods
    methods (Access = private)
        % -----------------------------------------------------------------
        function obj = build(obj)
            % ---
            obj.id_zline = f_to_scellargin(obj.id_zline);
            % ---
            all_id_line = fieldnames(obj.parent_mesh.parent_mesh.dom);
            %--------------------------------------------------------------
            zline = [];
            for i = 1:length(obj.id_zline)
                id = obj.id_zline{i};
                valid_id = f_validid(id,all_id_line);
                for j = 1:length(valid_id)
                    zline = [zline obj.parent_mesh.parent_mesh.dom.(valid_id{j})];
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
                zl.build;
                z = zl.node;
                zdiv   = [zdiv z];
                %-----
                nbz = length(z);
                nb_layer = nb_layer + nbz;
                %-----
                % ---
                codeidz = [codeidz zl.elem_code .* ones(1,nbz)];
            end
            %--------------------------------------------------------------
            % build vertices (nodes) in 3D
            % ---
            mesh2d = obj.parent_mesh;
            % ---
            nbNode2D = mesh2d.nb_node;
            nb_node  = nbNode2D*(nb_layer+1);
            node_ = zeros(3,nb_node);
            node_(1:2,:) = repmat(mesh2d.node,1,nb_layer+1);
            for i = 1:nb_layer
               node_(3,i*nbNode2D+1:(i+1)*nbNode2D) = sum(zdiv(1:i)) .* ones(1,nbNode2D);
            end
            %--------------------------------------------------------------
            % build volume elements (elem) in 3D
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
            obj.is_build = 1;
        end
    end

end



