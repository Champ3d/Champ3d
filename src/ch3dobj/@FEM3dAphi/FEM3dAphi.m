%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FEM3dAphi < EmModel
    
    % --- Contructor
    methods
        function obj = FEM3dAphi(args)
            arguments
                args.id = 'no_id'
                args.parent_mesh = []
                args.fr = 0
            end
            % ---
            argu = f_to_namedarg(args);
            obj = obj@EmModel(argu{:});
            % ---
            obj <= args;
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function build_econductor(obj)
            phydom_type = 'econductor';
            % ---
            allphydom = fieldnames(obj.(phydom_type));
            % ---
            for i = 1:length(allphydom)
                % ---
                id_phydom = allphydom{i};
                % ---
                phydom = obj.(phydom_type).(id_phydom);
                dom__ = phydom.dom;
                for j = 1:length(dom__)
                    dom = dom__{j};
                    parent_mesh = dom.parent_mesh;
                    gid_elem    = dom.gid_elem;
                    %------------------------------------------------------
                    elem = parent_mesh.elem(:,gid_elem);
                    %------------------------------------------------------
                    id_node_phi = f_uniquenode(elem);
                    %------------------------------------------------------
                    sigma_array = obj.(phydom_type).(id_phydom).sigma.get_on(dom);
                    %------------------------------------------------------
                    sigmawewe = parent_mesh.cwewe('id_elem',gid_elem,'coefficient',sigma_array);
                    %------------------------------------------------------
                    obj.(phydom_type).(id_phydom).matrix.id_node_phi{j} = id_node_phi;
                    obj.(phydom_type).(id_phydom).matrix.sigmawewe{j} = sigmawewe;
                    %------------------------------------------------------
                end
            end
        end
        % -----------------------------------------------------------------
        function build_mconductor(obj)
            phydom_type = 'mconductor';
            % ---
            allphydom = fieldnames(obj.(phydom_type));
            % ---
            for i = 1:length(allphydom)
                % ---
                id_phydom = allphydom{i};
                % ---
                phydom = obj.(phydom_type).(id_phydom);
                dom__ = phydom.dom;
                for j = 1:length(dom__)
                    dom = dom__{j};
                    parent_mesh = dom.parent_mesh;
                    gid_elem    = dom.gid_elem;
                    %------------------------------------------------------
                    mu0 = 4 * pi * 1e-7;
                    nu0 = 1/mu0;
                    nu0nur = nu0 .* obj.(phydom_type).(id_phydom).mur.get_inverse_on(dom);
                    %------------------------------------------------------
                    nu0nurwfwf = parent_mesh.cwfwf('id_elem',gid_elem,'coefficient',nu0nur);
                    %------------------------------------------------------
                    obj.(phydom_type).(id_phydom).matrix.nu0nurwfwf{j} = nu0nurwfwf;
                    %------------------------------------------------------
                end
            end
        end
        % -----------------------------------------------------------------
        function build_airbox(obj)
            % ---
            if isempty(obj.airbox)
                if ~isfield(obj.parent_mesh.dom,'default_domain')
                    obj.parent_mesh.add_default_domain;
                end
                obj.add_airbox('id','default_airbox','id_dom3d','default_domain');
            end
            % ---
            gid_elem = [];
            gid_inner_edge = [];
            % ---
            phydom_type = 'airbox';
            % ---
            allphydom = fieldnames(obj.(phydom_type));
            % ---
            for i = 1:length(allphydom)
                % ---
                id_phydom = allphydom{i};
                % ---
                phydom = obj.(phydom_type).(id_phydom);
                dom__ = phydom.dom;
                for j = 1:length(dom__)
                    dom = dom__{j};
                    gid_elem = [gid_elem dom.gid.gid_elem];
                    gid_inner_edge = [gid_inner_edge dom.gid.gid_inner_edge];
                end
                %----------------------------------------------------------
                obj.(phydom_type).(id_phydom).matrix.gid_elem{j} = gid_elem;
                obj.(phydom_type).(id_phydom).matrix.gid_inner_edge{j} = gid_inner_edge;
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function build_nomesh(obj)
            % ---
            gid_elem = [];
            gid_inner_edge = [];
            gid_inner_node = [];
            % ---
            phydom_type = 'nomesh';
            % ---
            allphydom = fieldnames(obj.(phydom_type));
            % ---
            for i = 1:length(allphydom)
                % ---
                id_phydom = allphydom{i};
                % ---
                phydom = obj.(phydom_type).(id_phydom);
                dom__ = phydom.dom;
                for j = 1:length(dom__)
                    dom = dom__{j};
                    gid_elem = [gid_elem dom.gid.gid_elem];
                    gid_inner_edge = [gid_inner_edge dom.gid.gid_inner_edge];
                    gid_inner_node = [gid_inner_node dom.gid.gid_inner_edge];
                end
                %----------------------------------------------------------
                obj.(phydom_type).(id_phydom).matrix.gid_elem{j} = gid_elem;
                obj.(phydom_type).(id_phydom).matrix.gid_inner_edge{j} = gid_inner_edge;
                obj.(phydom_type).(id_phydom).matrix.gid_inner_node{j} = gid_inner_node;
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function build_bsfield(obj)
            phydom_type = 'bsfield';
            % ---
            allphydom = fieldnames(obj.(phydom_type));
            % ---
            for i = 1:length(allphydom)
                % ---
                id_phydom = allphydom{i};
                % ---
                phydom = obj.(phydom_type).(id_phydom);
                dom__ = phydom.dom;
                for j = 1:length(dom__)
                    dom = dom__{j};
                    parent_mesh = dom.parent_mesh;
                    gid_elem    = dom.gid_elem;
                    %------------------------------------------------------
                    bs = obj.(phydom_type).(id_phydom).bs.get_on(dom);
                    wfbs = parent_mesh.cwfvf('id_elem',gid_elem,'vector_field',bs);
                    %------------------------------------------------------
                    obj.(phydom_type).(id_phydom).matrix.wfbs{j} = wfbs;
                end
            end
        end
        % -----------------------------------------------------------------
        function build_pmagnet(obj)
            phydom_type = 'pmagnet';
            % ---
            allphydom = fieldnames(obj.(phydom_type));
            % ---
            for i = 1:length(allphydom)
                % ---
                id_phydom = allphydom{i};
                % ---
                phydom = obj.(phydom_type).(id_phydom);
                dom__ = phydom.dom;
                for j = 1:length(dom__)
                    dom = dom__{j};
                    parent_mesh = dom.parent_mesh;
                    gid_elem    = dom.gid_elem;
                    %------------------------------------------------------
                    br = obj.(phydom_type).(id_phydom).br.get_on(dom);
                    wfbr = parent_mesh.cwfvf('id_elem',gid_elem,'vector_field',br);
                    %------------------------------------------------------
                    obj.(phydom_type).(id_phydom).matrix.wfbr{j} = wfbr;
                end
            end
        end
        % -----------------------------------------------------------------
        function build_sibc(obj)
            phydom_type = 'sibc';
            % ---
            allphydom = fieldnames(obj.(phydom_type));
            % ---
            for i = 1:length(allphydom)
                % ---
                id_phydom = allphydom{i};
                % ---
                phydom = obj.(phydom_type).(id_phydom);
                dom__ = phydom.dom;
                for j = 1:length(dom__)
                    dom = dom__{j};
                    gid_face = dom.gid_face;
                    nb_face  = length(gid_face);
                    % ---
                    id_node_phi = f_uniquenode(dom.parent_mesh.face(:,gid_face));
                    % ---
                    sigma_array  = obj.(phydom_type).(id_phydom).sigma.get_on(dom);
                    mur_array    = obj.(phydom_type).(id_phydom).mur.get_on(dom);
                    cparam_array = obj.(phydom_type).(id_phydom).cparam.get_on(dom);
                    % ---
                    mu0 = 4 * pi * 1e-7;
                    fr = obj.fr;
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
                        gsibcwewe{j,k} = sm.cwewe('coefficient',g_sibc);
                        % ---
                        gid_face_{j,k} = sm.gid_face;
                    end
                    %------------------------------------------------------
                    obj.(phydom_type).(id_phydom).matrix.id_node_phi{j} = id_node_phi;
                end
                %------------------------------------------------------
                obj.(phydom_type).(id_phydom).matrix.gsibcwewe = gsibcwewe;
                obj.(phydom_type).(id_phydom).matrix.gid_face = gid_face_;
                %------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end
end