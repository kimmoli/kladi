#
# Project kladi, Pastebin application
#

TARGET = kladi

CONFIG += sailfishapp

DEVELKEY = $$system(cat develkey)

DEFINES += "APPVERSION=\\\"$${SPECVERSION}\\\""
DEFINES += "DEVELKEY=\\\"$${DEVELKEY}\\\""

message($${DEFINES})

#INCLUDEPATH += src

SOURCES += src/kladi.cpp \
	src/pastes.cpp \
    src/pastebinapi.cpp
	
HEADERS += src/pastes.h \
    src/pastebinapi.h

OTHER_FILES += qml/kladi.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FrontPage.qml \
    qml/pages/AboutPage.qml \
    rpm/kladi.spec \
	kladi.png \
    kladi.desktop \
    qml/pages/SettingsPage.qml

