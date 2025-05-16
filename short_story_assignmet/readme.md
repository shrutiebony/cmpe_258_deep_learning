Research Paper Selected: https://arxiv.org/abs/2402.02239
# 🧠 Core Idea
The authors present a new framework called Distributional Reduction (DistR) that uses Gromov-Wasserstein (GW) optimal transport to jointly perform dimensionality reduction and clustering. They treat datasets as probability distributions and optimize over a reduced set of representative points (prototypes) in a low-dimensional space.

# 🧩 Key Contributions
### Unifying DR and Clustering:
They show that DR and clustering are special cases of a broader optimal transport problem.
GW discrepancy, which compares distributions in different metric spaces, is used as the foundational tool.
### Formulation:
The proposed objective seeks an embedding that minimizes the GW distance between the original data’s similarity matrix and that of the low-dimensional prototype representation.
This allows simultaneous learning of both the number of clusters and the embedding dimensionality.
### Theoretical Insights:
DR techniques like PCA, t-SNE, and UMAP, and clustering techniques like k-means can be reframed under their GW-based model.
They derive equivalence theorems showing how common DR methods are instances of GW minimization.
### Algorithm:
They propose a block coordinate descent (BCD) algorithm with efficient solvers (Mirror Descent and Conditional Gradient) for computing the GW objective.
### Empirical Results:
The method is tested on image and genomics datasets.
It outperforms traditional sequential pipelines (DR→Clustering or Clustering→DR) in terms of silhouette score, homogeneity, and mutual information.
### Flexibility:
DistR works across Euclidean and non-Euclidean (e.g., hyperbolic) spaces.
It automatically selects the number of effective clusters based on data structure.
# 📌 Takeaway
DistR provides a principled and practical way to extract interpretable, low-dimensional prototypes from complex datasets, unifying two foundational unsupervised tasks using optimal transport theory. It leads to better cluster quality and more meaningful visualizations.
