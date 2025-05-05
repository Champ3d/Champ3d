%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef SibcAphijw < Sibc

    % --- computed
    properties
        matrix
    end

    % --- computed
    properties (Access = private)
        build_done = 0
        assembly_done = 0
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = Sibc.validargs;
        end
    end
    % --- Contructor
    methods
        function obj = SibcAphijw(args)
            arguments
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.sigma
                args.mur
                args.r_ht
                args.r_et
                args.cparam
            end
            % ---
            obj = obj@Sibc;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            obj.setup;
        end
    end

    % --- setup
    methods
        function setup(obj)
            setup@Sibc(obj);
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            obj.setup;
            % ---
            if obj.build_done
                return
            end
            % ---
            dom = obj.dom;
            % ---
            gid_face = dom.gid_face;
            lnb_face  = length(gid_face);
            % ---
            gid_node_phi = f_uniquenode(dom.parent_mesh.face(:,gid_face));
            % ---
            sigma_array  = obj.sigma.getvalue('in_dom',dom);
            mur_array    = obj.mur.getvalue('in_dom',dom);
            cparam_array = obj.cparam.getvalue('in_dom',dom);
            % ---
            mu0 = 4 * pi * 1e-7;
            fr = obj.parent_model.frequency;
            skindepth = sqrt(2./(2*pi*fr.*(mu0.*mur_array).*sigma_array));
            % ---
            z_sibc = (1+1j)./(skindepth.*sigma_array) .* ...
                (1 + (1-1j)/4 .* skindepth .* cparam_array);
            z_sibc = f_column_array(z_sibc,'nb_elem',lnb_face);
            % ---
            submesh = dom.submesh;
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lid_face_  = sm.lid_face;
                g_sibc = 1./z_sibc(lid_face_);
                gsibcwewe{k} = sm.cwewe('coefficient',g_sibc);
                % ---
                gid_face_{k} = sm.gid_face;
            end
            % ---
            obj.matrix.gid_node_phi = gid_node_phi;
            % ---
            obj.matrix.gsibcwewe = gsibcwewe;
            obj.matrix.gid_face = gid_face_;
            obj.matrix.sigma_array = sigma_array;
            obj.matrix.mur_array = mur_array;
            obj.matrix.cparam_array = cparam_array;
            obj.matrix.skindepth = skindepth;
            % ---
            obj.build_done = 1;
            obj.assembly_done = 0;
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            % ---
            if obj.assembly_done
                return
            end
            %--------------------------------------------------------------
            id_edge_in_face = obj.parent_model.parent_mesh.meshds.id_edge_in_face;
            nb_edge = obj.parent_model.parent_mesh.nb_edge;
            %--------------------------------------------------------------
            gsibcwewe = sparse(nb_edge,nb_edge);
            %--------------------------------------------------------------
            gid_face = obj.matrix.gid_face;
            lmatrix  = obj.matrix.gsibcwewe;
            %--------------------------------------------------------------
            for igr = 1:length(lmatrix)
                nbEd_inFa = size(lmatrix{igr},2);
                id_face = gid_face{igr};
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
                id_face = gid_face{igr};
                nbEd_inFa = size(lmatrix{igr},2);
                for i = 1:nbEd_inFa
                    gsibcwewe = gsibcwewe + ...
                        sparse(id_edge_in_face(i,id_face),id_edge_in_face(i,id_face),...
                        lmatrix{igr}(:,i,i),nb_edge,nb_edge);
                end
            end
            %--------------------------------------------------------------
            obj.parent_model.matrix.sigmawewe = ...
                obj.parent_model.matrix.sigmawewe + gsibcwewe;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_phi = ...
                [obj.parent_model.matrix.id_node_phi obj.matrix.gid_node_phi];
            %--------------------------------------------------------------
            obj.assembly_done = 1;
        end
    end

    % --- postpro
    methods
        function postpro(obj)
            % ---
            id_edge_in_face = obj.parent_model.parent_mesh.meshds.id_edge_in_face;
            lnb_face = length(obj.dom.gid_face);
            % ---
            sigma_array = f_column_array(obj.matrix.sigma_array,'nb_elem',lnb_face);
            skindepth   = f_column_array(obj.matrix.skindepth,'nb_elem',lnb_face);
            % ---
            es = sparse(2,lnb_face);
            js = sparse(2,lnb_face);
            %--------------------------------------------------------------
            submesh = obj.dom.submesh;
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lid_face = sm.lid_face;
                gid_face = sm.gid_face;
                cWes = sm.intkit.cWe{1};
                % ---
                if any(f_strcmpi(sm.elem_type,'tri'))
                    dofe = obj.parent_model.dof.e(id_edge_in_face(1:3,gid_face)).';
                elseif any(f_strcmpi(sm.elem_type,'quad'))
                    dofe = obj.parent_model.dof.e(id_edge_in_face(1:4,gid_face)).';
                end
                %----------------------------------------------------------
                es(1,lid_face) = es(1,lid_face) + sum(squeeze(cWes(:,1,:)) .* dofe,2).';
                es(2,lid_face) = es(2,lid_face) + sum(squeeze(cWes(:,2,:)) .* dofe,2).';
                js(1,lid_face) = sigma_array(lid_face,1).' .* es(1,lid_face);
                js(2,lid_face) = sigma_array(lid_face,1).' .* es(2,lid_face);
                %----------------------------------------------------------
                obj.parent_model.field.es(:,gid_face) = es(:,lid_face);
                obj.parent_model.field.js(:,gid_face) = js(:,lid_face);
                %----------------------------------------------------------
                obj.parent_model.field.ps(:,gid_face) = ...
                    real(1/2 .* skindepth(lid_face,1).' .* ...
                    sum(es(:,lid_face) .* conj(js(:,lid_face))));
                %----------------------------------------------------------
            end
        end
    end

    % --- reset
    methods
        function reset(obj)
            if isprop(obj,'setup_done')
                obj.setup_done = 0;
            end
            if isprop(obj,'build_done')
                obj.build_done = 0;
            end
            if isprop(obj,'assembly_done')
                obj.assembly_done = 0;
            end
        end
    end
end