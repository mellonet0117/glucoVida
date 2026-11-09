/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */


//const {setGlobalOptions} = require("firebase-functions");
//const {onRequest} = require("firebase-functions/https");
//const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
//setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentDeleted,
} = require("firebase-functions/v2/firestore");

const {
  initializeApp,
} = require("firebase-admin/app");

const {
  getFirestore,
} = require("firebase-admin/firestore");

const {
  getMessaging,
} = require("firebase-admin/messaging");

initializeApp();

const db = getFirestore();


// ======================================================
// ENVIAR NOTIFICACIÓN A UN USUARIO
// ======================================================

async function enviarNotificacion(
  uid,
  titulo,
  cuerpo,
  datos = {}
) {
  if (!uid) {
    console.log("No se recibió UID.");
    return;
  }

  // ==========================================
  // MODO EMULADOR
  // ==========================================

  if (
    process.env.FUNCTIONS_EMULATOR ===
    "true"
  ) {
    await db
      .collection("notificaciones_test")
      .add({
        usuarioId: uid,
        titulo: titulo,
        cuerpo: cuerpo,
        datos: datos,
        fecha:
          new Date(),
      });

    console.log(
      "🧪 NOTIFICACIÓN DE PRUEBA"
    );

    console.log(
      `Usuario: ${uid}`
    );

    console.log(
      `Título: ${titulo}`
    );

    console.log(
      `Cuerpo: ${cuerpo}`
    );

    return;
  }

  // ==========================================
  // PRODUCCIÓN
  // ==========================================

  const usuarioDoc = await db
    .collection("usuarios")
    .doc(uid)
    .get();

  if (!usuarioDoc.exists) {
    console.log(
      `Usuario ${uid} no existe.`
    );

    return;
  }

  const usuario =
    usuarioDoc.data();

  const token =
    usuario.fcmToken;

  if (!token) {
    console.log(
      `Usuario ${uid} no tiene fcmToken.`
    );

    return;
  }

  const datosString = {};

  for (
    const [clave, valor]
    of Object.entries(datos)
  ) {
    datosString[clave] =
      String(valor);
  }

  try {
    const respuesta =
      await getMessaging().send({
        token: token,

        notification: {
          title: titulo,
          body: cuerpo,
        },

        data: datosString,

        android: {
          priority: "high",

          notification: {
            sound: "default",
          },
        },
      });

    console.log(
      "Notificación enviada:",
      respuesta
    );
  } catch (error) {
    console.error(
      "Error enviando notificación:",
      error
    );
  }
}


// ======================================================
// FORMATEAR FECHA
// ======================================================

function formatearFecha(
  timestamp
) {
  if (!timestamp) {
    return "";
  }

  const fecha =
    timestamp.toDate();

  return new Intl.DateTimeFormat(
    "es-MX",
    {
      timeZone:
        "America/Mexico_City",

      day: "2-digit",
      month: "2-digit",
      year: "numeric",

      hour: "2-digit",
      minute: "2-digit",
    }
  ).format(fecha);
}


// ======================================================
// NUEVA RECOMENDACIÓN
// Doctor → Paciente
// ======================================================

exports.nuevaRecomendacion =
  onDocumentCreated(
    "usuarios/{pacienteId}/recomendaciones/{recomendacionId}",

    async (event) => {
      if (!event.data) {
        return;
      }

      const recomendacion =
        event.data.data();

      const pacienteId =
        event.params.pacienteId;

      const tipo =
        recomendacion.tipo ||
        "General";

      const titulo =
        recomendacion.titulo ||
        "Nueva recomendación";

      await enviarNotificacion(
        pacienteId,

        "🩺 Nueva recomendación",

        `${tipo}: ${titulo}`,

        {
          tipo:
            "recomendacion",

          recomendacionId:
            event.params
              .recomendacionId,

          pacienteId:
            pacienteId,
        }
      );
    }
  );


// ======================================================
// NUEVA CITA
// ======================================================

exports.nuevaCita =
  onDocumentCreated(
    "citas/{citaId}",

    async (event) => {
      if (!event.data) {
        return;
      }

      const cita =
        event.data.data();

      const fecha =
        formatearFecha(
          cita.fechaHora
        );

      // ----------------------------------
      // PACIENTE SOLICITÓ CITA
      // ----------------------------------

      if (
        cita.creadaPor ===
        "paciente"
      ) {
        await enviarNotificacion(
          cita.doctorId,

          "📅 Nueva solicitud de cita",

          `Un paciente solicitó una cita para ${fecha}.`,

          {
            tipo:
              "solicitud_cita",

            citaId:
              event.params.citaId,

            pacienteId:
              cita.pacienteId,
          }
        );

        return;
      }


      // ----------------------------------
      // DOCTOR CREÓ CITA
      // ----------------------------------

      if (
        cita.creadaPor ===
        "doctor"
      ) {
        await enviarNotificacion(
          cita.pacienteId,

          "📅 Nueva cita programada",

          `Tu doctor programó una cita para ${fecha}.`,

          {
            tipo:
              "cita",

            citaId:
              event.params.citaId,
          }
        );
      }
    }
  );


// ======================================================
// ACTUALIZACIÓN DE CITA
// Confirmar / cancelar / reprogramar
// ======================================================

exports.citaActualizada =
  onDocumentUpdated(
    "citas/{citaId}",

    async (event) => {
      if (!event.data) {
        return;
      }

      const antes =
        event.data.before.data();

      const despues =
        event.data.after.data();

      const pacienteId =
        despues.pacienteId;


      // ==================================
      // CAMBIO DE ESTADO
      // ==================================

      if (
        antes.estado !==
        despues.estado
      ) {
        if (
          despues.estado ===
          "confirmada"
        ) {
          await enviarNotificacion(
            pacienteId,

            "✅ Cita confirmada",

            `Tu cita del ${formatearFecha(
              despues.fechaHora
            )} fue confirmada.`,

            {
              tipo:
                "cita_confirmada",

              citaId:
                event.params.citaId,
            }
          );

          return;
        }


        if (
          despues.estado ===
          "cancelada"
        ) {
          await enviarNotificacion(
            pacienteId,

            "❌ Cita cancelada",

            "Tu doctor canceló una de tus citas.",

            {
              tipo:
                "cita_cancelada",

              citaId:
                event.params.citaId,
            }
          );

          return;
        }
      }


      // ==================================
      // CAMBIO DE FECHA
      // ==================================

      const fechaAntes =
        antes.fechaHora
          ?.toMillis();

      const fechaDespues =
        despues.fechaHora
          ?.toMillis();

      if (
        fechaAntes !==
        fechaDespues
      ) {
        await enviarNotificacion(
          pacienteId,

          "📅 Cita reprogramada",

          `Tu cita fue reprogramada para ${formatearFecha(
            despues.fechaHora
          )}.`,

          {
            tipo:
              "cita_reprogramada",

            citaId:
              event.params.citaId,
          }
        );
      }
    }
  );


// ======================================================
// CITA ELIMINADA
// ======================================================

exports.citaEliminada =
  onDocumentDeleted(
    "citas/{citaId}",

    async (event) => {
      if (!event.data) {
        return;
      }

      const cita =
        event.data.data();

      await enviarNotificacion(
        cita.pacienteId,

        "🗑️ Cita eliminada",

        "Tu doctor eliminó una cita de tu agenda.",

        {
          tipo:
            "cita_eliminada",

          citaId:
            event.params.citaId,
        }
      );
    }
  );