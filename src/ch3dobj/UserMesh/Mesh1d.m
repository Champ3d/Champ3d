%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Mesh1d < Xhandle

    % --- Properties
    properties
        id
        len
        dtype = 'lin'
        dnum = 1
        flog = 1.05
        node
        elem_code
    end
    % ---
    properties (Access = protected)
        is_build = 0;
    end

    % --- Dependent Properties
    properties (Dependent = true)

    end

    % --- Constructors
    methods
        function obj = Mesh1d(args)
            arguments
                args.id char = '0'
                args.len {mustBeNumeric}  = 0
                args.dtype = 'lin'
                args.dnum {mustBeInteger} = 1
                args.flog {mustBeNumeric} = 1.05
            end
            % ---
            obj <= args;
            % ---
            if obj.is_available(args,{'id','len','dtype','dnum','flog'})
                obj.build;
            end
        end
    end

    % --- Methods
    methods
        function build(obj)
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
            obj.elem_code = f_str2code(obj.id);
            obj.is_build = 1;
        end
    end
end











