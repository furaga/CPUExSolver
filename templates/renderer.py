#coding:utf-8
import sys
from mako.template import Template
from xml.etree.ElementTree import *
xml = parse(sys.argv[1]) # 返値はElementTree型
t = Template(filename=sys.argv[2], input_encoding="utf-8", output_encoding="utf-8", encoding_errors="replace")
print t.render(xmlroot=xml.getroot())
