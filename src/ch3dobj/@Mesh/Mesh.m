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
        refelem
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
        % --- global coordinates
        gcoor_type {mustBeMember(gcoor_type,{'cartesian','cylindrical'})} = 'cartesian'
        move_type {mustBeMember(move_type,{'linear','rotational'})} = 'linear'
        gcoor
        move
    end

    % --- Dependent Properties
    properties (Dependent = true)
        nb_node
        nb_elem
        nb_edge
        nb_face
        % ---
        dim
        gnode
        gnode_cartesian
        gnode_cylindrical
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
            obj.intkit.detJ = {};
            obj.intkit.gradWn = {};
            obj.intkit.Jinv = {};
            obj.intkit.We = {};
            obj.intkit.Wf = {};
            obj.intkit.Wn = {};
            % ---
            obj.prokit.detJ = {};
            obj.prokit.gradWn = {};
            obj.prokit.Jinv = {};
            obj.prokit.We = {};
            obj.prokit.Wf = {};
            obj.prokit.Wn = {};
            obj.prokit.node = {};
            % ---
            obj.gcoor.origin = [];
            obj.gcoor.otheta = [];
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
        function val = get.gnode(obj)
            if f_strcmpi(obj.gcoor_type,'cartesian')
                val = obj.get_gnode_cartesian;
            elseif f_strcmpi(obj.gcoor_type,'cylindrical')
                val = obj.get_gnode_cylindrical;
            end
        end
        
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



