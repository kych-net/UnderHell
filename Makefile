# 根目录委托 Makefile:把所有目标转发到 文档/ 下的真实 Makefile。
# 用法:在根目录直接 make all / web / print / screen / clean ...
# 与 元素系统 类似的目标(参数化)也会连同参数一起转发,例如:
#   make 元素系统 元素系统名=academic
%:
	$(MAKE) -C 文档 $@