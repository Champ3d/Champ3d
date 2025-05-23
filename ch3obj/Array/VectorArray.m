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

classdef VectorArray < Array
    properties
        parent_dom
        value
    end
    % --- Contructor
    methods
        function obj = VectorArray(args)
            arguments
                args.parent_dom {mustBeA(args.parent_dom,{'PhysicalDom','MeshDom'})}
                args.value = []
            end
            % ---
            obj = obj@Array;
            % ---
            if nargin >1
                if ~isfield(args,'parent_dom')
                    error('#parent_dom must be given !');
                end
            end
            % ---
            obj <= args;
            % ---
        end
    end
    % --- Utilily Methods
    % --- array methods not for obj
    % --- not-cell row-vector column-array
    methods (Static)
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
                s = VectorArray.dot(varray,varray);
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
                s = VectorArray.dot(varray,varray);
                vcomplex = abs(sqrt(s)) .* varray ./ sqrt(s);
                vmin = imag(vcomplex);
            end
            % ---
        end
        %-------------------------------------------------------------------
        function vtime = at_time(vector_array,frequency,t)
            arguments
                vector_array
                frequency = 1
                t = 0
            end
            varray = Array.vector(vector_array);
            % ---
            if isreal(varray)
                vtime = varray;
            else
                mag = abs(varray);
                ang = angle(varray);
                vtime = mag .* cos(2*pi*frequency*t + ang);
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
    % --- Utilily Methods
    % --- array methods not for obj
    % --- cell/not-cell row-vector column-array (general purpose)
    methods (Static)
        %-------------------------------------------------------------------
        function s = dot(v1,v2)
            if iscell(v1) && iscell(v2)
                for i = 1:length(v1)
                    s{i} = VectorArray.dot(v1{i},v2{i});
                end
            elseif iscell(v1) && ~iscell(v2)
                for i = 1:length(v1)
                    s{i} = VectorArray.dot(v1{i},v2);
                end
            elseif ~iscell(v1) && iscell(v2)
                for i = 1:length(v2)
                    s{i} = VectorArray.dot(v1,v2{i});
                end
            else
                s = sum(v1 .* v2, 2);
            end
        end
        %-------------------------------------------------------------------
        function vxcoef = multiply(varray,tarray)
            arguments
                varray
                tarray
            end
            % ---
            if nargin <= 1
                vxcoef = varray;
                return
            end
            % ---
            [tarray, array_type] = Array.tensor(tarray);
            % ---
            if iscell(varray)
                %------------------------------------------------------
                for ic = 1:length(varray)
                    V = varray{ic};
                    if strcmpi(array_type,'scalar')
                        vxcoef{ic} = V .* tarray;
                    elseif strcmpi(array_type,'tensor')
                        vxc = zeros(size(V));
                        if size(vxc,2) == 3
                            vxc(:,1) = tarray(:,1,1) .* V(:,1) + ...
                                       tarray(:,1,2) .* V(:,2) + ...
                                       tarray(:,1,3) .* V(:,3);
                            vxc(:,2) = tarray(:,2,1) .* V(:,1) + ...
                                       tarray(:,2,2) .* V(:,2) + ...
                                       tarray(:,2,3) .* V(:,3);
                            vxc(:,3) = tarray(:,3,1) .* V(:,1) + ...
                                       tarray(:,3,2) .* V(:,2) + ...
                                       tarray(:,3,3) .* V(:,3);
                        elseif size(vxc,2) == 2
                            vxc(:,1) = tarray(:,1,1) .* V(:,1) + ...
                                       tarray(:,1,2) .* V(:,2);
                            vxc(:,2) = tarray(:,2,1) .* V(:,1) + ...
                                       tarray(:,2,2) .* V(:,2);
                        end
                        vxcoef{ic} = vxc;
                    end
                end
                %------------------------------------------------------
            else
                %------------------------------------------------------
                if strcmpi(array_type,'scalar')
                    vxcoef = varray .* tarray;
                elseif strcmpi(array_type,'tensor')
                    vxcoef = zeros(size(varray));
                    if size(vxcoef,2) == 3
                        vxcoef(:,1) = tarray(:,1,1) .* varray(:,1) + ...
                                      tarray(:,1,2) .* varray(:,2) + ...
                                      tarray(:,1,3) .* varray(:,3);
                        vxcoef(:,2) = tarray(:,2,1) .* varray(:,1) + ...
                                      tarray(:,2,2) .* varray(:,2) + ...
                                      tarray(:,2,3) .* varray(:,3);
                        vxcoef(:,3) = tarray(:,3,1) .* varray(:,1) + ...
                                      tarray(:,3,2) .* varray(:,2) + ...
                                      tarray(:,3,3) .* varray(:,3);
                    elseif size(vxcoef,2) == 2
                        vxcoef(:,1) = tarray(:,1,1) .* varray(:,1) + ...
                                      tarray(:,1,2) .* varray(:,2);
                        vxcoef(:,2) = tarray(:,2,1) .* varray(:,1) + ...
                                      tarray(:,2,2) .* varray(:,2);
                    end
                end
                 %------------------------------------------------------
            end
        end
        %-------------------------------------------------------------------
        function vout = conj(vector_array)
            if iscell(vector_array)
                for i = 1:length(vector_array)
                    vout{i} = conj(vector_array{i});
                end
            else
                vout = conj(vector_array);
            end
        end
        %-------------------------------------------------------------------
        function vout = uminus(vector_array)
            if iscell(vector_array)
                for i = 1:length(vector_array)
                    vout{i} = - vector_array{i};
                end
            else
                vout = - vector_array;
            end
        end
        %-------------------------------------------------------------------
    end

    % --- obj's methods
    methods
        %-------------------------------------------------------------------
        function set.value(obj,val)
            obj.value = Array.vector(val);
        end
        %-------------------------------------------------------------------
        function gindex = gindex(obj)
            gindex = obj.parent_dom.gindex;
        end
        %-------------------------------------------------------------------
    end
end