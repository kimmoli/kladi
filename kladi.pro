#
# Project kladi, Pastebin application
#

TARGET = harbour-kladi

CONFIG += sailfishapp

DEVELKEY = $$system(cat develkey)

DEFINES += "APPVERSION=\\\"$${SPECVERSION}\\\""
DEFINES += "DEVELKEY=\\\"$${DEVELKEY}\\\""

message($${DEFINES})

#INCLUDEPATH += src

SOURCES += src/kladi.cpp \
	src/pastes.cpp
	
HEADERS += src/pastes.h

OTHER_FILES += qml/kladi.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FrontPage.qml \
    qml/pages/AboutPage.qml \
    rpm/kladi.spec \
	harbour-kladi.png \
    harbour-kladi.desktop \
    qml/components/Messagebox.qml \
    qml/pages/ShowPaste.qml \
    qml/pages/EditPaste.qml \
    qml/pages/PasteInfo.qml \
    qml/pages/LoginPage.qml \
    qml/pages/AskFilename.qml

