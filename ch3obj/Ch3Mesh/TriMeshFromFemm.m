%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef TriMeshFromFemm < TriMesh

    % --- Properties
    properties
        mesh_file
        data
    end

    properties (Access = private)
        setup_done = 0
        build_done = 0
    end

    % --- Dependent Properties
    properties (Dependent = true)

    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'node','elem','mesh_file'};
        end
    end
    % --- Constructors
    methods
        function obj = TriMeshFromFemm(args)
            arguments
                % --- super
                args.node
                args.elem
                % ---
                args.mesh_file
            end
            % --- super
            obj@TriMesh;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            TriMeshFromFemm.setup(obj);
            % ---
        end
    end

    % --- setup/reset/build/assembly
    methods (Static)
        % -----------------------------------------------------------------
        function obj = setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            setup@TriMesh(obj);
            % ---
            if isempty(obj.mesh_file)
                return
            end
            % ----- 1/ read all -----
            fileID = fopen(obj.mesh_file);
            if fileID < 3
                warning([obj.mesh_file ' not found.']);
                return
            end
            fileDA = textscan(fileID,'%s %s %s %s %s %s %s %s %s');
            fclose(fileID);
            % ----- 2/ mesh and solution data -----
            iData   = find(strcmp(fileDA{1,1}(:,1),'[Solution]'));
            iNoeud  = iData+1;          nb_node = str2double(fileDA{1,1}(iNoeud,1));
            iElem   = iNoeud+nb_node+1; nb_elem = str2double(fileDA{1,1}(iElem ,1));
            % 2/a/ points
            node_ = zeros(2,nb_node);
            node_(1,:) = str2double(fileDA{1,1}(iNoeud+1 : iNoeud+nb_node,1));
            node_(2,:) = str2double(fileDA{1,2}(iNoeud+1 : iNoeud+nb_node,1));
            % 2/b/ potential A
            try 
                data_ = str2double(fileDA{1,3}(iNoeud+1 : iNoeud+nb_node,1)) + ...
                        1j .* ...
                        str2double(fileDA{1,4}(iNoeud+1 : iNoeud+nb_node,1));
            catch
                data_ = str2double(fileDA{1,3}(iNoeud+1 : iNoeud+nb_node,1));
            end
            % 2/c/ element
            elem_ = zeros(3,nb_elem);
            elem_(1,:) = str2double(fileDA{1,1}(iElem +1 : iElem +nb_elem ,1)) + 1 ;
            elem_(2,:) = str2double(fileDA{1,2}(iElem +1 : iElem +nb_elem ,1)) + 1 ;
            elem_(3,:) = str2double(fileDA{1,3}(iElem +1 : iElem +nb_elem ,1)) + 1 ;
            elem_code_ = str2double(fileDA{1,4}(iElem +1 : iElem +nb_elem ,1)) + 1 ;
            %--------------------------------------------------------------
            %----- check and correct mesh
            [node_,elem_] = f_reorg2d(node_,elem_);
            %----- correct data (maybe necessary due to axi formulation)
            data_(isnan(data_)) = 0;
            %-----
            obj.node = node_;
            obj.elem = elem_;
            obj.elem_code = elem_code_;
            obj.data = data_;
            % --- 2d elem surface
            obj.velem = f_volume(node_,elem_,'elem_type',obj.elem_type);
            % --- edge length
            % obj.sface = f_area(node_,face_);
            % ---
            obj.setup_done = 1;
            obj.build_done = 0;
            % ---
        end
        % -----------------------------------------------------------------
    end
    methods (Access = public)
        function reset(obj)
            % reset super
            reset@TriMesh(obj);
            % ---
            obj.setup_done = 0;
            TriMeshFromFemm.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    methods
        function build(obj)
            % ---
            TriMeshFromFemm.setup(obj);
            % ---
            build@TriMesh(obj);
            % ---
            if obj.build_done
                return
            end
            %--------------------------------------------------------------
            % obj.build_defining_obj;
            %--------------------------------------------------------------
            obj.build_done = 1;
            % ---
        end
    end
end



