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
        % --- moving frame
        moving_frame {mustBeMember(moving_frame,'MovingFrame')}
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

    % --- Methods
    methods
        % --- get
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
    % --- Methods
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
    % --- Methods
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
    % --- Methods
    methods
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
                args.rot_axis_origin = [];
                args.rot_axis = [];
                args.rot_angle = 0;
            end
            % ---
            rot_axis_origin = args.rot_axis_origin;
            rot_axis   = args.rot_axis;
            rot_angle  = args.rot_angle;
            % ---
            node_ = obj.node;
            % ---
            if isa(obj,'Mesh2d')
                % ---
                if isempty(rot_axis)
                    return
                else
                    if rot_angle ~= 0
                        % ---
                        rot_axis_origin = [rot_axis_origin 0];
                        rot_axis = [rot_axis 0];
                        node_ = [node_; zeros(1,size(node_,2))];
                        % ---
                        node_ = f_rotaroundaxis(node_.', ...
                            'rot_axis_origin',rot_axis_origin, ...
                            'rot_axis',rot_axis,'rot_angle',rot_angle);
                        % ---
                        node_ = node_.';
                        node_ = node_(1:2,:);
                    end
                end
                % ---
            elseif isa(obj,'Mesh3d')
                % ---
                if isempty(rot_axis)
                    return
                else
                    if rot_angle ~= 0
                        % ---
                        node_ = f_rotaroundaxis(node_.', ...
                            'rot_axis_origin',rot_axis_origin, ...
                            'rot_axis',rot_axis,'rot_angle',rot_angle);
                        % ---
                        node_ = node_.';
                    end
                end
            end
            % ---
            obj.node = node_;
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
    end
    % --- Methods
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
end



