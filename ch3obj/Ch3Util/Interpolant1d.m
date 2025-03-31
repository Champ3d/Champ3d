%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
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
        f
        df
        ddf
        dddf
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
        function val = fx(obj,x)
            if nargin < 2
                val = obj.f;
            else
                val = ppval(obj.f, x);
            end
        end
        % -----------------------------------------------------------------
        function val = dfx(obj,x)
            if nargin < 2
                val = obj.df;
            else
                val = ppval(obj.df, x);
            end
        end
        % -----------------------------------------------------------------
        function val = ddfx(obj,x)
            if nargin < 2
                val = obj.ddf;
            else
                val = ppval(obj.ddf, x);
            end
        end
        % -----------------------------------------------------------------
        function val = dddfx(obj,x)
            if nargin < 2
                val = obj.dddf;
            else
                val = ppval(obj.dddf, x);
            end
        end
        % -----------------------------------------------------------------
        function fx = build(obj)
            % ---
            if f_strcmpi(obj.algorithme,'makima')
                fx = makima(obj.xdata,obj.ydata);
            elseif f_strcmpi(obj.algorithme,'spline')
                fx = spline(obj.xdata,obj.ydata);
            elseif f_strcmpi(obj.algorithme,'pchip')
                fx = pchip(obj.xdata,obj.ydata);
            end
            % ---
            obj.f = fx;
            obj.df = f_dfpolynomial(obj.f);
            obj.ddf = f_dfpolynomial(obj.df);
            obj.dddf = f_dfpolynomial(obj.ddf);
            % ---
        end
    end
end