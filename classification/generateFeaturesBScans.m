function [featureCollection, description, pcaParams] = generateFeaturesBScans(DataDescriptors, Layers, Additional, Features, Types)
% Load all data (segmentations, age, diagnosis) that is necessary for
% creating feature files. Generate all the features according to the
% specifictions in the parameters. Generate the features names accordingly.
% 
% ToDo: Parameter description.

octsegConstantVariables;

featureCollection = cell(0,1);
dataAll = cell(1, 1);
validCount = 1;
classes = [];
age = [];

% Load the layer thickness data and the additional information
if(DataDescriptors.featureDataLoaded)
    featureCollection = DataDescriptors.FeatureData.featureCollection;
    dataAll = DataDescriptors.FeatureData.dataAll;
    classes = DataDescriptors.FeatureData.classes;
    age = DataDescriptors.FeatureData.age;
else
    for i = 1:numel(DataDescriptors.filenameList)
        [numDescriptor, openFuncHandle] = examineOctFile(DataDescriptors.pathname, ...
            [DataDescriptors.filenameList{i} DataDescriptors.filenameEnding]);
        if numDescriptor == 0
            disp([DataDescriptors.pathname DataDescriptors.filenameList{i} ': File is no OCT file.']);
            continue;
        end
        [Header, BScanHeader] = ...
            openFuncHandle([DataDescriptors.pathname DataDescriptors.filenameList{i} DataDescriptors.filenameEnding], 'header');
        
        class = loadClass(DataDescriptors.pathname, DataDescriptors.filenameList{i}, Features);
        if numel(class) == 0
            disp(['No Class data for ' DataDescriptors.filenameList{i} '! Skipping!']);
            continue;
        end
        adder = loadAdditional(DataDescriptors.pathname, DataDescriptors.filenameList{i}, Header, Additional);
        data = loadLayers(DataDescriptors.filenameList{i}, Header, DataDescriptors, Layers, Features);
        
        featureCollection{validCount, 1} = adder;
        featureCollection{validCount, 2} = class;
        classes(validCount) = class;
        dataAll{validCount} = data;
        age(validCount) = calculateAge(Header);
        % Missing: Preprocessing
        validCount = validCount + 1;
    end
end

if Features.ageNormalize
    dataAll = thicknessAgeNormalize(dataAll, age, classes, Features.ageNormalClass, Features.ageNormalizeSamples, Features.ageNormalizeRefAge);
end

featureDescription = getFeatureDescription(Types, Layers, Features);
featureTable = zeros(numel(dataAll), numel(featureDescription));

pcaCoeffsAll = [];
pcaCoeffsNormal = [];

if Types.pcaAll
    [pcaCoeffsAll, eigenValues] = calculatePCACoeffs(dataAll, classes, Features.pcaAllClasses, Features.numSamplesPCA);
    pcaParams.eigenValuesAll = eigenValues;
    pcaParams.coeffsAll = pcaCoeffsAll;
end

if Types.pcaNormal
    [pcaCoeffsNormal, eigenValues] = calculatePCACoeffs(dataAll, classes, Features.pcaNormalClasses, Features.numSamplesPCA);
    pcaParams.eigenValuesNormal = eigenValues;
    pcaParams.coeffsNormal = pcaCoeffsNormal;
end

for i = 1:numel(dataAll)
    featureData = calculateLayerFeatures(dataAll{i}, Types, Features, pcaCoeffsAll, pcaCoeffsNormal);
    featureTable(i, :) = featureData;
end

if Features.normalize
    featureTable = normalizeFeatures(featureTable);
end

for i = 1:size(featureTable, 1)
    featureCollection{i, 3} = featureTable(i,:);
end

% Make the descriptions of the Additional information / Features
adderDescription = getAdditonalDescription(Additional);
classDescription = Features.class;

description = cell(0, 1);
desCount = 1;
for i = 1:numel(adderDescription)
    description{desCount} = adderDescription{i};
    desCount = desCount + 1;
end
description{desCount} = classDescription;
desCount = desCount + 1;
for i = 1:numel(featureDescription)
    description{desCount} = featureDescription{i};
    desCount = desCount + 1;
end

end

%%%%%%%%%%%%%HELPER FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function features = normalizeFeatures(features)
for i = 1:size(features, 2)
    features(:, i) = features(:, i) - mean(features(:, i));
    
    stdFeatures = std(features(:, i));
    if stdFeatures == 0
        stdFeatures = 1;
    end
    features(:, i) = features(:, i) / stdFeatures;
end
end

function [coeffs, eigenValues] = calculatePCACoeffs(dataAll, classes, validClasses, samples)
    coeffs = cell(0,1);
    eigenValues = cell(0,1);
    
    valid = false(size(classes));
    for i = 1:numel(validClasses)
        validAdder = classes == validClasses(i);
        valid = valid | validAdder;
    end

    dataAll = dataAll(valid);
    
    for i = 1:size(dataAll{1}, 1)
        data = zeros(numel(dataAll), samples);
        for k = 1:numel(dataAll)
            data(k, :) = featureMeanSections(dataAll{k}(i,:), samples);
        end
        
        % The following code had to be replaced, as it does not work
        % with matlab 2012b anymore (uups, that was just a path problem):
        [coeffs{i}, transform, eigenValues{i}] = princomp(data);
        % Replacement:
        
        %coeff = pca(data', 0);
        %coeffs{i} = coeff;
        %eigenValues{i} = latent; 
    end
end

function data = loadLayers(filename, Header, DataDescriptors, Layers, Features)
    if Features.onlyAuto
        tag = 'autoData';
    else
        tag = 'bothData';
    end
    
    if Layers.retina
        ilm = readData(getMetaTag('INFL', tag),DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        rpe = readData(getMetaTag('RPE', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(ilm) == numel(rpe)
            data = (rpe - ilm) * Header.ScaleZ * 1000;
        end
    end
    
    if Layers.rnfl 
        ilm = readData(getMetaTag('INFL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        onfl = readData(getMetaTag('ONFL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(ilm) == numel(onfl)
            if numel(data) == 0
                data = (onfl - ilm) * Header.ScaleZ * 1000;
            else
                data = [data; (onfl - ilm) * Header.ScaleZ * 1000];
            end
        end
    end
    
    if Layers.ipl 
        ipl = readData(getMetaTag('IPL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        onfl = readData(getMetaTag('ONFL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(ipl) == numel(onfl)
            if numel(data) == 0
                data = (ipl - onfl) * Header.ScaleZ * 1000;
            else
                data = [data; (ipl - onfl) * Header.ScaleZ * 1000];
            end
        end
    end
    
    if Layers.opl 
        ipl = readData(getMetaTag('IPL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        opl = readData(getMetaTag('OPL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(ipl) == numel(opl)
            if numel(data) == 0
                data = (opl - ipl) * Header.ScaleZ * 1000;
            else
                data = [data; (opl - ipl) * Header.ScaleZ * 1000];
            end
        end
    end
    
    if Layers.onl 
        icl = readData(getMetaTag('ICL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        opl = readData(getMetaTag('OPL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(icl) == numel(opl)
            if numel(data) == 0
                data = (icl - opl) * Header.ScaleZ * 1000;
            else
                data = [data; (icl - opl) * Header.ScaleZ * 1000];
            end
        end
    end
    
    if Layers.rpe 
        icl = readData(getMetaTag('ICL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        rpe = readData(getMetaTag('RPE', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(icl) == numel(rpe)
            if numel(data) == 0
                data = (rpe - icl) * Header.ScaleZ * 1000;
            else
                data = [data; (rpe - icl) * Header.ScaleZ * 1000];
            end
        end
    end
    
    if Layers.bv
        bv = readData(getMetaTag('Blood Vessels', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(data) == 0
            data = bv;
        else
            data = [data; bv];
        end
    end
    
    if Features.normFocus
        data = data * Header.ScaleX;
    end
end

function adder = loadAdditional(pathname, filename, Header, Additional)
    adder = cell(0,1);
    adderCount = 1;
    if Additional.filename
        adder{adderCount} = filename;
        adderCount = adderCount + 1;
    end
    
    if Additional.age    
        adder{adderCount} = calculateAge(Header);
        adderCount = adderCount + 1;
    end
    
    if Additional.patientID
        adder{adderCount} = deblank(Header.PatientID);
        adderCount = adderCount + 1;
    end
end

function adderDescription = getAdditonalDescription(Additional)
    adderDescription = cell(0,1);
    adderCount = 1;
    if Additional.filename
        adderDescription{adderCount} = 'Filename';
        adderCount = adderCount + 1;
    end
    
    if Additional.age    
        adderDescription{adderCount} = 'Age';
        adderCount = adderCount + 1;
    end
    
    if Additional.patientID
        adderDescription{adderCount} = 'PatientID';
        adderCount = adderCount + 1;
    end
end

function class = loadClass(pathname, filename, Features)
    class = readOctMeta([pathname filename], Features.class);
    class = round(class);
end

function data = readData(tags, pathname, filename, evaluatorName)
    tagMan = [];
    if numel(tags) == 2 && iscell(tags)
        tagAuto = tags{1};
        tagMan = tags{2};
    else
        if iscell(tags)
            tagAuto = tags{1};
        else
            tagAuto = tags;
        end
    end
    
    data = [];
    if numel(tagMan) ~= 0
        data = readOctMeta([pathname filename], [evaluatorName tagMan]);
    end
    if numel(data) == 0
        data = readOctMeta([pathname filename], [evaluatorName tagAuto]);
    end
end

function featureData = calculateLayerFeatures(data, Types, Features, pcaCoeffAll, pcaCoeffNormal)
    featureCell = cell(0,1);
    featureCount = 1;

    if Types.completeStd
        for k = 1:size(data, 1)
            featureCell{k, featureCount} = featureStandard(data(k,:));
        end
        featureCount = featureCount + 1;
    end
    
    if Types.meanSections
        for k = 1:size(data, 1)
            featureCell{k, featureCount} = featureMeanSections(data(k,:), Features.samples);
        end
        featureCount = featureCount + 1;
    end
    
    % It is assumed that the retina thickness is the first thickness vector
    % in the matrix and the blood vessels are the last. Retina ratio and 
    % bv ratio do not make sense, however they are included to ease 
    % computation.
    if Types.ratioRetina 
        retinaMean = featureMeanSections(data(1,:), Features.samples);
        for k = 1:size(data, 1)
            layerMean = featureMeanSections(data(k,:), Features.samples);
            featureCell{k, featureCount} = layerMean ./ retinaMean;
        end
        featureCount = featureCount + 1;
    end
    
    if Types.pcaAll
        for k = 1:size(data, 1)
            samples = featureMeanSections(data(k,:), Features.numSamplesPCA);
            samplesTransformed = pcaCoeffAll{k} * samples';
            featureCell{k, featureCount} = samplesTransformed(1:Features.numEV)';
        end
        featureCount = featureCount + 1;
    end
    
    if Types.pcaNormal
        for k = 1:size(data, 1)
            samples = featureMeanSections(data(k,:), Features.numSamplesPCA);
            samplesTransformed = pcaCoeffNormal{k} * samples';
            featureCell{k, featureCount} = samplesTransformed(1:Features.numEV)';
        end
        featureCount = featureCount + 1;
    end
    
    featureData = [];
    for i = 1:size(featureCell, 1)
        for k = 1:size(featureCell, 2)
            featureData = [featureData featureCell{i, k}];
        end
    end
end

function featureDescription = getFeatureDescription(Types, Layers, Features)
    featureDescription = cell(0,1);
    featurePerLayer = cell(0,1);
    layerDescription = cell(0,1);
    featureCount = 1;

    % Features
    if Types.completeStd
        featurePerLayer{featureCount} = 'StdMin';
        featureCount = featureCount + 1;
        featurePerLayer{featureCount} = 'StdMax';
        featureCount = featureCount + 1;
        featurePerLayer{featureCount} = 'StdMean';
        featureCount = featureCount + 1;
        featurePerLayer{featureCount} = 'StdMedian';
        featureCount = featureCount + 1;
    end
    
    if Types.meanSections
        for i = 1:Features.samples
            featurePerLayer{featureCount} = ['Section' num2str(Features.samples) '_' num2str(i)];
            featureCount = featureCount + 1;
        end
    end
    
    if Types.ratioRetina 
        for i = 1:Features.samples
            featurePerLayer{featureCount} = ['Ratio' num2str(Features.samples) '_' num2str(i)];
            featureCount = featureCount + 1;
        end
    end
    
    if Types.pcaAll
        for i = 1:Features.numEV
            featurePerLayer{featureCount} = ['PCAAll' num2str(i)];
            featureCount = featureCount + 1;
        end
    end
    
    if Types.pcaNormal
        for i = 1:Features.numEV
            featurePerLayer{featureCount} = ['PCANormal' num2str(i)];
            featureCount = featureCount + 1;
        end
    end
    
    % Layers
    featureCount = 1;
    
    if Layers.retina
        layerDescription{featureCount} = 'Retina';
        featureCount = featureCount + 1;
    end
    
    if Layers.rnfl 
        layerDescription{featureCount} = 'RNFL';
        featureCount = featureCount + 1;
    end
    
    if Layers.ipl 
        layerDescription{featureCount} = 'IPL';
        featureCount = featureCount + 1;
    end
    
    if Layers.opl 
        layerDescription{featureCount} = 'OPL';
        featureCount = featureCount + 1;
    end
    
    if Layers.onl 
        layerDescription{featureCount} = 'ONL';
        featureCount = featureCount + 1;
    end
    
    if Layers.rpe 
        layerDescription{featureCount} = 'RPE';
        featureCount = featureCount + 1;
    end
    
    if Layers.bv
        layerDescription{featureCount} = 'BV';
        featureCount = featureCount + 1;
    end
    
    featureCount = 1;
    for z = 1:numel(layerDescription)
        for k = 1:numel(featurePerLayer) 
            featureDescription{featureCount} = [layerDescription{z} featurePerLayer{k}];
            featureCount = featureCount + 1;
        end
    end
end
