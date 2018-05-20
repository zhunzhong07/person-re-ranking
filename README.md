# Re-ranking Person Re-identification with k-reciprocal Encoding 
================================================================

### This code has the source code for the paper "Re-ranking Person Re-identification with k-reciprocal Encoding". Including:
1. IDE baseline
2. Re-ranking code
3. CUHK03 new training/testing protocol

If you find this code useful in your research, please consider citing:

    @article{zhong2017re,
      title={Re-ranking Person Re-identification with k-reciprocal Encoding},
      author={Zhong, Zhun and Zheng, Liang and Cao, Donglin and Li, Shaozi},
      booktitle={CVPR},
      year={2017}
    }
    
The neighbor encoding method of our paper is inspired by the reference [2]. If you use the re-ranking code in your paper, please also cite:

    @article{bai2016sparse,
      title={Sparse contextual activation for efficient visual re-ranking},
      author={Bai, Song and Bai, Xiang},
      journal={IEEE Transactions on Image Processing},
      year={2016},
      publisher={IEEE}
    }
    
================================================================ 

### Two python version of re-ranking fcuntions are added in the 'python' folder.
1. re_ranking_feature.py: re-ranking with original feature, Euclidean distance is used. Thanks [Hao Luo](https://github.com/michuanhaohao) !
2. re_ranking_ranklist: re-ranking with given distance matrices, handle the difference of / division between python 2 and 3. Thanks [huang houjing](https://github.com/huanghoujing)  !

### Pytorch re-implementation
[[Baseline + CamStyle + Random Erasing + Re-ranking](https://github.com/zhunzhong07/CamStyle)]

[[Person_reID_baseline + Random Erasing + Re-ranking](https://github.com/layumi/Person_reID_baseline_pytorch)]

================================================================ 

## The new training/testing protocol for CUHK03
[[Dataset and state-of-the-art](https://github.com/zhunzhong07/person-re-ranking/tree/master/CUHK03-NP)]



================================================================
## IDE Baseline + Re-ranking

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
You can download our pre-trained IDE models and IDE features, and put them in the "output"  and "evaluation/feat" folder, respectively. 

- IDE models [[Baiduyun]](https://pan.baidu.com/s/1jHVj2C2) [[Google drive]](https://drive.google.com/open?id=0B7TOZKXmIjU3ZTNsWGt3azcxUUU)

- IDE features [[Baiduyun]](https://pan.baidu.com/s/1c1TtKcw) [[Google drive]](https://drive.google.com/open?id=0B7TOZKXmIjU3ODhaRm8yN2QzRHc)

Using the above IDE models and IDE features, you can reproduce the results with our re-ranking method as follows:

- Market-1501

|Methods |   Rank@1 | mAP|
| --------   | -----  | ----  |
|IDE_ResNet_50  + Euclidean | 78.92% | 55.03%|
|IDE_ResNet_50  + Euclidean + re-ranking | 81.44% | 70.39%|
|IDE_ResNet_50  + XQDA      | 77.58% | 56.06%|
|IDE_ResNet_50  + XQDA + re-ranking     | 80.70% | 69.98%|

For Market-1501, these results are better than those reported in our paper, since we add a dropout = 0.5 layer after pool5.

- CUHK03 under  the new training/testing protocol

| |  Labeled | Labeled|  detected | detected|
| -------| -----  | ----  |----  |----  |
|Methods |  Rank@1 | mAP|  Rank@1 | mAP|
|BOW  + XQDA [1]      | 7.93% | 7.29%|6.36% | 6.39%|
|BOW  + XQDA + re-ranking     | 8.93% | 9.94%|8.29% | 8.81%|
|LOMO  + XQDA [3]      | 14.8% | 13.6%|12.8% | 11.5%|
|LOMO  + XQDA + re-ranking     | 19.1% | 20.8%|16.6% | 17.8%|
|IDE_CaffeNet  + Euclidean | 15.6% | 14.9%|  15.1% | 14.2%|
|IDE_CaffeNet  + Euclidean + re-ranking | 19.1% | 21.3%|19.3% | 20.6%|
|IDE_CaffeNet  + XQDA      | 21.9% | 20.0%|21.1% | 19.0%|
|IDE_CaffeNet  + XQDA + re-ranking     | 25.9% | 27.8%|26.4% | 26.9%|
|IDE_ResNet_50  + Euclidean | 22.2% | 21.0%|21.3% | 19.7%|
|IDE_ResNet_50  + Euclidean + re-ranking | 26.6% | 28.9%|24.9% | 27.3%|
|IDE_ResNet_50  + XQDA      | 32.0% | 29.6%|31.1% | 28.2%|
|IDE_ResNet_50  + XQDA + re-ranking     | 38.1% | 40.3%|34.7% | 37.4%|

### References

[1] Scalable Person Re-identification: A Benchmark. Zheng, Liang and Shen, Liyue and Tian, Lu and Wang, Shengjin and Wang, Jingdong and Tian, Qi. In ICCV 2015.

[2] Sparse contextual activation for efficient visual re-ranking. Bai, Song and Bai, Xiang. IEEE Transactions on Image Processing. 2016

[3] Person re-identification by local maximal occurrence representation and metric learning. Liao S, Hu Y, Zhu X, et al. In CVPR. 2015
### Contact us

If you have any questions about this code, please do not hesitate to contact us.

[Zhun Zhong](http://zhunzhong.site)

[Liang Zheng](http://liangzheng.com.cn)
