#ifndef BIERCALC_H
#define BIERCALC_H

#include <QObject>
#include <QColor>

#if defined(KBCORE_LIBRARY)
  #define KBCORE_EXPORT Q_DECL_EXPORT
#else
  #define KBCORE_EXPORT Q_DECL_IMPORT
#endif

/**
 * @brief Berechnungen rund um die Bierherstellung
 * @note Wird von QObject abgeleitet, damit die Klasse in QML aufgerufen werden kann
 */
class KBCORE_EXPORT BierCalc : public QObject
{
    Q_OBJECT

public:

    /**
     * @brief Formel für Umrechnung von brix [°brix] nach spezifische Dichte [g/ml]
     */
    enum BrixToPlato
    {
        Terrill = 0,
        TerrillLinear = 1,
        Standard = 2
    };
    Q_ENUM(BrixToPlato)

    /**
     * @brief Dichte von Alkohol bei 20°C [kg/l]
     */
    static const double dichteAlkohol;

    /**
     * @brief Umrechnungsfaktor von brix [°brix] nach plato [°P], da Bierwürze
     * keine reine Saccharoselösung ist
     * @note Zwischen 1.02 und 1.06 je nach Literaturangabe, meist 1.03
     */
    static const double faktorBrixToPlato;

public:

    /**
     * @brief Umrechnung von Refraktometerwert [°brix] nach plato [°P]
     * @note 1°Plato = 1g Saccharose / 100g Saccharoselösung
     * @param brix Refraktometerwert [°brix]
     * @return Plato [°P]
     */
    Q_INVOKABLE static double brixToPlato(double brix);

    /**
     * @brief Umrechnung von Refraktometerwert [°brix] nach plato [°P]
     * @note 1°Plato = 1g Saccharose / 100g Saccharoselösung
     * @param plato Plato [°P]
     * @return Refraktometerwert [°brix]
     */
    Q_INVOKABLE static double platoToBrix(double plato);

    /**
     * @brief Umrechnung von Refraktometerwert [°brix] nach spezifische Dichte [g/ml]
     * @param sw Stammwürze [°P]
     * @param brix Refraktometerwert [°brix]
     * @param formel Benutze Umrechnungsformel
     * @return Spezifische Dichte [g/ml]
     */
    Q_INVOKABLE static double brixToDichte(double sw, double brix, BrixToPlato formel = Terrill);

    /**
     * @brief Umrechnung spezifische Dichte bei 20°C [g/ml] nach plato [°P]
     * @note 1°Plato = 1g Saccharose / 100g Saccharoselösung
     * @param sg Spezifische Dichte [g/ml]
     * @return Plato [°P]
     */
    Q_INVOKABLE static double dichteToPlato(double sg);

    /**
     * @brief Umrechnung plato [°P] nach spezifische Dichte bei 20°C [g/ml]
     * @note 1°Plato = 1g Saccharose / 100g Saccharoselösung
     * @param plato Plato [°P]
     * @return Spezifische Dichte [g/ml]
     */
    Q_INVOKABLE static double platoToDichte(double plato);

    /**
     * @brief Tatsächlicher Restextrakt (Alkohol-korrigiert) [°P]
     * @param sw Stammwürze [°P]
     * @param sre Scheinbarer Restextrakt [°P]
     * @return Tatsächlicher Restextrakt [°P]
     */
    Q_INVOKABLE static double toTRE(double sw, double sre);

    /**
     * @brief Scheinbarer Restextrakt (Alkohol-verfälscht) [°P]
     * @param sw Stammwürze [°P]
     * @param tre TatsächlicherScheinbarer Restextrakt [°P]
     * @return Scheinbarer Restextrakt [°P]
     */
    Q_INVOKABLE static double toSRE(double sw, double tre);

    /**
     * @brief Benoetigtes Extrakt um CO2 zu bilden
     * @param co2 CO2 Gehalt [g/l]
     * @return Extrakt [g/l]
     */
    Q_INVOKABLE static double extraktForCO2(double co2);

    /**
     * @brief CO2 Bildung bei gegebenen Extrakt
     * @param extrakt Extrakt [g/l]
     * @return CO2 Gehalt [g/l]
     */
    Q_INVOKABLE static double co2ForExtrakt(double extrakt);

    /**
     * @brief Vergärungsgrad [%]
     * @param sw Stammwuerze [°P]
     * @param e Extrakt [°P]
     * @return Vergärungsgrad [%]
     */
    Q_INVOKABLE static double vergaerungsgrad(double sw, double e);

    /**
     * @brief Alkohol [vol%]
     * @param sw Stammwürze [°P]
     * @param sre Scheinbarer Restextrakt [°P]
     * @return Alkohol [vol%]
     */
    Q_INVOKABLE static double alkohol(double sw, double sre);

    /**
     * @brief CO2 Gehalt bei bestimmentem Druck und bestimmter Temperatur [g/l]
     * @param p Druck [bar]
     * @param T Temperatur [°C]
     * @return CO2 Gehalt [g/l]
     */
    Q_INVOKABLE static double co2(double p, double T);

    /**
     * @brief Druck bei bestimmentem CO2 Gehalt und bestimmter Temperatur [bar]
     * @param co2 CO2 Gehalt [g/l]
     * @param T Temperatur [°C]
     * @return Druck [bar]
     */
    Q_INVOKABLE static double p(double co2, double T);

    /**
     * @brief Gruenschlauchzeitpunkt [°P]
     * @param co2Soll Soll CO2 Gehalt [g/l]
     * @param sw Stammwuerze [°P]
     * @param sreSchnellgaerprobe Scheinbarer Restextrakt Schnellgaerprobe [°P]
     * @param T Temperatur Jungbier [°C]
     * @return Gruenschlauchzeitpunkt [°P]
     */
    Q_INVOKABLE static double gruenschlauchzeitpunkt(double co2Soll, double sw, double sreSchnellgaerprobe, double T);

    /**
     * @brief spundungsdruck Spundungsdruck [bar]
     * @param co2Soll Soll CO2 Gehalt [g/l]
     * @param T Temperatur Jungbier [°C]
     * @return Spundungsdruck [bar]
     */
    Q_INVOKABLE static double spundungsdruck(double co2Soll, double T);

    /**
     * @brief Benoetigte Speise fuer Karbonisierung [L/L]
     * @param co2Soll Soll CO2 Gehalt [g/l]
     * @param sw Stammwuerze [°P]
     * @param sreSchnellgaerprobe Scheinbarer Restextrakt Schnellgaerprobe [°P]
     * @param sreJungbier Scheinbarer Restextrakt Jungbier [°P]
     * @param T Temperatur Jungbier [°C]
     * @return Speisemenge [L/L]
     */
    Q_INVOKABLE static double speise(double co2Soll, double sw, double sreSchnellgaerprobe, double sreJungbier, double T);

    /**
     * @brief Umrechnung von benoetigter Speise in benoetiges Zucker
     * @param sw Stammwuerze Speise [°P]
     * @param sre Scheinbarer Restextrakt Speise [°P]
     * @param speise Speisemenge [mL]
     * @return Zuckermenge [g]
     */
    Q_INVOKABLE static double speiseToZucker(double sw, double sre, double speise);

    /**
     * @brief Dichte von Wasser bei gegebenen Temperatur
     * @param T Temperatur [°C]
     * @return Dichte
     */
    Q_INVOKABLE static double dichteWasser(double T);

    /**
     * @brief Berechnet das Volumen von Wasser bei einer andere Temperatur
     * @param T1 Temperatur 1 [°C]
     * @param T2 Temperatur 2 [°C]
     * @param V1 Volumen bei Temperatur 1 [L]
     * @return Volumen bei Temperatur 2 [L]
     */
    Q_INVOKABLE static double volumenWasser(double T1, double T2, double V1);

    /**
     * @brief Berechnet die Verdampfungsziffer
     * @param V1 Anfangsvolumen [L]
     * @param V2 Endvolumen [L]
     * @param t Kochzeit [min]
     * @return Verdampfungsziffer [%]
     */
    Q_INVOKABLE static double verdampfungsziffer(double V1, double V2, double t);

    /**
     * @brief Berechnet die Sudhausausbeute
     * @param sw Stammwürze [°P]
     * @param V Volumen [L]
     * @param schuettung Schüttung [kg]
     * @return Sudhausausbeute [%]
     */
    Q_INVOKABLE static double sudhausausbeute(double sw, double V, double schuettung);

    /**
     * @brief Benötigte Wassermenge, um auf die Sollstammwürze zu erreichen
     * @param swIst Iststammwürze [°P]
     * @param swSoll Sollstammwürze [°P]
     * @param menge Volumen [L]
     * @return Verschneidung [L]
     */
    Q_INVOKABLE static double verschneidung(double swIst, double swSoll, double menge);

    /**
     * @brief Farbe im RGB Raum
     * @param ebc EBC Farbwert [EBC]
     * @return Farbwert im RGB Raum
     */
    Q_INVOKABLE static QColor ebcToColor(double ebc);
};

#endif // BIERCALC_H
