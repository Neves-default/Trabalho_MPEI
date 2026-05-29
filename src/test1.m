%teste

amountOfData=100; %1000
fileName='sqlSpecObj.csv';
pathFile=fullfile('/Users/lemadti/UA/MPEI2026/Trabalho_MPEI',fileName);
dataManager = DataSetManager(pathFile,amountOfData);

dataManager.loadData();
data=dataManager.getData();

%disp(unique(data.class));
disp(data);