#!/bin/bash

if [ -d "venv" ]; then
  pwd
else
  virtualenv -p /opt/homebrew/bin/python3.12 venv
  source venv/bin/activate

	wget https://files.pythonhosted.org/packages/ac/b6/b55c3f49042f1df3dcd422b7f224f939892ee94f22abcf503a9b7339eaf2/html5lib-1.1.tar.gz -O html5lib-1.1.tar.gz
	wget https://files.pythonhosted.org/packages/71/39/171f1c67cd00715f190ba0b100d606d440a28c93c7714febeca8b79af85e/six-1.16.0.tar.gz -O six-1.16.0.tar.gz
	wget https://files.pythonhosted.org/packages/0b/02/ae6ceac1baeda530866a85075641cec12989bd8d31af6d5ab4a3e8c92f47/webencodings-0.5.1.tar.gz -O webencodings-0.5.1.tar.gz

	pip install html5lib-1.1.tar.gz
	pip install six-1.16.0.tar.gz
	pip install webencodings-0.5.1.tar.gz

  pip install meson
fi

