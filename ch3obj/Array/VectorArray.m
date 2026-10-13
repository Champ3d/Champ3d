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
    
    % --- obj's methods - ([...])
    methods
        %-------------------------------------------------------------------
        function vaout = subsref(obj,lidstruct)
            % ---
            % taobj([...])
            % taobj([])
            % ---
            switch lidstruct(1).type
                case '()'
                    if isempty(lidstruct(1).subs)
                        lindex = 1:size(obj.value,1);
                    else
                        lindex = lidstruct(1).subs{1};
                    end
                    % ---
                    if isempty(lindex)
                        val = [];
                    else
                        val = obj.value(lindex,:);
                    end
                    % ---
                    vaout = obj';
                    vaout.value = val;
                    % ---
                otherwise
                    % builtin behavior
                    try
                        vaout = builtin('subsref', obj, lidstruct);
                    catch
                        builtin('subsref', obj, lidstruct);
                    end
            end
        end
    end

    % --- set/get
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
        function value = uplus(obj)
            value = obj.value;
        end
        %-------------------------------------------------------------------
    end

    % --- operators (overload)
    methods
        %-------------------------------------------------------------------
        function objout = uminus(obj)
            objout = VectorArray(- obj.value);
        end
        %-------------------------------------------------------------------
        function objout = norm(obj)
            objout = VectorArray(Array.norm(obj.value));
        end
        %-------------------------------------------------------------------
        function objout = normalize(obj)
            objout = VectorArray(Array.normalize(obj.value));
        end
        %-------------------------------------------------------------------
        function objout = conj(obj)
            objout = VectorArray(conj(obj.value));
        end
        %-------------------------------------------------------------------
        function objout = real(obj)
            objout = VectorArray(real(obj.value));
        end
        %-------------------------------------------------------------------
        function objout = imag(obj)
            objout = VectorArray(imag(obj.value));
        end
        %-------------------------------------------------------------------
        function objout = plus(obj1,obj2)
            objout = VectorArray(obj1.value + obj2.value);
        end
        %-------------------------------------------------------------------
        function objout = minus(obj1,obj2)
            objout = VectorArray(obj1.value - obj2.value);
        end
        %-------------------------------------------------------------------
    end
end