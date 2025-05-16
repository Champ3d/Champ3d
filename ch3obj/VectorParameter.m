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

classdef VectorParameter < Parameter
    properties
        parent_model
        f
        depend_on
        from
        varargin_list
        fvectorized
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','f','depend_on','from','varargin_list','fvectorized'};
        end
    end
    % --- Contructor
    methods
        function obj = VectorParameter(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,{'PhysicalModel','CplModel'})}
                args.f = []
                args.depend_on {mustBeMember(args.depend_on,...
                    {'celem','cface','velem','sface','ledge',...
                     'J','V','I','Z','T','B','E','H','A','P','Phi',...
                     'ltime'})}
                args.from = []
                args.varargin_list = []
                args.fvectorized = 0
            end
            % ---
            obj = obj@Parameter;
            % ---
            if isnumeric(args.f)
                if isequal(s,[1 2]) || isequal(s,[2 1]) || ...
                   isequal(s,[1 3]) || isequal(s,[3 1])
                    args.f = f_tocolv(args.f);
                else
                    error('input is not a vector !');
                end
            end
            % ---
            argu = f_to_namedarg(args);
            obj.setup(argu{:});
            % -------------------------------------------------------------
        end
    end

    % --- Methods
    methods
        %------------------------------------------------------------------
        function vout = getvalue(obj,args)
            arguments
                obj
                args.in_dom = []
            end
            vout = getvalue@Parameter(obj,'in_dom',args.in_dom);
            vout = TensorArray.vector(vout);
            %--------------------------------------------------------------
            if any(isinf(vout))
                f_fprintf(1,'Value has Inf ! \n');
            end
            % --- 
            if any(isnan(vout))
                f_fprintf(1,'Value has NaN ! \n');
            end
            %--------------------------------------------------------------
        end
        %------------------------------------------------------------------
        function vout = get_inverse(obj,args)
            arguments
                obj
                args.in_dom = []
            end
            vout = obj.getvalue('in_dom',args.in_dom);
            vout = -vout;
        end
        %------------------------------------------------------------------
    end
end