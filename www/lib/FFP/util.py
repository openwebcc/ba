#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Forschungsfestplatte metadata application helper library
#

import sys

class Config:
    """ utility module for Forschungsfestplatte metadata application """

    def __init__(self):
        """ define globals """
        self.base_dir = '/home/laser/rawdata/ffp'
        self.download_dir = '/home/laser/rawdata/download/ffp'
        self.download_hours_available = 48
        self.app_root = '/data/ffp'
        self.leaflet_root = '/data/lib'
        self.dataset_title = {
            '090930_gesamt' : 'Gesamtbefliegung 2006 - 2009',
        }

    def get_base_dir(self):
        """ return full path to download directory """
        return self.base_dir

    def get_download_dir(self):
        """ return full path to download directory """
        return self.download_dir

    def get_download_hours_available(self):
        """ return number of hours that data will be available """
        return self.download_hours_available

    def get_app_root(self):
        """ return URI to the base directory of the application """
        return self.app_root

    def get_leaflet_root(self):
        """ return URI to the base directory of the Leaflet library"""
        return self.leaflet_root

    def get_dataset_title(self,dataset):
        """ return title of dataset if any, None otherwise """
        if dataset in self.dataset_title:
            return self.dataset_title[dataset]
        else:
            return None
