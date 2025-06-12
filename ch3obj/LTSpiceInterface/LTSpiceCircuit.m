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
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef LTSpiceCircuit < Xhandle
    properties
        net_file
        rawdata = []
        % ---
        I
        V
        % ---
        file
        circuit
        param
        net
        % --- options
        % opt
        % --- simulation options
        sim
        % ---
    end
    % --- Contructor
    methods
        function obj = LTSpiceCircuit(args)
            arguments
                args.net_file char
            end
            % ---
            obj = obj@Xhandle;
            % ---
            if ~contains(args.net_file,'.net')
                args.net_file = [args.net_file '.net'];
            end
            % ---
            if ~isfile(args.net_file)
                error([args.net_file ' not found !']);
            end
            % ---
            obj <= args;
            % ---
            obj.setup;
            % ---
        end
    end
    % ---
    methods
        function setup(obj)
            % ---
            obj.sim.tran = [];
            obj.sim.ac = [];
            obj.sim.dc = [];
            obj.sim.noise = [];
            obj.sim.tf = [];
            obj.sim.op = [];
            % ---
            [folderpath, netname, ~] = fileparts(which(obj.net_file));
            % ---
            obj.file.FOLDER_path = folderpath;
            % --- TRAN
            newnetname = [netname 'xCh3TRAN'];
            obj.file.tran.NET_name   = [newnetname '.net'];
            obj.file.tran.RAW_name   = [newnetname '.raw'];
            obj.file.tran.OPRAW_name = [newnetname '.op.raw'];
            obj.file.tran.LOG_name   = [newnetname '.log'];
            obj.file.tran.NET_file   = [folderpath '/' obj.file.tran.NET_name];
            obj.file.tran.RAW_file   = [folderpath '/' obj.file.tran.RAW_name];
            obj.file.tran.OPRAW_file = [folderpath '/' obj.file.tran.OPRAW_name];
            obj.file.tran.LOG_file   = [folderpath '/' obj.file.tran.LOG_name];
            % --- AC
            newnetname = [netname 'xCh3AC'];
            obj.file.ac.NET_name   = [newnetname '.net'];
            obj.file.ac.RAW_name   = [newnetname '.raw'];
            obj.file.ac.OPRAW_name = [newnetname '.op.raw'];
            obj.file.ac.LOG_name   = [newnetname '.log'];
            obj.file.ac.NET_file   = [folderpath '/' obj.file.ac.NET_name];
            obj.file.ac.RAW_file   = [folderpath '/' obj.file.ac.RAW_name];
            obj.file.ac.OPRAW_file = [folderpath '/' obj.file.ac.OPRAW_name];
            obj.file.ac.LOG_file   = [folderpath '/' obj.file.ac.LOG_name];
            % --- DC
            newnetname = [netname 'xCh3DC'];
            obj.file.dc.NET_name   = [newnetname '.net'];
            obj.file.dc.RAW_name   = [newnetname '.raw'];
            obj.file.dc.OPRAW_name = [newnetname '.op.raw'];
            obj.file.dc.LOG_name   = [newnetname '.log'];
            obj.file.dc.NET_file   = [folderpath '/' obj.file.dc.NET_name];
            obj.file.dc.RAW_file   = [folderpath '/' obj.file.dc.RAW_name];
            obj.file.dc.OPRAW_file = [folderpath '/' obj.file.dc.OPRAW_name];
            obj.file.dc.LOG_file   = [folderpath '/' obj.file.dc.LOG_name];
            % --- NOISE
            newnetname = [netname 'xCh3NOISE'];
            obj.file.noise.NET_name   = [newnetname '.net'];
            obj.file.noise.RAW_name   = [newnetname '.raw'];
            obj.file.noise.OPRAW_name = [newnetname '.op.raw'];
            obj.file.noise.LOG_name   = [newnetname '.log'];
            obj.file.noise.NET_file   = [folderpath '/' obj.file.noise.NET_name];
            obj.file.noise.RAW_file   = [folderpath '/' obj.file.noise.RAW_name];
            obj.file.noise.OPRAW_file = [folderpath '/' obj.file.noise.OPRAW_name];
            obj.file.noise.LOG_file   = [folderpath '/' obj.file.noise.LOG_name];
            % --- TF
            newnetname = [netname 'xCh3TF'];
            obj.file.tf.NET_name   = [newnetname '.net'];
            obj.file.tf.RAW_name   = [newnetname '.raw'];
            obj.file.tf.OPRAW_name = [newnetname '.op.raw'];
            obj.file.tf.LOG_name   = [newnetname '.log'];
            obj.file.tf.NET_file   = [folderpath '/' obj.file.tf.NET_name];
            obj.file.tf.RAW_file   = [folderpath '/' obj.file.tf.RAW_name];
            obj.file.tf.OPRAW_file = [folderpath '/' obj.file.tf.OPRAW_name];
            obj.file.tf.LOG_file   = [folderpath '/' obj.file.tf.LOG_name];
            % --- OP
            newnetname = [netname 'xCh3OP'];
            obj.file.op.NET_name   = [newnetname '.net'];
            obj.file.op.RAW_name   = [newnetname '.raw'];
            obj.file.op.OPRAW_name = [newnetname '.op.raw'];
            obj.file.op.LOG_name   = [newnetname '.log'];
            obj.file.op.NET_file   = [folderpath '/' obj.file.op.NET_name];
            obj.file.op.RAW_file   = [folderpath '/' obj.file.op.RAW_name];
            obj.file.op.OPRAW_file = [folderpath '/' obj.file.op.OPRAW_name];
            obj.file.op.LOG_file   = [folderpath '/' obj.file.op.LOG_name];
            % ---
            try
                filetext = fileread(obj.net_file);
            catch
                f_fprintf(1,'/!\\',0,'can not read ',1,obj.net_file,0,'\n');
                return
            end
            % ---
            all_line = regexp(filetext,'[^\n]*','match');
            % ---
            param_line = {};
            tran_line = {};
            circuit_line = {};
            ac_line = {};
            dc_line = {};
            noise_line = {};
            tf_line = {};
            op_line = {};
            % ---
            for i = 1:length(all_line)
                % ---
                current_line = all_line{i};
                % ---
                if contains(current_line,'.param')
                    param_line{end+1} = current_line;
                elseif contains(current_line,'.tran')
                    tran_line{end+1} = current_line;
                elseif contains(current_line,'.ac')
                    ac_line{end+1} = current_line;
                elseif contains(current_line,'.dc')
                    dc_line{end+1} = current_line;
                elseif contains(current_line,'.noise')
                    noise_line{end+1} = current_line;
                elseif contains(current_line,'.tf')
                    tf_line{end+1} = current_line;
                elseif contains(current_line,'.op')
                    op_line{end+1} = current_line;
                elseif ~contains(current_line,'.')
                    circuit_line{end+1} = current_line;
                end
            end
            % ---
            for i = 1:length(param_line)
                cell_p_exp = regexp(param_line{i},'[\w]*[\s]*=[\s]*[\w]*','match');
                for j = 1:length(cell_p_exp)
                    % ---
                    p_exp = split(regexprep(cell_p_exp{j},'[\s]*',''),'=');
                    % ---
                    obj.param.(p_exp{1}) = str2double(p_exp{2});
                end
            end
            % ---
            obj.circuit = circuit_line;
            % ---
            obj.net.original.param_line = param_line;
            obj.net.original.tran_line = tran_line;
            obj.net.original.circuit_line = circuit_line;
            obj.net.original.ac_line = ac_line;
            obj.net.original.dc_line = dc_line;
            obj.net.original.noise_line = noise_line;
            obj.net.original.tf_line = tf_line;
            obj.net.original.op_line = op_line;
            % ---
        end
    end
    % ---
    methods
        %--------------------------------------------------------------------------
        function run(obj,simulation)
            arguments
                obj
                simulation {mustBeMember(simulation,{'tran','ac','dc','tf','noise','op'})} = 'tran'
            end
            % ---
            switch simulation
                case 'tran'
                    obj.run_tran;
                case 'ac'
                case 'dc'
                case 'tf'
                case 'noise'
                case 'op'
            end
        end
        %--------------------------------------------------------------------------
        function run_tran(obj)
            % --- write
            obj.write_tran;
            % --- delete old data
            system(['rm ' obj.file.tran.RAW_file ' ' ...
                          obj.file.tran.OPRAW_file ' ' ...
                          obj.file.tran.LOG_file]);
            % ---
            call_LTSpice_run = [Ch3Config.ExecutableLTSpiceLocation ' -b ' obj.file.tran.NET_file];
            % ---
            try
                status = system(call_LTSpice_run);
                if status == 0
                    k = 0;
                    while ~isfile(obj.file.tran.RAW_file)
                        if k == 0
                            f_fprintf(0,'Waiting RAW file \n');
                        end
                        k = 1;
                    end
                    % ---
                    obj.rawdata = LTspice2Matlab(obj.file.tran.RAW_file);
                end
            catch
                f_fprintf(1,'/!\\',0,'can not run ',1,obj.file.tran.NET_file,0,'\n');
                return
            end
            % ---
        end
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
    end
    % ---
    methods (Access = private)
        function write_tran(obj)
            % ---
            system(['rm ' obj.file.tran.NET_file]);
            % --- 
            try 
                fileID = fopen(obj.file.tran.NET_file,'w');
            catch
                fclose('all');
                f_fprintf(1,'/!\\',0,'can not write, check file name',1,obj.file.tran.NET_file,0,'\n');
                return
            end
            % --- header with *
            fprintf(fileID,'%s \n',['*' obj.file.tran.NET_name]);
            % --- param
            all_param = fieldnames(obj.param);
            for i = 1:length(all_param)
                pname  = all_param{i};
                pvalue = obj.param.(pname);
                fprintf(fileID,'.param %s = %.18f \n',pname,pvalue);
            end
            % --- circuit
            for i = 1:length(obj.circuit)
                fprintf(fileID,'%s \n',obj.circuit{i});
            end
            % --- tran
            if isempty(obj.sim.tran)
                for i = 1:length(obj.net.original.tran_line)
                    fprintf(fileID,'%s \n',obj.net.original.tran_line{i});
                end
            else
                % --- XTODO
            end
            % --- end of file
            fprintf(fileID,'%s \n','.backanno');
            fprintf(fileID,'%s \n','.end');
            % --- close file
            fclose('all');
        end
    end
end