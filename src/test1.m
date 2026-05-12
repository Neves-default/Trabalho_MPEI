%teste

amountOfData=1000;
fileName='DataSet.csv';
pathFile=fullfile('/home/neves-default/Secretária/universidade de Aveiro/2ºano/2º semestre/Metodos_probabilisticos_EI/Trabalho_Pratico/',fileName);
dataManager = DataSetManager(pathFile,amountOfData);

dataManager.loadData();
data=dataManager.getData();

disp(unique(data.class));