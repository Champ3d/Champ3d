%system("C:\Users\E248836Z\Downloads\gmsh-4.13.1-Windows64\gmsh-4.13.1-Windows64\gmsh.exe 2cylindres2x3spires.geo -parse_and_exit")
%
%
system("C:\Users\E248836Z\Downloads\getdp-3.5.0-Windows64c\getdp-3.5.0-Windows64\getdp.exe 2cylindres2x3spires.pro -solve MagStat -pos MagStat");

f=load("flux1.csv");