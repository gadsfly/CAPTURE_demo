%% Demo for Tadross lab behavioral analysis
% ---------------------------
% (C) Jesse D Marshall 2020
%     Harvard University

my_fps = 90; %what is the fps of the video we are analyzing?
%internal: check dependencies
[fList,pList] = matlab.codetools.requiredFilesAndProducts('pd_analysis_demo.m');


%% run the analysis
basedirectory = '/media/twd/dannce-pd/PDBmirror/merged_r01/merged_hr1_2/';
%input predictions in DANNCE format
animfilename = strcat(basedirectory,filesep,'predictions.mat');
%outputfile
animfilename_out = strcat(basedirectory,filesep,'ratception_struct.mat');

% input_params.SpineM_marker = 'centerBack';
% input_params.SpineF_marker = 'backHead';
% input_params.conversion_factor = 525; %mm/selman
input_params.repfactor = floor(300/my_fps);

%% preprocess the data
ratception_struct = preprocess_dannce(animfilename,animfilename_out,'taddy_mouse',input_params);

%% copy over camera information and metadata
predictionsfile = load(animfilename);
if isfield(predictionsfile,'cameras')
    predictionsfieldnames = fieldnames(predictionsfile);
    for lk=1:numel(predictionsfieldnames)
        ratception_struct.(predictionsfieldnames{lk}) = predictionsfile.(predictionsfieldnames{lk});
    end
end
save(strcat(basedirectory,filesep,'ratception_struct.mat'),'-struct','ratception_struct','-v7.3')

%%

ratception_struct.predictions = ratception_struct.markers_preproc;
ratception_struct.sample_factor = floor(300/my_fps);
ratception_struct.shift = 0;

%% do embedding
[analysisstruct,hierarchystruct] = CAPTURE_quickdemo(...
    strcat(basedirectory,filesep,'ratception_struct.mat'),...
    'taddy_mouse','my_coefficients','taddy_mouse');
save(strcat(basedirectory,filesep,'myanalysisstruct.mat'),'-struct','analysisstruct',...
    '-v7.3')
save(strcat(basedirectory,filesep,'myhierarchystruct.mat'),'-struct','hierarchystruct',...
    '-v7.3')

%% plot the tsne
plotfolder = strcat(basedirectory,filesep,'plots/');
mkdir(plotfolder)

h1=figure(608)
clf;
params.nameplot=0;
params.density_plot =1;
params.watershed = 1;
params.sorted = 0;
params.markersize = 0.2;
params.jitter = 0;
params.coarseboundary = 0;
analysisstruct.params.density_width=0.25;
analysisstruct.params.density_res=4001;
plot_clustercolored_tsne(analysisstruct,1,params.watershed,h1,params)
set(gcf,'renderer','painters')
%colorbar off
axis equal
set(gcf,'Position',([100 100 1100 1100]))
print('-dpng',strcat(plotfolder,'taddysne.png'),'-r1200')
print('-depsc',strcat(plotfolder,'taddysne.eps'),'-r1200')
