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

classdef Sibcjw < PhysicalDom
    properties
        sigma = 0
        mur = 1
        r_ht = 1e9
        r_et = 1e9
    end
    % --- 
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_model','id_dom3d','sigma','mur', ...
                        'r_ht','r_et','cparam','parameter_dependency_search'};
        end
    end
    % --- Contructor
    methods
        function obj = Sibcjw(args)
            arguments
                args.id
                args.parent_model
                args.id_dom3d
                args.sigma
                args.mur
                args.r_ht
                args.r_et
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
            Sibcjw.setup(obj);
            % ---
        end
    end

    % --- setup
    methods (Static)
        function setup(obj)
            % --- call utility methods
            obj.set_parameter;
            obj.get_geodom;
            obj.dom.is_defining_obj_of(obj);
            % --- Initialization
            obj.matrix.gid_node_phi = [];
            obj.matrix.gsibcwewe = [];
            obj.matrix.gindex = [];
            obj.matrix.sigma_array = [];
            obj.matrix.mur_array = [];
            obj.matrix.cparam_array = [];
            obj.matrix.skindepth = [];
            % ---
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            Sibcjw.setup(obj);
        end
    end
    % --- build
    methods
        function build(obj)
            % ---
            it = obj.parent_model.ltime.it;
            % ---
            dom = obj.dom;
            % ---
            gindex = dom.gindex;
            lnb_face  = length(gindex);
            % ---
            gid_node_phi = f_uniquenode(dom.parent_mesh.face(:,gindex));
            % ---
            sigma_array  = obj.sigma.getvalue('in_dom',dom);
            mur_array    = obj.mur.getvalue('in_dom',dom);
            r_ht_array   = obj.r_ht.getvalue('in_dom',dom);
            r_et_array   = obj.r_et.getvalue('in_dom',dom);
            % ---
            mu0 = 4 * pi * 1e-7;
            fr = obj.parent_model.frequency;
            skindepth = sqrt(2./(2*pi*fr.*(mu0.*mur_array).*sigma_array));
            cparam_array = 1./r_ht_array - 1./r_et_array;
            % ---
            z_sibc = (1+1j)./(skindepth.*sigma_array) .* ...
                (1 + (1-1j)/4 .* skindepth .* cparam_array);
            z_sibc = Array.tensor(z_sibc,'nb_elem',lnb_face);
            %--------------------------------------------------------------
            % local surface mesh
            submesh = dom.submesh;
            %--------------------------------------------------------------
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                gindex_{k} = sm.gindex;
            end
            %--------------------------------------------------------------
            % --- check changes
            is_changed = 1;
            if isequal(gid_node_phi,obj.matrix.gid_node_phi) && ...
               isequal(gindex_,obj.matrix.gindex) && ...
               isequal(sigma_array,obj.matrix.sigma_array) && ...
               isequal(skindepth,obj.matrix.skindepth)
                is_changed = 0;
            end
            %--------------------------------------------------------------
            if ~is_changed && obj.build_done == 1
                obj.tarray{it}.sigma = obj.tarray{it-1}.sigma;
                obj.tarray{it}.skindepth = obj.tarray{it-1}.skindepth;
                % obj.tarray{it}.sigma = TensorArray(sigma_array,'parent_dom',obj);
                % obj.tarray{it}.skindepth = TensorArray(skindepth,'parent_dom',obj);
                return
            end
            %--------------------------------------------------------------
            obj.matrix.gid_node_phi = gid_node_phi;
            obj.matrix.gindex = gindex_;
            obj.matrix.sigma_array = sigma_array;
            obj.matrix.skindepth = skindepth;
            obj.matrix.z_sibc = z_sibc;
            % obj.matrix.mur_array = mur_array;
            % obj.matrix.cparam_array = cparam_array;
            %--------------------------------------------------------------
            obj.tarray{it}.sigma = TensorArray(sigma_array,'parent_dom',obj);
            obj.tarray{it}.skindepth = TensorArray(skindepth,'parent_dom',obj);
            %--------------------------------------------------------------
            % local gsibcwewe matrix
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lindex_  = sm.lindex;
                g_sibc = 1./z_sibc(lindex_);
                lmatrix{k} = sm.cwewe('coefficient',g_sibc);
                % ---
            end
            %--------------------------------------------------------------
            id_edge_in_face = obj.parent_model.parent_mesh.meshds.id_edge_in_face;
            nb_edge = obj.parent_model.parent_mesh.nb_edge;
            %--------------------------------------------------------------
            % global elementary gsibcwewe matrix
            gsibcwewe = sparse(nb_edge,nb_edge);
            %--------------------------------------------------------------
            gindex = obj.matrix.gindex;
            %--------------------------------------------------------------
            for igr = 1:length(lmatrix)
                nbEd_inFa = size(lmatrix{igr},2);
                id_face = gindex{igr};
                for i = 1:nbEd_inFa
                    for j = i+1 : nbEd_inFa
                        gsibcwewe = gsibcwewe + ...
                            sparse(id_edge_in_face(i,id_face),id_edge_in_face(j,id_face),...
                            lmatrix{igr}(:,i,j),nb_edge,nb_edge);
                    end
                end
            end
            %--------------------------------------------------------------
            gsibcwewe = gsibcwewe + gsibcwewe.';
            %--------------------------------------------------------------
            for igr = 1:length(lmatrix)
                id_face = gindex{igr};
                nbEd_inFa = size(lmatrix{igr},2);
                for i = 1:nbEd_inFa
                    gsibcwewe = gsibcwewe + ...
                        sparse(id_edge_in_face(i,id_face),id_edge_in_face(i,id_face),...
                        lmatrix{igr}(:,i,i),nb_edge,nb_edge);
                end
            end
            %--------------------------------------------------------------
            obj.matrix.gsibcwewe = gsibcwewe;
            % ---
            obj.build_done = 1;
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            %--------------------------------------------------------------
            obj.parent_model.matrix.sigmawewe = ...
                obj.parent_model.matrix.sigmawewe + obj.matrix.gsibcwewe;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_phi = ...
                unique([obj.parent_model.matrix.id_node_phi, obj.matrix.gid_node_phi]);
            %--------------------------------------------------------------
            it = obj.parent_model.ltime.it;
            obj.parent_model.field{it}.J.face.sibc.(obj.id).sigma = obj.tarray{it}.sigma;
            obj.parent_model.field{it}.P.face.sibc.(obj.id).skindepth = obj.tarray{it}.skindepth;
            %--------------------------------------------------------------
        end
    end

    % --- postpro
    methods
        function postpro(obj)
            % ---
            id_edge_in_face = obj.parent_model.parent_mesh.meshds.id_edge_in_face;
            lnb_face = length(obj.dom.gindex);
            % ---
            sigma_array = Array.tensor(obj.matrix.sigma_array,'nb_elem',lnb_face);
            skindepth   = Array.tensor(obj.matrix.skindepth,'nb_elem',lnb_face);
            % ---
            es = sparse(2,lnb_face);
            js = sparse(2,lnb_face);
            %--------------------------------------------------------------
            submesh = obj.dom.submesh;
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lindex = sm.lindex;
                gindex = sm.gindex;
                cWes = sm.intkit.cWe{1};
                % ---
                if any(f_strcmpi(sm.elem_type,'tri'))
                    dofe = obj.parent_model.dof.e(id_edge_in_face(1:3,gindex)).';
                elseif any(f_strcmpi(sm.elem_type,'quad'))
                    dofe = obj.parent_model.dof.e(id_edge_in_face(1:4,gindex)).';
                end
                %----------------------------------------------------------
                es(1,lindex) = es(1,lindex) + sum(squeeze(cWes(:,1,:)) .* dofe,2).';
                es(2,lindex) = es(2,lindex) + sum(squeeze(cWes(:,2,:)) .* dofe,2).';
                js(1,lindex) = sigma_array(lindex,1).' .* es(1,lindex);
                js(2,lindex) = sigma_array(lindex,1).' .* es(2,lindex);
                %----------------------------------------------------------
                obj.parent_model.field.es(:,gindex) = es(:,lindex);
                obj.parent_model.field.js(:,gindex) = js(:,lindex);
                %----------------------------------------------------------
                obj.parent_model.field.ps(:,gindex) = ...
                    real(1/2 .* skindepth(lindex,1).' .* ...
                    sum(es(:,lindex) .* conj(js(:,lindex))));
                %----------------------------------------------------------
            end
        end
    end
end