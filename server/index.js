require("dotenv").config();
const express = require("express");
const OpenAI = require("openai");
const cors = require("cors");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json({ limit: '200mb' }));
app.use(express.urlencoded({ limit: '200mb', extended: true }));

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || "INSERISCI_QUI_LA_TUA_CHIAVE",
});

app.post("/chat", async (req, res) => {
  const { richiesta, fileName, fileBytes } = req.body;

  if (!richiesta && !fileBytes) {
    return res.status(400).json({ errore: "Richiesta mancante" });
  }

  try {
    const promptText = richiesta || "Analizza questo contenuto e descrivi in dettaglio cosa vedi.";
    const userContent = [{ type: "text", text: promptText }];

    if (fileBytes && fileName) {
      const extension = fileName.split(".").pop().toLowerCase();
      
      let mimeType = "image/jpeg";
      if (extension === "png") mimeType = "image/png";
      if (extension === "webp") mimeType = "image/webp";
      if (extension === "gif") mimeType = "image/gif";

      userContent.push({
        type: "image_url",
        image_url: {
          url: `data:${mimeType};base64,${fileBytes}`,
        },
      });
    }

    console.log("Invio dati a OpenAI in corso...");

    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "user",
          content: userContent,
        },
      ],
    });

    res.json({ risposta: response.choices[0].message.content });

  } catch (errore) {
    console.error("ERRORE SERVER:", errore);
    res.status(500).json({ errore: "Errore durante l'elaborazione del file." });
  }
});

app.listen(PORT, () => {
  console.log(`TelemedIA Server (OpenAI) attivo sulla porta ${PORT}`);
});