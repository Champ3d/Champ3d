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

classdef Thconvection < PhysicalDom
    properties
        h = 0
    end
    % --- 
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_model','id_dom3d','h','parameter_dependency_search'};
        end
    end
    % --- Contructor
    methods
        function obj = Thconvection(args)
            arguments
                args.id
                args.parent_model
                args.id_dom3d
                args.h
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
            Thconvection.setup(obj);
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
            obj.matrix.h_array = [];
            obj.matrix.hwnwn = [];
            % ---
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            Thconvection.setup(obj);
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
            h_array = obj.h.getvalue('in_dom',obj);
            h_array = Array.tensor(h_array,'nb_elem',nb_face);
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
            if isequal(h_array,obj.matrix.h_array) && ...
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
            obj.matrix.h_array = h_array;
            %--------------------------------------------------------------
            % local hwnwn matrix
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lindex_  = sm.lindex;
                h_sm = h_array(lindex_);
                lmatrix{k} = sm.cwnwn('coefficient',h_sm);
                % ---
            end
            %--------------------------------------------------------------
            face = obj.parent_model.parent_mesh.face;
            nb_node = obj.parent_model.parent_mesh.nb_node;
            %--------------------------------------------------------------
            % global elementary hwnwn matrix
            hwnwn = sparse(nb_node,nb_node);
            %--------------------------------------------------------------
            gindex = obj.matrix.gindex;
            %--------------------------------------------------------------
            for igr = 1:length(lmatrix)
                nbNo_inFa = size(lmatrix{igr},2);
                id_face = gindex{igr};
                for i = 1:nbNo_inFa
                    for j = i+1 : nbNo_inFa
                        hwnwn = hwnwn + ...
                            sparse(face(i,id_face),face(j,id_face),...
                            lmatrix{igr}(:,i,j),nb_node,nb_node);
                    end
                end
            end
            %--------------------------------------------------------------
            hwnwn = hwnwn + hwnwn.';
            %--------------------------------------------------------------
            for igr = 1:length(lmatrix)
                id_face = gindex{igr};
                nbNo_inFa = size(lmatrix{igr},2);
                for i = 1:nbNo_inFa
                    hwnwn = hwnwn + ...
                        sparse(face(i,id_face),face(i,id_face),...
                        lmatrix{igr}(:,i,i),nb_node,nb_node);
                end
            end
            %--------------------------------------------------------------
            obj.matrix.hwnwn = hwnwn;
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
            obj.parent_model.matrix.hwnwn = ...
                obj.parent_model.matrix.hwnwn + obj.matrix.hwnwn;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_t = ...
                [obj.parent_model.matrix.id_node_t obj.matrix.gid_node_t];
            %--------------------------------------------------------------
        end
    end
end