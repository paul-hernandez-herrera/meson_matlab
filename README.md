# MultiscalE Segmentation Of Neurons (MESON) 

![MESON overview](/figures/MESON_overview.png)

An algoritm based on one-class classification to automatically segment neurons (bright tubular structures). The metodology is described in the papers:

- Hernandez-Herrera, P., Papadakis, M., & Kakadiaris, I. A. (2014, April). [*Segmentation of neurons based on one-class classification*](https://doi.org/10.1109/ISBI.2014.6868119). In 2014 IEEE 11th International Symposium on Biomedical Imaging (ISBI) (pp. 1316-1319). IEEE.

- Hernandez-Herrera, P., Papadakis, M., & Kakadiaris, I. A. (2016). [*Multi-scale segmentation of neurons based on one-class classification*](https://doi.org/10.1016/j.jneumeth.2016.03.019). Journal of neuroscience methods, 266, 94-106.

Please cite the paper(s) if you are using this code in your research.

## Overview
The current approach is designed to segment neurons from a 3D image stack, however it has also been applied to segment other bright structures. **The algorithm only requires a 3D image stack and the expected sizes (radius) of the structures to detect**. The algorithm automatically output a 3D image stack with voxels assigned the value 0 to background while value 255 to structures detected as foreground. The algorithm has 4 main steps:
- *Training set detection of background voxels (**Step 1**)*: A training set of background voxels is automatically detected using a Laplacian filter on the Frecuency domain. 
- *Feature extraction (**Step 2**)*: The eigenvalues of the Hessian Matrix are used as the feature descriptor for each voxel of the image.
- *Model construction (**Step 3**)*: The training set and feaure descriptors are used to generate a one-class classification model for each given radius to segment the background.
- *Prediction (**Step 4**)*: The one-class classification model is applied to the 3D image stack, high values correspond to voxels belonging to background. Foreground is detected as those voxels rejected to be background.



## System requirements
- Tested on Matlab R2020a
- Linux and Windows. Not tested on Mac but it may work.
- At least 4GB to process a 640x480x140 image stack.

## Dependencies
- The MESON algorithm depends on the code implementation of the [*Frangi Vesselness Filter*](https://www.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter) [[1]](#1) to compute the eigenvalues of the Hessian Matrix.

## Instalation

1. Download the lastest release of the code 
2. Dowload the MathWorks code [*Frangi Vesselness Filter*](https://www.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter) and create the mex file for the code eig3volume.c (```
mex eig3volume.c ```)
3. Make sure to add the downloaded codes to Matlab Path.

## Usage
**Requirements**: 3D image stack in tif format and the radii size in voxel of the structures to detect

**Open MATLAB 2020 or newer** (it may work with older versions) and type:
```
meson(file_path, 'radius', [r1 r2 r3 ... rn])
```
where r1, r2, r3, ..., rn are the expected radii.

A segmentation and a mat file (used for post-processing) will be created in the folder containing the 3D input image. 

## Post-process
The automatic threshold selected by the algorithm in some cases may not be optimal, furthermore, the user may need to remove small structures. To this end, we created a Graphic User Interface to manually select the threhold value and the minimum structure size to be used as foreground.

**Open MATLAB 2020 or newer** (it may work with older versions) and type:

```
manual_segmentation_from_prediction
```

- **Open file**: Allows to open the mat file generated with the meson algorithm.
- **Theshold**: Allows to detect as foreground those voxels in the predicted volue with value larger than **Threshold**. Voxels with lower value are assigned to background.
- **min_con_size**: Allows to elliminate structures in the segmentation with volume less than **min_con_size** voxels.
- **Figure 1/2 radio button**: Allows to select the figure to display. 


![Manual segmentation](/figures/manual_segmentation_GUI.png)

## References
<a id="1">[1]</a>  Dirk-Jan Kroon (2022). Hessian based Frangi Vesselness filter (https://www.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter), MATLAB Central File Exchange. Retrieved June 18, 2022.