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

classdef LVector < Xhandle
    properties
        parent_model
        main_value
        main_dir
        rot_axis
        rot_angle
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','main_value','main_dir','rot_axis','rot_angle'};
        end
    end
    % --- Contructor
    methods
        function obj = LVector(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,{'PhysicalModel','CplModel'})}
                args.main_value = []
                args.main_dir = []
                args.rot_axis = []
                args.rot_angle = []
            end
            % ---
            obj = obj@Xhandle;
            % ---
            if ~isfield(args,'parent_model')
                error('#parent_model must be given !');
            end
            % ---
            obj <= args;
            % ---
        end
    end

    % --- Methods
    methods
        function gvector = getvalue(obj,args)
            arguments
                obj
                args.in_dom = [] %{mustBeA(args.in_dom,{'VolumeDom','SurfaceDom'})}
            end
            % ---
            dom = args.in_dom;
            % ---
            if isa(dom,'PhysicalDom')
                meshdom = dom.dom;
            else
                meshdom = dom;
            end
            % ---
            if isa(meshdom,'VolumeDom')
                id_elem = meshdom.gid_elem;
            elseif isa(meshdom,'SurfaceDom')
                id_elem = meshdom.gid_face;
            elseif isprop(meshdom,'gid_elem')
                id_elem = meshdom.gid_elem;
            elseif isprop(meshdom,'gid_face')
                id_elem = meshdom.gid_face;
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
                        if isequal(obj.parent_model,lvfield.parent_model)
                            lvector.(fn) = lvfield.getvalue('in_dom',dom);
                        else
                            error(['#parent_model of LVector must be the same as ' fn ' Parameter !']);
                        end
                    end
                end
            end
            % --- normalize
            lvector.main_dir = f_normalize(lvector.main_dir,2);
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
        function ginv = get_inverse(obj,args)
            arguments
                obj
                args.in_dom = [] %{mustBeA(args.in_dom,{'VolumeDom','SurfaceDom'})}
            end
            % ---
            dom = args.in_dom;
            % ---
            gvector = obj.getvalue('in_dom',dom);
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