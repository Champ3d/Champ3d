function clViewer = f_classviewer(ch3obj_path,options)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

arguments
    ch3obj_path = []
    options.addAllClasses = 0
end
% ---
clViewer = [];
% ---
if isempty(ch3obj_path)
    ch3obj_path = fileparts(which('Mesh.m'));
end
% ---
clNames = what(ch3obj_path);
clNames = clNames.m;
for i = 1:length(clNames)
    clNames{i} = replace(clNames{i},'.m','');
end
% ---
% clViewer = matlab.diagram.ClassViewer();
clViewer = matlab.diagram.ClassViewer('Folders',ch3obj_path);
% ---
if ~options.addAllClasses
    removeAllClasses(clViewer);
end
% ---
% for i = 1:length(clNames)
%     addClass(clViewer,clNames{i});
% end
