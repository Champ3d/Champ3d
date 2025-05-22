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
        function vmax = maxvector(vector_array)
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
        function vmin = minvector(vector_array)
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
        function vtime = complex2time(vector_array,frequency,t)
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
        function s = dot(v1,v2)
            s = sum(v1 .* v2, 2);
        end
        %-------------------------------------------------------------------
    end
    % --- obj's methods
    methods
        %-------------------------------------------------------------------
        %-------------------------------------------------------------------
    end
end