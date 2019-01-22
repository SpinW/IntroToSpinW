%% How to produce constant energy cut of spin wave spectrum?
% This example shows how to calculate the spin wave spectrum of the square
% lattice Heisenberg antiferromagnet and to produce a constant energy cut
% of the spectrum.

%% Crystal & magnetic structure
% Using sw_model, the crystal and magnetic structure are readily available.
% Using the 'squareAF' option, a square lattice Heisenberg Antiferromagnet
% with S = 1 and J = 1 is created.

sq = sw_model('squareAF',1,0);

% add some magnetic form factor
%[~,Cf] = sw_mff('MCu2+',[],11);
sq.addatom('label','atom_1','r',[0 0 0],'formfactn',###,'S',1/2)

plot(sq)
swplot.zoom(2)

%% Plan the cut

% % start horace
% addpath(genpath('~/Documents/MATLAB/ISIS'))
herbert_init
horace_init

% Create empty D3D object, can be fake data generated during the Horace
% workshop.
d3dobj = d3d(sq.abc,[1 0 0 0],[-2,0.01,2],[0 1 0 0],[-2,0.01,2],[0 0 0 1],[0,0.1,10]);

% Fill the bins with the model calculation, convoluted a 0.1 meV FWHM
% Gaussian in energy
d3dobj = disp2sqw_eval(d3dobj,@sq.horace,{'component','Sperp','useMex',false,'formfact',true},0.3);


% Plot a constant energy cut
plot(cut(d3dobj,[],[],[3.8 4.2]))
colormap(flipud(cm_inferno))
colorslider('delete')

% Why is the intensity along (0K0) weaker than along (H00)?
% Is there a problem with the form factor calculation?
%
% Hint, check the 3D structure plot again...
%
% Let's compare the intensities along the two directions

Fact = 1;
amark o
acolor r
plot(cut(Fact*d3dobj,[-0.1 0.1],[],[0 5]))
acolor k
pm(cut(d3dobj,[],[-0.1 0.1],[0 5]))

% What is the intensity ratio along the two directions?
%

% 3D plot with sliceomatic, including isonormals
%plot(d3dobj,'isonormals',true)

%% Spin wave dispersion along a line
% We define a path in reciprocal space

G = [0     0 0];
X = [1/2   0 0];
M = [1/2 1/2 0];

nQ = 301;

spec = sq.spinwave({G X M G nQ});

figure
subplot(3,1,1)
sw_plotspec(spec,'colorbar',false);
% How many modes do you see? Why?
% Let's calculate color map
%

spec = sw_egrid(spec,'Evect',linspace(0,5,501));
subplot(3,1,2)
sw_plotspec(spec,'colorbar',false)

subplot(3,1,3)
sw_plotspec(spec,'mode','color','colorbar',false)
% What is going on here?

%% Let's convolute some energy resolution

spec = sw_instrument(spec,'dE',0.5);
figure
sw_plotspec(spec,'mode','color','dashed',true)
colormap(flipud(cm_inferno(100)))
caxis([0 0.1])
% change the labels
set(gca,'XTickLabel',{'\Gamma' 'X' 'M' '\Gamma'})
% remove legend
legend off

%% Let's do some powder average
% Cut out data with fixed Ei and lowest detector angle at ThetaMin = 5 deg.
%

sq.genlattice('lat_const',[6 6 9]);
spec = sq.powspec(linspace(0,2,101),'Evect',linspace(0,5,501),'nRand',3e3,'useMex',false,'formfact',true);
spec = sw_instrument(spec,'dE',0.2,'Ei',8,'thetaMin',5);
clf
sw_plotspec(spec,'mode','color','dE',0.2)
caxis([0 0.2])




