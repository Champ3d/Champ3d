%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
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

classdef CplAphiModelByODDM < CplModel

    properties
        scheme
        source
        load
    end

    % --- Constructor
    methods
        function obj = CplAphiModelByODDM(args)
            arguments
                args.source {mustBeA(args.source,'FEM3dAphi')}
                args.load
                args.scheme {mustBeMember(args.scheme,{'s-->l','s<-->l'})} = 's-->l'
            end
            % ---
            obj = obj@CplModel;
            % ---
            obj.scheme = args.scheme;
            % ---
            if isfield(args,'source')
                obj.source = args.source;
            end
            % ---
            if isfield(args,'load')
                if ~iscell(args.load)
                    if isa(args.load,'FEM3dAphi')
                        obj.load{1} = args.load;
                    end
                else
                    for i = 1:length(args.load)
                        if isa(args.load{i},'FEM3dAphi')
                            obj.load{i} = args.load{i};
                        end
                    end
                end
            end
            % ---
        end
    end

    % --- Methods / set
    methods
        % ---
        function set.source(obj,smodel)
            arguments
                obj
                smodel = []
            end
            % ---
            if isempty(smodel)
                f_fprintf(1,'No source added !');
                return
            end
            % ---
            if ~iscell(smodel)
                if isa(smodel,'FEM3dAphi')
                    obj.source{1} = smodel;
                else
                    error('#source must be a FEM3dAphi model !');
                end
            else
                for i = 1:length(smodel)
                    if isa(smodel{i},'FEM3dAphi')
                        obj.source{i} = smodel{i};
                    else
                        error('#source must be a FEM3dAphi model !');
                    end
                end
            end
            % ---
        end
        % ---
        function set.load(obj,lmodel)
            arguments
                obj
                lmodel = []
            end
            % ---
            if isempty(lmodel)
                f_fprintf(1,'No load added !');
                return
            end
            % ---
            if ~iscell(lmodel)
                if isa(lmodel,'FEM3dAphi')
                    obj.load{1} = lmodel;
                else
                    error('#load must be a FEM3dAphi model !');
                end
            else
                for i = 1:length(lmodel)
                    if isa(lmodel{i},'FEM3dAphi')
                        obj.load{i} = lmodel{i};
                    else
                        error('#load must be a FEM3dAphi model !');
                    end
                end
            end
            % ---
        end
        % ---
    end
    
    
    
    % --- Methods
    methods
        % ---
        function transfer(obj,smodel,lmodel)
            
        end
        % ---
    end
end