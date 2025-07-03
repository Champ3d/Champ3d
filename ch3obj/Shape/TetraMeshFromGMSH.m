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

classdef TetraMeshFromGMSH < TetraMesh
    properties
        physical_volume = []
        airbox_volume = []
        mesh_file = ''
        use_user_defined_airbox = 0
        use_bounding_box_airbox = 0
        tol_mesh_size = 1e-9
    end
    properties (Access = private)
        build_from
    end
    % --- Constructors
    methods
        function obj = TetraMeshFromGMSH(args)
            arguments
                % --- super
                args.node
                args.elem
                % --- sub
                args.id = ''
                args.physical_volume
                args.airbox_volume (1,1) {mustBeA(args.airbox_volume,{'AirboxVolume'})}
                args.mesh_file char = ''
                args.use_bounding_box_airbox {mustBeMember(args.use_bounding_box_airbox,{0,1})}
                args.tol_mesh_size = 1e-9
            end
            % ---
            obj = obj@TetraMesh;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            if isfield(args,'physical_volume')
                args.physical_volume = f_to_scellargin(args.physical_volume);
                obj.build_from = 'physical_volume';
            elseif ~isempty(args.mesh_file)
                args.physical_volume = [];
                obj.build_from = 'mesh_file';
            else
                error('#physical_volume or #mesh_file must be given !');
            end
            % ---
            if isfield(args,'airbox_volume')
                obj.use_user_defined_airbox = 1;
                obj.use_bounding_box_airbox = 0;
            elseif ~isfield(args,'use_bounding_box_airbox')
                obj.use_user_defined_airbox = 0;
                obj.use_bounding_box_airbox = 0;
            else
                if args.use_bounding_box_airbox == 1
                    obj.use_user_defined_airbox = 0;
                end
            end
            % ---
            if isempty(args.id)
                args.id = f_uqid();
            end
            % ---
            obj <= args;
            % ---
            TetraMeshFromGMSH.setup(obj);
            % ---
        end
    end
    % --- setup/reset
    methods (Static)
        function setup(obj)
            % ---
            if strcmpi(obj.build_from,'mesh_file')
                obj.build_from_mesh_file;
                % ---
                return
            end
            % ---
            if strcmpi(obj.build_from,'physical_volume')
                obj.build_from_physical_volume;
            end
        end
    end
    methods (Access = public)
        function reset(obj)
            TetraMeshFromGMSH.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods (Access = protected)
        %------------------------------------------------------------------
        function build_from_mesh_file(obj)
            mesh_file_ = which(obj.mesh_file);
            if isfile(mesh_file_)
                if contains(mesh_file_,'.m')
                    % ---
                    run(mesh_file_);
                    % ---
                    node_ = msh.POS.';
                    elem_ = msh.TETS(:,1:4).';
                    elem_code_ = f_torowv(msh.TETS(:,5));
                    %--------------------------------------------------------------
                    nb_elem = length(elem_code_);
                    celem_ = mean(reshape(node_(:,elem_(1:4,:)),3,4,nb_elem),2);
                    celem_ = squeeze(celem_);
                    %--------------------------------------------------------------
                    face_ = f_face(elem_,'elem_type','tetra');
                    nb_face = size(face_,2);
                    cface_ = mean(reshape(node_(:,face_(1:3,:)),3,3,nb_face),2);
                    cface_ = squeeze(cface_);
                    %--------------------------------------------------------------
                    edge_ = f_edge(elem_,'elem_type','tetra');
                    nb_edge = size(edge_,2);
                    cedge_ = mean(reshape(node_(:,edge_(1:2,:)),3,2,nb_edge),2);
                    cedge_ = squeeze(cedge_);
                    %--------------------------------------------------------------
                    obj.node = node_;
                    obj.elem = elem_;
                    obj.elem_code = elem_code_;
                    obj.edge = edge_;
                    obj.face = face_;
                    obj.celem = celem_;
                    obj.cedge = cedge_;
                    obj.cface = cface_;
                    % ---
                    obj.velem = f_volume(node_,elem_,'elem_type',obj.elem_type);
                    obj.sface = f_area(node_,face_);
                    obj.ledge = f_ledge(node_,edge_);
                    % ---
                else
                    f_fprintf(1,'/!\\',0,'Only .m mesh file is acceptable !\n');
                    error(['Can not run #mesh_file ' obj.mesh_file]);
                end
            else
                error(['#mesh_file ' obj.mesh_file ' not found !']);
            end
        end
        %------------------------------------------------------------------
        function build_from_physical_volume(obj)
            % ---
            geoname = [obj.id '.geo'];
            mshname = [obj.id '.m'];
            % ---
            obj.mesh_file = mshname;
            % ---
            if isfile(geoname)
                fprintf('Cleaning ...\n');
                system(['rm ' geoname ' ' mshname]);
                fprintf('Old data cleaned.\n');
            end
            % ---
            geofile = fopen(geoname,'w');
            % --- Init
            initgeocode = GMSHWriter.init(obj.use_user_defined_airbox, ...
                                          obj.use_bounding_box_airbox, ...
                                          obj.tol_mesh_size);
            fprintf(geofile,'%s \n',initgeocode);
            % --- airbox volume
            if obj.use_user_defined_airbox
                aboxvol = obj.airbox_volume;
                aboxvol.is_defining_obj_of(obj);
                % ---
                fprintf(geofile,'%s \n',aboxvol.geocode);
            end
            % --- physical volume
            obj.physical_volume = f_to_scellargin(obj.physical_volume);
            % ---
            nb_phyvol = length(obj.physical_volume);
            elem_code = zeros(1,nb_phyvol);
            id_vdom   = cell(1,nb_phyvol);
            % ---
            for i = 1:length(obj.physical_volume)
                phyvol = obj.physical_volume{i};
                % ---
                phyvol.is_defining_obj_of(obj);
                % ---
                elem_code(i) = phyvol.id_number;
                id_vdom{i} = phyvol.id;
                % ---
                fprintf(geofile,'%s \n',phyvol.geocode);
            end
            % --- Final
            if obj.use_user_defined_airbox
                fprintf(geofile,'%s \n',GMSHWriter.final(mshname, ...
                    obj.airbox_volume.id, ...
                    obj.airbox_volume.id_number, ...
                    obj.airbox_volume.mesh_size.getvalue));
            else
                fprintf(geofile,'%s \n',GMSHWriter.final(mshname));
            end
            fclose(geofile);
            % ---
            call_GMSH_run = [Ch3Config.GMSHExecutable ' ' ...
                             geoname ' ' ...
                             '-v 0 -'];
            % ---
            try
                fprintf('GMSH running ... \n');
                [status, cmdout] = system(call_GMSH_run);
                fprintf('Done.\n');
                if status == 0
                    k = 0;
                    while ~isfile(mshname)
                        if k == 0
                            f_fprintf(0,'Waiting mesh file ... \n');
                        end
                        k = 1;
                    end
                    % ---
                    obj.build_from_mesh_file;
                    % ---
                end
            catch
                f_fprintf(1,'/!\\',0,'can not run ',1,geoname,0,'\n');
                return
            end
            % ---
            for i = 1:nb_phyvol
                obj.add_vdom('id',id_vdom{i},'elem_code',elem_code(i));
            end
            % ---
        end
        %------------------------------------------------------------------
    end
end