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

classdef TriMeshFromPDETool < TriMesh
    properties
        shape
        hgrad = 1.3
        hmax = 0
    end
    properties (Hidden)
        version = 'R2013a'
    end
    properties %(Access = private)
        shape_gd
        mesh_gd
        petds
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
            argslist = {'id','node','elem','shape'};
        end
    end
    % --- Constructors
    methods
        function obj = TriMeshFromPDETool(args)
            arguments
                % --- super
                args.id
                args.node
                args.elem
                % ---
                args.shape
                args.hgrad = 1.3
                args.hmax = 0
            end
            % --- super
            obj@TriMesh;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            if args.hgrad <= 1 || args.hgrad >= 2
                args.hgrad = 1.3;
            end
            % ---
            args.shape = f_to_scellargin(args.shape);
            % ---
            obj <= args;
            % ---
            TriMeshFromPDETool.setup(obj);
            % ---
        end
    end

    % --- setup/reset/build
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
            if isempty(obj.shape)
                return
            end
            % ---
            sh2d = f_to_scellargin(obj.shape);
            shape_gd = [];
            for i = 1:length(sh2d)
                shape_gd = obj.add_geodesc(shape_gd,sh2d{i}.geodesc);
            end
            % ---
            obj.shape_gd = shape_gd;
            obj.mesh_gd  = decsg(obj.shape_gd);
            % --- meshing
            [p,e,t] = initmesh(obj.mesh_gd,"MesherVersion",obj.version,...
                               "Hgrad",obj.hgrad,"Hmax",obj.hmax);
            % ---
            obj.getmesh(p,e,t);
            % ---
        end
        % -----------------------------------------------------------------
    end
    methods (Access = public)
        function reset(obj)
            TriMeshFromPDETool.setup(obj);
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
    methods 
        function refine(obj,id_dom)
            id_dom = f_to_scellargin(id_dom);
            domlist = fieldnames(obj.dom);
            numid = [];
            for i = 1:length(id_dom)
                id_ = id_dom{i};
                if isnumeric(id_)
                    numid = [numid, id_];
                else
                    for j = 1:length(domlist)
                        domname = domlist{j};
                        if f_strcmpi(string(id_),string(domname))
                            numid = [numid, unique(obj.dom.(domname).elem_code)];
                        end
                    end
                end
            end
            % ---
            [p,e,t] = refinemesh(obj.mesh_gd, obj.petds.p, obj.petds.p, obj.petds.p, numid);
            % ---
            obj.getmesh(p,e,t);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
        function plot(obj)
            pdemesh(obj.petds.p,obj.petds.e,obj.petds.t); hold on
            pdegplot(obj.mesh_gd,"FaceLabels","on");
            axis equal; xlabel('x (m)'); ylabel('y (m)'); 
        end
    end
    methods (Access = private)
        function gdnew = add_geodesc(obj,gd1,gd2)
            l1 = length(gd1);
            l2 = length(gd2);
            if l1 ~= 0
                gd1 = [gd1; zeros(l2-l1,size(gd1,2))];
            end
            if l2 ~= 0
                gd2 = [gd2; zeros(l1-l2,size(gd2,2))];
            end
            gdnew = [gd1, gd2];
        end
        function getmesh(obj,p,e,t)
            % ---
            node_ = p;
            elem_ = t(1:3,:);
            elem_code_ = t(4,:);
            [node_,elem_] = f_reorg2d(node_,elem_);
            % ---
            obj.petds.p = p;
            obj.petds.e = e;
            obj.petds.t = t;
            % ---
            obj.node = node_;
            obj.elem = elem_;
            obj.elem_code = elem_code_;
            % --- 2d elem surface
            obj.velem = f_volume(node_,elem_,'elem_type',obj.elem_type);
            % ---
            % --- edge length
            % obj.sface = f_ledge(node_,edge_);
            % obj.ledge = obj.sface;
            % ---
            for i = 1:length(obj.shape)
                sh2d = obj.shape{i};
                id_ = sh2d.id;
                for j = 1:length(sh2d.choosed_by)
                    chby = sh2d.choosed_by{j};
                    id_elem = f_find_bounding_elem(obj.node,obj.elem,sh2d.(chby));
                    elcode = obj.elem_code(id_elem);
                    obj.add_vdom("id",id_,"elem_code",elcode);
                end
            end
            % ---
        end
    end
end