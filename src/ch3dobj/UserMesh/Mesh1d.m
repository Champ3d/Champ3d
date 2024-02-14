%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Mesh1d < handle

    % --- Properties
    properties
        id
        len
        dtype = 'lin'
        dnum = 1
        flog = 1.05
        node
    end
    % ---
    properties (Access = protected)
        is_build = 0;
    end

    % --- Dependent Properties
    properties (Dependent = true)
        elem_code
    end

    % --- Constructors
    methods
        function obj = Mesh1d(args)
            arguments
                args.id char
                args.len {mustBeNumeric}
                args.dtype = 'lin'
                args.dnum {mustBeInteger} = 1
                args.flog {mustBeNumeric} = 1.05
            end
            % ---
            obj.id = args.id;
            obj.len = args.len;
            obj.dtype = args.dtype;
            obj.dnum = args.dnum;
            obj.flog = args.flog;
            % ---
        end
    end

    % --- Methods
    methods
        % ---
        function val = get.elem_code(obj)
            val = f_str2code(obj.id);
        end
        % ---
        function obj = build(obj)
            % ---
            if obj.is_build == 1
                return
            end
            %--------------------------------------------------------------
            len_   = obj.len;
            dnum_  = obj.dnum;
            dtype_ = obj.dtype;
            flog_  = obj.flog;
            %--------------------------------------------------------------
            if strcmpi(dtype_,'lin')
                ratio = dnum_;
                node_ = len_/ratio .* ones(1,ratio);
            end
            if strcmpi(dtype_,'log+') % || |  |   |
                ratio = logspace(0,flog_,dnum_)./sum(logspace(0,flog_,dnum_));
                node_ = len_ .* ratio;
            end
            if strcmpi(dtype_,'log-') % |   |  | ||
                ratio = logspace(0,flog_,dnum_)./sum(logspace(0,flog_,dnum_));
                node_ = len_ .* ratio;
                node_ = node_(end:-1:1);
            end
            if strcmpi(dtype_,'log+-') || strcmpi(dtype_,'log=') % || |  |   |   |  | ||
                dnum_  = dnum_ * 2;
                ratio = logspace(0,flog_,dnum_)./sum(logspace(0,flog_,dnum_));
                node_ = len_/2 .* ratio;
                node_ = [node_, node_(end:-1:1)];
            end
            if strcmpi(dtype_,'log-+') % |   |  | || |  |   |
                dnum_  = dnum_ * 2;
                ratio = logspace(0,flog_,dnum_)./sum(logspace(0,flog_,dnum_));
                node_ = len_/2 .* ratio;
                node_ = [node_(end:-1:1), node_];
            end
            %--------------------------------------------------------------
            obj.node = node_;
            obj.is_build = 1;
        end
    end
end











