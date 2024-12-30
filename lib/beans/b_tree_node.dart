//rui c14230277
class BTreeNode {
  bool isLeaf; //memastikan apakah node adalah leaf
  List<String> keys; //menyimpan nama-nama dari produk yang diistilahkan sebagai key 
  List<dynamic> products; //menyimpan objek yang berkaitan dengan nama di key
  List<BTreeNode?> children; //menyimpan children
  int maxKeys; //max key untuk b tree
  
  //constructor
  BTreeNode(this.isLeaf, this.maxKeys)
      : keys = [],
        products = [],
        children = [];
}
