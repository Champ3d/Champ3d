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
        info
        node
        elem
        edge
        face
        elem_code
        elem_type
        celem
        cface
        cedge
        origin
        % ---
        id_edge_in_elem
        ori_edge_in_elem
        sign_edge_in_elem
        id_face_in_elem
        ori_face_in_elem
        sign_face_in_elem
        % ---
        id_edge_in_face
        ori_edge_in_face
        sign_edge_in_face
        % ---
        div
        grad
        rot
        % ---
        intkit
        % ---
        is_build
        % --- submesh
        parent_mesh
        gid_node
        gid_elem
        gid_edge
        gid_face
        flat_node
        % --- link
        dom2d_collection
        dom3d_collection
    end

    % --- Dependent Properties
    properties (Dependent = true)
        nb_node
        nb_elem
        nb_edge
        nb_face
    end

    % --- Constructors
    methods
        function obj = Mesh(args)
            arguments
                args.info = 'no_info';
            end
            % ---
            obj.info = args.info;
        end
    end

    % --- Methods
    methods
        % --- get
        function val = get.nb_node(obj)
            val = size(obj.node,2);
        end
        function val = get.nb_elem(obj)
            val = size(obj.elem,2);
        end
        function val = get.nb_edge(obj)
            val = size(obj.edge,2);
        end
        function val = get.nb_face(obj)
            val = size(obj.face,2);
        end
    end

    % --- Methods
    methods
        % --- get
        function plot(obj,varargin)
            if isempty(obj.node) || isempty(obj.elem)
                f_fprintf(1,'An empty Mesh object',0,'\n');
            else
                f_fprintf(1,'A Mesh object',0,'\n');
            end
        end
    end
end



