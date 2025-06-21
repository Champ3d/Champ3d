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
            bcut  = max(0, min(1, bcut));
            tcut  = max(0, min(1, tcut));
            angle = max(0, min(2*pi, angle*pi/180));
            % ---
            angle_1 = interp1([0 1], [-pi/2 0], bcut);
            angle_2 = interp1([1 0], [0 +pi/2], tcut);
            % ---
            geocode = fileread('BSphere_.geo');
            % ---
            
            % ---
            geocode = GMSHWriter.write_scalar_parameter(geocode,'radius',r);
            geocode = GMSHWriter.write_vector_parameter(geocode,'center',c);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'opening_angle_1',angle_1);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'opening_angle_2',angle_2);
            geocode = GMSHWriter.write_scalar_parameter(geocode,'opening_angle_3',angle);
            % ---
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function geocode = write_final(geocode,mesh_file_name)
            arguments
                geocode char
                mesh_file_name char
            end
            finalcode = fileread('final_.geo');
            finalcode = regexprep(finalcode,'Save[\s]*[\w]*[^;]*',['Save "' mesh_file_name '"']);
            geocode = [geocode newline finalcode];
        end
        %------------------------------------------------------------------
        function geocode = write_scalar_parameter(geocode,pname,pvalue)
            arguments
                geocode char
                pname
                pvalue
            end
            pcode   = [pname ' = ' num2str(pvalue,16)];
            geocode = regexprep(geocode,[pname '[\s]*=[\s]*[\w]*[^;]*'],pcode);
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
            geocode   = regexprep(geocode,[pname '[\s]*=[\s]*[\w]*[^;]*'],pcode);
        end
        %------------------------------------------------------------------
    end
end