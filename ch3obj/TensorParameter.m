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

classdef TensorParameter < Parameter
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','f','depend_on','from','varargin_list','fvectorized'};
        end
    end
    % --- Contructor
    methods
        function obj = TensorParameter(args)
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
                s = size(args.f);
                if ~isequal(s,[2 2]) && ~isequal(s,[3 3])
                    error('input is not a tensor !');
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
            vout = Array.tensor(vout);
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
            % ---
            vin = obj.getvalue('in_dom',args.in_dom);
            len = size(vin,1);
            dim = size(vin,2);
            % ---
            if dim == 2
                % --- 
                vout = zeros(len,2,2);
                % ---
                a11(1,:) = vin(:,1,1);
                a12(1,:) = vin(:,1,2);
                a21(1,:) = vin(:,2,1);
                a22(1,:) = vin(:,2,2);
                d = a11.*a22 - a21.*a12;
                ix = find(d);
                vout(ix,1,1) = +1./d(ix).*a22(ix);
                vout(ix,1,2) = -1./d(ix).*a12(ix);
                vout(ix,2,1) = -1./d(ix).*a21(ix);
                vout(ix,2,2) = +1./d(ix).*a11(ix);
            elseif dim == 3
                % --- 
                vout = zeros(len,3,3);
                % ---
                a11(1,:) = vin(:,1,1);
                a12(1,:) = vin(:,1,2);
                a13(1,:) = vin(:,1,3);
                a21(1,:) = vin(:,2,1);
                a22(1,:) = vin(:,2,2);
                a23(1,:) = vin(:,2,3);
                a31(1,:) = vin(:,3,1);
                a32(1,:) = vin(:,3,2);
                a33(1,:) = vin(:,3,3);
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
                vout(ix,1,1) = 1./d(ix).*A11(ix);
                vout(ix,1,2) = 1./d(ix).*A12(ix);
                vout(ix,1,3) = 1./d(ix).*A13(ix);
                vout(ix,2,1) = 1./d(ix).*A21(ix);
                vout(ix,2,2) = 1./d(ix).*A22(ix);
                vout(ix,2,3) = 1./d(ix).*A23(ix);
                vout(ix,3,1) = 1./d(ix).*A31(ix);
                vout(ix,3,2) = 1./d(ix).*A32(ix);
                vout(ix,3,3) = 1./d(ix).*A33(ix);
            end
            %--------------------------------------------------------------
            if any(isinf(vout))
                f_fprintf(1,'Inverse has Inf ! \n');
            end
            % --- 
            if any(isnan(vout))
                f_fprintf(1,'Inverse has NaN ! \n');
            end
            %--------------------------------------------------------------
        end
        %------------------------------------------------------------------
    end
end