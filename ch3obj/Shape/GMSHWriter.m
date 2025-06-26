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
    methods (Static)
        %------------------------------------------------------------------
        function geocode = bsphere(r,c,bcut,tcut,angle)
            arguments
                r = 1
                c = [0 0 0]
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
            if any(len == 0)
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
        function geocode = rotate_volume(origin,axis,angle,nb_copy)
            arguments
                origin  = [0, 0, 0]
                axis    = [0, 0, 0]
                angle   = 0
                nb_copy = 0
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
                nb_copy  = 0
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
                nb_copy = 0
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
                nb_copy  = 0
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
        %------------------------------------------------------------------
        function geocode = final(mesh_file_name)
            arguments
                mesh_file_name char
            end
            finalcode = fileread('__final.geo');
            geocode = [newline ...
                       finalcode newline ...
                       'Save "' mesh_file_name '";' newline ...
                       'Exit;' ...
                       newline];
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
                pcode  = [pcode num2str(pvalue(i),16) ', '];
                if mod(i,10) == 0
                    pcode = [pcode newline];
                end
            end
            pcode(end-1:end) = []; % ',newline'
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