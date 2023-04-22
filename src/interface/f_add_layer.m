function layer = f_add_layer(layer,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% --- valid argument list (to be updated each time modifying function)
arglist = {'id_layer','thickness','nb_slice','z_type'};
%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No layer to add!']);
end
%--------------------------------------------------------------------------
% --- default input value
len = length(layer) + 1;
id_layer  = ['LayerNo' num2str(len)];
thickness = 0;
nb_slice  = 1;
z_type    = 'lin';
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
switch z_type(1:3)
    case 'log'
        if length(z_type) > 4
            p = str2double(z_type(5:end));
        else
            p = 1.3;
        end
        switch z_type(4)
            case '-'
                lthickness = logspace(0,p,nb_slice) * (thickness) ./ ...
                           sum(logspace(0,p,nb_slice));
                lthickness = lthickness(end:-1:1);
            case '+'
                lthickness = logspace(0,p,nb_slice) * (thickness) ./ ...
                           sum(logspace(0,p,nb_slice));
            case '='
                th1 = logspace(0,p,nb_slice) * (thickness/2) ./ ...
                           sum(logspace(0,p,nb_slice));
                th2 = logspace(0,p,nb_slice) * (thickness/2) ./ ...
                           sum(logspace(0,p,nb_slice));
                th2 = th2(end:-1:1);
                lthickness = [th1 th2];
            otherwise
        end
    case 'lin'
        lthickness  = thickness/nb_slice*ones(1,nb_slice);
    otherwise
        lthickness  = thickness/nb_slice*ones(1,nb_slice);
end
%--------------------------------------------------------------------------
% --- output
layer.(id_layer).nb_slice  = nb_slice;
layer.(id_layer).z_type    = z_type;
layer.(id_layer).thickness = lthickness;
% --- info message
fprintf(['Add ' id_layer ' - done \n']);

