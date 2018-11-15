#include "biercalc.h"
#include <math.h>

const double BierCalc::dichteAlkohol = 0.7894;

const double BierCalc::faktorBrixToPlato = 1.03;

double BierCalc::brixToPlato(double brix)
{
    return brix / faktorBrixToPlato;
}

double BierCalc::platoToBrix(double plato)
{
    return plato * faktorBrixToPlato;
}

double BierCalc::brixToDichte(double sw, double brix, BrixToPlato formel)
{
    double b = brixToPlato(brix);
    switch (formel)
    {
    case Terrill:
        // http://seanterrill.com/2011/04/07/refractometer-fg-results/
        return 1 - 0.0044993*sw + 0.0117741*b + 0.000275806*sw*sw - 0.00127169*b*b - 0.00000727999*sw*sw*sw + 0.0000632929*b*b*b;
    case TerrillLinear:
        // http://seanterrill.com/2011/04/07/refractometer-fg-results/
        return 1.0000 - 0.00085683*sw + 0.0034941*b;
    case Standard:
        return 1.001843-0.002318474*sw - 0.000007775*sw*sw - 0.000000034*sw*sw*sw + 0.00574*brix + 0.00003344*brix*brix + 0.000000086*brix*brix*brix;
    default:
        return 0.0;
    }
}

double BierCalc::dichteToPlato(double sg)
{
    // deClerk: http://www.realbeer.com/spencer/attenuation.html
    return 668.72 * sg - 463.37 - 205.347 * sg * sg;
}

double BierCalc::platoToDichte(double plato)
{
  #if 0 // Umkehrformel zu dichteToPlato()
    // deClerk: http://www.realbeer.com/spencer/attenuation.html
    double a = 205.347;
    double b = 668.72;
    double c = 463.37 + plato;
    double d = 4 * a * c;
    return (-b + sqrt(b * b - d)) / (2 * a) * -1;
  #else // Formel vom Internet
    return 261.11 / (261.53 - plato);
  #endif
}

double BierCalc::toTRE(double sw, double sre)
{
#if 1
    // Balling: http://realbeer.com/spencer/attenuation.html
    return 0.1808 * sw + 0.8192 * sre;
#else
    // http://hobbybrauer.de/modules.php?name=eBoard&file=viewthread&fid=1&tid=11943
    double q = 0.22 + 0.001 * sw;
    return (q * sw + sre)/(1 + q);
#endif
}

double BierCalc::toSRE(double sw, double tre)
{
#if 1
    // Balling: http://realbeer.com/spencer/attenuation.html
    return (tre - 0.1808 * sw) / 0.8192;
#else
    // http://hobbybrauer.de/modules.php?name=eBoard&file=viewthread&fid=1&tid=11943
    double q = 0.22 + 0.001 * sw;
    return tre * (1 + q) - q * sw;
#endif
}

double BierCalc::extraktForCO2(double co2)
{
    // C12H22O11 + H2O -> 4C2H5OH + 4CO2
    //  342.3g   +  .. ->   ...   + 127.04g
    //   1g            ->           0.51429
    return co2 / 0.51429;
}

double BierCalc::co2ForExtrakt(double extrakt)
{
    // C12H22O11 + H2O -> 4C2H5OH + 4CO2
    //  342.3g   +  .. ->   ...   + 127.04g
    //   1g            ->           0.51429
    return extrakt * 0.51429;
}

double BierCalc::vergaerungsgrad(double sw, double e)
{
    if (sw <= 0.0)
        return 0.0;
    double res = (1 - e / sw) * 100;
    if (res < 0.0)
        res = 0.0;
    return res;
}

double BierCalc::alkohol(double sw, double sre)
{
    if (sw <= 0.0)
        return 0.0;

    double tre = toTRE(sw, sre);
    double dichte = platoToDichte(tre);

    // Alkohol Gewichtsprozent
    // http://www.realbeer.com/spencer/attenuation.html
    // Balling: 2.0665g Extrakt ergibt 1g Alkohol, 0.9565g CO2, 0.11g Hefe
    double alcGewicht = (sw - tre) / (2.0665 - 0.010665 * sw);

    // Alkohol Volumenprozent
    double alc = alcGewicht * dichte / dichteAlkohol;
    if (alc < 0.0)
        alc = 0.0;
    return alc;
}

double BierCalc::co2(double p, double T)
{
    return (1.013 + p) * exp(-10.73797+(2617.25/(T+273.15))) * 10;
}

double BierCalc::p(double co2, double T)
{
    return co2 / (exp(-10.73797+(2617.25/(T+273.15))) * 10) - 1.013;
}

double BierCalc::gruenschlauchzeitpunkt(double co2Soll, double sw, double sreSchnellgaerprobe, double T)
{
    double tre = toTRE(sw, sreSchnellgaerprobe);
    double dichte = platoToDichte(tre);
    double extraktCO2 = extraktForCO2(co2Soll - co2(0.0, T)) / (dichte * 10);
    double res = toSRE(sw, tre + extraktCO2);
    if (res < 0.0)
        res = 0.0;
    return res;
}

double BierCalc::spundungsdruck(double co2Soll, double T)
{
    double res = p(co2Soll, T);
    if (res < 0.0)
        res = 0.0;
    return res;
}

double BierCalc::speise(double co2Soll, double sw, double sreSchnellgaerprobe, double sreJungbier, double T)
{
    double treSchnellgaerprobe = toTRE(sw, sreSchnellgaerprobe);
    double treJungbier = toTRE(sw, sreJungbier);
    double dichteSpeise = platoToDichte(sw);
    double dichteJungbier = platoToDichte(treJungbier);

    // CO2 Potenzial der endvergorenen Speise
    double co2Pot = co2ForExtrakt(sw - treSchnellgaerprobe) * (dichteSpeise * 10);
    if (co2Pot <= 0.0)
        return 0.0;

    // CO2 Potenzial im teilvergorenen Jungbier
    double co2PotJungbier = co2ForExtrakt((treJungbier - treSchnellgaerprobe) * (dichteJungbier * 10));

    // Benoetigtes zusaetzliches CO2
    double co2Add = co2Soll - co2(0.0, T) - co2PotJungbier;

    // Benoetigte zusaetzliche Speise
    double speise1 = co2Add / co2Pot;
    if (speise1 < 0.0)
        speise1 = 0.0;

    // Benoetigte zusaetzliche Speise fuer Karbonisierung der Speise 1
    double speise2 = speise1 * co2Soll / co2Pot;

    // Benoetigte zusaetzliche Speise fuer Karbonisierung der Speise 2
    double speise3 = speise2 * co2Soll / co2Pot;

    // Total benoetigte zusaetzliche Speise
    return speise1 + speise2 + speise3;
}

double BierCalc::speiseToZucker(double sw, double sre, double speise)
{
    if (speise <= 0.0)
        return 0.0;
    double tre = toTRE(sw, sre);
    return (sw - tre) * 10 * (speise / 1000);
}

double BierCalc::dichteWasser(double T)
{
    const double a0 = 999.83952;
    const double a1 = 16.952577;
    const double a2 = -0.0079905127;
    const double a3 = -0.000046241757;
    const double a4 = 0.00000010584601;
    const double a5 = -0.00000000028103006;
    const double b = 0.016887236;
    return (a0 + T * a1 + pow(T,2) * a2 + pow(T,3) * a3 + pow(T,4) * a4 + pow(T,5) * a5) / (1 + T * b);
}

double BierCalc::volumenWasser(double T1, double T2, double V1)
{
    double rho1 = dichteWasser(T1);
    double rho2 = dichteWasser(T2);
    return (rho1 * V1) / rho2;
}

double BierCalc::verdampfungsziffer(double V1, double V2, double t)
{
    if (t == 0.0 || V2 == 0.0 || V1 < V2)
        return 0.0;
    return ((V1 - V2) * 100 * 60) / (V2 * t);
}

double BierCalc::sudhausausbeute(double sw, double V, double schuettung)
{
    if (schuettung <= 0.0)
        return 0.0;
    return sw * platoToDichte(sw) * 0.96 * V / schuettung;
}

double BierCalc::verschneidung(double swIst, double swSoll, double menge)
{
    if (swIst < swSoll || swSoll == 0.0)
        return 0.0;
    return menge * (swIst / swSoll - 1);
}

QColor BierCalc::ebcToColor(double ebc)
{
    static int aFarbe[300][3] = {
        {250,250,210},
        {250,250,204},
        {250,250,199},
        {250,250,193},
        {250,250,188},
        {250,250,182},
        {250,250,177},
        {250,250,171},
        {250,250,166},
        {250,250,160},
        {250,250,155},
        {250,250,149},
        {250,250,144},
        {250,250,138},
        {250,250,133},
        {250,250,127},
        {250,250,122},
        {250,250,116},
        {250,250,111},
        {250,250,105},
        {250,250,100},
        {250,250,94},
        {250,250,89},
        {250,250,83},
        {250,250,78},
        {249,250,72},
        {248,249,67},
        {247,248,61},
        {246,247,56},
        {245,246,50},
        {244,245,45},
        {243,244,45},
        {242,242,45},
        {241,240,46},
        {240,238,46},
        {239,236,46},
        {238,234,46},
        {237,232,47},
        {236,230,47},
        {235,228,47},
        {234,226,47},
        {233,224,48},
        {232,222,48},
        {231,220,48},
        {230,218,48},
        {229,216,49},
        {228,214,49},
        {227,212,49},
        {226,210,49},
        {225,208,50},
        {224,206,50},
        {223,204,50},
        {222,202,50},
        {221,200,51},
        {220,198,51},
        {219,196,51},
        {218,194,51},
        {217,192,52},
        {216,190,52},
        {215,188,52},
        {214,186,52},
        {213,184,53},
        {212,182,53},
        {211,180,53},
        {210,178,53},
        {209,176,54},
        {208,174,54},
        {207,172,54},
        {206,170,54},
        {205,168,55},
        {204,166,55},
        {203,164,55},
        {202,162,55},
        {201,160,56},
        {200,158,56},
        {200,156,56},
        {199,154,56},
        {199,152,56},
        {198,150,56},
        {198,148,56},
        {197,146,56},
        {197,144,56},
        {196,142,56},
        {196,141,56},
        {195,140,56},
        {195,139,56},
        {194,139,56},
        {194,138,56},
        {193,137,56},
        {193,136,56},
        {192,136,56},
        {192,135,56},
        {192,134,56},
        {192,133,56},
        {192,133,56},
        {192,132,56},
        {192,131,56},
        {192,130,56},
        {192,130,56},
        {192,129,56},
        {192,128,56},
        {192,127,56},
        {192,127,56},
        {192,126,56},
        {192,125,56},
        {192,124,56},
        {192,124,56},
        {192,123,56},
        {192,122,56},
        {192,121,56},
        {192,121,56},
        {192,120,56},
        {192,119,56},
        {192,118,56},
        {192,118,56},
        {192,117,56},
        {192,116,56},
        {192,115,56},
        {192,115,56},
        {192,114,56},
        {192,113,56},
        {192,112,56},
        {192,112,56},
        {192,111,56},
        {192,110,56},
        {192,109,56},
        {192,109,56},
        {192,108,56},
        {191,107,56},
        {190,106,56},
        {189,106,56},
        {188,105,56},
        {187,104,56},
        {186,103,56},
        {185,103,56},
        {184,102,56},
        {183,101,56},
        {182,100,56},
        {181,100,56},
        {180,99,56},
        {179,98,56},
        {178,97,56},
        {177,97,56},
        {175,96,55},
        {174,95,55},
        {172,94,55},
        {171,94,55},
        {169,93,54},
        {168,92,54},
        {167,91,54},
        {165,91,54},
        {164,90,53},
        {162,89,53},
        {161,88,53},
        {159,88,53},
        {158,87,52},
        {157,86,52},
        {155,85,52},
        {154,85,52},
        {152,84,51},
        {151,83,51},
        {149,82,51},
        {148,82,51},
        {147,81,50},
        {145,80,50},
        {144,79,50},
        {142,78,50},
        {141,77,49},
        {139,76,49},
        {138,75,48},
        {137,75,47},
        {135,74,47},
        {134,73,46},
        {132,72,45},
        {131,72,45},
        {129,71,44},
        {128,70,43},
        {127,69,43},
        {125,69,42},
        {124,68,41},
        {122,67,41},
        {121,66,40},
        {119,66,39},
        {118,65,39},
        {117,64,38},
        {115,63,37},
        {114,63,37},
        {112,62,36},
        {111,61,35},
        {109,60,34},
        {108,60,33},
        {107,59,32},
        {105,58,31},
        {104,57,29},
        {102,57,28},
        {101,56,27},
        {99,55,26},
        {98,54,25},
        {97,54,24},
        {95,53,23},
        {94,52,21},
        {92,51,20},
        {91,51,19},
        {89,50,18},
        {88,49,17},
        {87,48,16},
        {85,48,15},
        {84,47,13},
        {82,46,12},
        {81,45,11},
        {79,45,10},
        {78,44,9},
        {77,43,8},
        {75,42,9},
        {74,42,9},
        {72,41,10},
        {71,40,10},
        {69,39,11},
        {68,39,11},
        {67,38,12},
        {65,37,12},
        {64,36,13},
        {62,36,13},
        {61,35,14},
        {59,34,14},
        {58,33,15},
        {57,33,15},
        {55,32,16},
        {54,31,16},
        {52,30,17},
        {51,30,17},
        {49,29,18},
        {48,28,18},
        {47,27,19},
        {45,27,19},
        {44,26,20},
        {42,25,20},
        {41,24,21},
        {39,24,21},
        {38,23,22},
        {37,22,21},
        {37,22,21},
        {36,22,21},
        {36,21,20},
        {35,21,20},
        {35,21,20},
        {34,20,19},
        {34,20,19},
        {33,20,19},
        {33,19,18},
        {32,19,18},
        {32,19,18},
        {31,18,17},
        {31,18,17},
        {30,18,17},
        {30,17,16},
        {29,17,16},
        {29,17,16},
        {28,16,15},
        {28,16,15},
        {27,16,15},
        {27,15,14},
        {26,15,14},
        {26,15,14},
        {25,14,13},
        {25,14,13},
        {24,14,13},
        {24,13,12},
        {23,13,12},
        {23,13,12},
        {22,12,11},
        {22,12,11},
        {21,12,11},
        {21,11,10},
        {20,11,10},
        {20,11,10},
        {19,10,9},
        {19,10,9},
        {18,10,9},
        {18,9,8},
        {17,9,8},
        {17,9,8},
        {16,8,7},
        {16,8,7},
        {15,8,7},
        {15,7,6},
        {14,7,6},
        {14,7,6},
        {13,6,5},
        {13,6,5},
        {12,6,5},
        {12,5,4},
        {11,5,4},
        {11,5,4},
        {10,4,3},
        {10,4,3},
        {9,4,3},
        {9,3,2},
        {8,3,2},
        {8,3,2}
    };
    double srm = ebc / 1.97;
    int index = (int)round(srm * 10);
    if (index > 300)
        index = 300;
    --index;
    if (index >= 0)
        return QColor::fromRgb(aFarbe[index][0], aFarbe[index][1], aFarbe[index][2]);
    else
        return Qt::white;
}
