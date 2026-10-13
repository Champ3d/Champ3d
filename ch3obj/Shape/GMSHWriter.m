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

classdef GMSHWriter
    % --- base shape
    methods (Static)
        %------------------------------------------------------------------
        function geocode = bsphere(c,r,bcut,tcut,angle)
            arguments
                c = [0 0 0]
                r = 1
                bcut = 0
                tcut = 0
                angle = 360
            end
            % ---
            if r <= 0
                geocode = '';
                return
            end
            % ---
            bcut  = max(0, min(1, bcut));
            tcut  = max(0, min(1, tcut));
            angle = max(0, min(2*pi, angle*pi/180));
            % ---
            angle_1 = interp1([0 1], [-pi/2 0], bcut);
            angle_2 = interp1([1 0], [0 +pi/2], tcut);
            % ---
            geocode = newline;
            geocode = [geocode fileread('__BSphere.geo')];
            % ---
            geocode = GMSHWriter.write_scalar_parameter(geocode,'radius',r);
            geocode = GMSHWriter.write_vector_parameter(geocode,'center',c);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'opening_angle_1',angle_1);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'opening_angle_2',angle_2);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'opening_angle_3',angle);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = bbox(c,len,orientation)
            arguments
                c   = [0 0 0]
                len = [1, 1, 1]
                orientation = [0 0 1]
            end
            % ---
            if any(len <= 0)
                geocode = '';
                return
            end
            % ---
            oori = [0 0 1];
            corner = c - len./2;
            axis = cross(oori,orientation);
            angle = acos(dot(oori,orientation) / (norm(oori) * norm(orientation)));
            % ---
            geocode = newline;
            geocode = [geocode fileread('__BBox.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'center',c);
            geocode = GMSHWriter.write_vector_parameter(geocode,'corner',corner);
            geocode = GMSHWriter.write_vector_parameter(geocode,'len',len);
            geocode = GMSHWriter.write_vector_parameter(geocode,'axis',axis);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'angle',angle);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = btorus(c,rtorus,rsection,opening_angle,orientation)
            arguments
                c  = [0 0 0]
                rtorus = 2
                rsection = 1
                opening_angle = 360
                orientation = [0 0 1]
            end
            % ---
            if (rtorus <= 0) || (rsection <= 0) || opening_angle == 0
                geocode = '';
                return
            end
            % ---
            opening_angle = opening_angle * pi/180;
            % ---
            oori = [0 0 1];
            axis = cross(oori,orientation);
            angle = acos(dot(oori,orientation) / (norm(oori) * norm(orientation)));
            % ---
            geocode = newline;
            geocode = [geocode fileread('__BTorus.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'center',c);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'rtorus',rtorus);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'rsection',rsection);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'opening_angle',opening_angle);
            geocode = GMSHWriter.write_vector_parameter(geocode,'axis',axis);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'angle',angle);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = bcylinder(c,r,hei,opening_angle,orientation)
            arguments
                c = [0 0 0]
                r = 1
                hei = 1
                opening_angle = 360
                orientation = [0 0 1]
            end
            % ---
            if (hei <= 0) || (r <= 0)
                geocode = '';
                return
            end
            % ---
            bottom = f_torowv(c) - hei/2 .* f_torowv(orientation); 
            opening_angle = opening_angle * pi/180;
            orientation = orientation ./ norm(orientation);
            % ---
            geocode = newline;
            geocode = [geocode fileread('__BCylinder.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'center',c);
            geocode = GMSHWriter.write_vector_parameter(geocode,'bottom',bottom);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'r',r);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'hei',hei);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'opening_angle',opening_angle);
            geocode = GMSHWriter.write_vector_parameter(geocode,'orientation',orientation);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = bhollowcylinder(c,ri,ro,hei,opening_angle,orientation)
            arguments
                c  = [0 0 0]
                ri = 1
                ro = 2
                hei = 1
                opening_angle = 360
                orientation = [0 0 1]
            end
            % ---
            if (hei <= 0) || (ri < 0) || (ro <= 0) || (ro <= ri)
                geocode = '';
                return
            end
            % ---
            if ri == 0
                geocode = GMSHWriter.bcylinder(c,ro,hei,opening_angle,orientation);
                return
            end
            % ---
            bottom = f_torowv(c) - hei/2 .* f_torowv(orientation); 
            opening_angle = opening_angle * pi/180;
            orientation = orientation ./ norm(orientation);
            % ---
            geocode = newline;
            geocode = [geocode fileread('__BHollowCylinder.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'center',c);
            geocode = GMSHWriter.write_vector_parameter(geocode,'bottom',bottom);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'ri',ri);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'ro',ro);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'hei',hei);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'opening_angle',opening_angle);
            geocode = GMSHWriter.write_vector_parameter(geocode,'orientation',orientation);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = bdisk(c,r)
            arguments
                c = [0 0]
                r = 1
            end
            % ---
            if length(c) == 2
                c = [c(1) c(2) 0];
            end
            % ---
            geocode = newline;
            geocode = [geocode fileread('__BDisk.geo')];
            % ---
            geocode = GMSHWriter.write_scalar_parameter(geocode,'radius',r);
            geocode = GMSHWriter.write_vector_parameter(geocode,'center',c);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = brectangle(c,len,orientation,r_corner)
            arguments
                c   = [0 0]
                len = [1 1]
                orientation = [1 0]
                r_corner = 0
            end
            % ---
            if length(orientation) == 2
                orientation = [orientation(1) orientation(2) 0];
            end
            % ---
            if length(len) > 2
                error('#len must be of dim 2 : [lenx leny].')
            end
            % ---
            if any(len <= 0)
                f_fprintf(1,'/!\\',0,'#len must be positive \n');
                geocode = '';
                return
            end
            % ---
            if r_corner > min(len)/2
                r_corner = min(len)/2 - min(len)/100; % tol
            end
            % ---
            if length(c) == 2
                corner = [c(1)-len(1)/2, c(2)-len(2)/2, 0];
                c = [c(1) c(2) 0];
            elseif length(c) == 3
                corner = [c(1)-len(1)/2, c(2)-len(2)/2, c(3)];
            end
            % ---
            oori = [1 0 0];
            axis = cross(oori,orientation);
            angle = acos(dot(oori,orientation) / (norm(oori) * norm(orientation)));
            % ---
            geocode = newline;
            geocode = [geocode fileread('__BRectangle.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'center',c);
            geocode = GMSHWriter.write_vector_parameter(geocode,'corner',corner);
            geocode = GMSHWriter.write_vector_parameter(geocode,'len',len);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'r_corner',r_corner);
            geocode = GMSHWriter.write_vector_parameter(geocode,'axis',axis);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'angle',angle);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = bhollowdisk(c,ri,ro)
            arguments
                c  = [0 0]
                ri = 1
                ro = 2
            end
            % ---
            if (ri < 0) || (ro <= 0) || (ro <= ri)
                f_fprintf(1,'/!\\',0,'degenerated hollow disk !\n');
                geocode = '';
                return
            end
            % ---
            if length(c) == 2
                c = [c(1) c(2) 0];
            end
            % ---
            if ri == 0
                geocode = GMSHWriter.bdisk(c,ro);
                return
            end
            % ---
            geocode = newline;
            geocode = [geocode fileread('__BHollowDisk.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'center',c);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'ri',ri);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'ro',ro);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = bcurve(x,y,z,type)
            arguments
                x = [0 1]
                y = [0 1]
                z = [0 1]
                type = 0
            end
            % ---
            geocode = newline;
            geocode = [geocode fileread('__BCurve.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'x',x);
            geocode = GMSHWriter.write_vector_parameter(geocode,'y',y);
            geocode = GMSHWriter.write_vector_parameter(geocode,'z',z);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'type',type);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
    end

    % --- transform
    methods (Static)
        %------------------------------------------------------------------
        function geocode = rotate_volume(origin,axis,angle,nb_copy)
            arguments
                origin  = [0, 0, 0]
                axis    = [0, 0, 0]
                angle   = 0
                nb_copy = 1
            end
            % ---
            if isequal(f_torowv(axis),[0 0 0])
                geocode = '';
                return
            end
            % ---
            angle = angle*pi/180;
            % ---
            geocode = newline;
            geocode = [geocode fileread('__rotateVolume.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'origin',origin);
            geocode = GMSHWriter.write_vector_parameter(geocode,'axis',axis);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'angle',angle);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'nb_copy',nb_copy);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = dilate_volume(origin,scale)
            arguments
                origin  = [0, 0, 0]
                scale   = [1, 1, 1]
            end
            % ---
            geocode = newline;
            geocode = [geocode fileread('__dilateVolume.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'origin',origin);
            geocode = GMSHWriter.write_vector_parameter(geocode,'scale',scale);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = translate_volume(distance,nb_copy)
            arguments
                distance = [0, 0, 0]
                nb_copy = 1
            end
            % ---
            if isequal(f_torowv(distance),[0 0 0])
                geocode = '';
                return
            end
            % ---
            geocode = newline;
            geocode = [geocode fileread('__translateVolume.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'distance',distance);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'nb_copy',nb_copy);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = rotate_surface(origin,angle,nb_copy)
            arguments
                origin  = [0, 0]
                angle   = 0
                nb_copy = 1
            end
            % ---
            origin = [origin(1) origin(2) 0];
            % ---
            if angle == 0
                geocode = '';
                return
            end
            % ---
            angle = angle*pi/180;
            % ---
            geocode = newline;
            geocode = [geocode fileread('__rotateSurface.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'origin',origin);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'angle',angle);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'nb_copy',nb_copy);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = dilate_surface(origin,scale)
            arguments
                origin  = [0, 0]
                scale   = [1, 1]
            end
            % ---
            origin = [origin(1) origin(2) 0];
            scale  = [scale(1) scale(2) 0];
            % ---
            geocode = newline;
            geocode = [geocode fileread('__dilateSurface.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'origin',origin);
            geocode = GMSHWriter.write_vector_parameter(geocode,'scale',scale);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = translate_surface(distance,nb_copy)
            arguments
                distance = [0, 0, 0]
                nb_copy = 1
            end
            % ---
            distance = [distance(1) distance(2) 0];
            % ---
            if isequal(f_torowv(distance),[0 0 0])
                geocode = '';
                return
            end
            % ---
            geocode = newline;
            geocode = [geocode fileread('__translateSurface.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'distance',distance);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'nb_copy',nb_copy);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = finish_coilshape(fit_axis,fit_angle,rotation)
            arguments
                fit_axis
                fit_angle
                rotation
            end
            % ---
            fit_angle = fit_angle*pi/180;
            rotation  = rotation*pi/180;
            % ---
            geocode = newline;
            geocode = [geocode fileread('__finishCoilShape.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'fit_axis',fit_axis);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'fit_angle',fit_angle);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'rotation',rotation);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = finish_physicalvolume(id_dom_string,id_dom_number,mesh_size)
            arguments
                id_dom_string
                id_dom_number
                mesh_size
            end
            % ---
            geocode = newline;
            geocode = [geocode fileread('__finishPhysicalVolume.geo')];
            % ---
            geocode = GMSHWriter.write_string_parameter(geocode,'id_dom_string',id_dom_string);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'id_dom_number',id_dom_number);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'mesh_size',mesh_size);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
        function geocode = finish_airboxvolume()
            % ---
            geocode = [newline fileread('__finishAirboxVolume.geo') newline];
            % ---
        end
        %------------------------------------------------------------------
    end
    % --- init/final
    methods (Static)
        %------------------------------------------------------------------
        function geocode = union_volume()
            geocode = fileread('__unionVolume.geo');
            geocode = [geocode newline];
        end
        %------------------------------------------------------------------
        function geocode = difference_volume()
            geocode = fileread('__differenceVolume.geo');
            geocode = [geocode newline];
        end
        %------------------------------------------------------------------
        function geocode = intersection_volume()
            geocode = fileread('__intersectionVolume.geo');
            geocode = [geocode newline];
        end
        %------------------------------------------------------------------
        function geocode = union_surface()
            geocode = fileread('__unionSurface.geo');
            geocode = [geocode newline];
        end
        %------------------------------------------------------------------
        function geocode = difference_surface()
            geocode = fileread('__differenceSurface.geo');
            geocode = [geocode newline];
        end
        %------------------------------------------------------------------
        function geocode = intersection_surface()
            geocode = fileread('__intersectionSurface.geo');
            geocode = [geocode newline];
        end
        %------------------------------------------------------------------
    end
    % --- init/final
    methods (Static)
        %------------------------------------------------------------------
        function geocode = init(use_user_defined_airbox,use_bounding_box_airbox,tol_mesh_size)
            arguments
                use_user_defined_airbox = 0
                use_bounding_box_airbox = 0
                tol_mesh_size = 1e-9
            end
            geocode = fileread('__init.geo');
            geocode = GMSHWriter.write_scalar_parameter(geocode,'use_user_defined_airbox',use_user_defined_airbox);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'use_bounding_box_airbox',use_bounding_box_airbox);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'tol_mesh_size',tol_mesh_size);
            geocode = [geocode newline];
        end
        %------------------------------------------------------------------
        function geocode = final(mesh_file_name,id_air_dom_string,id_air_dom_number,air_mesh_size)
            arguments
                mesh_file_name char
                id_air_dom_string = "by_default_air"
                id_air_dom_number = 1
                air_mesh_size = 0
            end
            finalcode = fileread('__final.geo');
            % ---
            finalcode = GMSHWriter.write_string_parameter(finalcode,'id_air_dom_string',id_air_dom_string);
            finalcode = GMSHWriter.write_scalar_parameter(finalcode,'id_air_dom_number',id_air_dom_number);
            finalcode = GMSHWriter.write_scalar_parameter(finalcode,'air_mesh_size',air_mesh_size);
            % ---
            geocode = [newline finalcode newline];
            % ---
            % geocode = [newline ...
            %            finalcode newline ...
            %            'Save "' mesh_file_name '";' newline ...
            %            'Exit;' ...
            %            newline];
            % ---
        end
        %------------------------------------------------------------------
    end
    % --- Utility
    methods (Static)
        %------------------------------------------------------------------
        function geocode = write_scalar_parameter(geocode,pname,pvalue)
            arguments
                geocode char
                pname char
                pvalue 
            end
            pcode   = [pname ' = ' num2str(pvalue,16)];
            geocode = regexprep(geocode,['(?<!\w)' pname '(?!\w)[\s]*=(?!=)[\s]*[\w]*[^;]*'],pcode);
        end
        %------------------------------------------------------------------
        function geocode = write_vector_parameter(geocode,pname,pvalue)
            arguments
                geocode char
                pname char
                pvalue 
            end
            % ---
            pcode = [pname ' = {'];
            for i = 1:length(pvalue)
                pcode  = [pcode num2str(pvalue(i),16) ','];
                % if mod(i,10) == 0
                %     pcode = [pcode newline];
                % end
            end
            %pcode(end-1:end) = []; % ',newline'
            pcode(end) = []; % ','
            pcode = [pcode '}'];
            geocode = regexprep(geocode,['(?<!\w)' pname '(?!\w)[\s]*=(?!=)[\s]*[\w]*[^;]*'],pcode);
        end
        %------------------------------------------------------------------
        function geocode = write_string_parameter(geocode,pname,pvalue)
            arguments
                geocode char
                pname char
                pvalue char
            end
            pcode   = [pname ' = "' pvalue '"'];
            geocode = regexprep(geocode,['(?<!\w)' pname '(?!\w)[\s]*=(?!=)[\s]*[\w]*[^;]*'],pcode);
        end
        %------------------------------------------------------------------
    end
end