%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef SibcAphijw < Sibc

    % --- computed
    properties
        build_done = 0
        matrix
    end

    % --- Contructor
    methods
        function obj = SibcAphijw(args)
            arguments
                args.id
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
            obj.setup_done = 0;
            obj.build_done = 0;
            % ---
            obj.setup;
        end
    end

    % --- setup
    methods
        function setup(obj)
            if ~obj.setup_done
                % ---
                setup@Sibc(obj);
                % ---
                if isnumeric(obj.sigma)
                    obj.sigma = Parameter('f',obj.sigma);
                end
                % ---
                obj.setup_done = 1;
                % ---
                obj.build_done = 0;
            end
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
            nb_face  = length(gid_face);
            % ---
            id_node_phi = f_uniquenode(dom.parent_mesh.face(:,gid_face));
            % ---
            sigma_array  = obj.sigma.get_on(dom);
            mur_array    = obj.mur.get_on(dom);
            cparam_array = obj.cparam.get_on(dom);
            % ---
            mu0 = 4 * pi * 1e-7;
            fr = obj.frequency;
            skindepth = sqrt(2./(2*pi*fr.*(mu0.*mur_array).*sigma_array));
            % ---
            z_sibc = (1+1j)./(skindepth.*sigma_array) .* ...
                (1 + (1-1j)/4 .* skindepth .* cparam_array);
            z_sibc = obj.column_array(z_sibc,'nb_elem',nb_face);
            % ---
            dom.build_submesh;
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
            obj.matrix.id_node_phi = id_node_phi;
            % ---
            obj.matrix.gsibcwewe = gsibcwewe;
            obj.matrix.gid_face = gid_face_;
            obj.matrix.sigma_array = sigma_array;
            obj.matrix.mur_array = mur_array;
            obj.matrix.cparam_array = cparam_array;
            obj.matrix.skindepth = skindepth;
            % ---
            obj.build_done = 1;
        end
    end
end