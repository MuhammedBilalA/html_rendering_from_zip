class DirectoryModel {
  final String path;
  DirectoryModel({ required this.path});

  Map<String, dynamic> toMap() {
    return {'path': path};
  }
}
