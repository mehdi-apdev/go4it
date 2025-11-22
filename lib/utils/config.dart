/*
 * Fichier de configuration central pour l'API.
 *
 * MODIFIER LES CONSTANTES CI-DESSOUS EN FONCTION DE VOTRE ENVIRONNEMENT.
 */

// --- 1. ADRESSE IP DU MAC SUR LE WIFI ---
// (Dans Réglages Système -> Wi-Fi -> Détails...)
// Remplacez "192.168.1.10" par l'IP du Mac.
// const String _macWiFiIp = '192.168.129.50';


// --- 2. CHOISISSEZ VOTRE ENVIRONNEMENT ACTUEL ---
//
// Décommentez la ligne correspondant à l'appareil que vous utilisez
// pour vos tests.

// --- OPTION A : Pour le SIMULATEUR iOS ---
 const String baseUrl = 'http://localhost:3000/api';

// --- OPTION B : Pour votre IPHONE PHYSIQUE ---
// (S'assurez que _macWiFiIp est correcte)
// const String baseUrl = 'http://$_macWiFiIp:3000/api';

// --- OPTION C : Pour un ÉMULATEUR ANDROID ---
// const String baseUrl = 'http://10.0.2.2:3000/api';