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

classdef CurveGo
    properties
        id = ''
        type
        len
        dnum
        lenx
        leny
        lenz
        angle
        center
        dir
        % ---
        vi
        vf
        div
        % ---
    end
    % --- Constructors
    methods
        function obj = CurveGo(args)
            arguments
                args.id = ''
                args.type {mustBeMember(args.type,{'xgo,ygo,zgo,xygo,xzgo,yzgo,xyzgo,ago_xy,ago_xz,ago_yz'})}
                args.len
                args.dnum
                args.lenx
                args.leny
                args.lenz
                args.angle
                args.center
                args.dir
            end
            obj.id = id;
        end
    end
    % ---
    methods
        
    end
end