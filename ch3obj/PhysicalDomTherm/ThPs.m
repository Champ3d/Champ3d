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

classdef ThPs < PhysicalDom
    properties
        ps = 0
    end
    % --- 
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_model','id_dom3d','ps','parameter_dependency_search'};
        end
    end
    % --- Contructor
    methods
        function obj = ThPs(args)
            arguments
                args.id
                args.parent_model
                args.id_dom3d
                args.ps
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
            ThPs.setup(obj);
            % ---
        end
    end

    % --- setup/reset/build/assembly
    methods (Static)
        function setup(obj)
            % --- call utility methods
            obj.set_parameter;
            obj.get_geodom;
            obj.dom.is_defining_obj_of(obj);
            % --- Initialization
            obj.matrix.gindex = [];
            obj.matrix.gid_node_t = [];
            obj.matrix.ps_array = [];
            obj.matrix.pswn = [];
            % ---
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            ThPs.setup(obj);
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            dom = obj.dom;
            % ---
            gindex = dom.gindex;
            nb_face  = length(gindex);
            % ---
            gid_node_t = f_uniquenode(dom.parent_mesh.face(:,gindex));
            % ---
            ps_array = obj.ps.getvalue('in_dom',obj);
            ps_array = Array.tensor(ps_array,'nb_elem',nb_face);
            %--------------------------------------------------------------
            % local surface mesh
            submesh = dom.submesh;
            %--------------------------------------------------------------
            for k = 1:length(submesh)
                sm = submesh{k};
                % ---
                gindex_{k} = sm.gindex;
            end
            % --- check changes
            is_changed = 1;
            if isequal(ps_array,obj.matrix.ps_array) && ...
               isequal(gindex_,obj.matrix.gindex) && ...
               isequal(gid_node_t,obj.matrix.gid_node_t)
                is_changed = 0;
            end
            %--------------------------------------------------------------
            if ~is_changed && obj.build_done == 1
                return
            end
            %--------------------------------------------------------------
            obj.matrix.gindex = gindex_;
            obj.matrix.gid_node_t = gid_node_t;
            obj.matrix.ps_array = ps_array;
            %--------------------------------------------------------------
            % local pswn matrix
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lindex_  = sm.lindex;
                ps_sm = ps_array(lindex_);
                lmatrix{k} = sm.cwn('coefficient',ps_sm);
                % ---
            end
            %--------------------------------------------------------------
            face = obj.parent_model.parent_mesh.face;
            nb_node = obj.parent_model.parent_mesh.nb_node;
            %--------------------------------------------------------------
            % global elementary pswn matrix
            pswn = sparse(nb_node,1);
            %--------------------------------------------------------------
            gindex = obj.matrix.gindex;
            %--------------------------------------------------------------
            for igr = 1:length(lmatrix)
                nbNo_inFa = size(lmatrix{igr},2);
                id_face = gindex{igr};
                for i = 1:nbNo_inFa
                    pswn = pswn + ...
                        sparse(face(i,id_face),1,lmatrix{igr}(:,i),nb_node,1);
                end
            end
            %--------------------------------------------------------------
            obj.matrix.pswn = pswn;
            % ---
            obj.build_done = 1;
            % ---
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            %--------------------------------------------------------------
            obj.parent_model.matrix.pswn = ...
                obj.parent_model.matrix.pswn + obj.matrix.pswn;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_t = ...
                [obj.parent_model.matrix.id_node_t obj.matrix.gid_node_t];
            %--------------------------------------------------------------
        end
    end
end