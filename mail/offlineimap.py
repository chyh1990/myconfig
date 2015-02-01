#!/usr/bin/env python
import os
import keyring

#port install py-keyring
def get_password(lib, name):
	return keyring.get_password(lib, name)
