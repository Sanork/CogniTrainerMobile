#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "core/ModuleRegistry.h"
#include "core/CategoryManager.h"

int main(int argc, char *argv[])
{

    QCoreApplication::setOrganizationName("MyCompany");
    QCoreApplication::setOrganizationDomain("mycompany.com");
    QCoreApplication::setApplicationName("CognitiveApp");
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    //QCoreApplication::setAttribute(Qt::AA_UseSoftwareOpenGL);

    QQuickStyle::setStyle("Material");

    ModuleRegistry moduleRegistry;
    moduleRegistry.loadModules();

    // Доступ из QML
    engine.rootContext()->setContextProperty("moduleRegistry", &moduleRegistry);

    CategoryManager categoryManager;
    engine.rootContext()->setContextProperty("categoryManager", &categoryManager);

    const QUrl url(u"qrc:/qml/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
