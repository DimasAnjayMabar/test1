import 'package:test1/beans/algorithm/b_tree/b_tree_node.dart';

class BTree {
  BTreeNode? root;
  int degree; // Minimum degree dari b tree

  BTree(this.degree);

  //joey c14230256
  List<dynamic> searchBySubstring(String substring) {
    List<dynamic> results = [];
    _searchBySubstring(root, substring, results);
    return results;
  }
  
  //joey c14230256
  void _searchBySubstring(BTreeNode? node, String substring, List<dynamic> results) {
    if (node == null) return;

    // Traverse seluruh data dalam b tree
    for (int i = 0; i < node.keys.length; i++) {
      if (node.keys[i].contains(substring)) {
        results.add(node.products[i]);
      }
      if (!node.isLeaf) {
        _searchBySubstring(node.children[i], substring, results);
      }
    }

    if (!node.isLeaf) {
      _searchBySubstring(node.children[node.keys.length], substring, results);
    }
  }

  //greg c14230127
  void insertIntoBtree(String key, dynamic product) {
    if (root == null) {
      root = BTreeNode(true, degree * 2 - 1);
      root!.keys.add(key);
      root!.products.add(product);
    } else {
      if (root!.keys.length == root!.maxKeys) {
        BTreeNode newRoot = BTreeNode(false, degree * 2 - 1);
        newRoot.children.add(root);
        _splitChild(newRoot, 0);
        root = newRoot;
      }
      _insertNonFull(root!, key, product);
    }
  }

  //greg c14230127
  void _insertNonFull(BTreeNode node, String key, dynamic product) {
    int i = node.keys.length - 1;

    if (node.isLeaf) {
      while (i >= 0 && key.compareTo(node.keys[i]) < 0) {
        i--;
      }
      node.keys.insert(i + 1, key);
      node.products.insert(i + 1, product);
    } else {
      while (i >= 0 && key.compareTo(node.keys[i]) < 0) {
        i--;
      }
      i++;
      if (node.children[i]!.keys.length == node.maxKeys) {
        _splitChild(node, i);
        if (key.compareTo(node.keys[i]) > 0) {
          i++;
        }
      }
      _insertNonFull(node.children[i]!, key, product);
    }
  }

  //rui c14230277
  void _splitChild(BTreeNode parent, int index) {
    BTreeNode fullNode = parent.children[index]!;
    BTreeNode newNode = BTreeNode(fullNode.isLeaf, fullNode.maxKeys);

    int medianIndex = fullNode.maxKeys ~/ 2;
    String medianKey = fullNode.keys[medianIndex];

    parent.keys.insert(index, medianKey);
    parent.products.insert(index, fullNode.products[medianIndex]);
    parent.children.insert(index + 1, newNode);

    newNode.keys.addAll(fullNode.keys.sublist(medianIndex + 1));
    newNode.products.addAll(fullNode.products.sublist(medianIndex + 1));
    fullNode.keys.removeRange(medianIndex, fullNode.keys.length);
    fullNode.products.removeRange(medianIndex, fullNode.products.length);

    if (!fullNode.isLeaf) {
      newNode.children.addAll(fullNode.children.sublist(medianIndex + 1));
      fullNode.children.removeRange(medianIndex + 1, fullNode.children.length);
    }
  }
}
