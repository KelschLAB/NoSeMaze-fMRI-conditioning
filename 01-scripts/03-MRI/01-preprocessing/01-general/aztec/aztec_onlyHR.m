function [filenames, mean_HR, range_HR, X] = aztec_onlyHR(varargin)

% function [filenames, mean_HR, range_HR, X] = aztec(logfile, funcfiles, FS_Phys, TR, only_retroicor, ORI, output_dir)
%
% If called with no arguments: GUI invoked.
% 
% Version 1.0
% Thomas E. Gladwin, Mariet van Buuren, Matthijs Vink. 2007.

if length(varargin) == 7
    [filenames, mean_HR, range_HR, X] = executeInner(varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5}, varargin{6}, varargin{7});
    return;
end;

fprintf('Initializing GUI for aztec version 2.0\n');

global h logfile funcfiles; % define global variables
logfile = [];
funcfiles = [];
FS_Phys = [];
TR = [];
nScans = [];

figure;
clf;
set(gcf, 'Position', [50, 50, 2*170, 2*240]);
try,
    [BG, colormap] = imread('background.jpg');
    image(BG);
    set(gca, 'visible', 'off');
    set(gca, 'position', [0, 0, 1, 1]);
catch,
end;
set(gcf, 'Name', 'AZTEC');
% Organize controls
% log-file button and label
h.bLogfile = uicontrol('style','pushbutton','String','Select log file');
setpos(h.bLogfile, 0.8, 0.1, 3);
set(h.bLogfile, 'Callback', @selectLogFile);
h.eLogfile = uicontrol('style','edit','String','');
setpos(h.eLogfile, 0.8, 0.5, 17);
% func-files button and label
h.bFuncfiles = uicontrol('style','pushbutton','String','Select images');
setpos(h.bFuncfiles, 0.7, 0.1, 6);
set(h.bFuncfiles, 'Callback', @selectFuncFiles);
h.tFuncfiles = uicontrol('style','text','String','Not selected');
setpos(h.tFuncfiles, 0.7, 0.5, 17);
% Sample rate phys text and editbox
h.tFS_Phys = uicontrol('style','text','String','Sampling rate [Hz]');
setpos(h.tFS_Phys, 0.6, 0.1, 3);
h.eFS_Phys = uicontrol('style','edit','String','500');
setpos(h.eFS_Phys, 0.6, 0.5, 5);
% TR text and editbox
h.tTR = uicontrol('style','text','String','TR [ms]');
setpos(h.tTR, 0.5, 0.1, 3);
h.eTR = uicontrol('style','edit','String','2000');
setpos(h.eTR, 0.5, 0.5, 5);
% only_retroicor toggle
h.toggle0 = uicontrol('style','toggle','String','Only RETROICOR');
setpos(h.toggle0, 0.4, 0.1, 12);
% ORI text and editbox
h.tORI = uicontrol('style','text','String','Output directory');
setpos(h.tORI, 0.3, 0.1, 12);
h.eORI = uicontrol('style','edit','String','/data/thomas/');
setpos(h.eORI, 0.3, 0.5, 5);
% Execute and Quit
h.bExecute = uicontrol('style','pushbutton','String','EXECUTE');
set(h.bExecute, 'Callback', @executeOuter);
setpos(h.bExecute, 0.2, 0.1, 9);
h.bQuit = uicontrol('style','pushbutton','String','Quit', 'callback','closereq');
setpos(h.bQuit, 0.2, 0.7, 3);

function selectLogFile(obj, eventData)
global h logfile;
[filename, pathname] = uigetfile({'*.log'}, 'Pick a file');
logfile = [pathname filename];
set(h.eLogfile, 'String', filename);

function selectFuncFiles(obj, eventData)
global h funcfiles;
% funcfiles = spm_get([], '*.img');
% funcfiles = spm_select;
funcfiles = spm_select( Inf, 'image' );
set(h.tFuncfiles, 'String', 'Selected');

function executeOuter(obj, eventData)
global h logfile funcfiles;
FS_Phys = str2num(get(h.eFS_Phys, 'String'));
TR = str2num(get(h.eTR, 'String')) / 1000;
only_retroicor = get(h.toggle0, 'Value');
%output_dir = str2num(get(h.eORI, 'String'));
output_dir = get(h.eORI, 'String');
fprintf('Running, please wait...');
if ~iscell(funcfiles),
    funcfiles=cellstr(funcfiles);
end;
[outputfiles, mean_HR, range_HR, X] = executeInner(logfile, funcfiles, FS_Phys, TR, only_retroicor, 1 / 128, output_dir);
fprintf('Correction complete, aztecX saved to workspace.');
assignin('base','aztecX',X);

function setpos(uic0, row, col, minwidth)
fig_pos = get(gcf, 'Position');
p = get(uic0, 'Position');
p(1) = col * fig_pos(3); 
p(2) = row * fig_pos(4);
str = get(uic0, 'String');
content0 = (2/3) * length(str);
p(3) = get(uic0, 'FontSize') * max(minwidth, content0);
set(uic0, 'Position', p);

function [outputfiles, mean_HR, range_HR, X] = executeInner(logfile, funcfiles, FS_Phys, TR, only_retroicor, ORI, output_dir)
%fprintf('Running Aztec, HR_2HR version.\n');
nScans = length(funcfiles);
% Read log file
[X, measures, scan_vectortardet] = parseLog(logfile, TR, FS_Phys, nScans);
HR = X(:, 2);
HR(find(HR == 0)) = [];
mean_HR = mean(HR);
range_HR(1) = min(HR);
range_HR(2) = max(HR);
% Correction and maps
outputfiles = physcorr_onlyHR(funcfiles, X, TR, only_retroicor, ORI, output_dir);
