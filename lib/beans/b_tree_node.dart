class BTreeNode {
  bool isLeaf; // True if the node is a leaf node
  List<String> keys; // List of product names (keys)
  List<dynamic> products; // Corresponding product objects
  List<BTreeNode?> children; // Child nodes
  int maxKeys; // Maximum number of keys per node (determines the degree of the tree)

  BTreeNode(this.isLeaf, this.maxKeys)
      : keys = [],
        products = [],
        children = [];
}
