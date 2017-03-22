# Re-ranking Person Re-identification with k-reciprocal Encoding 
================================================================

### This code has the IDE baseline for the Market-1501 and CUHK03 new training/testing protocol.

### The re-ranking code is available upon request.

If you find this code useful in your research, please consider citing:

    @article{zhong2017re,
      title={Re-ranking Person Re-identification with k-reciprocal Encoding},
      author={Zhong, Zhun and Zheng, Liang and Cao, Donglin and Li, Shaozi},
      booktitle={CVPR},
      year={2017}
    }


### Requirements: Caffe

Requirements for `Caffe` and `matcaffe` (see: [Caffe installation instructions](http://caffe.berkeleyvision.org/installation.html))

### Installation
1. Build Caffe and matcaffe
    ```Shell
    cd $Re-ranking_ROOT/caffe
    # Now follow the Caffe installation instructions here:
    # http://caffe.berkeleyvision.org/installation.html
    make -j8 && make matcaffe
    ```
    
2. Download pre-computed imagenet models, Market-1501 dataset and CUHK03 dataset
  ```Shell
  Please download the pre-trained imagenet models and put it in the "data/imagenet_models" folder.
  Please download Market-1501 dataset and unzip it in the "evaluation/data/Market-1501" folder. 
  Please download CUHK03 dataset and unzip it in the "evaluation/data/CUHK03" folder.
  ```
  
- [Pre-trained imagenet models](https://pan.baidu.com/s/1o7YZT8Y)
  
- [Market-1501](https://pan.baidu.com/s/1ntIi2Op)

- CUHK03 [[Baiduyun]](https://pan.baidu.com/s/1o8txURK) [[Google drive]](https://drive.google.com/open?id=0B7TOZKXmIjU3OUhfd3BPaVRHZVE)

### The new training/testing protocol for CUHK03
The new training/testing protocol split for CUHK03 in our paper is in the "evaluation/data/CUHK03/" folder.
- cuhk03_new_protocol_config_detected.mat
- cuhk03_new_protocol_config_labeled.mat

### Training and testing IDE model

1. Training 
  ```Shell
  cd $Re-ranking_ROOT
  # train IDE ResNet_50 for Market-1501
  ./experiments/Market-1501/train_IDE_ResNet_50.sh
  
  # train IDE ResNet_50 for CUHK03
  ./experiments/CUHK03/train_IDE_ResNet_50_labeled.sh
  ./experiments/CUHK03/train_IDE_ResNet_50_detected.sh
  ```
2. Feature Extraction
  ```Shell
  cd $Re-ranking_ROOT/evaluation
  # extract feature for Market-1501
  matlab Market_1501_extract_feature.m
  
  # extract feature for CUHK03
  matlab CUHK03_extract_feature.m
  ```
  
3. Evaluation
  ```Shell
  # evaluation for Market-1501
  matlab Market_1501_evaluation.m
    
  # evaluation for CUHK03
  matlab CUHK03_evaluation.m
  ``` 
  
### Results
You can download our pre-trained IDE models and IDE features, and put them in the "out_put"  and "evaluation/feat" folder, respectively. 

- IDE models [[Baiduyun]](https://pan.baidu.com/s/1jHVj2C2) [[Google drive]](https://drive.google.com/open?id=0B7TOZKXmIjU3ZTNsWGt3azcxUUU)

- IDE features [[Baiduyun]](https://pan.baidu.com/s/1c1TtKcw) [[Google drive]](https://drive.google.com/open?id=0B7TOZKXmIjU3ODhaRm8yN2QzRHc)

Using the above IDE models and IDE features, you can reproduce the results as follows:

- Market-1501

|Methods |   Rank@1 | mAP|
| --------   | -----  | ----  |
|IDE_ResNet_50  + Euclidean | 78.92% | 55.03%|
|IDE_ResNet_50  + XQDA      | 77.58% | 56.06%|

For Market-1501, these results are better than those reported in our paper, since we add a dropout = 0.5 layer after pool5.

- CUHK03 under  the new training/testing protocol

| |  Labeled | Labeled|  detected | detected|
| -------| -----  | ----  |----  |----  |
|Methods |  Rank@1 | mAP|  Rank@1 | mAP|
|IDE_CaffeNet  + Euclidean | 15.6% | 14.9%|  15.1% | 14.2%|
|IDE_CaffeNet  + XQDA      | 21.9% | 20.0%|21.1% | 19.0%|
|IDE_ResNet_50  + Euclidean | 22.2% | 21.0%|21.3% | 19.7%|
|IDE_ResNet_50  + XQDA      | 32.0% | 29.6%|31.1% | 28.2%|

### Contact us

If you have any questions about this code, please do not hesitate to contact us.

[Zhun Zhong](http://zhunzhong.site)

[Liang Zheng](http://liangzheng.com.cn)

=======
# person-re-ranking
