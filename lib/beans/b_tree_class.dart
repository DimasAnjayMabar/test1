import 'package:test1/beans/b_tree_node.dart';

class BTree {
  BTreeNode? root;
  int degree; // Minimum degree of the tree (controls branching factor)

  BTree(this.degree);

  // Search for products by prefix in the B-Tree
  List<dynamic> searchByPrefix(String prefix) {
    List<dynamic> results = [];
    _searchByPrefix(root, prefix, results);
    return results;
  }

  void _searchByPrefix(BTreeNode? node, String prefix, List<dynamic> results) {
    if (node == null) return;

    for (int i = 0; i < node.keys.length; i++) {
      if (node.keys[i].startsWith(prefix)) {
        results.add(node.products[i]);
      }
      if (!node.isLeaf) {
        _searchByPrefix(node.children[i], prefix, results);
      }
    }

    // Search in the last child if it's not a leaf
    if (!node.isLeaf) {
      _searchByPrefix(node.children[node.keys.length], prefix, results);
    }
  }

  // **NEW FUNCTION**: Search for products by substring in the B-Tree
  List<dynamic> searchBySubstring(String substring) {
    List<dynamic> results = [];
    _searchBySubstring(root, substring, results);
    return results;
  }

  void _searchBySubstring(BTreeNode? node, String substring, List<dynamic> results) {
    if (node == null) return;

    for (int i = 0; i < node.keys.length; i++) {
      if (node.keys[i].contains(substring)) { // Check if the key contains the substring
        results.add(node.products[i]);
      }
      if (!node.isLeaf) {
        _searchBySubstring(node.children[i], substring, results);
      }
    }

    // Search in the last child if it's not a leaf
    if (!node.isLeaf) {
      _searchBySubstring(node.children[node.keys.length], substring, results);
    }
  }

  // Insert a new product into the B-Tree
  void insert(String key, dynamic product) {
    if (root == null) {
      root = BTreeNode(true, degree * 2 - 1);
      root!.keys.add(key);
      root!.products.add(product);
    } else {
      if (root!.keys.length == root!.maxKeys) {
        // Split root if full
        BTreeNode newRoot = BTreeNode(false, degree * 2 - 1);
        newRoot.children.add(root);
        _splitChild(newRoot, 0);
        root = newRoot;
      }
      _insertNonFull(root!, key, product);
    }
  }

  // Helper method: Insert a key into a non-full node
  void _insertNonFull(BTreeNode node, String key, dynamic product) {
    int i = node.keys.length - 1;

    if (node.isLeaf) {
      // Insert into leaf node
      while (i >= 0 && key.compareTo(node.keys[i]) < 0) {
        i--;
      }
      node.keys.insert(i + 1, key);
      node.products.insert(i + 1, product);
    } else {
      // Find child to insert into
      while (i >= 0 && key.compareTo(node.keys[i]) < 0) {
        i--;
      }
      i++;
      if (node.children[i]!.keys.length == node.maxKeys) {
        // Split child if full
        _splitChild(node, i);
        if (key.compareTo(node.keys[i]) > 0) {
          i++;
        }
      }
      _insertNonFull(node.children[i]!, key, product);
    }
  }

  // Helper method: Split a child node
  void _splitChild(BTreeNode parent, int index) {
    BTreeNode fullNode = parent.children[index]!;
    BTreeNode newNode = BTreeNode(fullNode.isLeaf, fullNode.maxKeys);

    int medianIndex = fullNode.maxKeys ~/ 2;
    String medianKey = fullNode.keys[medianIndex];

    // Move median key to parent
    parent.keys.insert(index, medianKey);
    parent.products.insert(index, fullNode.products[medianIndex]);
    parent.children.insert(index + 1, newNode);

    // Split keys and products
    newNode.keys.addAll(fullNode.keys.sublist(medianIndex + 1));
    newNode.products.addAll(fullNode.products.sublist(medianIndex + 1));
    fullNode.keys.removeRange(medianIndex, fullNode.keys.length);
    fullNode.products.removeRange(medianIndex, fullNode.products.length);

    // Split children if not a leaf
    if (!fullNode.isLeaf) {
      newNode.children.addAll(fullNode.children.sublist(medianIndex + 1));
      fullNode.children.removeRange(medianIndex + 1, fullNode.children.length);
    }
  }
}
