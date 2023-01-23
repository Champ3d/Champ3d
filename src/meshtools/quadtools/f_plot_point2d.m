function f_plot_point2d(p2d,varargin)


%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
cr = copyright();
if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
    error(' must add copyright file :( ');
end
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id'};

% --- default input value
id = [];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
% -------------------------------------------------------------------------

lenp = length(p2d);
if isempty(id)
    plot([p2d(:).x],[p2d(:).y],'sr','MarkerFaceColor','r'); hold on
    for i = 1:lenp
        text(p2d(i).x,p2d(i).y,p2d(i).id); hold on
    end
else
    for i = 1:lenp
        for j = 1:length(id)
            if strcmpi(p2d(i).id,id{j})
                plot(p2d(i).x,p2d(i).y,'sr','MarkerFaceColor','r'); hold on
                text(p2d(i).x,p2d(i).y,p2d(i).id); hold on
            end
        end
    end
end
hold off;



