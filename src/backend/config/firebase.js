import admin from 'firebase-admin';
import fs from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const serviceAccountPath = join(__dirname, '../services/cafeteriauide-firebase.json');

// ────────────────────────────────────────────────
// Solo inicializamos UNA VEZ
let messagingInstance;

if (!admin.apps.length) {
    try {
        const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            // projectId: 'cafeteriauide',   // opcional, pero ayuda en algunos casos
        });

        console.log('[FIREBASE] Inicialización exitosa - primera vez');
    } catch (err) {
        console.error('[FIREBASE] Error crítico al inicializar Firebase Admin:');
        console.error(err);
        process.exit(1); // o maneja según tu estrategia
    }
} else {
    console.log('[FIREBASE] Firebase Admin ya estaba inicializado, reutilizando');
}

// Exportamos siempre la instancia (ya sea nueva o existente)
export const messaging = admin.messaging();

// Si quieres también exportar sendNotificationToTopic
export const sendNotificationToTopic = async (topic, title, body, data = {}) => {
    const message = {
        notification: { title, body },
        data: { ...data, click_action: 'FLUTTER_NOTIFICATION_CLICK' },
        topic,
    };

    try {
        const response = await messaging.send(message);
        console.log(`[FCM] Enviado a "${topic}" → ${response}`);
        return response;
    } catch (error) {
        console.error(`[FCM] Error enviando a "${topic}":`, error.code, error.message);
        throw error;
    }
};