#!/usr/bin/r

x <- structure(.External(.C_dotTclObjv, objv), class = "tclObj")
tkwm.client(x)
