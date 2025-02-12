function validargs = f_to_namedarg(args_in,fargs)
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
    args_in
    fargs.for {mustBeA(fargs.for,'char')} = ''
    fargs.with_out = []
    fargs.with_only = []
end
% ---
forname = fargs.for;
with_out = fargs.with_out;
with_only = fargs.with_only;
%--------------------------------------------------------------------------
validargslist = {};
if ~isempty(forname)
    % ---
    forname = split(forname,'.');
    cls_name = forname{1};
    % ---
    fun_name = [];
    if length(forname) > 1
        fun_name = forname{2};
    end
    % ---
    try
        metlist = methods(cls_name);
        if any(f_strcmpi('validargs',metlist))
            f2 = str2func([cls_name '.validargs']);
            if isempty(fun_name)
                validargslist = f2();
            else
                validargslist = f2(fun_name);
            end
        end
    catch
        % ---
    end
end
%--------------------------------------------------------------------------
args_in_key   = {};
args_in_value = {};
if iscell(args_in)
    args_in = f_to_scellargin(args_in);
    nb_arg = length(args_in)/2;
    % ---
    args_in_key = cell(nb_arg,1);
    args_in_value = cell(nb_arg,1);
    % ---
    for i = 1:nb_arg
        args_in_key{i} = lower(args_in{2*i-1});
        args_in_value{i} = args_in{2*i};
    end
elseif isstruct(args_in)
    arg_name = fieldnames(args_in);
    nb_arg = length(arg_name);
    % ---
    args_in_key = cell(nb_arg,1);
    args_in_value = cell(nb_arg,1);
    % ---
    for i = 1:nb_arg
        arg_name_ = arg_name{i};
        args_in_key{i} = arg_name_;
        args_in_value{i}   = args_in.(arg_name_);
    end
end
%--------------------------------------------------------------------------
if ~isempty(validargslist)
    i2rm = 1:length(args_in_key);
    i2rm = i2rm(~f_strcmpi(args_in_key,validargslist) == 1);
    args_in_key(i2rm) = [];
    args_in_value(i2rm) = [];
end
%--------------------------------------------------------------------------
if ~isempty(with_out)
    i2rm = 1:length(args_in_key);
    i2rm = i2rm(f_strcmpi(args_in_key,with_out) == 1);
    args_in_key(i2rm) = [];
    args_in_value(i2rm) = [];
elseif ~isempty(with_only)
    i2rm = 1:length(args_in_key);
    i2rm = i2rm(~f_strcmpi(args_in_key,with_only) == 1);
    args_in_key(i2rm) = [];
    args_in_value(i2rm) = [];
end
%--------------------------------------------------------------------------
nb_arg = length(args_in_key);
validargs = cell(nb_arg * 2, 1);
for i = 1:length(args_in_key)
    validargs{2*i - 1} = args_in_key{i};
    validargs{2*i}     = args_in_value{i};
end
%--------------------------------------------------------------------------