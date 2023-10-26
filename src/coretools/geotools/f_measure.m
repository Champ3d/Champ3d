function meas = f_measure(node,element,varargin)
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
arglist = {'node','edge','face','elem'};

% --- check and update input
if nargin > 2
    if any(strcmpi(arglist,varargin{1}))
        datin.element_type = varargin{1};
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
else
    error([mfilename ' : specify the element type: #edge, #face, #elem)']);
end

%--------------------------------------------------------------------------

nbElem = size(element,2);
meas = zeros(1,nbElem);
switch lower(datin.element_type)
    case 'edge'
        vec = node(:,element(2,:)) - node(:,element(1,:));
        meas = f_norm(vec);
    case 'face'
        [filterface,id_face] = f_filterface(element);
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






