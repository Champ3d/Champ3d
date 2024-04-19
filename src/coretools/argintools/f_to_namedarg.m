function validargs = f_to_namedarg(argsin,fargs)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

arguments
    argsin
    fargs.with_out = [];
    fargs.with_only = [];
end
% ---
with_out = fargs.with_out;
with_only = fargs.with_only;
%--------------------------------------------------------------------------
if iscell(argsin)
    argsin = f_to_scellargin(argsin);
    % ---
    if ~isempty(with_out)
        k = 0;
        validargs = [];
        for i = 1:length(argsin)/2
            if ~f_strcmpi(lower(argsin{2*i-1}),with_out)
                k = k + 1;
                validargs{2*k-1} = lower(argsin{2*i-1});
                validargs{2*k}   = argsin{2*i};
            end
        end
    elseif ~isempty(with_only)
        k = 0;
        validargs = [];
        for i = 1:length(argsin)/2
            if any(f_strcmpi(lower(argsin{2*i-1}),with_only))
                k = k + 1;
                validargs{2*k-1} = lower(argsin{2*i-1});
                validargs{2*k}   = argsin{2*i};
            end
        end
    else
        validargs = argsin;
    end
    %----------------------------------------------------------------------
elseif isstruct(argsin)
    %----------------------------------------------------------------------
    if ~isempty(with_out)
        validargs = {};
        arg_name = fieldnames(argsin);
        nb_arg = length(arg_name);
        k = 0;
        for i = 1:nb_arg
            arg_name_ = arg_name{i};
            if ~f_strcmpi(lower(arg_name_),with_out)
                k = k + 1;
                validargs{2*k - 1} = arg_name_;
                validargs{2*k}     = argsin.(arg_name_);
            end
        end
    elseif ~isempty(with_only)
        validargs = {};
        arg_name = fieldnames(argsin);
        nb_arg = length(arg_name);
        k = 0;
        for i = 1:nb_arg
            arg_name_ = arg_name{i};
            if any(f_strcmpi(lower(arg_name_),with_only))
                k = k + 1;
                validargs{2*k - 1} = arg_name_;
                validargs{2*k}     = argsin.(arg_name_);
            end
        end
    else
        validargs = {};
        arg_name = fieldnames(argsin);
        nb_arg = length(arg_name);
        for i = 1:nb_arg
            arg_name_ = arg_name{i};
            validargs{2*i - 1} = arg_name_;
            validargs{2*i}     = argsin.(arg_name_);
        end
    end
    %----------------------------------------------------------------------
else
    validargs = [];
end
