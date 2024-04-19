%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef LVector < Xhandle
    properties
        main_value
        main_dir
        rot_axis
        rot_angle
    end

    % --- Contructor
    methods
        function obj = LVector(args)
            arguments
                args.main_value = []
                args.main_dir = []
                args.rot_axis = []
                args.rot_angle = []
            end
            % ---
            obj <= args;
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