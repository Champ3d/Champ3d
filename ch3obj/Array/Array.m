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

classdef (Abstract) Array < Xhandle
    % --- Contructor
    methods
        function obj = Array()
            obj = obj@Xhandle;
        end
    end
    % --- Utilily Methods - creat/format
    methods (Static, Sealed)
        %-------------------------------------------------------------------
        function array_type = type(array)
            array_type = [];
            s = size(array);
            lens = length(s);
            % ---
            if lens == 2
                if s(2) == 1
                    array_type = 'scalar';
                elseif s(2) == 2 || s(2) == 3
                    array_type = 'vector';
                end
            elseif lens == 3
                if isequal(s(2:3),[2 2]) || isequal(s(2:3),[3 3])
                    array_type = 'tensor';
                end
            end
            % ---
            if isempty(array_type)
                f_fprintf(1,'/!\\',0,'array_type undefined, not conform to n x dim, n x dim x dim \n');
                error('array_type undefined');
            end
        end
        %-------------------------------------------------------------------
        function [varray, array_type] = vector(array,args)
            arguments
                array
                args.nb_elem = 1
            end
            % ---
            nb_elem = args.nb_elem;
            array = squeeze(array); % !!!
            % ---
            s = size(array);
            if length(s) >= 3
                error('#array is not a vector array !');
            end
            % ---
            if isequal(s,[1 2]) || isequal(s,[2 1]) || ...
               isequal(s,[1 3]) || isequal(s,[3 1])
                array = f_torowv(array);
                varray = repmat(array,[nb_elem,1]);
            elseif isequal(s,[2 2]) || isequal(s,[3 3])
                f_fprintf(1,'/!\\',0,'vector-array input understood as [n x dim] \n');
                varray = array;
            elseif s(1) < s(2) && s(1) <= 3
                f_fprintf(1,'/!\\',0,'vector-array input understood as [dim x n] --> output [n x dim] \n');
                varray = permute(array,[2 1]);
            elseif s(2) < s(1) && s(2) <= 3
                varray = array;
            else
                error('#array is not a vector array !');
            end
            % ---
            array_type = 'vector';
        end
        %-------------------------------------------------------------------
        function [tarray, array_type] = tensor(array,args)
            arguments
                array
                args.nb_elem = 1
            end
            % ---
            nb_elem = args.nb_elem;
            array = squeeze(array); % !!!
            % ---
            s = size(array);
            if length(s) >= 4
                error('#array is not a scalar/tensor array !');
            end
            % ---
            if length(s) == 2 && min(s) == 1
                if numel(array) == 1
                    tarray = repmat(array,[nb_elem,1]);
                    array_type = 'scalar';
                else
                    tarray = f_tocolv(array);
                    array_type = 'scalar';
                end
            else
                if isequal(s,[2 2]) || isequal(s,[3 3])
                    tarray = permute(reshape(repmat(array,[1,nb_elem]),[s nb_elem]),[3 1 2]);
                    array_type = 'tensor';
                elseif isequal(s,[2 2 2]) || isequal(s,[3 3 3])
                    f_fprintf(1,'/!\\',0,'tensor input array understood as [n x dim x dim] \n');
                    tarray = array;
                    array_type = 'tensor';
                elseif s(1) == s(2) && s(1) <= 3
                    f_fprintf(1,'/!\\',0,'tensor input array understood as [dim x dim x n] --> output [n x dim x dim] \n');
                    tarray = permute(array,[3 1 2]);
                    array_type = 'tensor';
                elseif s(1) == s(3) && s(1) <= 3
                    f_fprintf(1,'/!\\',0,'tensor input array understood as [dim x n x dim] --> output [n x dim x dim] \n');
                    tarray = permute(array,[2 1 3]);
                    array_type = 'tensor';
                elseif s(2) == s(3) && s(2) <= 3
                    tarray = array;
                    array_type = 'tensor';
                else
                    error('#array is not a scalar/tensor array !');
                end
            end
        end
        %-------------------------------------------------------------------
    end

    % --- Utilily Methods - for vector array
    methods (Static, Sealed)
        %-------------------------------------------------------------------
        function s = dot(v1,v2)
            v1 = Array.vector(v1);
            v2 = Array.vector(v2);
            % ---
            s = sum(v1 .* v2, 2);
        end
        %-------------------------------------------------------------------
        function varray = normalize(vector_array)
            varray = Array.vector(vector_array);
            % ---
            VM = sqrt(sum(varray.^2, 2)); % 2-position !!
            varray = varray ./ VM;
            varray(VM <= eps,:) = 0;
        end
        %-------------------------------------------------------------------
        function vnorm = norm(vector_array)
            varray = Array.vector(vector_array);
            % ---
            if isreal(varray)
                vnorm = sqrt(sum(varray.^2, 2)); % 2-position !!
                vnorm(abs(vnorm) <= eps) = 0;
            else
                % --- max
                vnorm = sqrt(sum(varray .* conj(varray), 2)); % 2-position !!
                vnorm(abs(vnorm) <= eps) = 0;
            end
        end
        %-------------------------------------------------------------------
        function vmax = max(vector_array)
            % --- make sense for complex vector
            varray = Array.vector(vector_array);
            % ---
            if isreal(varray)
                vmax = varray;
            else
                s = Array.dot(varray,varray);
                vcomplex = abs(sqrt(s)) .* varray ./ sqrt(s);
                vmax = real(vcomplex);
            end
            % ---
        end
        %-------------------------------------------------------------------
        function vmin = min(vector_array)
            % --- make sense for complex vector
            varray = Array.vector(vector_array);
            % ---
            if isreal(varray)
                vmin = varray;
            else
                s = Array.dot(varray,varray);
                vcomplex = abs(sqrt(s)) .* varray ./ sqrt(s);
                vmin = imag(vcomplex);
            end
            % ---
        end
        %-------------------------------------------------------------------
        function vtime = at_time(vector_array,time_fraction_of_one_period)
            arguments
                vector_array
                time_fraction_of_one_period = 0
            end
            varray = Array.vector(vector_array);
            % ---
            if isreal(varray)
                vtime = varray;
            else
                mag = abs(varray);
                ang = angle(varray);
                vtime = mag .* cos(2*pi*time_fraction_of_one_period + ang);
            end
            % ---
        end
        %-------------------------------------------------------------------
        function vrot = rotaroundaxis(vector_array,rot_axis,rot_angle)
            arguments
                vector_array
                rot_axis
                rot_angle
            end
            % ---
            vector_array = Array.vector(vector_array);
            nb_elem = size(vector_array,1);
            dim = size(vector_array,2);
            % ---
            vrot = zeros(nb_elem,dim);
            for i = 1:nb_elem
                v = vector_array(i,:);
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
                vrot(i,:) = (R * v.').';
            end
            % ---
        end
        %-------------------------------------------------------------------
    end

    % --- Utilily Methods - for tensor array
    methods (Static, Sealed)
        %-------------------------------------------------------------------
        function tinv = inverse(tensor_array)
            % ---
            [tensor_array,array_type] = Array.tensor(tensor_array);
            if strcmpi(array_type,'scalar')
                tinv = 1./tensor_array;
            elseif strcmpi(array_type,'tensor')
                sizeg = size(tensor_array);
                dim = sizeg(2);
                % ---
                if dim == 2
                    % --- 
                    tinv = zeros(sizeg(1),2,2);
                    % ---
                    a11(1,:) = tensor_array(:,1,1);
                    a12(1,:) = tensor_array(:,1,2);
                    a21(1,:) = tensor_array(:,2,1);
                    a22(1,:) = tensor_array(:,2,2);
                    d = a11.*a22 - a21.*a12;
                    ix = find(d);
                    tinv(ix,1,1) = +1./d(ix).*a22(ix);
                    tinv(ix,1,2) = -1./d(ix).*a12(ix);
                    tinv(ix,2,1) = -1./d(ix).*a21(ix);
                    tinv(ix,2,2) = +1./d(ix).*a11(ix);
                    % ---
                elseif dim == 3
                    % --- 
                    tinv = zeros(sizeg(1),3,3);
                    % ---
                    a11(1,:) = tensor_array(:,1,1);
                    a12(1,:) = tensor_array(:,1,2);
                    a13(1,:) = tensor_array(:,1,3);
                    a21(1,:) = tensor_array(:,2,1);
                    a22(1,:) = tensor_array(:,2,2);
                    a23(1,:) = tensor_array(:,2,3);
                    a31(1,:) = tensor_array(:,3,1);
                    a32(1,:) = tensor_array(:,3,2);
                    a33(1,:) = tensor_array(:,3,3);
                    A11 = a22.*a33 - a23.*a32;
                    A12 = a32.*a13 - a12.*a33;
                    A13 = a12.*a23 - a13.*a22;
                    A21 = a23.*a31 - a21.*a33;
                    A22 = a33.*a11 - a31.*a13;
                    A23 = a13.*a21 - a23.*a11;
                    A31 = a21.*a32 - a31.*a22;
                    A32 = a31.*a12 - a32.*a11;
                    A33 = a11.*a22 - a12.*a21;
                    d = a11.*a22.*a33 + a21.*a32.*a13 + a31.*a12.*a23 - ...
                        a11.*a32.*a23 - a31.*a22.*a13 - a21.*a12.*a33;
                    ix = find(d);
                    tinv(ix,1,1) = 1./d(ix).*A11(ix);
                    tinv(ix,1,2) = 1./d(ix).*A12(ix);
                    tinv(ix,1,3) = 1./d(ix).*A13(ix);
                    tinv(ix,2,1) = 1./d(ix).*A21(ix);
                    tinv(ix,2,2) = 1./d(ix).*A22(ix);
                    tinv(ix,2,3) = 1./d(ix).*A23(ix);
                    tinv(ix,3,1) = 1./d(ix).*A31(ix);
                    tinv(ix,3,2) = 1./d(ix).*A32(ix);
                    tinv(ix,3,3) = 1./d(ix).*A33(ix);
                end
            end
        end
        %-------------------------------------------------------------------
    end

    % --- Utilily Methods - for vector+tensor array
    methods (Static, Sealed)
        %-------------------------------------------------------------------
        function aout = multiply(array1,array2)
            arguments
                array1
                array2
            end
            type1 = Array.type(array1);
            type2 = Array.type(array2);
            if strcmpi(type1,'scalar') && strcmpi(type2,'scalar') || ...
               strcmpi(type1,'scalar') && strcmpi(type2,'vector') || ...
               strcmpi(type1,'scalar') && strcmpi(type2,'tensor') || ...
               strcmpi(type1,'vector') && strcmpi(type2,'scalar') || ...
               strcmpi(type1,'tensor') && strcmpi(type2,'scalar')
                % ---
                aout = array1 .* array2;
                % ---
            elseif strcmpi(type1,'vector') && strcmpi(type2,'vector')
                aout = sum(array1 .* array2, 2);
            elseif strcmpi(type1,'vector') && strcmpi(type2,'tensor')
                %------------------------------------------------------
                aout = zeros(size(array1));
                if size(aout,2) == 3
                    aout(:,1) = array2(:,1,1) .* array1(:,1) + ...
                                array2(:,1,2) .* array1(:,2) + ...
                                array2(:,1,3) .* array1(:,3);
                    aout(:,2) = array2(:,2,1) .* array1(:,1) + ...
                                array2(:,2,2) .* array1(:,2) + ...
                                array2(:,2,3) .* array1(:,3);
                    aout(:,3) = array2(:,3,1) .* array1(:,1) + ...
                                array2(:,3,2) .* array1(:,2) + ...
                                array2(:,3,3) .* array1(:,3);
                elseif size(aout,2) == 2
                    aout(:,1) = array2(:,1,1) .* array1(:,1) + ...
                                array2(:,1,2) .* array1(:,2);
                    aout(:,2) = array2(:,2,1) .* array1(:,1) + ...
                                array2(:,2,2) .* array1(:,2);
                end
                 %------------------------------------------------------
            elseif strcmpi(type1,'tensor') && strcmpi(type2,'vector')
                aout = multiply(array2,array1);
            end
        end
        %-------------------------------------------------------------------
    end
end