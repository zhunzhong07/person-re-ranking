# The new training/testing protocol for CUHK03 (CUHK03-NP)

The new protocol splits the CUHK03 dataset into training set and testing set similar to that of Market-1501, which consist of 767 identities and 700 identities respectively. 

In testing, we randomly select one image from each camera as the query for each identity and use the rest of images to construct the gallery set. We make sure that each query identity is selected by both two cameras, so that cross-camera search can be performed.

In evaluation, true matched images captured in the same camera as the query are viewed as “junk”.  Meaning that junk images is of zero influence to re-id accuracy (CMC/mAP).

The new training/testing protocol split for CUHK03 in our paper is in the "root/evaluation/data/CUHK03/" folder.
- cuhk03_new_protocol_config_detected.mat
- cuhk03_new_protocol_config_labeled.mat


| |  Labeled | detected|
| -------| -----  | ----  |
|#Training |  7,368 | 7,365|  
|#Query      | 1,400 | 1,400|
|#Gallery      | 5,328 | 5,332|

- CUHK03 [[Baiduyun]](https://pan.baidu.com/s/1o8txURK) [[Google drive]](https://drive.google.com/open?id=0B7TOZKXmIjU3OUhfd3BPaVRHZVE)

## Download CUHK03-NP
We also provide the CUHK03-NP as the format of Market-1501. You can download it following:
- CUHK03-NP [[Baiduyun](https://pan.baidu.com/s/1RNvebTccjmmj1ig-LVjw7A)] [[Google Drive](https://drive.google.com/open?id=1pBCIAGSZ81pgvqjC-lUHtl0OYV1icgkz)]

- Directory Structure

Followings are the directory structure for CUHK03-NP. 
> cuhk03-np
>> detected/labeled
>>> bounding_box_train/bounding_box_test/query

If you use CUHK03-NP in your experiment, please consider citing:

    @inproceedings{zhong2017re,
      title={Re-ranking Person Re-identification with k-reciprocal Encoding},
      author={Zhong, Zhun and Zheng, Liang and Cao, Donglin and Li, Shaozi},
      booktitle={CVPR},
      year={2017}
    }
    
    @inproceedings{li2014deepreid,
    title={DeepReID: Deep Filter Pairing Neural Network for Person Re-identification},
    author={Li, Wei and Zhao, Rui and Xiao, Tong and Wang, Xiaogang},
    booktitle={CVPR},
    year={2014}
    }
    
## [CUHK03-NP-Mask](https://github.com/developfeng/MGCAM/tree/master/data)

You can also obtain the person mask of CUHK03-NP from [CUHK03-NP-Mask](https://github.com/developfeng/MGCAM/tree/master/data).


## State-of-the-art

| - |  Labeled | Labeled|  detected | detected|  |
| -------| -----  | ----  |----  |----  |----  |
|Methods | Rank@1 | mAP|  Rank@1 | mAP| Reference |
|BOW+XQDA| 7.93% | 7.29%|6.36% | 6.39%|"[Scalable person re-identification: a benchmark](http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=7410490)", Zheng Liang, Shen Liyue, Tian Lu, Wang Shengjin, Wang Jingdong and Tian, Qi, ICCV 2015 [[project]](http://www.liangzheng.org/Project/project_reid.html)|
|PUL| - | -|9.1% | 9.2%|"[Unsupervised Person Re-identification: Clustering and Fine-tuning](https://arxiv.org/pdf/1705.10444.pdf)", Hehe Fan, Liang Zheng and Yi Yang, arXiv:1705.10444  [[code]](https://github.com/hehefan/Unsupervised-Person-Re-identification-Clustering-and-Fine-tuning)|
|LOMO+XQDA| 14.8% | 13.6%|12.8% | 11.5%|"[Person Re-identification by Local Maximal Occurrence Representation and Metric Learning](https://arxiv.org/abs/1406.4216)", Liao Shengcai, Hu Yang, Zhu Xiangyu and Li Stan Z, CVPR 2015 [[project]](http://www.cbsr.ia.ac.cn/users/scliao/projects/lomo_xqda/index.html)|
|IDE| 22.2% | 21.0%|21.3% | 19.7%|"[Person Re-identification: Past, Present and Future](https://arxiv.org/abs/1610.02984)", Zheng Liang, Yi Yang, and Alexander G. Hauptmann, arXiv:1610.02984 [[code]](https://github.com/zhunzhong07/IDE-baseline-Market-1501)|
|IDE+DaF| 27.5%| 31.5% | 26.4% | 30.0|"[Divide and Fuse: A Re-ranking Approach for Person Re-identification](https://arxiv.org/abs/1708.04169)", Rui Yu, Zhichao Zhou, Song Bai, Xiang Bai, BMVC 2017
|IDE+XQ.+RR     | 38.1% | 40.3%|34.7% | 37.4%| "[Re-ranking Person Re-identification with k-reciprocal Encoding](http://zhunzhong.site/paper/re-ranking-cvpr.pdf)", Zhun Zhong, Liang Zheng, Donglin Cao,Shaozi Li, CVPR 2017 [[code]](https://github.com/zhunzhong07/person-re-ranking)|
|PAN| 36.9% | 35.0%|36.3% | 34.0%| "[Pedestrian Alignment Network for Person Re-identification](https://arxiv.org/abs/1707.00408)", Zhedong Zheng, Liang Zheng, Yi Yang, arXiv:1707.00408 [[code]](https://github.com/layumi/Pedestrian_Alignment)|
|DPFL | 43.0% | 40.5%|40.7% | 37.0%| "[Person Re-Identification by Deep Learning Multi-Scale Representations](http://www.eecs.qmul.ac.uk/~sgg/papers/ChenEtAl_ICCV2017WK_CHI.pdf?nsukey=bFKy637SdfiMPVNHqNPm9DbM4V%2BJvHS3xsL4zYv0aecUKkedzKZC304%2FT4Ot96qbKCoD%2BbcV7OA92VISMCiqLzSj4%2BBCbF3cYAmodWYkUhcK%2FFYRtZ3LLKff1Fb0GVNplfrcVq%2B%2BJJ2QO5uMDyiIFth9%2BAhb8Ib%2FZ0%2FkZyqB9rnsLKHkBXa6SI5OMMibGklQ)", Yanbei Chen, Xiatian Zhu, Shaogang Gong|
|SVDNet| 40.93 | 37.83|41.5% | 37.26%| "[SVDNet for Pedestrian Retrieval](https://arxiv.org/abs/1703.05693)", Sun Yifan, Zheng Liang, Deng Weijian, Wang Shengjin, ICCV 2017|
|HA-CNN| 44.4%| 41.0% |41.7% |38.6%| "[Harmonious Attention Network for Person Re-Identification](https://arxiv.org/pdf/1802.08122.pdf)", Wei Li1 Xiatian Zhu2 Shaogang Gong1, CVPR 2018|
|HCN+XQDA+RR| 43.7%| 45.3%| 44.0%| 46.9%| "[HIERARCHICAL CROSS NETWORK FOR PERSON RE-IDENTIFICATION](https://arxiv.org/pdf/1712.06820.pdf)", Huan-Cheng Hsu, Ching-Hang Chen, Hsiao-Rong Tyan, Hong-Yuan Mark Liao, arxiv 2017|
|MLFN| 54.7% | 49.2%| 52.8%| 47.8%| "[Multi-Level Factorisation Net for Person Re-Identification](https://arxiv.org/pdf/1803.09132.pdf)", Xiaobin Chang, Timothy M. Hospedales, Tao Xiang， CVPR 2018|
|DaRe| 58.1% | 53.7% | 55.1% | 51.3%| "[Resource Aware Person Re-identification across Multiple Resolutions](http://www.cs.cornell.edu/~gaohuang/papers/Anytime-ReID.pdf)", Yan Wang, Lequn Wang, Yurong You, Xu Zou, Vincent Chen. CVPR 2018|
|TriNet+RE| 58.14% | 53.83% | 55.50% | 50.74%| "[Random Erasing Data Augmentation](https://arxiv.org/abs/1708.04896)", Zhun Zhong, Liang Zheng, Guoliang Kang, Shaozi Li, Yi Yang, arXiv 2017|
|TriNet+RR+RE| 63.93% | 65.05% | 64.43% | 64.75%| "[Random Erasing Data Augmentation](https://arxiv.org/abs/1708.04896)", Zhun Zhong, Liang Zheng, Guoliang Kang, Shaozi Li, Yi Yang, arXiv 2017|
|PCB (RPP)| - | - | 63.7% | 57.5%| "[Beyond Part Models: Person Retrieval with Refined Part Pooling (and A Strong Convolutional Baseline)](https://arxiv.org/pdf/1711.09349.pdf)", Yifan Sun, Liang Zheng, Yi Yang, Qi Tian, Shengjin Wang, arXiv 2017|
|HPM+HRE| - | - | 63.2% | 59.7%| "[Horizontal Pyramid Matching for Person Re-identification](https://arxiv.org/pdf/1804.05275.pdf)", Yang Fu, Yunchao Wei, Yuqian Zhou, Honghui Shi, arXiv 2018|
|DGNet| - | - | 65.6% | 61.1%| "[Joint Discriminative and Generative Learning for Person Re-identification](https://arxiv.org/abs/1904.07223)", Zhedong Zheng, Xiaodong Yang, Zhiding Yu, Liang Zheng, Yi Yang and Jan Kautz, CVPR 2019 (Oral)|
|MGN| 68.0% | 67.4% | 66.8% | 66%| "[Learning Discriminative Features with Multiple Granularity for Person Re-Identification](https://arxiv.org/pdf/1804.01438.pdf)", Guanshuo Wang, Yufeng Yuan, Xiong Chen, Jiwei Li, Xi Zhou, arXiv 2018|
|DaRe(R)+RE+RR| 72.9% | 73.7% | 69.8% | 71.2%| "[Resource Aware Person Re-identification across Multiple Resolutions](http://www.cs.cornell.edu/~gaohuang/papers/Anytime-ReID.pdf)", Yan Wang, Lequn Wang, Yurong You, Xu Zou, Vincent Chen. CVPR 2018|

- RR (Re-ranking) Re-ranking person re-identification with k-reciprocal encoding. Z. Zhong, L. Zheng, D. Cao, and S. Li. CVPR 2017. [[code]](https://github.com/zhunzhong07/person-re-ranking)

- RE (Random Erasing) Random erasing data augmentation. Z. Zhong, L. Zheng, G. Kang, S. Li, and Y. Yang. arXiv, 2017. [[Code]](https://github.com/zhunzhong07/Random-Erasing)
