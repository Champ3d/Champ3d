function f_plot_line2d(line2d,p2d,varargin)


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
for i = 1:(nargin-2)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
% -------------------------------------------------------------------------

lenp = length(line2d);
if isempty(id)
    for i = 1:lenp
        plot([p2d(line2d(i).ips).x p2d(line2d(i).ipe).x],...
             [p2d(line2d(i).ips).y p2d(line2d(i).ipe).y],'k','Linewidth',2); hold on
        cx = (p2d(line2d(i).ips).x + p2d(line2d(i).ipe).x)/2;
        cy = (p2d(line2d(i).ips).y + p2d(line2d(i).ipe).y)/2;
        t = text(cx,cy,[line2d(i).id '|' num2str(line2d(i).nbi) '|' 'F' num2str(line2d(i).fixed)]); hold on
        t.Color = 'red';
        t.BackgroundColor = 'w';
    end
else
    for i = 1:lenp
        for j = 1:length(id)
            if strcmpi(line2d(i).id,id{j})
                plot([p2d(line2d(i).ips).x p2d(line2d(i).ipe).x],...
                     [p2d(line2d(i).ips).y p2d(line2d(i).ipe).y],'k','Linewidth',2); hold on
                cx = (p2d(line2d(i).ips).x + p2d(line2d(i).ipe).x)/2;
                cy = (p2d(line2d(i).ips).y + p2d(line2d(i).ipe).y)/2;
                t = text(cx,cy,[line2d(i).id '|' num2str(line2d(i).nbi) '|' 'F' num2str(line2d(i).fixed)]); hold on
                t.Color = 'red';
                t.BackgroundColor = 'w';
            end
        end
    end
end
hold off;



