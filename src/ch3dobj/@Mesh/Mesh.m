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
        function lock_to_gcoor(obj,args)
            arguments
                obj
                args.gcoor_system {mustBeMember(args.gcoor_system,{'cartesian','cylindrical'})} = 'cartesian'
                args.gcoor_origin = []
                args.gcoor_otheta = []
            end
            % ---
            gcoor_system = args.gcoor_system;
            % --- for cartesian/cylindrical
            gcoor_origin = args.gcoor_origin;
            % --- for cylindrical only w/ counterclockwise convention
            gcoor_otheta = args.gcoor_otheta;
            % ---
            if f_strcmpi(gcoor_system,'cartesian')
                obj.lock_to_cartesian('gcoor_origin',gcoor_origin);
            elseif f_strcmpi(gcoor_system,'cylindrical')
                obj.lock_to_cylindrical('gcoor_origin',gcoor_origin,'gcoor_otheta',gcoor_otheta);
            end
            % ---
            obj.celem = obj.cal_celem('coordinate_system','local');
            obj.cface = obj.cal_cface('coordinate_system','local');
            obj.cedge = obj.cal_cedge('coordinate_system','local');
        end
        % -----------------------------------------------------------------
        function celem = cal_celem(obj,args)
            arguments
                obj
                args.coordinate_system {mustBeMember(args.coordinate_system,{'local','global'})} = 'global'
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
                args.coordinate_system {mustBeMember(args.coordinate_system,{'local','global'})} = 'global'
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
                args.coordinate_system {mustBeMember(args.coordinate_system,{'local','global'})} = 'global'
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
    methods (Access = private)
        % -----------------------------------------------------------------
        function lock_to_cartesian(obj,args)
            arguments
                obj
                args.gcoor_origin = []
            end
            % ---
            gcoor_origin = args.gcoor_origin;
            % ---
            if isa(obj,'Mesh2d')
                if isempty(gcoor_origin)
                    return
                elseif any(gcoor_origin ~= [0 0])
                    obj.node = obj.node - gcoor_origin.';
                end
            elseif isa(obj,'Mesh3d')
                if isempty(gcoor_origin)
                    return
                elseif any(gcoor_origin ~= [0 0 0])
                    obj.node = obj.node - gcoor_origin.';
                end
            end
        end
        % -----------------------------------------------------------------
        function lock_to_cylindrical(obj,args)
            arguments
                obj
                args.gcoor_origin = []
                args.gcoor_otheta = []
            end
            % ---
            gcoor_origin = args.gcoor_origin;
            gcoor_otheta = args.gcoor_otheta;
            % ---
            if isa(obj,'Mesh2d')
                if isempty(gcoor_origin)
                    return
                elseif any(gcoor_origin ~= [0 0])
                    node_ = obj.node - gcoor_origin.';
                end
                % ---
                if isempty(gcoor_otheta)
                    return
                elseif any(gcoor_otheta ~= [1 0])
                    otheta0 = [1 0 0];
                    otheta1 = [gcoor_otheta 0];
                    rot_axis  = cross(otheta0,otheta1);
                    rot_angle = - acosd(dot(otheta0,otheta1)/(norm(otheta0)*norm(otheta1)));
                    % ---
                    node_ = [node_; zeros(1,size(node_,2))];
                    % ---
                    node_ = f_rotaroundaxis(node_.','rot_axis',rot_axis,'angle',rot_angle);
                    % ---
                    node_ = node_.';
                    node_ = node_(1:2,:);
                end
                % ---
                obj.node = node_;
                % ---
            elseif isa(obj,'Mesh3d')
                if isempty(gcoor_origin)
                    return
                elseif any(gcoor_origin ~= [0 0 0])
                    node_ = obj.node - gcoor_origin.';
                end
                % ---
                if isempty(gcoor_otheta)
                    return
                elseif any(gcoor_otheta ~= [1 0 0])
                    otheta0 = [1 0 0];
                    otheta1 = gcoor_otheta;
                    rot_axis  = cross(otheta0,otheta1);
                    rot_angle = acosd(dot(otheta0,otheta1)/(norm(otheta0)*norm(otheta1)));
                    % ---
                    node_ = f_rotaroundaxis(node_.','rot_axis',rot_axis,'angle',rot_angle);
                    % ---
                    node_ = node_.';
                end
                % ---
                obj.node = node_;
                % ---
            end
        end
        % -----------------------------------------------------------------
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



