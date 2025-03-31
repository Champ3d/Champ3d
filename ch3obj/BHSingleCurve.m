%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef BHSingleCurve < Xhandle
    properties
        b
        h
        % --- added for interpolation
        hlarge = 200e3
        % --- Steinmetz coef in harmonic
        alpha
        beta
        k
        % ---
        fmurb
        fbh
        fdbdh
    end
    properties (Access=private)
        is_build = 0
    end
    % --- Constructor
    methods
        function obj = BHSingleCurve(args)
            arguments
                args.b
                args.h
                % ---
                args.hlarge = 200e3
                % ---
                args.alpha = 0
                args.beta = 0
                args.k = 0
            end
            % ---
            obj@Xhandle;
            % ---
            obj <= args;
            % ---
        end
    end
    % --- Methods/public
    methods (Access = public)
        function build(obj)
            % ---
            h_ = f_torowv(obj.h);
            b_ = f_torowv(obj.b);
            % ---
            [h_, i] = sort(h_);
            b_ = b_(i);
            % ---
            [h_, i] = unique(h_);
            b_ = b_(i);
            % ---
            [b_, i] = unique(b_);
            h_ = h_(i);
            % ---
            i0 = find(h_ > 0);
            h_ = [0 h_(i0)];
            b_ = [0 b_(i0)];
            % ---
            nb_point = 2 * length(h_);
            hdata = linspace(min(h_),max(h_),nb_point);
            bdata = interp1(h_,b_,hdata);
            % ---
            h_ = f_torowv(hdata);
            b_ = f_torowv(bdata);
            % ---
            mu0 = 4*pi*1e-7;
            mmax = b_(end)/mu0 - h_(end);
            % ---
            nbpt = 20;
            h2   = linspace(h_(end),obj.hlarge,nbpt);
            b2   = mu0 .* (h2 + mmax);
            h_ = [h_(1:end-1), h2];
            b_ = [b_(1:end-1), b2];
            % ---
            dBdHdata = diff(b_) ./ diff(h_);
            fx = Interpolant1d('xdata',h_,'ydata',b_,'algorithme','makima');
            fx.build;
            dfx = Interpolant1d('xdata',h_(1:end-1),'ydata',dBdHdata,'algorithme','makima');
            dfx.build;
            % ---
            obj.fbh = fx;
            obj.fdbdh = dfx;
            % ---
        end
    end
end