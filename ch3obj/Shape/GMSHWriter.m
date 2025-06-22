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
        function geocode = bbar(r,c,bcut,tcut,angle)
            arguments
                r = 1
                c = [0 0 0]
                bcut = 0
                tcut = 0
                angle = 360
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
        function geocode = rotate(origin,axis,angle,nb_copy)
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
            geocode = [geocode fileread('__rotate.geo')];
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
        function geocode = dilate(origin,scale,nb_copy)
            arguments
                origin  = [0, 0, 0]
                scale   = [1, 1, 1]
                nb_copy = 0
            end
            % ---
            geocode = newline;
            geocode = [geocode fileread('__dilate.geo')];
            % ---
            geocode = GMSHWriter.write_vector_parameter(geocode,'origin',origin);
            geocode = GMSHWriter.write_vector_parameter(geocode,'scale',scale);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'nb_copy',nb_copy);
            % ---
            geocode = [geocode newline];
            % ---
        end
        %------------------------------------------------------------------
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
                pname
                pvalue
            end
            pcode   = [pname ' = ' num2str(pvalue,16)];
            geocode = regexprep(geocode,[pname '[\s]*=(?!=)[\s]*[\w]*[^;]*'],pcode);
        end
        %------------------------------------------------------------------
        function geocode = write_vector_parameter(geocode,pname,pvalue)
            arguments
                geocode char
                pname
                pvalue
            end
            pcode  = [pname ' = ' ...
                      '{' num2str(pvalue(1),16) ', ' ...
                          num2str(pvalue(2),16) ', ' ...
                          num2str(pvalue(3),16) '}'];
            geocode   = regexprep(geocode,[pname '[\s]*=(?!=)[\s]*[\w]*[^;]*'],pcode);
        end
        %------------------------------------------------------------------
    end
end