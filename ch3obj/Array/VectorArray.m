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
        function obj = VectorArray(value,args)
            arguments
                value = []
                args.parent_dom {mustBeA(args.parent_dom,{'PhysicalDom','MeshDom'})}
            end
            % ---
            obj = obj@Array;
            % ---
            if nargin > 0
                obj.value = value;
                if isfield(args,'parent_dom')
                    obj.parent_dom = args.parent_dom;
                end
            end
            % ---
        end
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