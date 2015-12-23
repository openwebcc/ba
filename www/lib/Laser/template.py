#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# templateing module
#

import re
import os

from string import Template

class impl:
    """ simple templating implementation """
    def __init__(self, base=None):
        """ initialize new template instance """
        self.base = base
        self.terms = {}

    def add_term(self, term=None, value=None):
        """ add a value to the given template term """
        self.terms[term] = value

    def append_to_term(self, term=None, value=None):
        """ append a value to given template term """
        if term in self.terms:
            self.terms[term] += value
        else:
            self.terms[term] = value

    def get_term(self, term=None):
        """ return the value for the given template term if any """
        if term in self.terms:
            return self.terms[term]
        else:
            return None

    def get_terms(self, term=None):
        """ return dictionary of all available template terms """
        return self.terms

    def read_template(self, fpath=None):
        """ safely read the given template file into a string """
        template_string = ""
        if os.path.exists(fpath):
            with open(fpath) as f:
                template_string = f.read()
        return template_string

    def resolve_template(self, fpath=None):
        """ safely resolve template with collected terms, set unknown terms to empty string """
        template_string = self.read_template(fpath)

        # set empty string for terms that start with a single $ and are not present in the terms dictionary
        def fillTerm(matchobj):
            if matchobj.group(1) == '$':
                if not self.terms.has_key(matchobj.group(2)):
                    self.terms[matchobj.group(2)] = ''
        re.sub(r'(\$+)(\w+)', fillTerm, template_string)

        return Template(template_string).safe_substitute(self.terms)
