// ============================================================
// CONFIGURAZIONE DOCUMENTO
// ============================================================
#set document(
  title: "Piano di Lavoro",
  author: "Amerigo Vegliante",
)

#set page(
  paper: "a4",
  margin: (top: 3cm, bottom: 4cm, left: 3cm, right: 3cm),
  header: context {
    if counter(page).get().first() > 2 [
      #set text(size: 10pt)
      #grid(
        columns: (1fr, auto),
        gutter: 0pt,
        align(left + horizon)[
          #text(weight: "bold")[
            #{
              let h = query(heading.where(level: 1).before(here()))
              if h.len() > 0 { h.last().body }
            }
          ]
        ],
        align(right + horizon)[
          #image("unipd.png", width: 1.8cm)
        ],
      )
      #line(length: 100%, stroke: 0.8pt + black)
    ]
  },
  footer: context [
    #line(length: 100%, stroke: 0.8pt + black)
    #v(2pt)
    #grid(
      columns: (1fr, auto),
      gutter: 0pt,
      align(left)[#text(size: 10pt)[Piano di Lavoro]],
      align(right)[#text(size: 10pt)[#counter(page).display("1")]],
    )
  ],
)

#set text(
  font: "New Computer Modern",
  size: 12pt,
  lang: "it",
)

#set par(
  justify: true,
  leading: 0.75em,
  spacing: 0.75em,
)

#set heading(numbering: "1.1")

#set table(
  stroke: 0.3pt + black,
  inset: 9pt,
)

// ============================================================
// PRIMA PAGINA
// ============================================================
#align(center)[
  #v(1cm)
  #image("unipd.png", width: 7cm)
  #v(0.6cm)
  #text(size: 13pt)[Laurea Triennale in Informatica]
  #v(0.5cm)
  #line(length: 100%, stroke: 1pt + black)
  #v(0.4cm)
  #text(size: 22pt, weight: "bold")[PIANO DI LAVORO]
  #v(0.4cm)
  #line(length: 100%, stroke: 1pt + black)
  #v(1.2cm)
  #text(size: 17pt, weight: "bold")[Amerigo Vegliante]
  #v(0.2cm)
  #text(size: 13pt, style: "italic")[2111004]
  #v(2cm)
  #text(size: 13pt)[
    Dipartimento di Matematica "Tullio Levi-Civita" \
    Università degli Studi di Padova
  ]
  #v(1fr)
  #link("https://www.math.unipd.it/")[https://www.math.unipd.it/]
  #v(1cm)
]

#pagebreak()

// ============================================================
// INDICE
// ============================================================
#outline(
  title: "Indice",
  indent: auto,
)

#pagebreak()

// ============================================================
// SEZIONE 1 — CONTATTI
// ============================================================
= Contatti

== Studente

- Amerigo Vegliante
- #link("mailto:amerigo.vegliante@studenti.unipd.it")[amerigo.vegliante\@studenti.unipd.it]
- +39 338 1551859

== Soggetto Promotore

- Prof. Nicolò Navarin
- #link("mailto:nicolo.navarin@unipd.it")[nicolo.navarin\@unipd.it]
- +39 049 8271384

== Tutor del CCS

- Prof.ssa Ombretta Gaggi
- #link("mailto:gaggi@math.unipd.it")[gaggi\@math.unipd.it]
- +39 049 8271356

#pagebreak()

// ============================================================
// SEZIONE 2 — SCOPO DELLA TESI
// ============================================================
= Scopo della tesi

== Contesto e motivazione

Il lavoro di tesi si inserisce nel filone di ricerca inaugurato dalla tesi triennale di Ane-Marie Margarit (Università degli Studi di Padova, A.A. 2024--2025), che ha sviluppato un sistema predittivo del prezzo di Bitcoin basato su Sentiment Analysis con VADER e modelli di Machine Learning classici (Logistic Regression) applicati a post del social network Mastodon. Quel lavoro ha dimostrato la fattibilità dell'approccio identificandone chiaramente i limiti principali: soli 12.190 post disponibili, 55 settimane di overlap tra dati di sentiment e di prezzo, e un'accuratezza predittiva di circa il 45--47%, appena inferiore alla casualità in un contesto binario, a dimostrazione di come il sistema non riesca a cogliere in modo affidabile la direzione del prezzo.

La letteratura recente offre una prospettiva importante su questi risultati: predire la direzione del prezzo di Bitcoin su base settimanale è un problema estremamente difficile, e sistemi ben più sofisticati, inclusi LSTM, LLM con memoria contestuale e framework multi-agente, raramente superano il 52% di accuratezza su questo task specifico (Mudbari, 2025). Raggiungere o superare tale soglia costituisce già un risultato di rilievo. Il vero contributo scientifico non risiede quindi nel "battere il mercato", bensì nel costruire un sistema più ricco, interpretabile e rigoroso che: (i) utilizzi una fonte dati più strutturata e meno rumorosa dei social media; (ii) sfrutti un LLM specifico per il dominio finanziario al posto di VADER; (iii) integri lo storico dei prezzi con indicatori tecnici consolidati; (iv) valuti l'utilità pratica tramite simulazione di una strategia di trading (_backtesting_); (v) esplori l'interpretabilità del modello, cercando di comprendere quali fattori influenzano maggiormente le variazioni di prezzo.

La domanda di ricerca centrale è la seguente: *in che misura l'adozione di modelli di Machine Learning avanzati e di tecniche di Sentiment Analysis basate su LLM specifici di dominio _Finance_, applicati a notizie finanziarie strutturate, migliora la qualità predittiva dell'andamento settimanale del prezzo di Bitcoin, e cosa ci dicono i modelli sui fattori che ne guidano le variazioni?* Rispondere a questa domanda in modo rigoroso e documentato costituisce il contributo principale della tesi.

== Obiettivi del progetto

L'obiettivo centrale è sviluppare una *pipeline modulare* per la predizione dell'andamento settimanale del prezzo di Bitcoin che integri due categorie di segnali:

+ *Sentiment testuale*: estratto da notizie finanziarie crypto (CoinDesk, CoinTelegraph) tramite feed RSS, utilizzando FinBERT come modello principale e VADER come baseline di confronto;
+ *Storico dei prezzi e indicatori tecnici*: medie mobili (SMA, EMA), RSI, MACD e volatilità storica, come feature complementari al sentiment.

La valutazione finale avverrà tramite *backtesting*: simulazione di una strategia Long/Short confrontata con baseline standard (Buy and Hold, MACD, SMA crossover), calcolando rendimento cumulativo, Sharpe Ratio e Maximum Drawdown. Un ulteriore asse di analisi sarà l'*interpretabilità*: attraverso tecniche come la feature importance e, ove possibile, metodi di spiegazione locale (es. SHAP), si cercherà di individuare quali segnali di sentiment e quali indicatori tecnici risultino più informativi per la predizione, contribuendo a una comprensione qualitativa dei meccanismi che sottendono le variazioni di prezzo di Bitcoin.

== Descrizione del lavoro

=== Raccolta dei dati

Il dataset verrà costruito su tre fonti:

- *Notizie finanziarie crypto*: raccolta di titoli e sommari da feed RSS di CoinDesk e CoinTelegraph tramite API gratuite, su un orizzonte temporale di almeno 2 anni. Questa fonte è stata preferita ai social media per la maggiore struttura e la minore presenza di rumore testuale, caratteristiche che la rendono particolarmente adatta a modelli come FinBERT;
- *Storico dei prezzi di Bitcoin*: dati giornalieri/settimanali da CoinGecko o CoinMarketCap, con calcolo degli indicatori tecnici (SMA, EMA, RSI, MACD, volatilità storica);
- *Allineamento temporale*: i punteggi di sentiment settimanali verranno allineati allo storico dei prezzi per costruire il dataset finale di addestramento.

=== Sentiment Analysis con FinBERT

Il modello principale sarà *FinBERT* (Huang et al., 2023), un modello BERT fine-tuned su testi finanziari, particolarmente adatto per notizie e report di mercato. FinBERT sarà scaricato gratuitamente da HuggingFace e utilizzato localmente tramite Google Colab (GPU T4). L'inferenza verrà eseguita a blocchi con salvataggio progressivo, il codice versionato tramite GitHub, così da garantire la robustezza rispetto alle disconnessioni di sessione.

FinBERT verrà confrontato quantitativamente con *VADER* come baseline lessicale, documentando il miglioramento in termini di correlazione tra sentiment e variazione di prezzo. Questo confronto costituisce uno dei contributi principali della tesi rispetto al lavoro triennale di partenza.

=== Modello predittivo

Le feature estratte, sentiment aggregato settimanale, variazione del sentiment rispetto alla settimana precedente, e indicatori tecnici di prezzo, alimenteranno un classificatore binario (UP/DOWN del prezzo nella settimana successiva). Rispetto alla Logistic Regression della tesi triennale, verrà sperimentato *XGBoost*, già ampiamente validato in letteratura per questo task e addestrabile nei tempi disponibili su hardware ordinario. L'analisi dell'importanza delle feature (_feature importance_) permetterà di quantificare il contributo relativo del sentiment rispetto agli indicatori tecnici.

=== Interpretabilità del modello

Un aspetto esplicitamente esplorato sarà la *comprensione dei fattori predittivi*. Tramite feature importance globale (nativa in XGBoost) e, ove i tempi lo consentano, tecniche di spiegazione locale come *SHAP* (_SHapley Additive exPlanations_), si cercherà di rispondere a domande quali: il sentiment delle notizie contribuisce in modo significativo alla predizione, o è dominato dagli indicatori tecnici di prezzo? Esistono periodi o condizioni di mercato in cui il segnale testuale risulta particolarmente informativo? Questi risultati verranno discussi qualitativamente nella tesi, riconoscendo i limiti intrinseci dell'interpretabilità su serie temporali finanziarie.

=== Backtesting della strategia di trading

Il modello predittivo verrà valutato simulando una semplice strategia Long/Short: acquistare Bitcoin quando il modello predice UP, stare liquidi quando predice DOWN. Le metriche di valutazione saranno:

- Rendimento cumulativo;
- Sharpe Ratio;
- Maximum Drawdown.

Tali metriche verranno confrontate con le seguenti baseline: *Buy and Hold*, *MACD crossover* e *SMA crossover*. Il confronto misura il valore aggiunto del segnale di sentiment rispetto alle sole informazioni di prezzo.

#pagebreak()

// ============================================================
// SEZIONE 3 — PIANIFICAZIONE
// ============================================================
= Pianificazione del lavoro

== Distribuzione delle ore

#align(center)[
  #table(
    columns: (4cm, 11cm),
    align: (center + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header(
      [*Durata in ore*], [*Descrizione attività*],
      repeat: false
    ),
    [40],
    [Studio e rassegna della letteratura: analisi dei lavori recenti su sentiment analysis e predizione crypto, studio di FinBERT e delle metodologie di backtesting, revisione critica della tesi triennale di partenza.],
    [60],
    [Raccolta e preparazione dei dati: raccolta notizie da feed RSS/API di CoinDesk e CoinTelegraph (almeno 2 anni di storico), download dello storico dei prezzi di Bitcoin, calcolo degli indicatori tecnici, pulizia e allineamento temporale dei dataset.],
    [80],
    [Sviluppo del modulo di Sentiment Analysis: integrazione di FinBERT via HuggingFace, gestione dell'inferenza a blocchi su Google Colab con salvataggio progressivo, confronto quantitativo con VADER, aggregazione settimanale dei punteggi di sentiment.],
    [90],
    [Sviluppo del modello predittivo e backtesting: ingegnerizzazione delle feature (sentiment e indicatori tecnici), addestramento e valutazione di XGBoost, analisi dell'importanza delle feature, implementazione della strategia Long/Short e confronto con le baseline Buy and Hold, MACD e SMA.],
    [50],
    [Interpretabilità e analisi dei risultati: applicazione di tecniche di feature importance e SHAP, interpretazione dei fattori predittivi, produzione di grafici e tabelle comparative, discussione dei limiti e dei lavori futuri.],
    table.cell(colspan: 2, align: center)[*320 ore totali*],
  )
]

#pagebreak()

// ============================================================
// SEZIONE 4 — OBIETTIVI
// ============================================================
= Obiettivi

Si farà riferimento ai requisiti secondo le seguenti notazioni:

- *OB* per i requisiti obbligatori, vincolanti in quanto obiettivo primario richiesto dal committente;
- *DE* per i requisiti desiderabili, non vincolanti o strettamente necessari, ma dal riconoscibile valore aggiunto;
- *OP* per i requisiti opzionali, rappresentanti valore aggiunto non strettamente competitivo.

Le sigle precedentemente indicate saranno seguite da un numero, identificativo del requisito. Si prevede lo svolgimento dei seguenti obiettivi:

#v(0.5cm)

#align(center)[
  #table(
    columns: (3cm, 12cm),
    align: (center + horizon, left + horizon),
    fill: (_, y) => if y == 0 or y == 6 or y == 10 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header(
      table.cell(colspan: 2, align: center)[*Obbligatorio*],
      repeat: false
    ),
    [*OB 1*],
    [Costruzione di un dataset di notizie finanziarie crypto (CoinDesk, CoinTelegraph) con copertura temporale di almeno 2 anni, allineato allo storico dei prezzi di Bitcoin e agli indicatori tecnici calcolati.],
    [*OB 2*],
    [Sviluppo di un modulo di Sentiment Analysis basato su FinBERT, con confronto quantitativo rispetto a VADER come baseline, documentando il miglioramento in termini di correlazione tra sentiment e variazione di prezzo.],
    [*OB 3*],
    [Addestramento e valutazione di un modello predittivo XGBoost che integri feature di sentiment e indicatori tecnici di prezzo, con confronto rispetto alla Logistic Regression della tesi triennale di partenza, valutando la qualità predittiva complessiva.],
    [*OB 4*],
    [Implementazione di un sistema di backtesting che simuli una strategia Long/Short e la confronti con le baseline Buy and Hold, MACD e SMA, calcolando rendimento cumulativo, Sharpe Ratio e Maximum Drawdown.],
    [*OB 5*],
    [Analisi dell'interpretabilità del modello tramite feature importance globale (XGBoost) per identificare e discutere i fattori, testuali e tecnici, che maggiormente influenzano le variazioni di prezzo di Bitcoin.],
    table.cell(colspan: 2, align: center)[*Desiderabile*],
    [*DE 1*],
    [Estensione dell'analisi di interpretabilità tramite tecniche di spiegazione locale (es. SHAP), per investigare se e quando il segnale di sentiment risulta particolarmente determinante nelle predizioni del modello.],
    [*DE 2*],
    [Estensione del dataset con post di Mastodon relativi a Bitcoin, così da confrontare l'efficacia del segnale di sentiment da fonte social rispetto alle notizie strutturate.],
    [*DE 3*],
    [Integrazione di un secondo modello di sentiment (Twitter-RoBERTa-Base) per un confronto a tre vie: VADER, FinBERT, RoBERTa.],
    table.cell(colspan: 2, align: center)[*Opzionale*],
    [*OP 1*],
    [Estensione del sistema a un secondo asset cryptocurrency (es. Ethereum) per verificare la generalizzabilità dell'approccio.],
    [*OP 2*],
    [Sviluppo di una dashboard interattiva per la visualizzazione del sentiment nel tempo, delle predizioni e delle metriche di backtesting.],
  )
]
