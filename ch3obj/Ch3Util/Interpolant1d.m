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

classdef Interpolant1d < Xhandle
    properties
        xdata
        ydata
        % ---
        algorithme
        % ---
        form
    end

    % --- Constructor
    methods
        function obj = Interpolant1d(args)
            arguments
                args.xdata = []
                args.ydata = []
                args.algorithme {mustBeMember(args.algorithme,{'makima','spline','pchip'})} = 'makima'
            end
            % ---
            obj@Xhandle;
            % ---
            x = args.xdata;
            y = args.ydata;
            % ---
            if isempty(y)
                x = 0;
                y = 0;
            else
                if isempty(x)
                    x = 1:length(y);
                end
            end
            % ---
            data = f_unique([f_torowv(x);f_torowv(y)]);
            % ---
            obj.xdata = data(1,:);
            obj.ydata = data(2,:);
            obj.algorithme = args.algorithme;
            % ---
        end
    end
    % --- Methods/public
    methods (Access = public)
        % -----------------------------------------------------------------
        function val = eval(obj,x)
            if nargin < 2
                val = obj.form.f;
            else
                val = ppval(obj.form.f, x);
            end
        end
        % -----------------------------------------------------------------
        function val = evaldf(obj,x)
            if nargin < 2
                val = obj.form.df;
            else
                val = ppval(obj.form.df, x);
            end
        end
        % -----------------------------------------------------------------
        function val = evalddf(obj,x)
            if nargin < 2
                val = obj.form.ddf;
            else
                val = ppval(obj.form.ddf, x);
            end
        end
        % -----------------------------------------------------------------
        function build(obj)
            % ---
            if f_strcmpi(obj.algorithme,'makima')
                fx = makima(obj.xdata,obj.ydata);
            elseif f_strcmpi(obj.algorithme,'spline')
                fx = spline(obj.xdata,obj.ydata);
            elseif f_strcmpi(obj.algorithme,'pchip')
                fx = pchip(obj.xdata,obj.ydata);
            end
            % ---
            obj.form.f = fx;
            obj.form.df = f_dfpolynomial(obj.form.f);
            obj.form.ddf = f_dfpolynomial(obj.form.df);
            % ---
        end
    end
end