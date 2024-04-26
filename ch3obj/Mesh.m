%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Mesh < Xhandle

    % --- Properties
    properties
        node
        elem
        edge
        face
        elem_code
        elem_type
        celem
        cface
        cedge
        % ---
        dom
        % ---
        meshds
        discrete
        intkit
        prokit
        % ---
        setup_done = 0
        build_meshds_done = 0
        build_discrete_done = 0
        build_intkit_done = 0
        build_prokit_done = 0
        % --- submesh
        parent_mesh
        gid_node
        gid_elem
        gid_edge
        gid_face
        flat_node
        % ---
    end

    % --- Dependent Properties
    properties (Dependent = true)
        nb_node
        nb_elem
        nb_edge
        nb_face
        % ---
        refelem
        % ---
        dim
    end

    % --- Constructors
    methods
        function obj = Mesh()
            % ---
            obj.meshds.id_edge_in_elem = [];
            obj.meshds.ori_edge_in_elem = [];
            obj.meshds.sign_edge_in_elem = [];
            obj.meshds.id_face_in_elem = [];
            obj.meshds.ori_face_in_elem = [];
            obj.meshds.sign_face_in_elem = [];
            % ---
            obj.meshds.id_edge_in_face = [];
            obj.meshds.ori_edge_in_face = [];
            obj.meshds.sign_edge_in_face = [];
            % ---
            obj.discrete.div = [];
            obj.discrete.grad = [];
            obj.discrete.rot = [];
            % ---
            obj.intkit.cdetJ = {};
            obj.intkit.cgradWn = {};
            obj.intkit.cJinv = {};
            obj.intkit.cWe = {};
            obj.intkit.cWf = {};
            obj.intkit.cWn = {};
            obj.intkit.cWv = {};
            obj.intkit.cnode = {};
            obj.intkit.detJ = {};
            obj.intkit.gradWn = {};
            obj.intkit.Jinv = {};
            obj.intkit.We = {};
            obj.intkit.Wf = {};
            obj.intkit.Wn = {};
            obj.intkit.node = {};
            % ---
            obj.prokit.detJ = {};
            obj.prokit.gradWn = {};
            obj.prokit.Jinv = {};
            obj.prokit.We = {};
            obj.prokit.Wf = {};
            obj.prokit.Wn = {};
            obj.prokit.node = {};
            % ---
        end
    end

    % --- Methods - Get
    methods
        % ---
        function val = get.nb_node(obj)
            val = size(obj.node,2);
        end
        % ---
        function val = get.nb_elem(obj)
            val = size(obj.elem,2);
        end
        % ---
        function val = get.nb_edge(obj)
            val = size(obj.edge,2);
        end
        % ---
        function val = get.nb_face(obj)
            val = size(obj.face,2);
        end
        % ---
        function val = get.dim(obj)
            val = size(obj.node,1);
        end
        % ---
        function val = get.refelem(obj)
            val = obj.reference;
        end
        % ---
    end
    % --- Methode - Add
    methods
        % -----------------------------------------------------------------
        function add_default_domain(obj,varargin)
            gid_elem_ = 1:obj.nb_elem;
            if isa(obj,'Mesh2d')
                obj.dom.default_domain = VolumeDom2d('parent_mesh',obj,'gid_elem',gid_elem_);
            elseif isa(obj,'Mesh3d')
                obj.dom.default_domain = VolumeDom3d('parent_mesh',obj,'gid_elem',gid_elem_);
            end
        end
        % -----------------------------------------------------------------
    end
    % --- Methods - Geo
    methods
        % -----------------------------------------------------------------
        function lbox = localbox(obj)
            lbox.xmin = min(obj.node(1,:));
            lbox.xmax = max(obj.node(1,:));
            lbox.ymin = min(obj.node(2,:));
            lbox.ymax = max(obj.node(2,:));
            if size(obj.node,1) == 3
                lbox.zmin = min(obj.node(3,:));
                lbox.zmax = max(obj.node(3,:));
            end
        end
        % -----------------------------------------------------------------
        function lock_origin(obj,args)
            arguments
                obj
                args.origin = []
            end
            % ---
            origin = args.origin;
            % ---
            if isa(obj,'Mesh2d')
                if isempty(origin)
                    return
                elseif any(origin ~= [0 0])
                    obj.node = obj.node - origin.';
                end
            elseif isa(obj,'Mesh3d')
                if isempty(origin)
                    return
                elseif any(origin ~= [0 0 0])
                    obj.node = obj.node - origin.';
                end
            end
            % ---
            obj.celem = obj.cal_celem;
            obj.cface = obj.cal_cface;
            obj.cedge = obj.cal_cedge;
        end
        % -----------------------------------------------------------------
        function rotate(obj,args)
            arguments
                obj
                args.rot_axis_origin = [0 0 0];
                args.rot_axis = [];
                args.rot_angle = 0;
            end
            % ---
            rot_axis_origin = args.rot_axis_origin;
            rot_axis   = args.rot_axis;
            rot_angle  = args.rot_angle;
            % ---
            if isempty(rot_axis)
                return
            end
            % ---
            obj.node = f_rotaroundaxis(obj.node, ...
                'rot_axis_origin',rot_axis_origin, ...
                'rot_axis',rot_axis,'rot_angle',rot_angle);
            % ---
            obj.celem = obj.cal_celem;
            obj.cface = obj.cal_cface;
            obj.cedge = obj.cal_cedge;
        end
        % -----------------------------------------------------------------
        function celem = cal_celem(obj,args)
            arguments
                obj
                args.coordinate_system {mustBeMember(args.coordinate_system,{'local','global'})} = 'local'
            end
            % ---
            coordinate_system = args.coordinate_system;
            % ---
            if f_strcmpi(coordinate_system,'local')
                node_ = obj.node;
            else
                %node_ = obj.gnode;
            end
            % ---
            dim_  = size(node_,1);
            elem_ = obj.elem;
            nb_elem_ = obj.nb_elem;
            % ---
            refelem_  = obj.refelem;
            nbNo_inEl = refelem_.nbNo_inEl;
            % ---
            celem = mean(reshape(node_(:,elem_(1:nbNo_inEl,:)),dim_,nbNo_inEl,nb_elem_),2);
            celem = squeeze(celem);
            % ---
        end
        % ---
        function cface = cal_cface(obj,args)
            arguments
                obj
                args.coordinate_system {mustBeMember(args.coordinate_system,{'local','global'})} = 'local'
            end
            % ---
            coordinate_system = args.coordinate_system;
            % ---
            if f_strcmpi(coordinate_system,'local')
                node_ = obj.node;
            else
                %node_ = obj.gnode;
            end
            % ---
            dim_  = size(node_,1);
            % ---
            [filface,id_face_] = f_filterface(obj.face);
            cface = zeros(dim_,size(obj.face,2));
            for i = 1:length(filface)
                face_ = filface{i};
                nb_face_ = size(face_,2);
                nbNo_inFa = size(face_,1);
                cface(:,id_face_{i}) = squeeze(mean(reshape(node_(:,face_(1:nbNo_inFa,:)),dim_,nbNo_inFa,nb_face_),2));
            end
        end
        % ---
        function cedge = cal_cedge(obj,args)
            arguments
                obj
                args.coordinate_system {mustBeMember(args.coordinate_system,{'local','global'})} = 'local'
            end
            % ---
            coordinate_system = args.coordinate_system;
            % ---
            if f_strcmpi(coordinate_system,'local')
                node_ = obj.node;
            else
                %node_ = obj.gnode;
            end
            % ---
            dim_  = size(node_,1);
            % ---
            refelem_  = obj.refelem;
            nbNo_inEd = refelem_.nbNo_inEd;
            % ---
            edge_ = obj.edge;
            nb_edge_ = size(edge_,2);
            % ---
            cedge = mean(reshape(node_(:,edge_(1:nbNo_inEd,:)),dim_,nbNo_inEd,nb_edge_),2);
            cedge = squeeze(cedge);
        end
        function obj = cal_flatnode(obj)
            % ---
            node_ = obj.node;
            face_ = obj.elem;
            % ---
            if isempty(face_) || isempty(node_) || size(node_,1) < 3
                obj.flat_node = [];
                return
            end
            % ---
            nvec      = f_chavec(node_,face_,'defined_on','face');
            nbNo_inFa = size(face_,1);
            nbFace    = size(face_,2);
            %--------------------------------------------------------------
            Ox = zeros(3,nbFace);
            Oy = zeros(3,nbFace);
            %----------------------
            Ox(1,:) = node_(1,face_(2,:)) - node_(1,face_(1,:));
            Ox(2,:) = node_(2,face_(2,:)) - node_(2,face_(1,:));
            Ox(3,:) = node_(3,face_(2,:)) - node_(3,face_(1,:));
            MOx     = sqrt(Ox(1,:).^2 + Ox(2,:).^2 + Ox(3,:).^2);
            Ox(1,:) = Ox(1,:)./MOx; % normalize
            Ox(2,:) = Ox(2,:)./MOx;
            Ox(3,:) = Ox(3,:)./MOx;
            % ---------------------
            Oy(1,:) = nvec(2,:).*Ox(3,:) - Ox(2,:).*nvec(3,:);
            Oy(2,:) = nvec(3,:).*Ox(1,:) - Ox(3,:).*nvec(1,:);
            Oy(3,:) = nvec(1,:).*Ox(2,:) - Ox(1,:).*nvec(2,:);
            MOy     = sqrt(Oy(1,:).^2 + Oy(2,:).^2 + Oy(3,:).^2);
            Oy(1,:) = Oy(1,:)./MOy; % normalize
            Oy(2,:) = Oy(2,:)./MOy;
            Oy(3,:) = Oy(3,:)./MOy;
            % ------------------------Transformation (Flating)-------------
            flatnode = zeros(2,nbNo_inFa,nbFace);
            % 1/ point 1
            flatnode(1,1,:) = 0;
            flatnode(2,1,:) = 0;
            % 2/ point 2
            flatnode(1,2,:) = MOx;
            flatnode(2,2,:) = 0;
            % 3/ point 3 -> nbNo_inFa
            for i = 3:nbNo_inFa
                p1pi(1,:) = node_(1,face_(i,:)) - node_(1,face_(1,:));
                p1pi(2,:) = node_(2,face_(i,:)) - node_(2,face_(1,:));
                p1pi(3,:) = node_(3,face_(i,:)) - node_(3,face_(1,:));
                flatnode(1,i,:) = Ox(1,:).*p1pi(1,:) + Ox(2,:).*p1pi(2,:) + Ox(3,:).*p1pi(3,:);
                flatnode(2,i,:) = Oy(1,:).*p1pi(1,:) + Oy(2,:).*p1pi(2,:) + Oy(3,:).*p1pi(3,:);
            end
            % -------------------------------------------------------------
            obj.flat_node = flatnode;
        end
        % -----------------------------------------------------------------
    end
    % --- Methods - Meshds/Discrete
    methods
        % -----------------------------------------------------------------
        function obj = build_meshds(obj,args)

            arguments
                obj
                % ---
                args.get {mustBeMember(args.get,...
                    {'all','edge','face','celem','cface','cedge','id_edge_in_elem',...
                    'ori_edge_in_elem','sign_edge_in_elem','id_face_in_elem',...
                    'ori_face_in_elem','sign_face_in_elem','id_edge_in_face',...
                    'ori_edge_in_face','sign_edge_in_face'})} = 'all'
            end
            %--------------------------------------------------------------
            if obj.build_meshds_done
                return
            end
            %--------------------------------------------------------------
            tic
            f_fprintf(0,'Make #meshds \n');
            fprintf('   ');
            % ---
            get = args.get;
            % ---
            node_ = obj.node;
            elem_ = obj.elem;
            elem_type_ = obj.elem_type;
            nb_elem_ = size(elem_,2);
            refelem_ = obj.refelem;
            nbNo_inEl = refelem_.nbNo_inEl;
            nbFa_inEl = refelem_.nbFa_inEl;
            nbEd_inFa = refelem_.nbEd_inFa;
            nbNo_inEd = refelem_.nbNo_inEd;
            siNo_inEd = refelem_.siNo_inEd;
            nbEd_inEl = refelem_.nbEd_inEl;
            %--------------------------------------------------------------
            %----- barrycenter
            all_get = {'all','celem'};
            if any(f_strcmpi(get,all_get))
                if isempty(obj.celem)
                    dim_ = size(node_,1);
                    obj.celem = mean(reshape(node_(:,elem_(1:nbNo_inEl,:)),dim_,nbNo_inEl,nb_elem_),2);
                    obj.celem = squeeze(obj.celem);
                end
            end
            %--------------------------------------------------------------
            %----- edges
            all_get = {'all','edge','id_edge_in_elem'};
            if any(f_strcmpi(get,all_get))
                if isempty(obj.edge)
                    obj.edge = f_edge(elem_,'elem_type',elem_type_);
                end
                if isempty(obj.meshds.id_edge_in_elem)
                    [id_edge_in_elem, ori_edge_in_elem, sign_edge_in_elem] = ...
                        f_edgeinelem(elem_,obj.edge,'elem_type',elem_type_);
                    % ---
                    obj.meshds.id_edge_in_elem   = id_edge_in_elem;
                    obj.meshds.ori_edge_in_elem  = ori_edge_in_elem;
                    obj.meshds.sign_edge_in_elem = sign_edge_in_elem;
                end
            end
            % ---
            all_get = {'all','cedge'};
            if any(f_strcmpi(get,all_get))
                if isempty(obj.edge)
                    obj.edge = f_edge(elem_,'elem_type',elem_type_);
                end
                if isempty(obj.cedge)
                    edge_ = obj.edge;
                    nb_edge_ = size(edge_,2);
                    dim_ = size(node_,1);
                    obj.cedge = mean(reshape(node_(:,edge_(1:nbNo_inEd,:)),dim_,nbNo_inEd,nb_edge_),2);
                    obj.cedge = squeeze(obj.cedge);
                end
            end
            %--------------------------------------------------------------
            %----- faces
            all_get = {'all','face','sign_face_in_elem'};
            if any(f_strcmpi(get,all_get))
                if isempty(obj.face)
                    obj.face = f_face(elem_,'elem_type',elem_type_);
                end
                % ---
                if isempty(obj.meshds.id_face_in_elem) || isempty(obj.meshds.sign_face_in_elem)
                    [id_face_in_elem, ori_face_in_elem, sign_face_in_elem] = ...
                        f_faceinelem(elem_,node_,obj.face,'elem_type',elem_type_);
                    % ---
                    obj.meshds.id_face_in_elem   = id_face_in_elem;
                    obj.meshds.ori_face_in_elem  = ori_face_in_elem;
                    obj.meshds.sign_face_in_elem = sign_face_in_elem;
                end
            end
            % ---
            all_get = {'all','cface'};
            if any(f_strcmpi(get,all_get))
                if isempty(obj.face)
                    obj.face = f_face(elem_,'elem_type',elem_type_);
                end
                if isempty(obj.cface)
                    dim_ = size(node_,1);
                    [filface,id_face_] = f_filterface(obj.face);
                    obj.cface = zeros(dim_,size(obj.face,2));
                    for i = 1:length(filface)
                        face_ = filface{i};
                        nb_face_ = size(face_,2);
                        nbNo_inFa = size(face_,1);
                        obj.cface(:,id_face_{i}) = squeeze(mean(reshape(node_(:,face_(1:nbNo_inFa,:)),dim_,nbNo_inFa,nb_face_),2));
                    end
                end
            end
            %--------------------------------------------------------------
            %----- edge/face
            all_get = {'all','id_edge_in_face','edge_in_face'};
            if any(f_strcmpi(get,all_get))
                % ---
                if isempty(obj.edge)
                    obj.edge = f_edge(elem_,'elem_type',elem_type_);
                end
                % ---
                if isempty(obj.face)
                    obj.face = f_face(elem_,'elem_type',elem_type_);
                end
                % ---
                if isempty(obj.meshds.id_edge_in_face) || isempty(obj.meshds.sign_edge_in_face)
                    [id_edge_in_face, ori_edge_in_face, sign_edge_in_face] = ...
                        f_edgeinface(obj.face,obj.edge);
                    % ---
                    obj.meshds.id_edge_in_face   = id_edge_in_face;
                    obj.meshds.ori_edge_in_face  = ori_edge_in_face;
                    obj.meshds.sign_edge_in_face = sign_edge_in_face;
                end
                % ---
            end
            %--------------------------------------------------------------
            all_get = {'all'};
            if any(f_strcmpi(get,all_get))
                obj.build_meshds_done = 1;
            end
            %--------------------------------------------------------------
            %--- Log message
            f_fprintf(0,'--- in',...
                1,toc, ...
                0,'s \n');
        end
        function obj = build_discrete(obj,args)
            arguments
                obj
                % ---
                args.get {mustBeMember(args.get,...
                    {'all','div','grad','curl'})} = 'all'
            end
            %--------------------------------------------------------------
            if obj.build_discrete_done
                return
            end
            %--------------------------------------------------------------
            tic
            f_fprintf(0,'Make #discrete \n');
            fprintf('   ');
            % ---
            get = args.get;
            % ---
            node_ = obj.node;
            elem_ = obj.elem;
            elem_type_ = obj.elem_type;
            nb_elem_ = size(elem_,2);
            refelem_ = obj.refelem;
            nbNo_inEl = refelem_.nbNo_inEl;
            nbFa_inEl = refelem_.nbFa_inEl;
            nbEd_inFa = refelem_.nbEd_inFa;
            nbNo_inEd = refelem_.nbNo_inEd;
            siNo_inEd = refelem_.siNo_inEd;
            nbEd_inEl = refelem_.nbEd_inEl;
            %--------------------------------------------------------------
            %----- Discrete Div
            all_get = {'all','div'};
            if any(f_strcmpi(get,all_get))
                % ---
                if isempty(obj.face)
                    obj.face = f_face(elem_,'elem_type',elem_type_);
                end
                % ---
                if isempty(obj.meshds.id_face_in_elem) || isempty(obj.meshds.sign_face_in_elem)
                    [id_face_in_elem, ori_face_in_elem, sign_face_in_elem] = ...
                        f_faceinelem(elem_,node_,obj.face,'elem_type',elem_type_);
                    % ---
                    obj.meshds.id_face_in_elem   = id_face_in_elem;
                    obj.meshds.ori_face_in_elem  = ori_face_in_elem;
                    obj.meshds.sign_face_in_elem = sign_face_in_elem;
                end
                % ---
                nbElem = size(obj.elem, 2);
                nbFace = size(obj.face, 2);
                % ---
                obj.discrete.div = sparse(nbElem,nbFace);
                for i = 1:nbFa_inEl
                    obj.discrete.div = obj.discrete.div + ...
                        sparse(1:nbElem,obj.meshds.id_face_in_elem(i,:),obj.meshds.sign_face_in_elem(i,:),nbElem,nbFace);
                end
                % ---
                clear id_face_in_elem ori_face_in_elem sign_face_in_elem
            end
            %--------------------------------------------------------------
            %----- Discrete Rot
            all_get = {'all','rot','curl'};
            if any(f_strcmpi(get,all_get))
                if any(f_strcmpi(elem_type_,{'tri', 'triangle', 'quad'}))
                    % ---
                    if isempty(obj.edge)
                        obj.edge = f_edge(elem_,'elem_type',elem_type_);
                    end
                    % ---
                    if isempty(obj.meshds.id_edge_in_elem) || isempty(obj.meshds.sign_edge_in_elem)
                        [id_edge_in_elem, ori_edge_in_elem, sign_edge_in_elem] = ...
                            f_edgeinelem(elem_,node_,obj.edge,'elem_type',elem_type_);
                        % ---
                        obj.meshds.id_edge_in_elem   = id_edge_in_elem;
                        obj.meshds.ori_edge_in_elem  = ori_edge_in_elem;
                        obj.meshds.sign_edge_in_elem = sign_edge_in_elem;
                    end
                    % ---
                    nbElem = size(obj.elem, 2);
                    nbEdge = size(obj.edge, 2);
                    % ---
                    obj.discrete.rot = sparse(nbElem,nbEdge);
                    for i = 1:nbEd_inEl
                        obj.discrete.rot = obj.discrete.rot + ...
                            sparse(1:nbElem,obj.meshds.id_edge_in_elem(i,:),obj.meshds.sign_edge_in_elem(i,:),nbElem,nbEdge);
                    end
                    % ---
                    clear id_edge_in_elem ori_edge_in_elem sign_edge_in_elem
                else
                    % ---
                    if isempty(obj.edge)
                        obj.edge = f_edge(elem_,'elem_type',elem_type_);
                    end
                    % ---
                    if isempty(obj.face)
                        obj.face = f_face(elem_,'elem_type',elem_type_);
                    end
                    % ---
                    if isempty(obj.meshds.id_edge_in_face) || isempty(obj.meshds.sign_edge_in_face)
                        [id_edge_in_face, ori_edge_in_face, sign_edge_in_face] = ...
                            f_edgeinface(obj.face,obj.edge);
                        % ---
                        obj.meshds.id_edge_in_face   = id_edge_in_face;
                        obj.meshds.ori_edge_in_face  = ori_edge_in_face;
                        obj.meshds.sign_edge_in_face = sign_edge_in_face;
                    end
                    % ---
                    nbEdge = size(obj.edge, 2);
                    nbFace = size(obj.face, 2);
                    %------------------------------------------------------
                    maxnbNo_inFa = size(obj.face,1);
                    itria = [];
                    iquad = [];
                    if maxnbNo_inFa == 3
                        itria = 1:nbFace;
                        iquad = [];
                    elseif maxnbNo_inFa == 4
                        itria = find(obj.face(4,:) == 0);
                        iquad = setdiff(1:nbFace,itria);
                    end
                    % ---
                    obj.discrete.rot = sparse(nbFace,nbEdge);
                    for k = 1:2 %---- 2 faceType
                        switch k
                            case 1
                                iface = itria;
                            case 2
                                iface = iquad;
                        end
                        for i = 1:nbEd_inFa{k}
                            obj.discrete.rot = obj.discrete.rot + ...
                                sparse(iface,obj.meshds.id_edge_in_face(i,iface),obj.meshds.sign_edge_in_face(i,iface),nbFace,nbEdge);
                        end
                    end
                    clear id_edge_in_face sign_edge_in_face
                end
            end
            %--------------------------------------------------------------
            %----- Discrete Grad
            all_get = {'all','grad'};
            if any(f_strcmpi(get,all_get))
                if isempty(obj.edge)
                    obj.edge = f_edge(elem_,'elem_type',elem_type_);
                end
                nbNode = size(obj.node, 2);
                nbEdge = size(obj.edge, 2);
                % ---
                obj.discrete.grad = sparse(nbEdge,nbNode);
                for i = 1:nbNo_inEd
                    obj.discrete.grad = obj.discrete.grad + ...
                        sparse(1:nbEdge,obj.edge(i,:),siNo_inEd(i),nbEdge,nbNode);
                end
            end
            %--------------------------------------------------------------
            all_get = {'all'};
            if any(f_strcmpi(get,all_get))
                obj.build_discrete_done = 1;
            end
            %--------------------------------------------------------------
            %--- Log message
            f_fprintf(0,'--- in',...
                1,toc, ...
                0,'s \n');
        end
        % -----------------------------------------------------------------
    end
    % --- Methods - Intkit
    methods
        % -----------------------------------------------------------------
        function obj = build_intkit(obj)
            %--------------------------------------------------------------
            if obj.build_intkit_done
                return
            end
            %--------------------------------------------------------------
            tic
            f_fprintf(0,'Make #intkit \n');
            fprintf('   ');
            %--------------------------------------------------------------
            U   = [];
            V   = [];
            W   = [];
            cU  = [];
            cV  = [];
            cW  = [];
            %--------------------------------------------------------------
            refelem_ = obj.refelem;
            U  = refelem_.U;
            V  = refelem_.V;
            W  = refelem_.W;
            cU = refelem_.cU;
            cV = refelem_.cV;
            cW = refelem_.cW;
            %--------------------------------------------------------------
            fnmeshds = fieldnames(obj.meshds);
            for i = 1:length(fnmeshds)
                if isempty(obj.meshds.(fnmeshds{i}))
                    obj.build_meshds;
                    break
                end
            end
            %--------------------------------------------------------------
            for3d = 0;
            dim_   = 2;
            if size(obj.node,1) == 3
                for3d = 1;
                dim_   = 3;
            end
            %--------------------------------------------------------------
            % Center
            [cdetJ, cJinv] = obj.jacobien('u',cU,'v',cV,'w',cW);
            cWn = obj.wn('u',cU,'v',cV,'w',cW);
            [cgradWn, cgradF] = obj.gradwn('u',cU,'v',cV,'w',cW,'jinv',cJinv,'get','gradF');
            cWe = obj.we('u',cU,'v',cV,'w',cW,'wn',cWn,'gradf',cgradF,'jinv',cJinv);
            cWf = obj.wf('u',cU,'v',cV,'w',cW,'wn',cWn,'gradf',cgradF,'jinv',cJinv);
            cWv = obj.wv('cdetJ',cdetJ);
            %--------------------------------------------------------------
            obj.build_meshds('get','celem');
            %--------------------------------------------------------------
            % Gauss points
            [detJ, Jinv] = obj.jacobien('u',U,'v',V,'w',W);
            Wn = obj.wn('u',U,'v',V,'w',W);
            [gradWn, gradF] = obj.gradwn('u',U,'v',V,'w',W,'jinv',Jinv,'get','gradF');
            We = obj.we('u',U,'v',V,'w',W,'wn',Wn,'gradf',gradF,'jinv',Jinv);
            Wf = obj.wf('u',U,'v',V,'w',W,'wn',Wn,'gradf',gradF,'jinv',Jinv);
            %--------------------------------------------------------------
            nbNo_inEl = refelem_.nbNo_inEl;
            realx = (reshape(obj.node(1,obj.elem),nbNo_inEl,[])).';
            realy = (reshape(obj.node(2,obj.elem),nbNo_inEl,[])).';
            if for3d
                realz = (reshape(obj.node(3,obj.elem),nbNo_inEl,[])).';
            end
            nb_inode  = length(U);
            node_g = cell(1,nb_inode);
            for i = 1:nb_inode
                node_g{i} = zeros(obj.nb_elem,dim_);
                node_g{i}(:,1) = sum(Wn{i} .* realx,2);
                node_g{i}(:,2) = sum(Wn{i} .* realy,2);
                if for3d
                    node_g{i}(:,3) = sum(Wn{i} .* realz,2);
                end
            end
            %--------------------------------------------------------------
            % --- Outputs
            obj.intkit.cdetJ = cdetJ;
            obj.intkit.cJinv = cJinv;
            obj.intkit.cWn = cWn;
            obj.intkit.cgradWn = cgradWn;
            obj.intkit.cWe = cWe;
            obj.intkit.cWf = cWf;
            obj.intkit.cWv = cWv;
            obj.intkit.cnode{1} = obj.celem.';
            % ---
            obj.intkit.detJ = detJ;
            obj.intkit.Jinv = Jinv;
            obj.intkit.Wn = Wn;
            obj.intkit.gradWn = gradWn;
            obj.intkit.We = We;
            obj.intkit.Wf = Wf;
            obj.intkit.node = node_g;
            %--------------------------------------------------------------
            obj.build_intkit_done = 1;
            %--------------------------------------------------------------
            %--- Log message
            f_fprintf(0,'--- in',...
                1,toc, ...
                0,'s \n');
        end
        % -----------------------------------------------------------------
        function node_g = get_gaussnode(obj,node)
            %--------------------------------------------------------------
            if nargin <= 1
                node = obj.node;
            end
            %--------------------------------------------------------------
            refelem_ = obj.refelem;
            U = refelem_.U;
            V = refelem_.V;
            W = refelem_.W;
            %--------------------------------------------------------------
            obj.build_meshds;
            %--------------------------------------------------------------
            for3d = 0;
            dim_   = 2;
            if size(node,1) == 3
                for3d = 1;
                dim_   = 3;
            end
            %--------------------------------------------------------------
            % Gauss points
            Wn = obj.wn('u',U,'v',V,'w',W);
            %--------------------------------------------------------------
            nbNo_inEl = refelem_.nbNo_inEl;
            realx = (reshape(node(1,obj.elem),nbNo_inEl,[])).';
            realy = (reshape(node(2,obj.elem),nbNo_inEl,[])).';
            if for3d
                realz = (reshape(node(3,obj.elem),nbNo_inEl,[])).';
            end
            nb_inode  = length(U);
            node_g = cell(1,nb_inode);
            for i = 1:nb_inode
                node_g{i} = zeros(obj.nb_elem,dim_);
                node_g{i}(:,1) = sum(Wn{i} .* realx,2);
                node_g{i}(:,2) = sum(Wn{i} .* realy,2);
                if for3d
                    node_g{i}(:,3) = sum(Wn{i} .* realz,2);
                end
            end
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end
    % --- Methods - Prokit
    methods
        % -----------------------------------------------------------------
        function obj = build_prokit(obj)
            %--------------------------------------------------------------
            if obj.build_prokit_done
                return
            end
            %--------------------------------------------------------------
            tic
            f_fprintf(0,'Make #prokit \n');
            fprintf('   ');
            %--------------------------------------------------------------
            refelem_ = obj.refelem;
            U = refelem_.iU;
            V = refelem_.iV;
            W = refelem_.iW;
            %--------------------------------------------------------------
            fnmeshds = fieldnames(obj.meshds);
            for i = 1:length(fnmeshds)
                if isempty(obj.meshds.(fnmeshds{i}))
                    obj.build_meshds;
                    break
                end
            end
            %--------------------------------------------------------------
            [detJ, Jinv] = obj.jacobien('u',U,'v',V,'w',W);
            Wn = obj.wn('u',U,'v',V,'w',W);
            [gradWn, gradF] = obj.gradwn('u',U,'v',V,'w',W,'jinv',Jinv,'get','gradF');
            We = obj.we('u',U,'v',V,'w',W,'wn',Wn,'gradf',gradF,'jinv',Jinv);
            Wf = obj.wf('u',U,'v',V,'w',W,'wn',Wn,'gradf',gradF,'jinv',Jinv);
            %--------------------------------------------------------------
            for3d = 0;
            dim_   = 2;
            if size(obj.node,1) == 3
                for3d = 1;
                dim_   = 3;
            end
            %--------------------------------------------------------------------------
            nbNo_inEl = refelem_.nbNo_inEl;
            realx = (reshape(obj.node(1,obj.elem),nbNo_inEl,[])).';
            realy = (reshape(obj.node(2,obj.elem),nbNo_inEl,[])).';
            if for3d
                realz = (reshape(obj.node(3,obj.elem),nbNo_inEl,[])).';
            end
            nb_inode  = length(U);
            node_i = cell(1,nb_inode);
            for i = 1:nb_inode
                node_i{i} = zeros(obj.nb_elem,dim_);
                node_i{i}(:,1) = sum(Wn{i} .* realx,2);
                node_i{i}(:,2) = sum(Wn{i} .* realy,2);
                if for3d
                    node_i{i}(:,3) = sum(Wn{i} .* realz,2);
                end
            end
            %--------------------------------------------------------------
            % --- Outputs
            obj.prokit.detJ = detJ;
            obj.prokit.Jinv = Jinv;
            obj.prokit.Wn = Wn;
            obj.prokit.gradWn = gradWn;
            obj.prokit.We = We;
            obj.prokit.Wf = Wf;
            obj.prokit.node = node_i;
            %--------------------------------------------------------------
            obj.build_prokit_done = 1;
            %--------------------------------------------------------------
            %--- Log message
            f_fprintf(0,'--- in',...
                1,toc, ...
                0,'s \n');
        end
        % -----------------------------------------------------------------
        function node_i = get_interpnode(obj,node)
            %--------------------------------------------------------------
            if nargin <= 1
                node = obj.node;
            end
            %--------------------------------------------------------------
            refelem_ = obj.refelem;
            U = refelem_.iU;
            V = refelem_.iV;
            W = refelem_.iW;
            %--------------------------------------------------------------
            obj.build_meshds;
            %--------------------------------------------------------------
            for3d = 0;
            dim_   = 2;
            if size(node,1) == 3
                for3d = 1;
                dim_   = 3;
            end
            %--------------------------------------------------------------
            % Interpolation points
            Wn = obj.wn('u',U,'v',V,'w',W);
            %--------------------------------------------------------------
            nbNo_inEl = refelem_.nbNo_inEl;
            realx = (reshape(node(1,obj.elem),nbNo_inEl,[])).';
            realy = (reshape(node(2,obj.elem),nbNo_inEl,[])).';
            if for3d
                realz = (reshape(node(3,obj.elem),nbNo_inEl,[])).';
            end
            nb_inode  = length(U);
            node_i = cell(1,nb_inode);
            for i = 1:nb_inode
                node_i{i} = zeros(obj.nb_elem,dim_);
                node_i{i}(:,1) = sum(Wn{i} .* realx,2);
                node_i{i}(:,2) = sum(Wn{i} .* realy,2);
                if for3d
                    node_i{i}(:,3) = sum(Wn{i} .* realz,2);
                end
            end
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end
    % --- Methods - Check
    methods
        % -----------------------------------------------------------------
        function check_meshds(obj)
            % ---
            elem_type_ = obj.elem_type;
            %--------------------------------------------------------------
            if any(f_strcmpi(elem_type_,{'tri', 'triangle', 'quad'}))
                if ~isempty(obj.discrete.div) && ~isempty(obj.discrete.rot)
                    if any(any(obj.discrete.div - obj.discrete.rot))
                        if any(any(obj.discrete.div - (- obj.discrete.rot)))
                            error([mfilename ': error on mesh entry, Div and Rot are not equal!']);
                        end
                    end
                end
                % ---
                if ~isempty(obj.discrete.rot) && ~isempty(obj.discrete.grad)
                    if any(any(obj.discrete.rot * obj.discrete.grad))
                        error([mfilename ': error on mesh entry, RotGrad is not null !']);
                    end
                end
                %----------------------------------------------------------
                %--- Log message
                f_fprintf(0,'--- check',1,'ok',0,'\n');
            else
                if ~isempty(obj.discrete.div) && ~isempty(obj.discrete.rot)
                    if any(any(obj.discrete.div * obj.discrete.rot))
                        error([mfilename ': error on mesh entry, DivRot is not null !']);
                    end
                end
                % ---
                if ~isempty(obj.discrete.rot) && ~isempty(obj.discrete.grad)
                    if any(any(obj.discrete.rot * obj.discrete.grad))
                        error([mfilename ': error on mesh entry, RotGrad is not null !']);
                    end
                end
                %----------------------------------------------------------
                %--- Log message
                f_fprintf(0,'--- check',1,'ok',0,'\n');
            end
        end
        % ---
        function check_discrete(obj)
            % ---
            elem_type_ = obj.elem_type;
            %--------------------------------------------------------------
            if any(f_strcmpi(elem_type_,{'tri', 'triangle', 'quad'}))
                if ~isempty(obj.discrete.div) && ~isempty(obj.discrete.rot)
                    if any(any(obj.discrete.div - obj.discrete.rot))
                        if any(any(obj.discrete.div - (- obj.discrete.rot)))
                            error([mfilename ': error on mesh entry, Div and Rot are not equal!']);
                        end
                    end
                end
                % ---
                if ~isempty(obj.discrete.rot) && ~isempty(obj.discrete.grad)
                    if any(any(obj.discrete.rot * obj.discrete.grad))
                        error([mfilename ': error on mesh entry, RotGrad is not null !']);
                    end
                end
                %----------------------------------------------------------
                %--- Log message
                f_fprintf(0,'--- check',1,'ok',0,'\n');
            else
                if ~isempty(obj.discrete.div) && ~isempty(obj.discrete.rot)
                    if any(any(obj.discrete.div * obj.discrete.rot))
                        error([mfilename ': error on mesh entry, DivRot is not null !']);
                    end
                end
                % ---
                if ~isempty(obj.discrete.rot) && ~isempty(obj.discrete.grad)
                    if any(any(obj.discrete.rot * obj.discrete.grad))
                        error([mfilename ': error on mesh entry, RotGrad is not null !']);
                    end
                end
                %----------------------------------------------------------
                %--- Log message
                f_fprintf(0,'--- check',1,'ok',0,'\n');
            end
        end
        % -----------------------------------------------------------------
    end
    % --- Methods - Shape fun
    methods
        % -----------------------------------------------------------------
        function Wn = wn(obj,args)
            arguments
                obj
                args.u = []
                args.v = []
                args.w = []
            end
            % ---
            u = args.u;
            v = args.v;
            w = args.w;
            %--------------------------------------------------------------
            elem_ = obj.elem;
            elem_type_ = obj.elem_type;
            %--------------------------------------------------------------
            if ~isempty(w)
                if (numel(u) ~= numel(v)) || (numel(u) ~= numel(w))
                    error([mfilename ': u, v, w do not have same size !']);
                end
            else
                if (numel(u) ~= numel(v))
                    error([mfilename ': u, v do not have same size !']);
                end
            end
            %--------------------------------------------------------------
            refelem_ = obj.refelem;
            nbNo_inEl = refelem_.nbNo_inEl;
            fN = refelem_.N;
            %--------------------------------------------------------------
            nb_elem_ = size(elem_,2);
            %--------------------------------------------------------------
            Wn = cell(1,length(u));
            for i = 1:length(u)
                Wn{i} = zeros(nb_elem_,nbNo_inEl);
            end
            %--------------------------------------------------------------
            if any(f_strcmpi(elem_type_,{'tri','triangle','quad'}))
                for i = 1:length(u)
                    u_ = u(i).*ones(nb_elem_,1);
                    v_ = v(i).*ones(nb_elem_,1);
                    % ---
                    fwn = zeros(nb_elem_,nbNo_inEl);
                    for j = 1:length(fN)
                        fwn(:,j) = fN{j}(u_,v_);
                    end
                    % ---
                    Wn{i} = fwn;
                end
            elseif any(f_strcmpi(elem_type_,{'tet','tetra','prism','hex','hexa'}))
                for i = 1:length(u)
                    u_ = u(i).*ones(nb_elem_,1);
                    v_ = v(i).*ones(nb_elem_,1);
                    w_ = w(i).*ones(nb_elem_,1);
                    % ---
                    fwn = zeros(nb_elem_,nbNo_inEl);
                    for j = 1:length(fN)
                        fwn(:,j) = fN{j}(u_,v_,w_);
                    end
                    % ---
                    Wn{i} = fwn;
                end
            end
        end
        % -----------------------------------------------------------------
        function [gradWn, gradF] = gradwn(obj,args)
            arguments
                obj
                args.u = []
                args.v = []
                args.w = []
                args.jinv = []
                args.get {mustBeMember(args.get,{'','gradF','sum_on_face'})} = ''
            end
            % ---
            u = args.u;
            v = args.v;
            w = args.w;
            jinv = args.jinv;
            get = args.get;
            %--------------------------------------------------------------
            elem_ = obj.elem;
            elem_type_ = obj.elem_type;
            %--------------------------------------------------------------
            if ~isempty(w)
                if (numel(u) ~= numel(v)) || (numel(u) ~= numel(w))
                    error([mfilename ': u, v, w do not have same size !']);
                end
            else
                if (numel(u) ~= numel(v))
                    error([mfilename ': u, v do not have same size !']);
                end
            end
            %--------------------------------------------------------------
            if isempty(jinv)
                [~, jinv] = obj.jacobien('u',u,'v',v,'w',w);
            end
            %--------------------------------------------------------------
            if any(f_strcmpi(elem_type_,{'tri','triangle','quad'}))
                dim_ = 2;
                refelem_ = obj.refelem;
                nbNo_inEl = refelem_.nbNo_inEl;
                FaNo_inEl = refelem_.FaNo_inEl;
                nbFa_inEl = refelem_.nbFa_inEl;
                fgradNx = refelem_.gradNx;
                fgradNy = refelem_.gradNy;
                %----------------------------------------------------------
                nb_elem_ = size(elem_,2);
                %----------------------------------------------------------
                lenu   = length(u);
                gradWn = cell(1,lenu);
                gradF  = cell(1,lenu);
                for i = 1:length(u)
                    gradWn{i} = zeros(nb_elem_,dim_,nbNo_inEl);
                    gradF{i}  = zeros(nb_elem_,dim_,nbFa_inEl);
                end
                %----------------------------------------------------------
                for i = 1:lenu
                    u_ = u(i).*ones(1,nb_elem_);
                    v_ = v(i).*ones(1,nb_elem_);
                    % ---
                    gradNx = fgradNx(u_,v_); gradNx = gradNx.';
                    gradNy = fgradNy(u_,v_); gradNy = gradNy.';
                    % ---
                    fgradwn = zeros(nb_elem_,dim_,nbNo_inEl);
                    Jinv1 = [jinv{i}(:,1,1), jinv{i}(:,1,2)];
                    Jinv2 = [jinv{i}(:,2,1), jinv{i}(:,2,2)];
                    for j = 1:nbNo_inEl
                        gradNxy = [gradNx(:,j), gradNy(:,j)];
                        fgradwn(:,1,j) = dot(Jinv1, gradNxy, 2);
                        fgradwn(:,2,j) = dot(Jinv2, gradNxy, 2);
                    end
                    %------------------------------------------------------
                    if any(strcmpi(get,{'gradF','sum_on_face'}))
                        fgradf = zeros(nb_elem_,dim_,nbFa_inEl);
                        for j = 1:nbFa_inEl
                            nbN = length(find(FaNo_inEl(j,:)));
                            fgradf(:,:,j) = sum(fgradwn(:,:,FaNo_inEl(j,1:nbN)),3);
                        end
                    end
                    % ---
                    gradWn{i} = fgradwn;
                    gradF{i}  = fgradf;
                end
            elseif any(f_strcmpi(elem_type_,{'tet','tetra','prism','hex','hexa'}))
                dim_ = 3;
                refelem_ = obj.refelem;
                nbNo_inEl = refelem_.nbNo_inEl;
                FaNo_inEl = refelem_.FaNo_inEl;
                nbFa_inEl = refelem_.nbFa_inEl;
                fgradNx = refelem_.gradNx;
                fgradNy = refelem_.gradNy;
                fgradNz = refelem_.gradNz;
                %----------------------------------------------------------
                nb_elem_ = size(elem_,2);
                %----------------------------------------------------------
                lenu   = length(u);
                gradWn = cell(1,lenu);
                gradF  = cell(1,lenu);
                for i = 1:length(u)
                    gradWn{i} = zeros(nb_elem_,dim_,nbNo_inEl);
                    gradF{i}  = zeros(nb_elem_,dim_,nbFa_inEl);
                end
                %----------------------------------------------------------
                for i = 1:lenu
                    u_ = u(i).*ones(1,nb_elem_);
                    v_ = v(i).*ones(1,nb_elem_);
                    w_ = w(i).*ones(1,nb_elem_);
                    % ---
                    gradNx = fgradNx(u_,v_,w_); gradNx = gradNx.';
                    gradNy = fgradNy(u_,v_,w_); gradNy = gradNy.';
                    gradNz = fgradNz(u_,v_,w_); gradNz = gradNz.';
                    % ---
                    fgradwn = zeros(nb_elem_,dim_,nbNo_inEl);
                    Jinv1 = [jinv{i}(:,1,1), jinv{i}(:,1,2), jinv{i}(:,1,3)];
                    Jinv2 = [jinv{i}(:,2,1), jinv{i}(:,2,2), jinv{i}(:,2,3)];
                    Jinv3 = [jinv{i}(:,3,1), jinv{i}(:,3,2), jinv{i}(:,3,3)];
                    for j = 1:nbNo_inEl
                        gradNxyz = [gradNx(:,j), gradNy(:,j), gradNz(:,j)];
                        fgradwn(:,1,j) = dot(Jinv1, gradNxyz, 2);
                        fgradwn(:,2,j) = dot(Jinv2, gradNxyz, 2);
                        fgradwn(:,3,j) = dot(Jinv3, gradNxyz, 2);
                    end
                    %------------------------------------------------------
                    if any(f_strcmpi(get,{'gradF','sum_on_face'}))
                        fgradf = zeros(nb_elem_,dim_,nbFa_inEl);
                        for j = 1:nbFa_inEl
                            nbN = length(find(FaNo_inEl(j,:)));
                            fgradf(:,:,j) = sum(fgradwn(:,:,FaNo_inEl(j,1:nbN)),3);
                        end
                    end
                    % ---
                    gradWn{i} = fgradwn;
                    gradF{i}  = fgradf;
                end
            end
        end
        % -----------------------------------------------------------------
        function We = we(obj,args)
            arguments
                obj
                args.u = []
                args.v = []
                args.w = []
                args.wn = []
                args.jinv = []
                args.gradf = []
            end
            % ---
            u = args.u;
            v = args.v;
            w = args.w;
            wn = args.wn;
            jinv = args.jinv;
            gradf = args.gradf;
            %--------------------------------------------------------------
            elem_ = obj.elem;
            elem_type_ = obj.elem_type;
            %--------------------------------------------------------------
            ori_edge_in_elem = obj.meshds.ori_edge_in_elem;
            %--------------------------------------------------------------
            if ~isempty(w)
                if (numel(u) ~= numel(v)) || (numel(u) ~= numel(w))
                    error([mfilename ': u, v, w do not have same size !']);
                end
            else
                if (numel(u) ~= numel(v))
                    error([mfilename ': u, v do not have same size !']);
                end
            end
            %--------------------------------------------------------------
            if isempty(wn)
                wn = obj.wn('u',u,'v',v,'w',w);
            end
            %--------------------------------------------------------------
            if isempty(gradf)
                if isempty(jinv)
                    [~, gradf] = obj.gradwn('u',u,'v',v,'w',w,'get','gradF');
                else
                    [~, gradf] = obj.gradwn('u',u,'v',v,'w',w,'Jinv',jinv,'get','gradF');
                end
            end
            %--------------------------------------------------------------
            if any(f_strcmpi(elem_type_,{'tri','triangle','quad'}))
                dim_ = 2;
                refelem_ = obj.refelem;
                nbEd_inEl = refelem_.nbEd_inEl;
                EdNo_inEl = refelem_.EdNo_inEl;
                NoFa_ofEd = refelem_.NoFa_ofEd;
                %----------------------------------------------------------
                nb_elem_ = size(elem_,2);
                %----------------------------------------------------------
                We = cell(1,length(u));
                for i = 1:length(u)
                    We{i} = zeros(nb_elem_,dim_,nbEd_inEl);
                end
                %----------------------------------------------------------
                for i = 1:length(u)
                    % ---
                    fwe = zeros(nb_elem_,dim_,nbEd_inEl);
                    for j = 1:nbEd_inEl
                        fwe(:,:,j) = - (wn{i}(:,EdNo_inEl(j,1)).*gradf{i}(:,:,NoFa_ofEd(j,1)) - ...
                            wn{i}(:,EdNo_inEl(j,2)).*gradf{i}(:,:,NoFa_ofEd(j,2)))...
                            .*ori_edge_in_elem(j,:).';
                    end
                    % ---
                    We{i} = fwe;
                end
                %----------------------------------------------------------
            elseif any(f_strcmpi(elem_type_,{'tet','tetra','prism','hex','hexa'}))
                dim_ = 3;
                refelem_ = obj.refelem;
                nbEd_inEl = refelem_.nbEd_inEl;
                EdNo_inEl = refelem_.EdNo_inEl;
                NoFa_ofEd = refelem_.NoFa_ofEd;
                %----------------------------------------------------------
                nb_elem_ = size(elem_,2);
                %----------------------------------------------------------
                We = cell(1,length(u));
                for i = 1:length(u)
                    We{i} = zeros(nb_elem_,dim_,nbEd_inEl);
                end
                %----------------------------------------------------------
                for i = 1:length(u)
                    % ---
                    fwe = zeros(nb_elem_,dim_,nbEd_inEl);
                    for j = 1:nbEd_inEl
                        fwe(:,:,j) = - (wn{i}(:,EdNo_inEl(j,1)).*gradf{i}(:,:,NoFa_ofEd(j,1)) - ...
                            wn{i}(:,EdNo_inEl(j,2)).*gradf{i}(:,:,NoFa_ofEd(j,2)))...
                            .*ori_edge_in_elem(j,:).';
                    end
                    % ---
                    We{i} = fwe;
                end
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function Wf = wf(obj,args)
            arguments
                obj
                args.u = []
                args.v = []
                args.w = []
                args.wn = []
                args.jinv = []
                args.gradf = []
                args.we = []
            end
            % ---
            u = args.u;
            v = args.v;
            w = args.w;
            wn = args.wn;
            jinv = args.jinv;
            gradf = args.gradf;
            we = args.we;
            %--------------------------------------------------------------
            elem_ = obj.elem;
            %--------------------------------------------------------------
            elem_type_ = obj.elem_type;
            %--------------------------------------------------------------
            ori_face_in_elem = obj.meshds.ori_face_in_elem;
            %--------------------------------------------------------------
            if ~isempty(w)
                if (numel(u) ~= numel(v)) || (numel(u) ~= numel(w))
                    error([mfilename ': u, v, w do not have same size !']);
                end
            else
                if (numel(u) ~= numel(v))
                    error([mfilename ': u, v do not have same size !']);
                end
            end
            %--------------------------------------------------------------
            if isempty(wn)
                wn = obj.wn('u',u,'v',v,'w',w);
            end
            %--------------------------------------------------------------
            if isempty(gradf)
                if isempty(jinv)
                    [~, gradf] = obj.gradwn('u',u,'v',v,'w',w,'get','gradF');
                else
                    [~, gradf] = obj.gradwn('u',u,'v',v,'w',w,'Jinv',jinv,'get','gradF');
                end
            end
            %--------------------------------------------------------------
            if any(f_strcmpi(elem_type_,{'tri','triangle','quad'}))
                %----------------------------------------------------------
                if isempty(we)
                    we = obj.we('u',u,'v',v,'w',w,'wn',wn,'gradf',gradf,'jinv',jinv);
                end
                %----------------------------------------------------------
                dim_ = 2;
                refelem_ = obj.refelem;
                nbFa_inEl = refelem_.nbFa_inEl;
                %----------------------------------------------------------
                nb_elem_ = size(elem_,2);
                %----------------------------------------------------------
                Wf = cell(1,length(u));
                for i = 1:length(u)
                    Wf{i} = zeros(nb_elem_,dim_,nbFa_inEl);
                end
                %----------------------------------------------------------
                if nb_elem_ == 1
                    for i = 1:length(u)
                        Wf{i}(1,1,:) = - squeeze(we{i}(:,2,:)).' .* ori_face_in_elem(:,:).';
                        Wf{i}(1,2,:) =   squeeze(we{i}(:,1,:)).' .* ori_face_in_elem(:,:).';
                    end
                else
                    for i = 1:length(u)
                        Wf{i}(:,1,:) = - squeeze(we{i}(:,2,:)) .* ori_face_in_elem(:,:).';
                        Wf{i}(:,2,:) =   squeeze(we{i}(:,1,:)) .* ori_face_in_elem(:,:).';
                    end
                end

                %----------------------------------------------------------
            elseif any(f_strcmpi(elem_type_,{'tet','tetra','prism','hex','hexa'}))
                dim_ = 3;
                refelem_ = obj.refelem;
                nbFa_inEl = refelem_.nbFa_inEl;
                nbNo_inFa = refelem_.nbNo_inFa;
                FaNo_inEl = refelem_.FaNo_inEl;
                NoFa_ofFa = refelem_.NoFa_ofFa;
                %----------------------------------------------------------
                nb_elem_ = size(elem_,2);
                %----------------------------------------------------------
                Wf = cell(1,length(u));
                for i = 1:length(u)
                    Wf{i} = zeros(nb_elem_,dim_,nbFa_inEl);
                end
                %----------------------------------------------------------
                for i = 1:length(u)
                    %------------------------------------------------------
                    nbNodemax = max(nbNo_inFa);
                    % ---
                    gradFxgradF = cell(nbNodemax,1);
                    % ---
                    for j = 1:nbNodemax
                        gradFxgradF{j} = zeros(nb_elem_,dim_,nbFa_inEl);
                    end
                    for j = 1:nbFa_inEl
                        for k = 1:nbNo_inFa(j)
                            knext = mod(k + 1,nbNo_inFa(j));
                            if knext == 0
                                knext = nbNo_inFa(j);
                            end
                            %-----
                            gradFk = gradf{i}(:,:,NoFa_ofFa(j,k));
                            gradFknext = gradf{i}(:,:,NoFa_ofFa(j,knext));
                            %-----
                            gradFxgradF{k}(:,:,j) = cross(gradFk,gradFknext,2);
                        end
                    end
                    %------------------------------------------------------
                    fwf = zeros(nb_elem_,dim_,nbFa_inEl);
                    for j = 1:nbFa_inEl
                        Wfxyz = zeros(nb_elem_,dim_);
                        for k = 1:nbNo_inFa(j)
                            Wfxyz = Wfxyz + ...
                                wn{i}(:,FaNo_inEl(j,k)).*gradFxgradF{k}(:,:,j);
                        end
                        fwf(:,:,j) = (5 - nbNo_inFa(j)) .* Wfxyz .* ori_face_in_elem(j,:).';
                    end
                    % ---
                    Wf{i} = fwf;
                end
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function Wv = wv(obj,args)
            arguments
                obj
                args.cdetJ = [];
            end
            % ---
            cdetJ = args.cdetJ;
            %--------------------------------------------------------------
            elem_type_ = obj.elem_type;
            %--------------------------------------------------------------
            node_ = obj.node;
            elem_ = obj.elem;
            %--------------------------------------------------------------
            if any(f_strcmpi(elem_type_,{'tri','triangle','quad'}))
                Wv{1} = 1./f_area(node_,elem_,'elem_type',elem_type_,'cdetJ',cdetJ);
            elseif any(f_strcmpi(elem_type_,{'tet','tetra','prism','hex','hexa'}))
                Wv{1} = 1./f_volume(node_,elem_,'elem_type',elem_type_,'cdetJ',cdetJ);
            end
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function [detJ, Jinv] = jacobien(obj,args)
            arguments
                obj
                args.u = []
                args.v = []
                args.w = []
            end
            % ---
            u = args.u;
            v = args.v;
            w = args.w;
            %--------------------------------------------------------------
            [detJ, Jinv] = f_jacobien(obj.node,obj.elem, ...
                'elem_type',obj.elem_type,...
                'u',u,'v',v,'w',w,'flat_node',obj.flat_node);
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end
    % --- Methods - Plot
    methods
        % -----------------------------------------------------------------
        function plot(obj,varargin)
            if isempty(obj.node) || isempty(obj.elem)
                f_fprintf(1,'An empty Mesh object',0,'\n');
            else
                f_fprintf(1,'A Mesh object',0,'\n');
            end
        end
        % -----------------------------------------------------------------
    end
    % --- Methods - Obj
    methods (Access = public)
        % ---
        function objx = uplus(obj)
            objx = copy(obj);
        end
        % ---
        function objx = ctranspose(obj)
            objx = copy(obj);
        end
        % ---
    end
    % --- Methods - Obj
    methods (Access = protected)
        function newmesh = copyElement(obj)
            newmesh = copyElement@matlab.mixin.Copyable(obj);
            % ---
            alldom = fieldnames(obj.dom);
            % ---
            for i = 1:length(alldom)
                newmesh.dom.(alldom{i}) = copy(obj.dom.(alldom{i}));
                newmesh.dom.(alldom{i}).parent_mesh = newmesh;
            end
        end
    end
end

