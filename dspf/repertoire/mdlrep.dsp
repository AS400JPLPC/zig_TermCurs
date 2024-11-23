{
  "PANEL": [
    {
      "name": "DEFREP",
      "posx": 1,
      "posy": 1,
      "lines": 44,
      "cols": 168,
      "cadre": "line1",
      "title": "Def.REPERTOIRE",
      "button": [
        {
          "name": "F1",
          "key": "F1",
          "show": true,
          "check": false,
          "title": "Help"
        },
        {
          "name": "F3",
          "key": "F3",
          "show": true,
          "check": false,
          "title": "Exit"
        },
        {
          "name": "F5",
          "key": "F5",
          "show": true,
          "check": false,
          "title": "display GRID"
        },
        {
          "name": "F9",
          "key": "F9",
          "show": true,
          "check": false,
          "title": "Enrg."
        },
        {
          "name": "F11",
          "key": "F11",
          "show": true,
          "check": false,
          "title": "Update"
        },
        {
          "name": "F12",
          "key": "F12",
          "show": true,
          "check": false,
          "title": "Return"
        },
        {
          "name": "F23",
          "key": "F23",
          "show": true,
          "check": false,
          "title": "Delette"
        }
      ],
      "label": [
        {
          "name": "L33",
          "posx": 3,
          "posy": 4,
          "text": "Name Extended",
          "title": false
        },
        {
          "name": "L320",
          "posx": 3,
          "posy": 20,
          "text": "Text",
          "title": false
        },
        {
          "name": "L371",
          "posx": 3,
          "posy": 71,
          "text": "MNEMO",
          "title": false
        },
        {
          "name": "L378",
          "posx": 3,
          "posy": 78,
          "text": "T",
          "title": false
        },
        {
          "name": "L380",
          "posx": 3,
          "posy": 80,
          "text": "Long",
          "title": false
        },
        {
          "name": "L385",
          "posx": 3,
          "posy": 85,
          "text": "Width",
          "title": false
        },
        {
          "name": "L391",
          "posx": 3,
          "posy": 91,
          "text": "Scal",
          "title": false
        }
      ],
      "field": [
        {
          "name": "MNEXTD",
          "posx": 4,
          "posy": 4,
          "reftyp": "TEXT_FREE",
          "width": 15,
          "scal": 0,
          "text": "",
          "requier": true,
          "protect": false,
          "edtcar": "",
          "errmsg": "Le nom est obligantoire",
          "help": "Nom de la zone étendue",
          "procfunc": "",
          "proctask": "TctlName",
          "progcall": "",
          "typecall": "",
          "parmcall": false,
          "regex": ""
        },
        {
          "name": "TEXT",
          "posx": 4,
          "posy": 20,
          "reftyp": "TEXT_FREE",
          "width": 50,
          "scal": 0,
          "text": "",
          "requier": true,
          "protect": false,
          "edtcar": "",
          "errmsg": "Text Invalide",
          "help": "Libellé de la zone NAME Extended",
          "procfunc": "",
          "proctask": "",
          "progcall": "",
          "typecall": "",
          "parmcall": false,
          "regex": ""
        },
        {
          "name": "MNEMO",
          "posx": 4,
          "posy": 71,
          "reftyp": "ALPHA_NUMERIC_UPPER",
          "width": 6,
          "scal": 0,
          "text": "",
          "requier": true,
          "protect": false,
          "edtcar": "",
          "errmsg": "Mnemonic onmigatoire",
          "help": "mnemoniqque de la zone MXEXTD",
          "procfunc": "",
          "proctask": "TctlMnemo",
          "progcall": "",
          "typecall": "",
          "parmcall": false,
          "regex": ""
        },
        {
          "name": "TYPE",
          "posx": 4,
          "posy": 78,
          "reftyp": "FUNC",
          "width": 1,
          "scal": 0,
          "text": "",
          "requier": true,
          "protect": false,
          "edtcar": "",
          "errmsg": "Type obligatoire",
          "help": "Type de zone",
          "procfunc": "Ctype",
          "proctask": "TctrlType",
          "progcall": "",
          "typecall": "",
          "parmcall": false,
          "regex": ""
        },
        {
          "name": "LONG",
          "posx": 4,
          "posy": 81,
          "reftyp": "UDIGIT",
          "width": 3,
          "scal": 0,
          "text": "",
          "requier": true,
          "protect": false,
          "edtcar": "",
          "errmsg": "Longueur de la zone extended Invalide",
          "help": "Longueur de la zone",
          "procfunc": "",
          "proctask": "TcrtlLong",
          "progcall": "",
          "typecall": "",
          "parmcall": false,
          "regex": ""
        },
        {
          "name": "WIDTH",
          "posx": 4,
          "posy": 87,
          "reftyp": "UDIGIT",
          "width": 3,
          "scal": 0,
          "text": "",
          "requier": true,
          "protect": false,
          "edtcar": "",
          "errmsg": "Width Obligatoire",
          "help": "longueur de la zone numérique",
          "procfunc": "",
          "proctask": "TctrlWidth",
          "progcall": "",
          "typecall": "",
          "parmcall": false,
          "regex": ""
        },
        {
          "name": "SCAL",
          "posx": 4,
          "posy": 92,
          "reftyp": "UDIGIT",
          "width": 3,
          "scal": 0,
          "text": "",
          "requier": true,
          "protect": false,
          "edtcar": "",
          "errmsg": "Scal Obligatoire",
          "help": "partie decimale",
          "procfunc": "",
          "proctask": "TctrlScal",
          "progcall": "",
          "typecall": "",
          "parmcall": false,
          "regex": ""
        }
      ],
      "linev": [],
      "lineh": []
    }
  ],
  "GRID": [
    {
      "name": "Grept",
      "posx": 6,
      "posy": 2,
      "pagerows": 30,
      "separator": "│",
      "cadre": "line1",
      "cells": [
        {
          "text": "MNXETD",
          "long": 15,
          "reftyp": "TEXT_FREE",
          "posy": 0,
          "edtcar": "",
          "atrcell": "fgYellow"
        },
        {
          "text": "TEXT",
          "long": 50,
          "reftyp": "TEXT_FREE",
          "posy": 1,
          "edtcar": "",
          "atrcell": "fgGreen"
        },
        {
          "text": "MNEMO",
          "long": 6,
          "reftyp": "TEXT_FREE",
          "posy": 2,
          "edtcar": "",
          "atrcell": "fgYellow"
        },
        {
          "text": "T",
          "long": 1,
          "reftyp": "TEXT_FREE",
          "posy": 3,
          "edtcar": "",
          "atrcell": "fgRed"
        },
        {
          "text": "LONG",
          "long": 4,
          "reftyp": "UDIGIT",
          "posy": 4,
          "edtcar": "",
          "atrcell": "fgCyan"
        },
        {
          "text": "WIGTH",
          "long": 5,
          "reftyp": "UDIGIT",
          "posy": 5,
          "edtcar": "",
          "atrcell": "fgMagenta"
        },
        {
          "text": "SCAL",
          "long": 4,
          "reftyp": "UDIGIT",
          "posy": 6,
          "edtcar": "",
          "atrcell": "fgMagenta"
        }
      ]
    },
    {
      "name": "Ctype",
      "posx": 5,
      "posy": 78,
      "pagerows": 7,
      "separator": "│",
      "cadre": "line1",
      "cells": [
        {
          "text": "Type",
          "long": 4,
          "reftyp": "TEXT_FREE",
          "posy": 0,
          "edtcar": "",
          "atrcell": "fgGreen"
        },
        {
          "text": "Label",
          "long": 10,
          "reftyp": "TEXT_FREE",
          "posy": 1,
          "edtcar": "",
          "atrcell": "fgYellow"
        }
      ]
    }
  ]
}
