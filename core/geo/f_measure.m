function meas = f_measure(node,elem,varargin)
% F_MEASURE returns the measure (length, area, volume)
%           of lines, surfaces and volumes.
%--------------------------------------------------------------------------
% meas = F_MEASURE(node,edge,'edge');
% meas = F_MEASURE(node,face,'face');
% meas = F_MEASURE(node,elem,'elem');
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'defined_on'};

% --- default input value
defined_on = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(defined_on)
    error([mfilename ': #defined_on must be given !']);
end
%--------------------------------------------------------------------------
nbElem = size(elem,2);
meas = zeros(1,nbElem);
switch defined_on
    case 'edge'
        vec = node(:,elem(2,:)) - node(:,elem(1,:));
        meas = f_norm(vec);
    case 'face'
        [filterface,id_face] = f_filterface(elem);
        for i = 1:length(filterface)
            nbVert = size(filterface{i},1);
            for j = 1:(nbVert-2)
                vec1 = node(:,filterface{i}(j+1,:)) - node(:,filterface{i}(1,:));
                vec2 = node(:,filterface{i}(j+2,:)) - node(:,filterface{i}(1,:));
                len1 = f_norm(vec1);
                len2 = f_norm(vec2);
                cosang = f_dot(vec1,vec2) ./ (len1 .* len2);
                sinang = sin(acos(cosang));
                meas(id_face{i}) = meas(id_face{i}) + ...
                                   1/2 .* len1 .* len2 .* sinang;
            end
        end
    case 'elem'
end






