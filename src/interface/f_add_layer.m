function layer = f_add_layer(layer,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
if isempty(layer)
    layer = [];
end

if nargin <= 1
    
    disp('No layer to add!')
    
else
    
    datin = [];
    for i = 1:(nargin-1)/2
        datin.(lower(varargin{2*i-1})) = varargin{2*i};
    end
    
    len = length(layer);
    len = len + 1;
    
    if ~isfield(datin,'id_layer')
        layer(len).id_layer = ['XXLayerNo' num2str(len)];
    else
        layer(len).id_layer = datin.id_layer;
    end
    
    if ~isfield(datin,'z_type')
        datin.z_type = 'lin';
        layer(len).z_type = 'lin';
    else
        layer(len).z_type = datin.z_type;
    end
    
    switch datin.z_type(1:3)
        case 'log'
            if length(datin.z_type) > 4
                p = str2double(datin.z_type(5:end));
            else
                p = 1.3;
            end
            switch datin.z_type(4)
                case '-'
                    layer(len).thickness = logspace(0,p,datin.nb_slice) * (datin.thickness) ./ ...
                               sum(logspace(0,p,datin.nb_slice));
                    layer(len).thickness = layer(len).thickness(end:-1:1);
                case '+'
                    layer(len).thickness = logspace(0,p,datin.nb_slice) * (datin.thickness) ./ ...
                               sum(logspace(0,p,datin.nb_slice));
                case '='
                    th1 = logspace(0,p,datin.nb_slice) * (datin.thickness/2) ./ ...
                               sum(logspace(0,p,datin.nb_slice));
                    th2 = logspace(0,p,datin.nb_slice) * (datin.thickness/2) ./ ...
                               sum(logspace(0,p,datin.nb_slice));
                    th2 = th2(end:-1:1);
                    layer(len).thickness = [th1 th2];
                otherwise
            end
        case 'lin'
            layer(len).thickness  = datin.thickness/datin.nb_slice*ones(1,datin.nb_slice);
        otherwise
            layer(len).thickness  = datin.thickness/datin.nb_slice*ones(1,datin.nb_slice);
    end
end