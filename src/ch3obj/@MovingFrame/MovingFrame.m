%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef MovingFrame < Xhandle
    properties
        lin_step
        rot_origin    % rot around o-->axis
        rot_axis      % rot around o-->axis
        rot_angle     % deg, counterclockwise convention
    end

    % --- Contructor
    methods
        function obj = MovingFrame(args)
            arguments
                args.lin_step = []
                args.rot_origin = []
                args.rot_axis = []
                args.rot_angle = []
            end
            % ---
            obj <= args;
            % ---
        end
    end

    % --- Methods for coordinates
    methods
        % ---
        function gnode_xyz = get_gnode_cartesian(obj)
            % ---
            if obj.dimension == 2
                % --- lock to gcoor
                if any(obj.gcoor.cartesian.o(1:2) ~= [0 0])
                    gnode_xyz = obj.node - obj.gcoor.cartesian.o(1:2).';
                end
                % --- move
                if any(obj.move.cartesian.xyz(1:2) ~= [0 0])
                    gnode_xyz = gnode_xyz + obj.move.cartesian.xyz(1:2).';
                end
            elseif obj.dimension == 3
                % --- lock to gcoor
                if any(obj.gcoor.cartesian.o(1:3) ~= [0 0 0])
                    gnode_xyz = obj.node - obj.gcoor.cartesian.o(1:3).';
                end
                % --- move
                if any(obj.move.cartesian.xyz(1:3) ~= [0 0 0])
                    gnode_xyz = gnode_xyz + obj.move.cartesian.xyz(1:3).';
                end
            end
            % ---
        end
        % ---
        function gnode_xyz = get_gnode_cylindrical(obj)
            % ---
            if obj.dimension == 2
                % --- lock to gcoor
                if any(obj.gcoor.cylindrical.o(1:2) ~= [0 0])
                    gnode_xyz = obj.node - obj.gcoor.cylindrical.o(1:2).';
                end
                % ---
                if any(obj.gcoor.cylindrical.otheta(1:2) ~= [1 0])
                    otheta0 = [1 0 0];
                    otheta1 = [obj.gcoor.cylindrical.otheta(1:2) 0];
                    rot_axis  = cross(otheta0,otheta1);
                    rot_angle = acosd(dot(otheta0,otheta1)/(norm(otheta0)*norm(otheta1)));
                    % ---
                    gnode_xyz = [gnode_xyz; zeros(1,size(gnode_xyz,2))];
                    % ---
                    gnode_xyz = f_rotaroundaxis(gnode_xyz.','rot_axis',rot_axis,'angle',rot_angle);
                    % ---
                    gnode_xyz = gnode_xyz.';
                    gnode_xyz = gnode_xyz(1:2,:);
                end
                % --- move
                if any(obj.move.cylindrical.theta ~= 0)
                    rot_axis = [0 0 1];
                    rot_angle = obj.move.cylindrical.theta;
                    % ---
                    gnode_xyz = [gnode_xyz; zeros(1,size(gnode_xyz,2))];
                    % ---
                    gnode_xyz = f_rotaroundaxis(gnode_xyz.','rot_axis',rot_axis,'angle',rot_angle);
                    % ---
                    gnode_xyz = gnode_xyz.';
                    gnode_xyz = gnode_xyz(1:2,:);
                end
            elseif obj.dimension == 3
                % --- lock to gcoor
                if any(obj.gcoor.cylindrical.o(1:3) ~= [0 0 0])
                    gnode_xyz = obj.node - obj.gcoor.cylindrical.o(1:3).';
                end
                % ---
                if any(obj.gcoor.cylindrical.otheta(1:3) ~= [1 0 0])
                    otheta0 = [1 0 0];
                    otheta1 = obj.gcoor.cylindrical.otheta(1:3);
                    rot_axis  = cross(otheta0,otheta1);
                    rot_angle = acosd(dot(otheta0,otheta1)/(norm(otheta0)*norm(otheta1)));
                    % ---
                    gnode_xyz = f_rotaroundaxis(gnode_xyz.','rot_axis',rot_axis,'angle',rot_angle);
                    % ---
                    gnode_xyz = gnode_xyz.';
                end
                % --- move
                if any(obj.move.cylindrical.theta ~= 0)
                    rot_axis = [0 0 1];
                    rot_angle = obj.move.cylindrical.theta;
                    % ---
                    gnode_xyz = f_rotaroundaxis(gnode_xyz.','rot_axis',rot_axis,'angle',rot_angle);
                    % ---
                    gnode_xyz = gnode_xyz.';
                end
            end
            % ---
        end
    end

    % --- Methods
    methods
        function gvector = get_on(obj,dom)
            % ---
            if isa(dom,'VolumeDom')
                id_elem = dom.gid_elem;
            elseif isa(dom,'SurfaceDom')
                id_elem = dom.gid_face;
            elseif isprop(dom,'gid_elem')
                id_elem = dom.gid_elem;
            elseif isprop(dom,'gid_face')
                id_elem = dom.gid_face;
            end
            % ---
            nb_elem = length(id_elem);
            % ---
            fnames = {'main_value','main_dir','rot_axis','rot_angle'};
            % ---
            lvector = [];
            for i = 1:length(fnames)
                fn = fnames{i};
                lvfield = obj.(fn);
                if ~isempty(lvfield)
                    if isnumeric(lvfield)
                        lvector.(fn) = repmat(lvfield,nb_elem,1);
                    elseif isa(lvfield,'Parameter')
                        lvector.(fn) = lvfield.get_on(dom);
                    end
                end
            end
            % ---
            if ~isempty(obj.rot_axis) && ~isempty(obj.rot_angle)
                for i = 1:nb_elem
                    % ---
                    raxis = lvector.rot_axis(i,:) ./ norm(lvector.rot_axis(i,:));
                    a = lvector.rot_angle(i,:);
                    %------------------------------------------------------
                    lvector.main_dir(i,:) = obj.rotaroundaxis(lvector.main_dir(i,:),raxis,a);
                    %------------------------------------------------------
                end
            end
            % ---
            gvector = lvector.main_value .* lvector.main_dir;
            % ---
        end
        % -----------------------------------------------------------------
        function ginv = get_inverse_on(obj,dom)
            gvector = obj.get_on(dom);
            ginv = - gvector;
        end
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        function vrot = rotaroundaxis(obj,v,rot_axis,rot_angle)
            % ---
            if length(v) == 3
                dim = 3;
            else
                dim = 2;
            end
            % ---
            a = rot_angle / 180 * pi;
            if dim == 3
                ux = rot_axis(1); uy = rot_axis(2); uz = rot_axis(3);
                R  = [cos(a) + ux^2 * (1-cos(a))    ux*uy*(1-cos(a)) - uz*sin(a)   ux*uz*(1-cos(a)) + uy*sin(a) ; ...
                      uy*ux*(1-cos(a)) + uz*sin(a)  cos(a) + uy^2 * (1-cos(a))     uy*uz*(1-cos(a)) - ux*sin(a) ;...
                      uz*ux*(1-cos(a)) - uy*sin(a)  uz*uy*(1-cos(a)) + ux*sin(a)   cos(a) + uz^2 * (1-cos(a))];
            elseif dim == 2
                ux = rot_axis_(1); uy = rot_axis_(2);
                R  = [cos(a) + ux^2 * (1-cos(a))    ux*uy*(1-cos(a)) ; ...
                      uy*ux*(1-cos(a))              cos(a) + uy^2 * (1-cos(a))];
            end
            % ---
            vrot = R * v.';
            vrot = vrot.';
        end
        % -----------------------------------------------------------------
    end
end