function [ params ] = loadConfig()
%LOADCONFIG Loads config file 'config.yaml'. Requires YAMLMatlab toolbox.
%
% Syntax: 
% params = LOADCONFIG()
% 
% Output:
% params - struct containing values read from config.yaml.

stepDetectFolder = fileparts(which('StepDetect.m'));
cfgFolder = fullfile(stepDetectFolder,'config');
cfgFile = fullfile(cfgFolder,'config.yaml');

params = ReadYaml(cfgFile);

end

