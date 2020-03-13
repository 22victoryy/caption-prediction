Please send questions to: fidler@cs.toronto.edu

Each image has one description in the current dataset. We are in the process of labeling more, which should be available soon.


FOLDERS:
--------

- data/descriptions contain the descriptions and visual alignments. You can view these via our annotation tool which is in labeling_tools/visualAnnot (cd to that folder and run 'texteditor' in Matlab)

- data/descriptions_gt contain ground-truth on the text side: GT class for each noun for a set of classes of interest (data/classes_final), GT attributes for *each* noun, GT coreference, as well as GT prepositions. 
The annotators have not looked at the image and annotated the sentence in isolation. They used the annotation tool in labeling_tools/sentAnnot. You can use it by cd-ing to that folder and running 'texteditor'. If you want to view GT annotations, input 'gt' when it asks you for the user name. 
For coreference, the annotators were asked to annotate whether two words talk about the same physical object. For example, "A chair is in the image. Next to it is a table." -> 'chair' and 'it' are marked as coreference



DATA FORMAT:
------------

Please refer to the original NYU dataset for object segmentations (for class info): http://cs.nyu.edu/~silberman/rmrc2014/indoor.php. We are including the images from NYUv2 for transparency (to avoid any indexing problems). If you use any of our data please also cite Silberman's paper (bibtex below). 

Each image has a file in data/descriptions and data/descriptions_gt folder. 


Visual alignments: data/descriptions
-------------------------------------

Each file has a field called 'annotation' with several fields:

- seg{i} … is a segmentation for the i-th object. You can visualize it with mask=roipoly(zeros(annotation.imsize(1:2)), annotation.seg{i}(:, 1), annotation.seg{i}(:, 2));

- descriptions … currently just one per image. 
  - descriptions.text is the description that the Turker wrote (plus cleanup)
  - descriptions.words is descriptions.text split into words  
  - descriptions.obj_id{i} tells you the id of the region that the i-th word talks about. That is, descriptions.word{i} talks about seg{descriptions.obj_id{i}}. Note that .obj_id can be multiple regions in the image. 

- color(i) … gives you color information about objects. Only a subset has been annotated (those that haven't are marked as 'unlabeled'). 


Text ground-truth: data/descriptions_gt
---------------------------------------

Each file has several variables: noun, prep, verb and class. * Note that only 'noun' and 'prep' have been fully annotated *, while verb and class (cardinality of each noun) haven't.

- noun.word is the actual word in the sentence
- noun.id is of format [i,j] where i is the sentence number and j is the word number in the sentence
- noun.cls is the class of interest of the word (if the word does not belong to class of interest this field will be empty or 'background')
- noun.adj is a list of adjectives for this noun
- noun.co is coreference, where [i,j] denotes the j-th word in i-th sentence (it links to a noun.id of the corefered word) that forms a coreference pair with the annotated word. Note that the annotators did not label all possible coreference pairs. They typically chose a reference word in the description and linked all mentions of the same object to this word. Each word could be linked to more than 1 word via coreference, thus noun.co can be a matrix (where is row is of type [i,j]).

- prep: each row in prep annotates one preposition in the description. Note that there may be empty rows between annotations. prep(i,1) is the word in the description represented as a triple [sentence #, word # in sentence, 1] and typically refers to a noun. prep(i,2) is a relation. Note that the annotators labeled the relation by clicking on the word in the description, eg. "mug is on top of the table" -> the relation will probably be either "top" or "on" (and on "on top of"). prep(i,3) and prep(i,4) are again the word/noun.



CITATION
--------

Please cite our paper if you use the data:

@inproceedings{KongCVPR14,
title = {What are you talking about? Text-to-Image Coreference},
author = {Chen Kong and Dahua Lin and Mohit Bansal and Raquel Urtasun and Sanja Fidler},
booktitle = {CVPR},
year = {2014}
}

as well as the NYUv2 dataset:

@inproceedings{NYUv2,
title = {Indoor Segmentation and Support Inference from RGBD Images},
author = {Nathan Silberman and Pushmeet Kohli and Derek Hoiem and Rob Fergus},
booktitle = {ECCV},
year = {2012}
}
