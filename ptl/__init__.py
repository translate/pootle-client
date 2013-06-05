# -*- coding: utf-8 -*-
#
# Copyright © 2013 Zuza Software Foundation
#
# This file is part of Pootle.

#
# enable HTTPretty mocking if PTL_TESTING set
#
import os

if os.getenv('PTL_TESTING'):
    from httpretty import HTTPretty

    # monkey patch the socket module (and leave it that way! DANGEROUS)
    HTTPretty.enable()

    # siteurl = "http://pootle.example.com/"
    siteurl = "http://localhost/"

    HTTPretty.register_uri(HTTPretty.GET, siteurl, body='<html></html>',
                           content_type="text/html")

    baseurl = siteurl + "api/v1/"

    HTTPretty.register_uri(HTTPretty.GET, baseurl, body='["API Root"]',
                           content_type="application/json")

    language_list = """
{
    "meta": {
        "limit": 1000,
        "next": null,
        "offset": 0,
        "previous": null,
        "total_count": 132
    },
    "objects": [
        {
            "code": "af",
            "description": "",
            "fullname": "Afrikaans",
            "nplurals": 2,
            "pluralequation": "(n != 1)",
            "resource_uri": "/api/v1/languages/3/",
            "specialchars": "ëïêôûáéíóúý",
            "translation_projects": [
                "/api/v1/translation-projects/2/",
                "/api/v1/translation-projects/3/"
            ]
        },
        {
            "code": "ak",
            "description": "",
            "fullname": "Akan",
            "nplurals": 2,
            "pluralequation": "(n > 1)",
            "resource_uri": "/api/v1/languages/4/",
            "specialchars": "ɛɔƐƆ",
            "translation_projects": [
                "/api/v1/translation-projects/4/"
            ]
        }
    ]
}
    """

    HTTPretty.register_uri(HTTPretty.GET, baseurl + "languages/",
                           body=language_list,
                           content_type="application/json")
