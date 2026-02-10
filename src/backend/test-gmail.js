// test-email.js
import { GmailEmailService } from './services/emailService.js';

async function probarEnvio() {
  try {
    const emailService = new GmailEmailService();

    // Esperamos a que se inicialice (puede tardar un poco la primera vez)
    await new Promise(resolve => setTimeout(resolve, 2000));

    console.log('Estado inicial:', await emailService.getStatus());

    // Si necesita autorización, imprime la URL para autorizar
    if (await emailService.needsAuthorization()) {
      console.log('Necesita autorización. Abre esta URL en tu navegador:');
      console.log(emailService.generateAuthUrl());

      console.log('\nDespués de autorizar, copia el código de la URL y pégalo aquí:');
      process.stdin.once('data', async (data) => {
        const code = data.toString().trim();
        try {
          await emailService.authorize(code);
          console.log('Autorización completada!');
          await enviarPrueba(emailService);
        } catch (err) {
          console.error('Error en autorización:', err.message);
        }
        process.exit(0);
      });
    } else {
      await enviarPrueba(emailService);
    }
  } catch (error) {
    console.error('Error general:', error.message);
  }
}

async function enviarPrueba(service) {
  console.log('Enviando email de prueba...');
  const resultado = await service.sendTestEmail();
  console.log('Resultado:', resultado);
}

probarEnvio();