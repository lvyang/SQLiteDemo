# SQLiteDemo
一个基于FMDB的数据库存储样例。以相册、照片的存储作为例子，演示数据库的存取操作

// 数据导入
打开工程后，先点击“导入照片”。这里会将系统相册的相册、照片的信息导入到本地数据库。

// 数据查询
数据导入后，点击相册列表即可查看到本地的相册，和相册里面的照片



// 主要技术点
1. 使用FMDB库操作数据库
2. 线程安全，所有数据库的操作都放在一个FMDBDataBaseQueue中进行
3. 使用事务来进行数据库的批量插入、更新操作
4. 多对多关系建表，联表查询，使用索引等。
