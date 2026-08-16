#show raw.where(block: true): it => pad(
  block(
    width: 100%,
    fill: luma(245),
    text(size: 8pt, it)
  )
)
#set heading(numbering: "1.")
#set text(font: "New Computer Modern")
#set page(numbering: none)
#show link: set text(fill: blue)
#set par(justify: true)
#let frontespizio = [
  #image("unipd.png", width: 10cm)

  #text(22pt)[Università degli Studi di Padova] \

  #text(22pt)[Corso di Laurea in Informatica]
  #v(0.5cm)
  #text(
    22pt,
    weight: "bold",
  )[
    Predizione dei movimenti di prezzo del Bitcoin attraverso il _Sentiment Analysis_ dei _Post Social_ ​]


  #text(22pt)[Tesi di Laurea Triennale]

  #text(20pt)[*Laureando*: \ Amerigo Vegliante \ 2111004]
]

#align(center)[#frontespizio]

#let indice = [
  #outline(title: "Indice")
]

#pagebreak()

#set page(numbering: "i")
#counter(page).update(1)
#indice

#pagebreak()

#set page(numbering: "1")

= Sommario

Il presente documento descrive il lavoro svolto durante il periodo di stage/tesi, finalizzato allo sviluppo di una pipeline software per la predizione della direzione settimanale del prezzo di Bitcoin, mediante l'integrazione di tecniche di Natural Language Processing, Sentiment Analysis e modelli di Machine Learning.

L'obiettivo della tesi è quello di costruire una pipeline strutturata e riproducibile che consenta, insieme all'estrazione automatica dei dati, di effettuare la pulizia, l'analisi e l'elaborazione di dati testuali provenienti dal social network Reddit, integrandoli con indicatori tecnici di mercato, metriche di blockchain di tipo energetico e un indice di sentiment di mercato (Fear & Greed Index), per la previsione della direzione del prezzo di Bitcoin su base settimanale.

Attraverso l'integrazione di un modulo di estrazione dati, è stata realizzata una soluzione che consente di raccogliere automaticamente i dati testuali e di mercato, facilitando la creazione di un dataset aggiornato per l'addestramento del modello predittivo (XGBoost), unitamente a una metodologia di validazione temporale (walk-forward) e a una verifica statistica rigorosa dei risultati tramite intervalli di confidenza bootstrap.

Le conclusioni, a differenza di quanto talvolta riportato in lavori analoghi senza una quantificazione esplicita dell'incertezza statistica, mostrano come, una volta corrette le criticità metodologiche individuate nella fase preliminare (overfitting nella selezione degli iperparametri, rischio di look-ahead bias nelle feature testuali), non emerga una correlazione tra il sentiment dei post e la direzione settimanale del prezzo di Bitcoin statisticamente distinguibile dal caso. Questo risultato è stato verificato anche con un ampliamento sostanziale del set di feature (indicatori macroeconomici come S&P 500, DXY, VIX, e metriche di volatilità/momentum multi-orizzonte), condotto con lo stesso rigore metodologico, senza ottenere miglioramenti misurabili: un indizio che il segnale assente non sia dovuto a un set di feature troppo povero. Questo risultato, pur negativo, è coerente con la letteratura sull'efficienza informativa dei mercati crypto su orizzonti brevi ed è reso metodologicamente solido proprio dalla pipeline di validazione sviluppata.

L'esperienza ha creato le precondizioni per un ulteriore sviluppo del progetto, con l'obiettivo di rafforzare la capacità predittiva del sistema, integrando uno storico di dati più ampio, ulteriori fonti non ancora esplorate, feature nuove e un confronto sistematico con modelli a minore complessità.

Il progetto è stato diviso in tre parti: la prima dedicata all'estrazione dei dati, garantendo l'accesso a informazioni aggiornate e utilizzando le Application Programming Interface (API) di Reddit, Yahoo Finance e dei principali indicatori on-chain/di sentiment di mercato; la seconda parte si è concentrata sull'effettivo sviluppo della pipeline, implementando le funzionalità di Natural Language Processing, Sentiment Analysis e del modello di Machine Learning, con particolare attenzione alla correttezza metodologica della fase di validazione (assenza di leakage temporale, quantificazione dell'incertezza statistica); infine, la terza parte ha riguardato l'analisi critica dei risultati ottenuti e la loro interpretazione attraverso metriche statistiche e il confronto con altri metodi, modelli e configurazioni di feature.

#pagebreak()

= Organizzazione del documento

I successivi capitoli del documento sono organizzati nel seguente modo:
- *Terzo Capitolo - Analisi della Letteratura*: Descrive il confronto e le motivazioni di determinate scelte tecnologiche e metodologiche nello sviluppo di questo modello predittivo.
- *Quarto Capitolo - Metodologia*: Descrive le scelte tecnologiche e metodologiche prese a monte della letteratura studiata.

= Analisi della Letteratura

== Fenomeni Correlati e Contesto Macroeconomico

I seguenti contributi non propongono modelli predittivi diretti sul valore del Bitcoin, ma forniscono evidenze empiriche su dinamiche esterne, energetiche, informative e geopolitiche, che influenzano il mercato e che vengono integrate come contesto fondazionale nella presente tesi.

== N. Sapra et al. (2026) - _Unraveling environmental threads: Bitcoin prices, energy consumption, and crypto market volatility_

=== Disamina del _paper_

Questo _paper_ esamina le relazioni dinamiche e non lineari tra il consumo di energia elettrica della rete Bitcoin, il prezzo dell'_asset_ e la volatilità complessiva del mercato delle criptovalute. Gli autori analizzano un _dataset_ di 1.761 osservazioni giornaliere (da marzo 2020 a gennaio 2025) combinando tecniche statistiche avanzate nei domini del tempo e della frequenza, come la _Biwavelet Coherence_ (*BWC*), la _Partial-Wavelet Transform Coherence_ (*PWC*) e i _test_ di causalità non lineare di Diks & Panchenko. L'indice utilizzato per stimare l'energia è il celebre *CBECI* (_Cambridge Bitcoin Electricity Consumption Index_). I risultati empirici rivelano un'importante asimmetria temporale: nel breve periodo, i movimenti di prezzo guidano il consumo energetico (poiché l'aumento dei prezzi rende il mining più redditizio, attirando nuovi nodi computazionali); nel lungo periodo, tuttavia, si verifica una causalità inversa, in cui il consumo di elettricità e i costi infrastrutturali strutturali fungono da driver e predittori per il valore intrinseco del Bitcoin.

=== Limitazioni e Differenze di Applicazione

Il lavoro si limita a presentare le relazioni di causalità tra il consumo di energia per "minare" Bitcoin e il valore stesso della criptovaluta senza porsi il problema della predizione e ignorando completamente altri componenti informative fondamentali come i vari indicatori tecnici di mercato visti prima.

=== Conclusioni

Questo _paper_ si rivela comunque utile in quanto ci porta una evidenza statistica che intendiamo utilizzare come _feature_ predittiva concreta in modo da aggiungere al modello delle metriche legate al costo di produzione "industriale" del Bitcoin e non unicamente su metriche basate su metriche basate su dinamiche speculative a breve termine.

== C. M. Liapis et al. (2021) - _A Multi-Method Survey on the Use of Sentiment Analysis in Multivariate Financial Time Series Forecasting_

=== Disamina del _paper_

Questo contributo si configura come una rassegna sistematica e "multi-metodo" della letteratura scientifica riguardante l'integrazione della _Sentiment Analysis_ all'interno di modelli predittivi multivariati per serie temporali finanziarie. Gli autori mappano un vasto ecosistema di pubblicazioni, classificando i lavori in base a tre pilastri fondamentali: la fonte dei dati testuali (notizie giornalistiche, Twitter, Reddit, _blog_), le tecniche di *NLP* (_Natural Language Processing_) impiegate per l'estrazione del _sentiment_ (metodi lessicali basati su dizionari rispetto ad approcci di _Machine Learning_ e _Deep Learning_) e, infine, gli algoritmi di previsione finanziaria utilizzati (dai modelli statistici lineari tradizionali come *ARIMA*, fino ai regressori non lineari e alle reti neurali *LSTM*). La survey dimostra empiricamente come l'inclusione del sentiment esogeno migliori quasi sistematicamente le metriche predittive rispetto ai modelli basati esclusivamente su dati storici di prezzo, evidenziando tuttavia una forte frammentazione metodologica nella letteratura.

=== Limitazioni e Differenze di Applicazione

Trattandosi di un _survey_, il lavoro presenta dei limiti intrinsechi legati alla sua natura descrittiva:

- *Mancanza di un framework sperimentale unificato*: Il paper analizza e confronta i risultati di studi terzi, ciascuno condotto su _dataset_, archi temporali e mercati differenti. Di conseguenza, non fornisce un _benchmark_ volto a stabilire quale combinazione esatta di modello di _sentiment_ e classificatore sia la più efficiente a parità di condizioni di mercato.

- *Focalizzazione pre-LLM e mercati tradizionali*: Essendo stato pubblicato alla fine del 2021, la panoramica dei modelli di *NLP* si ferma alle prime architetture *BERT* o a classificatori classici (*SVM*, _Naive Bayes_), non coprendo l'evoluzione recente dei modelli di dominio avanzati come _*FinBERT*_, *LLM* classici o l'uso di _framework_ multi-agente. Inoltre, la stragrande maggioranza della letteratura censita si focalizza sui mercati azionari tradizionali, lasciando parzialmente scoperto il settore ad alta volatilità delle criptovalute.

=== Conclusioni

Il valore di questa _survey_ nel contesto del presente progetto è di tipo fondazionale e giustificativo. La tesi sfrutta le conclusioni macroscopiche di questo paper, in particolare l'evidenza che i modelli ibridi multivariati (con prezzo e _sentiment_) superano quelli univariati, per legittimare la questa tesi.

== Gomes Jr. et al. (2024) - _Cryptoeconomic User Behavior in the Acute Stages of Geopolitical Conflict_

=== Disamina del _paper_

Questo _paper_ esamina l'impatto degli _shock_ geopolitici di vasta scala sul comportamento degli utenti all'interno delle _blockchain_ di Bitcoin ed Ethereum, focalizzandosi sulle fasi immediatamente precedenti e successive allo scoppio del conflitto russo-ucraino. Gli autori utilizzano un approccio basato su grafi dinamici variabili nel tempo (_time-varying graphs_) per modellare la rete delle transazioni _on-chain_ in un arco temporale critico di quattro settimane (due settimane prima e due settimane dopo l'inizio delle ostilità). L'obiettivo è analizzare la reattività della rete in una fase definita "acuta". I risultati empirici rivelano anomalie strutturali significative nel comportamento macroeconomico degli utenti: nella fase di pre-conflitto si registra un atteggiamento fortemente cauto e attendista (caratterizzato da una contrazione delle transazioni e da dinamiche di accumulazione), mentre nella fase post-conflitto si osserva un ritorno alla normalità nei volumi, ma con uno spostamento netto (shift) nelle traiettorie dei flussi di capitale e nella topologia della rete di trasferimento del valore.

=== Limitazioni e Differenze di Applicazione

Nonostante l'eccellente e rigorosa ricostruzione analitica delle dinamiche operate sui registri distribuiti, il lavoro evidenzia limiti sul piano della tempestività predittiva e algoritmica:

- *Analisi ex-post e focalizzazione esclusivamente _on-chain_*: Lo studio ricostruisce i comportamenti in modo puramente retrospettivo. Inoltre, basandosi solo sulle transazioni registrate sulla _blockchain_, non correla questi mutamenti strutturali con i flussi informativi esterni in tempo reale, come il _sentiment_ espresso dai media finanziari o dai _social network_ nelle ore esatte dello scoppio della crisi.

- *Assenza di finalità predittive e di moduli di trading*: Il _framework_ è di stampo prettamente analitico e sociologico-economico. Non traduce la categorizzazione del comportamento degli utenti in presenza di conflitti in feature quantitative spendibili da un algoritmo di _Machine Learning_ per anticipare la direzione del _trend_ o per automatizzare decisioni di portafoglio.

Queste limitazioni sono prettamente dovute al fatto che il _paper_ non si occupa di informatica o _machine learning_ nello specifico ma di analisi sociologica-economica che si rivela comunque utile ai fini dello sviluppo del progetto di questa tesi.

=== Conclusioni

Il presente lavoro di tesi integra ed evolve le scoperte derivate da questo _paper_, convertendo un'evidenza analitica ex-post in un segnale predittivo operante in tempo reale. Il presupposto scientifico che il comportamento degli investitori di Bitcoin cambi in modo drastico durante i conflitti armati viene qui ingegnerizzato all'interno del vettore multivariato di _*XGBoost*_. Per superare il limite dell'analisi puramente _on-chain_, questo modello sfrutta l'*LLM* _*Gemini*_ per intercettare istantaneamente il crollo del _sentiment_ e l'esplosione del panico geopolitico dai _feed_ di notizie globali e dai canali _social_ non appena l'evento si manifesta. In questo modo, l'algoritmo apprende la relazione matematica tra l'insorgere di uno _shock_ pubblico internazionale (catturato dal *NLP*) e le repentine fluttuazioni di prezzo di Bitcoin, testandone l'efficacia operativa e la protezione del capitale attraverso un modulo di _backtesting_ finanziario assente nel lavoro analizzato.

== Modelli Predittivi sul Valore delle Criptovalute

I seguenti paper propongono architetture di _machine learning_ o _deep learning_ per la predizione del valore di criptovalute, con o senza componente di _sentiment analysis_. Ciascun contributo è seguito da una tabella riassuntiva degli aspetti metodologici chiave; una tabella comparativa generale è riportata al termine del gruppo.

== Y. Xiao et al. (2024) - _TradingAgents: Multi-Agents LLM Financial Trading Framework_

=== Disamina del _paper_

Questo _paper_ introduce un _framework_ di _trading_ algoritmico innovativo che utilizza una società di Agenti alimentati da _Large Language Models_ nel tentativo di simulare e replicare le dinamiche collaborative e gerarchiche di una vera e propria società d'investimento. Il sistema non si affida a un singolo modello, ma frammenta il problema assegnando ruoli specializzati a diversi agenti: analisti fondamentali, analisti tecnici, analisti del sentiment, ricercatori macroeconomici (divisi in fazioni _Bull_ e _Bear_ per stimolare il dibattito), un _team_ di _risk management_ e, infine, un modulo _Trader_ che sintetizza i report e prende la decisione finale di investimento. Gli esperimenti condotti dagli autori mostrano prestazioni eccellenti rispetto alle _baseline_ tradizionali, evidenziando netti miglioramenti nelle metriche finanziarie chiave come il rendimento cumulativo, lo _Sharpe Ratio_ e il _Maximum Drawdown_.

=== Limitazioni e Differenze di Applicazione

Il _framework_ presenta tre limiti strutturali significativi se analizzato in un'ottica di sostenibilità e applicabilità reale:

- *Complessità Computazionale e Costi*: L'architettura multi-agente richiede continui scambi di _prompt_, "dibattiti" testuali e passaggi di memoria tra decine di istanze di LLM. Questo approccio genera un consumo di _token_ e una richiesta di potenza computazionale massiccia, rendendo il sistema estremamente costoso, lento nell'esecuzione e dipendente da API commerciali esterne non replicabili localmente su infrastrutture standard.

- *Focus sul Mercato Azionario Tradizionale*: Il modello è nativamente progettato e testato sulle azioni tradizionali (il _paper_ menziona ad esempio l'analisi fondamentale su titoli azionari come *AAPL*), dove i report finanziari, i bilanci trimestrali e le metriche macroeconomiche classiche hanno un peso preponderante. Questo impianto si adatta male alla natura stocastica, altamente speculativa e priva di bilanci societari tipica del mercato delle criptovalute.

- *Opacità della Sintesi Decisionale (Effetto _Black-Box_)*: Sebbene la separazione dei ruoli simuli la trasparenza, la decisione finale del _Trader agent_ avviene attraverso la generazione di testo libero da parte dell'*LLM*. Manca un'ispezione matematica quantitativa (come i valori *SHAP*) in grado di isolare l'esatto peso statistico di un indicatore tecnico rispetto a una notizia di _sentiment_.

=== Conclusioni

Il focus della presente tesi si inserisce per contrasto rispetto all'approccio di questo _paper_, proponendo un'architettura radicalmente più snella, quantitativa e mirata al contesto d'interesse. Invece di ricorrere a costosi dibattiti tra *LLM* generici, si opta per un singolo modello di estrazione del _sentiment_ specializzato combinato con un classificatore efficiente (XGBoost), addestrabile localmente in tempi ridotti. Inoltre, l'opacità descrittiva della decisione testuale viene qui superata mediante l'integrazione della Feature Importance e dei valori *SHAP*, fornendo un'interpretabilità matematica rigorosa del peso relativo tra metriche tecniche e _sentiment_ testuale sul mercato di _Bitcoin_.

#figure(
  caption: [Riepilogo metodologico, Xiao et al. (2024)],
  table(
    columns: (4.5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Azioni tradizionali (es. AAPL); non crypto],
    [*Modello NLP*], [LLM generici multi-agente (GPT-class), nessun modello a dizionario],
    [*Tipo NLP*], [LLM (generativo, basato su Transformer)],
    [*Modello predittivo*], [Agente _Trader_ LLM (sintesi testuale libera)],
    [*Feature utilizzate*], [Report fondamentali, dati tecnici, sentiment, macro, tutto via prompt],
    [*Granularità temporale*], [Non specificata (operatività intraday/giornaliera)],
    [*Backtesting*], [Sì (rendimento cumulativo, Sharpe Ratio, Max Drawdown)],
    [*Interpretabilità*], [Nessuna (black-box testuale)],
    [*Costo computazionale*], [*Molto elevato*, decine di istanze LLM in parallelo, dipendenza da API commerciali],
    [*Accuratezza dichiarata*], [Superiore alle baseline tradizionali (metriche finanziarie)],
  ),
)

== A. Hafid et al. (2024) - _Predicting Bitcoin Market Trends with Enhanced Technical Indicator Integration and Classification Models_

=== Disamina del _paper_

Questo _paper_ descrive un modello di _Machine Learning_ di classificazione per predire il corso del mercato delle criptovalute allenato su dati storici e indicatori tecnici importanti quali _Moving Average Convergence Divergence_, _Relative Strength Index_ e _Bollinger Bands_. Il _paper_, inoltre, fa diverse simulazioni usando Matrici di Confusione e la curva _Receiver Operating Characteristic_ per determinare la _performance_ del modello risultando in una accuratezza dei segnali _Buy_/_Sell_ di oltre il 92%. Il _paper_, inoltre, illustra il diagramma del _research process_ composto da 8 fasi: \

+ *_Research Problem_*: Fase di ricerca del problema e delle fonti di dati da prendere per risolverlo.
+ *_Data Collection_*: I dati riguardano lo storico dei prezzi del Bitcoin presi tramite *API* della piattaforma _Binance_ che coprono il periodo 01/02/2021 - 01/02/2022 con un intervallo di tempo di 15 minuti per maggiore accuratezza in un mercato altamente volatile come quello del Bitcoin.
+ *_Feature Engineering_*: Il modello utilizza dati storici di mercato e indicatori tecnici quali _Bollinger Bands_, _Average True Range_, _Commodity Channel Index_, _Williams %R_, _Chaikin Money Flow_, _On-Balance Volume_, _Moving Average Convergence Divergence_, _Accumulation_/_Distribution Line_.
+ *_Data Preprocessing_*: I dati vengono scalati usando lo _StandardScaler_ della libreria *scikitlearn*. Inoltre i dati sono divisi in due parti in modo _percentage-based_ dove l'80% lo si dedica al _training_ e il 20% al _testing_.
+ *_Feature Selection_*: Il modello utilizza il $\u{03A7}^2$ come funzione di _scoring_ per selezionare le $k=8$ migliori _feature_ (ovvero gli indicatori tecnici elencati prima) e ottimizza il _feature vector_.
+ *_Training XGBoost_*: Il modello, dopo aver ottimizzato la _cost function_ del *_XGBoost_* nella fase di _feature selection_ di prima, la minimizza usando l'algoritmo di _gradient boosting_.
+ *_Evaluation_*: Le _performance_ sono state analizzate tramite varie metriche quali la precisione, accuratezza e la curva *ROC*.
+ *_Result Analysis_*: I risultati riportati dal modello denotano una accuratezza del 92.4% utilizzando il regressore _*XGBoost*_, rispetto ad un approccio con _*Logistic Regression*_ che riporta una precisione del 91.01% e generalmente dei risultati migliori in tutti i parametri di _performance_ analizzati dal _paper_.


=== Limitazioni e Differenze di Applicazione

Nonostante l'elevata accuratezza statistica dichiarata, l'impianto metodologico presenta alcuni limiti critici se traslato in un contesto di operatività reale sul lungo periodo:

- *Assenza di Fattori Esterni*: Il modello si basa esclusivamente su informazioni di mercato (prezzo e volume tradotti in indicatori tecnici). Di conseguenza, ignora completamente l'impatto di _shock_ esterni, notizie macroeconomiche o variazioni repentine del _sentiment_ sui canali informativi, elementi che nel mercato delle criptovalute agiscono spesso da catalizzatori primari per i cambi di _trend_.

- *Granularità Estrema e Rischio di Overfitting*: L'orizzonte temporale a 15 minuti, limitato a un solo anno di storico (2021-2022), tende a catturare il rumore microscopico del mercato. Questa impostazione spiega l'accuratezza insolitamente elevata (oltre il 92%), la quale tuttavia rischia di non essere generalizzabile su archi temporali più estesi o di soffrire di fenomeni di _data leakage_ impliciti nella _cross-validation_ standard di serie temporali ad alta frequenza.

=== Conclusioni

Il presente lavoro di tesi trae spunto dalle ottime conferme ricevute da questo _paper_ circa l'efficacia del classificatore _*XGBoost*_ rispetto alla _*Logistic Regression*_, ma ne estende e corregge l'approccio sotto due aspetti fondamentali. In primo luogo, l'orizzonte temporale viene ricalibrato su base settimanale coprendo un arco di almeno due anni: questa scelta mitiga il rumore dei micro-movimenti a 15 minuti, offrendo un segnale più robusto e spendibile per un'analisi di medio-lungo periodo. In secondo luogo, il _feature vector_ viene arricchito in modalità ibrida: ai tradizionali indicatori tecnici (confermati come ottime metriche di baseline) viene integrato il segnale testuale estratto tramite Sentiment Analysis con *LLM*.

#figure(
  caption: [Riepilogo metodologico, Hafid et al. (2024)],
  table(
    columns: (5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Bitcoin (BTC)],
    [*Modello NLP*], [Nessuno, solo indicatori tecnici di mercato],
    [*Tipo NLP*], [Non applicabile],
    [*Modello predittivo*], [XGBoost (classificatore binario Buy/Sell)],
    [*Feature utilizzate*], [BB, ATR, CCI, Williams %R, CMF, OBV, MACD, A/D Line (k=8 via $chi^2$)],
    [*Granularità temporale*], [15 minuti (1 anno di storico: 2021–2022)],
    [*Backtesting*], [No (solo metriche statistiche: Accuracy, ROC)],
    [*Interpretabilità*], [No (feature importance non discussa)],
    [*Costo computazionale*], [*Basso*, XGBoost locale su dati tabulari],
    [*Accuratezza dichiarata*], [92.4% (XGBoost) vs 91.01% (Logistic Regression)],
  ),
)

== J. Manogna et al. (2023) - _Bitcoin Price Prediction Based on Sentiment Analysis_

=== Disamina del _paper_

Questo studio propone un _framework_ predittivo a breve termine per i movimenti di prezzo di Bitcoin focalizzandosi sull'estrazione del _sentiment_ in tempo reale dalla piattaforma _social_ Twitter (tramite Twitter API) in combinazione con i dati storici di prezzo di CoinMarketCap. Gli autori estraggono le metriche testuali grezze e utilizzano tecniche di _Natural Language Processing_ (*NLP*) per calcolare i punteggi di _sentiment_ (positivo, negativo, neutro). Successivamente, integrano questi dati con lo storico dei prezzi per addestrare modelli di _Deep Learning_ sequenziali, nello specifico reti _Long Short-Term Memory_ (*LSTM*) e _Bidirectional Gated Recurrent Units_ (*BiGRU*). I risultati empirici del _paper_ evidenziano come i modelli basati su reti neurali ricorrenti beneficino sensibilmente dell'aggiunta del _sentiment_ dei _social media_, ottenendo un'elevata precisione nel catturare le fluttuazioni di prezzo giornaliere rispetto ai modelli statistici tradizionali.

=== Limitazioni e Differenze di Applicazione

L'approccio addottato in questo _paper_, pur confermando la reattività del prezzo di Bitcoin ai flussi informativi dei _social_, presenta limiti rilevanti sotto il profilo della stabilità e dell'interpretabilità:

- *Elevato rumore e volatilità dei dati _social_*: L'affidamento esclusivo su Twitter introduce una massiccia quantità di rumore di fondo (spam, bot, post speculativi o manipolatori). Questa reattività estrema rende il modello adatto principalmente a predizioni su brevissimo termine (giornaliero o intra-giornaliero), ma altamente instabile se applicato a strategie di investimento con un orizzonte temporale più esteso.

- *Natura "Black Box" del Deep Learning*: L'utilizzo di architetture *LSTM* e *BiGRU* preclude una reale comprensione delle dinamiche interne del modello. Gli autori non integrano strumenti quantitativi di spiegazione algoritmica, rendendo impossibile stabilire in che misura esatta il sentiment pesi sulla decisione finale rispetto ai trend storici del prezzo.

=== Conclusioni

Il presente lavoro si aggancia alle tesi del presente _paper_ circa l'utilità dei dati _social_, ma ne corregge i limiti strutturali attraverso un disegno sperimentale comparativo e trasparente. In primo luogo, l'orizzonte temporale viene spostato su base settimanale, una granularità più adatta a stabilizzare il segnale macroeconomico rispetto alla volatilità frenetica dei _tweet_ giornalieri. In secondo luogo, per superare il problema del rumore isolato dei _social_, questo progetto introduce un approccio ibrido a due canali: il _sentiment_ estratto dai _social media_ viene messo a confronto diretto e combinato con quello di notizie finanziarie strutturate (CoinDesk, CoinTelegraph). Infine, l'opacità delle reti *LSTM* viene superata a favore del classificatore _*XGBoost*_.

#figure(
  caption: [Riepilogo metodologico, Manogna et al. (2023)],
  table(
    columns: (5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Bitcoin (BTC)],
    [*Modello NLP*], [Tecniche NLP non specificate (pipeline classica di classificazione del testo)],
    [*Tipo NLP*], [NLP classico (non LLM, non dizionario, probabile TF-IDF o simile)],
    [*Modello predittivo*], [LSTM e BiGRU (reti neurali ricorrenti)],
    [*Feature utilizzate*], [Punteggi di sentiment da Twitter + storico prezzi (CoinMarketCap)],
    [*Granularità temporale*], [Giornaliera],
    [*Backtesting*], [No (solo metriche di classificazione)],
    [*Interpretabilità*], [Nessuna (black-box neurale)],
    [*Costo computazionale*], [*Medio-alto*, training LSTM/BiGRU richiede GPU],
    [*Accuratezza dichiarata*], [Elevata precisione nelle fluttuazioni giornaliere (valore esatto non riportato)],
  ),
)

== H. Anand et al. (2024) - _An Empirical Study of Financial BERT Models for Sentiment Analysis and Cryptocurrency Price Correlation_

Questo _paper_ presenta un'analisi empirica e comparativa sull'efficacia di diversi strumenti di _Sentiment Analysis_ – sia lessicali che basati su architetture _Transformer_ di _Deep Learning_ nel determinare la correlazione tra il _sentiment_ del pubblico e le fluttuazioni di prezzo delle criptovalute, con un focus verticale su Bitcoin. Gli autori mettono a confronto diretto quattro modelli speculativi: *VADER* e _*SenticNet*_ (approcci basati su dizionari), e _*FinBERT*_ e _*CryptoBERT*_ (modelli pre-addestrati basati su *BERT* e specializzati rispettivamente nel dominio finanziario e crittografico). Inoltre, il _paper_ illustra il _fine-tuning_ di un modello _*DistilBERT*_ per catturare le relazioni non lineari tra il testo e i trend di mercato, riportando un coefficiente di correlazione estremamente elevato, pari a 0.88, tra il _sentiment_ aggregato e i movimenti di prezzo.

=== Limitazioni e Differenze di Applicazione

Sebbene il contributo fornisca una validazione cruciale sull'uso di modelli _domain-specific_ (come _*FinBERT*_ e _*CryptoBERT*_) rispetto a quelli generalisti, esso evidenzia due limiti sul piano dell'architettura predittiva complessiva:

- *Mancanza di un modello di classificazione e _machine learning_ a valle*: Il _paper_ si ferma a un'analisi di tipo puramente statistico e correlazionale. Gli autori dimostrano che esiste un forte legame matematico tra l'andamento del _sentiment_ e quello del prezzo, ma non utilizzano questo segnale come _feature_ di input per addestrare un algoritmo predittivo o di classificazione.

- *Assenza di indicatori tecnici e modulo di Backtesting*: L'analisi si concentra esclusivamente sulla componente testuale esterna. Ignorando gli indicatori di mercato interni (*RSI*, *MACD*) e non traducendo le decisioni in una simulazione di _trading_ reale (_backtesting_), il _framework_ non è in grado di misurare la sostenibilità economica o il rischio finanziario (_Sharpe Ratio_, _Drawdown_) delle metriche estratte.

=== Conclusioni

Il presente lavoro di tesi si configura come la naturale estensione ingegneristica e algoritmica dei risultati di questo _paper_. Presa per assodata l'eccellente correlazione dei modelli *BERT* finanziari dimostrata nel _paper_, questa tesi raccoglie la sfida e sposta il _framework_ sul piano predittivo ed economico. Il _sentiment_ ottimizzato (estratto e confrontato tramite _*Gemini*_) non viene studiato in modo isolato, ma viene integrato in un vettore multivariato insieme agli indicatori tecnici e ai dati energetici del _mining_. Questo vettore alimenta direttamente un classificatore _*XGBoost*_ volto a produrre decisioni di _trading_ che, a differenza del _paper_ analizzato, vengono simulate e validate tramite un modulo di _backtesting_ finanziario per calcolare l'effettivo rendimento economico della strategia.

#figure(
  caption: [Riepilogo metodologico, Anand et al. (2024)],
  table(
    columns: (5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Bitcoin (BTC) e altre criptovalute],
    [*Modello NLP*], [VADER, SenticNet (dizionario); FinBERT, CryptoBERT, DistilBERT (Transformer)],
    [*Tipo NLP*], [Ibrido: modelli a dizionario + LLM domain-specific (BERT-based)],
    [*Modello predittivo*], [Nessuno, solo analisi correlazionale],
    [*Feature utilizzate*], [Punteggi di sentiment aggregati da fonti testuali crypto],
    [*Granularità temporale*], [Non specificata],
    [*Backtesting*], [No],
    [*Interpretabilità*], [No (correlazione statistica, non spiegazione causale)],
    [*Costo computazionale*], [*Medio*, inferenza BERT/DistilBERT, fine-tuning locale],
    [*Accuratezza dichiarata*], [Correlazione sentiment-prezzo: r = 0.88 (DistilBERT fine-tuned)],
  ),
)

== C. Kaur et al. (2025) - _Twitter Sentiment Analysis of Bitcoin Price Fluctuation with Machine Learning Techniques_

=== Disamina del _paper_

Questo studio analizza la capacità predittiva dei post di Twitter nel determinare le fluttuazioni quotidiane dei rendimenti di Bitcoin. Gli autori raccolgono un _dataset_ di _tweet_ a tema criptovalute e utilizzano la libreria lessicale _*TextBlob*_ per l'estrazione e la classificazione del _sentiment_ (positivo, negativo, neutro). Una volta calcolati i punteggi di _sentiment_, questi vengono integrati con le variazioni storiche del prezzo di Bitcoin per addestrare ed effettuare un confronto tra diversi classificatori di _Machine Learning_ tradizionali: _Support Vector Machines_ (*SVM*), _Random Forest_, _Naive Bayes_ e _K-Nearest Neighbors_ (*KNN*). I risultati empirici evidenziano come i modelli come _Random Forest_ riescano a catturare parzialmente la direzione del _trend_ di mercato, confermando l'esistenza di un legame tra l'opinione pubblica sui _social media_ e i movimenti di prezzo dell'_asset_.

=== Limitazioni e Differenze di Applicazione

L'approccio metodologico di questo _paper_ presenta alcune limitazioni strutturali legate all'anzianità degli strumenti di *NLP* e all'orizzonte di validazione:

- *Inadeguatezza del *modello NLP* lessicale (TextBlob)*: L'utilizzo di _*TextBlob*_ rappresenta un limite critico nel contesto finanziario. Essendo un dizionario lessicale generico, non è in grado di cogliere l'ironia, il contesto o il gergo specifico del mercato crittografico generando un segnale di _sentiment_ piatto o distorto.

- *Mancanza di indicatori tecnici complessi e simulazione economica*: I classificatori vengono addestrati unicamente sull'interazione tra _sentiment_ grezzo e prezzo di chiusura, tralasciando indicatori macro-strutturali o di analisi tecnica (*RSI*, *MACD*, _Bollinger Bands_). Inoltre, il lavoro si ferma alle metriche di classificazione pura (_Accuracy_, _Precision_), omettendo un ambiente di backtesting che verifichi l'effettiva profittabilità finanziaria dei segnali generati.

=== Conclusioni

La presente tesi supera l'approccio di questo _paper_ introducendo un netto salto di qualità sia nell'estrazione del _sentiment_ che nella robustezza del modello predittivo. Al posto di algoritmi lessicali statici come TextBlob, questo modello adotta un *LLM* moderno della gamma *Google Gemini*. Sul fronte predittivo, anziché affidarsi a classificatori standard isolati, si sfrutta la potenza di _*XGBoost*_ alimentato da un vettore di _feature_ ibrido e multivariato, che unisce al _sentiment_ avanzato sia gli indicatori tecnici che i dati energetici di rete. Infine, l'utilità del modello non viene stimata solo tramite metriche statistiche, ma viene validata sul campo simulando una reale strategia _Long/Short_ tramite un modulo di _Backtesting_ dedicato.

#figure(
  caption: [Riepilogo metodologico, Kaur et al. (2025)],
  table(
    columns: (5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Bitcoin (BTC)],
    [*Modello NLP*], [TextBlob (dizionario lessicale generico)],
    [*Tipo NLP*], [Modello a dizionario (lessicale)],
    [*Modello predittivo*], [SVM, Random Forest, Naive Bayes, KNN],
    [*Feature utilizzate*], [Punteggi TextBlob + variazioni storiche prezzo BTC (Twitter)],
    [*Granularità temporale*], [Giornaliera],
    [*Backtesting*], [No (solo Accuracy e Precision)],
    [*Interpretabilità*], [No],
    [*Costo computazionale*], [*Molto basso*, classificatori classici su dati tabulari leggeri],
    [*Accuratezza dichiarata*], [Random Forest migliore tra i classificatori (valore esatto non riportato)],
  ),
)

== K. Vijayakuamar et al. (2023) - _Impact of Elon Musk’s tweets on the price of Dogecoin using Sentiment Analysis_

=== Disamina del Paper

Questo contributo investiga l'impatto diretto dei flussi comunicativi generati dai cosiddetti _Key Opinion Leaders_ (*KOL*) sulla volatilità e sulle variazioni di prezzo delle criptovalute. Nello specifico, gli autori esaminano la correlazione tra i _tweet_ di Elon Musk e le oscillazioni di prezzo di Dogecoin (*DOGE*). Il _framework_ si avvale di due motori di *NLP* classici per l'estrazione della polarità del testo, mettendone a confronto i risultati: TextBlob e *VADER* (_Valence Aware Dictionary and Sentiment Reasoner_). I punteggi di _sentiment_ ottenuti vengono poi sovrapposti temporalmente alle serie storiche di Dogecoin per misurare l'effetto di _shock_ esterni concentrati. I risultati empirici confermano che i _tweet_ positivi o ironici del multimiliardario agiscono da catalizzatori immediati, innescando fiammate rialziste nel volume di _trading_ e nel valore dell'_asset_, evidenziando l'estrema sensibilità del comparto _crypto_ a singoli attori di rilievo.

=== Limitazioni e Differenze di Applicazione

Nonostante l'efficacia nel dimostrare il fenomeno della manipolazione o dell'influenza mediatica concentrata, l'approccio di questo paper mostra limiti evidenti sul piano della generalizzabilità algoritmica:

- *Focalizzazione su un singolo _asset_ speculativo (_Meme Coin_)*: Dogecoin è una _meme coin_ la cui capitalizzazione risente in modo anomalo della componente speculativa e sociale, rendendo i risultati difficilmente estendibili ad _asset_ strutturati e a grandissima capitalizzazione come Bitcoin, i quali rispondono a dinamiche macroeconomiche e di mercato molto più complesse.

- *Modelli NLP non contestuali e assenza di Machine Learning*: L'adozione di *VADER* e TextBlob, pur adatta a catturare stringhe testuali brevi, soffre dell'assenza di una comprensione semantica profonda dei _Transformer_. Inoltre, lo studio si limita a mappare una correlazione ex-post, senza addestrare un classificatore predittivo (come _*XGBoost*_) e senza testare l'efficacia dei segnali in una strategia di _trading_ formalizzata.

=== Conclusioni

La presente tesi raccoglie l'importante intuizione di questo _paper_ riguardante il peso dei flussi informativi, ma ne evolve l'impianto verso un modello scientificamente più solido e generalizzabile. Invece di monitorare l'effetto isolato di un singolo _account_ su una _meme coin_, questo progetto si focalizza sul Bitcoin, integrando il sentiment_ aggregato_ sia di canali _social_ distribuiti che di testate giornalistiche finanziarie verificate. L'accuratezza lessicale viene drasticamente migliorata sostituendo i dizionari statici con *LLM*, garantendo la corretta interpretazione del contesto finanziario. Infine, la correlazione statistica viene qui tradotta in ingegneria delle _feature_, combinando il _sentiment_ con indicatori tecnici e metriche energetiche di _mining_ all'interno di un modello predittivo unificato e validato tramite simulazioni di _backtesting_.

#figure(
  caption: [Riepilogo metodologico, Vijayakumar et al. (2023)],
  table(
    columns: (5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Dogecoin (DOGE), meme coin],
    [*Modello NLP*], [TextBlob e VADER (dizionari lessicali)],
    [*Tipo NLP*], [Modello a dizionario (lessicale)],
    [*Modello predittivo*], [Nessuno, solo analisi di correlazione ex-post],
    [*Feature utilizzate*], [Tweet di Elon Musk + serie storiche prezzo DOGE],
    [*Granularità temporale*], [Non specificata (probabilmente giornaliera/intraday)],
    [*Backtesting*], [No],
    [*Interpretabilità*], [No],
    [*Costo computazionale*], [*Molto basso*, dizionari statici senza training],
    [*Accuratezza dichiarata*], [Non applicabile (studio correlazionale, non predittivo)],
  ),
)

== O. Sattarov et al. (2020) - _Forecasting Bitcoin Price Fluctuation by Twitter Sentiment Analysis_

=== Disamina del Paper

Questo studio analizza la capacità predittiva dei flussi di opinione di Twitter in merito alle fluttuazioni quotidiane del prezzo di Bitcoin, proponendo un approccio innovativo per l'anno di pubblicazione del _paper_. Gli autori estraggono un _dataset_ di _tweet_ legati all'ecosistema delle criptovalute e utilizzano il modulo *VADER* (_Valence Aware Dictionary and Sentiment Reasoner_), integrato nella libreria *NLTK*, per quantificare la polarità dei testi (positiva, negativa, neutra). Successivamente, combinando i punteggi di _sentiment_ aggregati giornalmente con la serie storica dei prezzi di chiusura dell'_asset_, gli autori addestrano e confrontano modelli di _Machine Learning_ tradizionali, tra cui _Support Vector Machines_ (*SVM*) e modelli di regressione lineare. I risultati empirici dimostrano che il _sentiment_ dei _social media_ possiede un effettivo potere predittivo, consentendo al _framework_ di raggiungere un'accuratezza del 62.48% nella classificazione della direzione del prezzo su base giornaliera.

=== Limitazioni e Differenze di Applicazione

L'impianto metodologico del lavoro risente inevitabilmente dell'anzianità della sua pubblicazione, mostrando limiti evidenti se confrontato con gli standard attuali:

- *Dipendenza da modelli NLP lessicali statici*: L'affidamento esclusivo su *VADER* rappresenta un forte limite intrinseco. Essendo un analizzatore basato su regole e dizionari linguistici statici, non è in grado di decodificare la semantica contestuale profonda, i neologismi, il sarcasmo o il gergo finanziario specialistico tipico della community crypto. Questo causa un'elevata percentuale di classificazione errata o neutrale di _tweet_ fortemente orientati.

- *Vettore di _feature_ minimale e assenza di _Backtesting_*: Il modello predittivo si basa esclusivamente sulla combinazione bivariata _Sentiment_-Prezzo storico. Viene del tutto trascurata l'integrazione di indicatori di analisi tecnica (come *RSI* o *MACD*) e di metriche macro-strutturali. Inoltre, il lavoro convalida i risultati solo tramite metriche di classificazione statistica pura (_Accuracy_), omettendo una simulazione di _trading_ reale che ne attesti la profittabilità economica al netto dei costi di transazione.

=== Conclusioni

Il presente lavoro adotta le conclusioni di questo _paper_ come una fondamentale _baseline_ storica, ma ne rivoluziona l'architettura per superarne i limiti strutturali. Sul piano del _Natural Language Processing_, l'approccio lessicale rudimentale di *VADER* viene qui sostituito (e messo a confronto) con l'*LLM* di _*Gemini*_. Sul piano predittivo, il vettore delle _feature_ viene espanso in modalità multivariata e ibrida, affiancando al _sentiment_ avanzato sia gli indicatori tecnici che le metriche energetiche di mining. Infine, la capacità predittiva non viene testata su modelli classici isolati come *SVM*, ma viene affidata all'algoritmo _*XGBoost*_ e validata economicamente tramite un modulo di _backtesting_ finanziario su base settimanale, garantendo una stabilità operativa assente nel _paper_ analizzato.

#figure(
  caption: [Riepilogo metodologico, Sattarov et al. (2020)],
  table(
    columns: (5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Bitcoin (BTC)],
    [*Modello NLP*], [VADER (dizionario lessicale, libreria NLTK)],
    [*Tipo NLP*], [Modello a dizionario (lessicale)],
    [*Modello predittivo*], [SVM e regressione lineare],
    [*Feature utilizzate*], [Punteggi VADER aggregati giornalmente + prezzo di chiusura BTC],
    [*Granularità temporale*], [Giornaliera],
    [*Backtesting*], [No (solo Accuracy statistica)],
    [*Interpretabilità*], [No],
    [*Costo computazionale*], [*Molto basso*, SVM su feature bivariata],
    [*Accuratezza dichiarata*], [62.48% nella classificazione della direzione del prezzo],
  ),
)

== Tabella Comparativa dei Paper con Modelli Predittivi

La seguente tabella riassume e mette a confronto i principali paper con approccio predittivo sul valore di criptovalute analizzati in questa sezione, includendo la presente tesi come termine di paragone metodologico.

#set table(inset: 6pt)
#figure(
  caption: [Confronto metodologico tra i paper predittivi su criptovalute],
  table(
    columns: (2cm, 1.8cm, 2.5cm, 2cm, 3.1cm, 2.8cm, 2cm),
    align: center + horizon,
    fill: (_, y) => if y == 0 { luma(180) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Paper*], [*Asset*], [*Modello NLP*], [*Tipo NLP*], [*Classificatore*], [*Backtesting*], [*Interp.*]),
    [Xiao\ (2024)], [Azioni], [LLM multi-agente\ (GPT-class)], [LLM], [Agente LLM\ (testo libero)], [Sì], [No],
    [Hafid\ (2024)], [BTC], [Nessuno], [N/A], [XGBoost], [No], [No],
    [Manogna\ (2023)], [BTC], [NLP classico\ (non specif.)], [Probabilm.\ TF-IDF], [LSTM,\ BiGRU], [No], [No],
    [Anand\ (2024)],
    [BTC/Crypto],
    [VADER, SenticNet,\ FinBERT, CryptoBERT],
    [Dizionario\ + LLM],
    [Nessuno\ (correlaz.)],
    [No],
    [No],
    [Kaur\ (2025)], [BTC], [TextBlob], [Dizionario], [SVM, RF,\ NB, KNN], [No], [No],
    [Vijayak.\ (2023)], [DOGE], [TextBlob,\ VADER], [Dizionario], [Nessuno\ (correlaz.)], [No], [No],
    [Sattarov\ (2020)], [BTC], [VADER], [Dizionario], [SVM,\ Regressione], [No], [No],
    table.cell(fill: luma(220))[*Questa\ tesi*],
    table.cell(fill: luma(220))[*BTC*],
    table.cell(fill: luma(220))[*Gemini\ 3.1\ flash-lite*],
    table.cell(fill: luma(220))[*LLM*],
    table.cell(fill: luma(220))[*XGBoost*],
    table.cell(fill: luma(220))[*Sì*],
    table.cell(fill: luma(220))[*Sì*],
  ),
)
#set table(inset: 9pt)

#pagebreak()

= Metodologia

== Formulazione del problema

Il problema affrontato è formulato come un compito di classificazione binaria supervisionata: dato un insieme di osservazioni settimanali relative al mercato di Bitcoin (BTC/USD) e a fonti informative correlate, si vuole prevedere se il prezzo di chiusura della settimana successiva sarà superiore (classe positiva, UP) o inferiore/uguale (classe negativa, DOWN) a quello della settimana corrente.

La scelta di una granularità settimanale, anziché giornaliera, risponde a tre esigenze metodologiche. In primo luogo, attenua il rumore ad alta frequenza che caratterizza i mercati delle criptovalute, dove le oscillazioni di prezzo su orizzonti brevi sono in larga parte guidate da dinamiche di microstruttura di mercato scarsamente prevedibili. In secondo luogo, rende compatibili fonti dati con cadenze di aggiornamento eterogenee (dati di mercato continui, indicatori on-chain aggiornati a intervalli variabili, un campione di post social non uniformemente distribuito nel tempo). In terzo luogo, riduce la numerosità di osservazioni ridondanti dal punto di vista informativo, a fronte di un corrispondente aumento della varianza campionaria dovuto alla ridotta ampiezza del dataset risultante.

== Fonti di dati

Il sistema integra quattro categorie di fonti dati, raccolte tramite un modulo di ingestion dedicato:

#figure(
  caption: [Fonti dati e modalità di raccolta],
  table(
    columns: (3.2cm, 6.5cm, 5.3cm),
    align: (left + horizon, left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Fonte*], [*Contenuto*], [*Modalità di accesso*]),
    [Mercato],
    [Quotazioni OHLCV settimanali di BTC/USD],
    [API Yahoo Finance],

    [On-chain/energetiche],
    [Costo di produzione stimato per bitcoin, hash rate della rete],
    [Metriche di mining aggregate],

    [Sentiment social],
    [Post/commenti da subreddit relativi a Bitcoin e criptovalute],
    [API Reddit, classificazione tramite modello linguistico (Gemini)],

    [Sentiment di mercato],
    [Fear \& Greed Index],
    [API pubblica dedicata],
  ),
)

Ciascuna fonte viene ricampionata a cadenza settimanale con lo stesso criterio di ancoraggio temporale (etichetta di fine settimana), condizione necessaria affinché le successive operazioni di join tra le diverse serie storiche siano corrette e non introducano disallineamenti tra le osservazioni. L'aggregazione dei valori di chiusura utilizza sempre l'ultimo valore disponibile nella settimana (non una media), per preservare il significato economico di "prezzo di chiusura settimanale".

== Feature Engineering

Le feature utilizzate dal modello sono organizzate in quattro famiglie omogenee per natura e fonte del dato: feature tecniche (derivate esclusivamente dalla serie dei prezzi di chiusura) feature di sentiment, feature on-chain/energetiche e feature derivate dal Fear & Greed Index.

=== Feature Tecniche

#figure(
  caption: [Feature tecniche],
  table(
    columns: (1fr, 1fr, 1fr),
    align: (left + horizon, left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Feature*], [*Descrizione*], [*Motivazione*]),

    [`log_return`], [Rendimento logaritmico settimanale], [Forma stazionaria e additiva, standard in finanza quantitativa],
    [`volatility_w`], [Deviazione standard dei rendimenti (4 settimane)], [Misura il rischio/instabilità recente del prezzo],
    [`rsi_14`], [Relative Strength Index a 14 periodi], [Momentum e condizioni di ipercomprato/ipervenduto],
    [`macd_hist`], [Istogramma MACD], [Cattura i crossover di trend; sostituisce `macd`/`macd_signal`, scartate per collinearità],
    [`sharpe_4w`], [Sharpe ratio mobile (4 settimane)], [Rendimento aggiustato per il rischio in un solo indicatore],
    [`volume_norm`], [Volume normalizzato sulla propria media mobile], [Rileva anomalie di interesse indipendenti dal livello assoluto],
  ),
)

=== Feature di Sentiment

#figure(
  caption: [Feature di sentiment],
  table(
    columns: (1fr, 1fr, 1fr),
    align: (left + horizon, left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Feature*], [*Descrizione*], [*Motivazione*]),

    [`sentiment_score_mean`], [Punteggio medio di sentiment settimanale], [Tono generale della discussione pubblica],
    [`sentiment_score_weighted`], [Punteggio pesato per follower dell'autore], [Maggior peso agli autori con più reach/influenza],
    [`positive_pct` \ `negative_pct`], [Percentuale di post positivi/negativi], [Cattura la polarizzazione, non solo il tono medio],
    [`tweet_count`], [Volume di post analizzati], [Proxy dell'attenzione pubblica verso Bitcoin],
    [`sentiment_momentum`], [Differenza dal sentiment medio delle 4 settimane precedenti], [Cattura variazioni brusche di umore],
  ),
)

=== Feature On-Chain / Energetiche

#figure(
  caption: [Feature on-chain / energetiche],
  table(
    columns: (1fr, 1fr, 1fr),
    align: (left + horizon, left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Feature*], [*Descrizione*], [*Motivazione*]),

    [`cost_per_btc`], [Costo di produzione stimato per bitcoin], [Proxy del valore "fondamentale" (cfr. Sapra et al.)],
    [`cost_per_btc_delta`], [Variazione percentuale settimanale del costo], [Cattura la dinamica, non solo il livello],
    [`hash_rate_norm`], [Hash rate normalizzato sulla propria media mobile], [Proxy della fiducia/investimento dei miner nella rete],
  ),
)

=== Feature di Sentiment del Mercato

#figure(
  caption: [Feature di sentiment del mercato],
  table(
    columns: (1fr, 1fr, 1fr),
    align: (left + horizon, left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Feature*], [*Descrizione*], [*Motivazione*]),

    [`fear_greed_mean` \ `fear_greed_close`], [Valore medio e di chiusura settimanale dell'indice], [Sentiment di mercato aggregato da fonti multiple],
    [`fear_greed_delta`], [Variazione rispetto alla settimana precedente], [Cambi repentini di sentiment, coerente col momentum del sentiment testuale],
  ),
)

Il criterio comune a tutte le famiglie, evidente dal confronto delle motivazioni riportate in tabella, è la ricerca di complementarità informativa più che di ridondanza: per ciascuna fonte si è privilegiata l'inclusione di misure che catturano aspetti distinti del fenomeno osservato (livello, variazione, dispersione, polarizzazione) piuttosto che più indicatori sostanzialmente equivalenti, come appunto vedremo successivamente.

=== Feature macro, volatilità e momentum (esperimento di ampliamento)

Successivamente

=== Selezione e pruning delle feature

Data l'ampiezza campionaria contenuta del dataset (dell'ordine di 110-120 osservazioni settimanali) rispetto al numero di feature disponibili, è stata applicata una fase di pruning automatico volta a contenere il rischio di overfitting:

Rimozione di feature ridondanti: per ogni coppia di feature con correlazione assoluta superiore a 0.95, viene mantenuta solo una delle due (ad esempio, tra le tre componenti del MACD, correlate per costruzione, è stato mantenuto solo l'istogramma).
Rimozione di feature a varianza nulla: feature costanti su tutto il periodo osservato non apportano alcuna informazione discriminante e vengono scartate esplicitamente.

Un principio metodologico osservato rigorosamente in questa fase è che nessuna selezione di feature è stata basata sulla correlazione con la variabile target calcolata sull'intero dataset. Una simile pratica, per quanto diffusa, costituisce una forma di leakage nella fase di feature engineering: utilizzare informazione proveniente anche dal periodo che verrà successivamente impiegato come test per decidere quali feature includere nel modello equivale a "sbirciare" il risultato prima della validazione, inficiandone la validità. Il pruning qui adottato si basa esclusivamente su proprietà interne alle feature stesse (correlazione reciproca, varianza), indipendenti dalla variabile da prevedere.

== Definizione del target

La variabile target è costruita confrontando il prezzo di chiusura della settimana corrente con quello della settimana immediatamente successiva nell'indice temporale. Un aspetto metodologico che richiede attenzione esplicita riguarda la costruzione di questo confronto: fare riferimento alla riga successiva nell'indice (offset posizionale) anziché alla settimana calendariale successiva (offset temporale) espone al rischio che, in presenza di anche una sola settimana mancante nella serie storica, il target smetta silenziosamente di rappresentare "direzione della settimana successiva" senza generare alcun errore. Per questo motivo, la costruzione del target verifica esplicitamente che la distanza temporale tra un'osservazione e la successiva nell'indice sia esattamente di sette giorni; in caso contrario, l'osservazione viene scartata anziché essere etichettata in modo semanticamente errato.

== Definizione del modello

Il modello adottato è XGBoost (Extreme Gradient Boosting), un ensemble di alberi decisionali allenati in sequenza secondo il principio del gradient boosting, in cui ciascun albero è addestrato a correggere l'errore residuo dei predecessori. La scelta è motivata da tre proprietà rilevanti per il contesto applicativo: la capacità di modellare relazioni non lineari e interazioni tra feature eterogenee senza richiedere una fase di scaling, la disponibilità di meccanismi di regolarizzazione nativi (penalizzazioni L1/L2, subsampling di righe e colonne, vincoli sulla profondità degli alberi), particolarmente rilevanti data la ridotta ampiezza campionaria del dataset e la diffusione consolidata dell'algoritmo nella letteratura sulla previsione di serie finanziarie con feature tabellari, che ne facilita il confronto con lavori analoghi.

== Metodologia di validazione

La natura sequenziale e temporalmente ordinata dei dati richiede una procedura di validazione che rispetti rigorosamente la cronologia delle osservazioni, per evitare qualunque forma di leakage temporale, ossia l'uso implicito o esplicito di informazione futura durante l'addestramento o la selezione del modello.

=== Split iniziale e purge gap

Il dataset viene suddiviso in una porzione di addestramento (70%) e una di test (30%), con l'introduzione di un ulteriore margine di separazione (purge gap) di due settimane tra le due porzioni. Questo accorgimento previene che feature calcolate su finestre mobili a cavallo del confine tra le due porzioni possano condividere informazione tra addestramento e test.

=== Ottimizzazione degli iperparametri

La selezione degli iperparametri avviene tramite ricerca randomizzata (``` RandomizedSearchCV```) su uno spazio di ricerca deliberatamente contenuto e orientato alla regolarizzazione (profondità massima degli alberi limitata a 3, penalizzazioni L1/L2 significative, subsampling di righe e colonne), coerente con l'ampiezza campionaria disponibile. La validazione incrociata durante questa fase utilizza uno schema ``` TimeSeriesSplit``` a 5 fold, con un margine di due settimane tra le porzioni di addestramento e validazione di ciascun fold, per prevenire leakage tra osservazioni temporalmente adiacenti dovuto a feature con finestre mobili.

Un aspetto metodologico rilevante riguarda l'interpretazione del punteggio massimo ottenuto da questa procedura (``` best_score_```): trattandosi del valore massimo osservato su un numero finito di configurazioni testate, tale punteggio è affetto da un bias di selezione che lo rende sistematicamente ottimistico rispetto alla reale capacità di generalizzazione del modello. Per questo motivo, tale valore non viene utilizzato come stima finale delle prestazioni del sistema, ruolo riservato esclusivamente alla procedura di validazione walk-forward descritta di seguito.

=== Validazione walk-forward

Per simulare in modo realistico l'utilizzo operativo del modello, la valutazione principale delle prestazioni avviene tramite una procedura di validazione walk-forward con finestra di addestramento progressivamente crescente (expanding window): a partire da una dimensione minima iniziale, il modello viene riaddestrato a ogni passo temporale sui soli dati disponibili fino a quel momento, e utilizzato per produrre una singola previsione sulla settimana immediatamente successiva, mai osservata durante l'addestramento.

Gli iperparametri vengono ri-ottimizzati periodicamente durante questa procedura (a intervalli di 26 settimane), ma solo quando la finestra di addestramento disponibile supera una soglia minima prestabilita; al di sotto di tale soglia, la ri-ottimizzazione viene omessa poiché condotta su un numero di osservazioni insufficiente a garantire risultati stabili, rischiando di introdurre instabilità nel modello anziché migliorarne l'adattamento a eventuali cambiamenti nel regime di mercato.

=== Quantificazione dell'incertezza statistica

Data la ridotta numerosità delle previsioni prodotte in fase di walk-forward (dell'ordine di 70-90 osservazioni a seconda della configurazione), una singola stima puntuale delle metriche di classificazione (accuratezza, precisione, richiamo, F1-score, area sotto la curva ROC) è di per sé poco informativa circa l'affidabilità del risultato. È stata pertanto adottata una procedura di bootstrap non parametrico: le coppie previsione/esito osservate durante il walk-forward vengono ricampionate con reinserimento un numero elevato di volte (2.000 ripetizioni), ricalcolando a ogni ripetizione le metriche di interesse; la distribuzione empirica così ottenuta consente di stimare intervalli di confidenza al 95% attorno a ciascuna metrica.

Questa procedura consente di distinguere un risultato metodologicamente solido da un artefatto di misurazione: qualora l'intervallo di confidenza ottenuto includa il valore corrispondente a un classificatore privo di potere predittivo (0,5 per accuratezza e AUC), il risultato puntuale osservato non può essere considerato statisticamente distinguibile dal caso, indipendentemente dal suo valore nominale.

A completamento di questa analisi, è stato condotto un controllo di stabilità del regime di mercato, confrontando la proporzione di settimane rialziste osservata nel periodo di addestramento iniziale con quella osservata nella finestra di walk-forward, al fine di escludere che un'eventuale variazione nelle prestazioni fosse attribuibile a un cambiamento nella distribuzione della variabile target piuttosto che a un limite intrinseco del modello.

== Baseline di confronto e backtesting

Le prestazioni del modello sono messe a confronto con tre strategie di riferimento: Buy & Hold (esposizione costante al mercato per l'intero periodo), un semplice incrocio MACD (strategia tecnica classica, utile a verificare che il modello non stia replicando un segnale già catturato da un indicatore elementare) e una strategia casuale (media su numerose estrazioni pseudo-casuali, a rappresentare la prestazione attesa in assenza di qualunque capacità predittiva).

È stata inoltre condotta una simulazione di backtesting, con un capitale iniziale nozionale e un costo di transazione applicato a ogni variazione di posizione, per stimare rendimento cumulato, Sharpe ratio annualizzato e drawdown massimo di una strategia operativa basata sui segnali del modello, posta a confronto con il Buy & Hold sullo stesso periodo. Questa analisi va interpretata con cautela quando le metriche di classificazione non risultano statisticamente significative: i costi di transazione tendono a erodere ulteriormente un segnale già debole o assente, e in periodi di trend di mercato marcato il Buy & Hold beneficia strutturalmente della semplice esposizione continua, indipendentemente dalla qualità di un eventuale segnale predittivo.

== Interpretabilità del modello

Un limite ricorrente nei lavori affini discussi nel capitolo precedente riguarda l'opacità decisionale dei modelli adottati, in particolare per le architetture neurali sequenziali e per i sistemi multi-agente basati su LLM, per i quali risulta difficile isolare il contributo delle singole feature a una predizione. La pipeline qui sviluppata affronta questo limite su due livelli complementari.

A livello globale, viene calcolata la feature importance nativa del modello (basata sul guadagno informativo, gain, apportato da ciascuna feature nella costruzione degli alberi), che fornisce un ranking di quanto ciascuna feature venga utilizzata in media dal modello.

A livello sia globale sia locale, viene condotta un'analisi tramite valori SHAP (SHapley Additive exPlanations), calcolati con un explainer specifico per modelli ad alberi (TreeExplainer), che restituisce valori esatti anziché approssimati. Per ciascuna osservazione, i valori SHAP scompongono l'output del modello nella somma dei contributi marginali di ogni feature, con segno e magnitudo, sulla base della teoria dei giochi cooperativi di Shapley; aggregando questi contributi su tutte le osservazioni si ottiene inoltre una misura di importanza globale (media del valore assoluto) alternativa e più informativa rispetto alla sola feature importance basata sul gain, poiché riflette anche l'eterogeneità e la direzione dell'effetto di ciascuna feature.

Un principio metodologico da tenere presente nell'interpretazione di questi risultati è che l'importanza (nativa o SHAP) descrive esclusivamente su quali feature il modello si appoggia per produrre le proprie predizioni, non se tali predizioni siano corrette o generalizzino a dati non osservati: le due analisi rispondono a domande distinte e vanno lette congiuntamente alla validazione statistica descritta nella sezione 3.6, non in sua sostituzione.

A completamento dell'analisi di interpretabilità, è stata condotta una procedura di ablation per gruppi di feature: le feature sono raggruppate per famiglia omogenea (tecniche, sentiment, on-chain/energetiche, Fear & Greed Index, macro/volatilità), e per ciascun gruppo viene ripetuta la procedura di validazione walk-forward utilizzando esclusivamente le feature di quel gruppo, con iperparametri fissi e conservativi per garantire un confronto omogeneo tra gruppi. Questa analisi consente di verificare se un sottoinsieme di feature isolato possieda un potere predittivo che risulti attenuato o mascherato dal rumore quando combinato con l'intero vettore di feature, offrendo un livello di granularità diagnostica ulteriore rispetto alla sola valutazione del modello completo.

== Sintesi delle scelte

L'insieme delle scelte descritte in questo capitolo risponde a un principio metodologico unificante: dato il vincolo strutturale rappresentato dalla ridotta ampiezza campionaria del dataset, ogni fase della pipeline (selezione delle feature, ottimizzazione degli iperparametri, valutazione delle prestazioni) è stata progettata per minimizzare il rischio di sovrastima delle capacità predittive del sistema, anche a costo di ottenere stime puntuali meno favorevoli. I risultati ottenuti applicando questa metodologia sono presentati e discussi nel capitolo successivo.

#pagebreak()

= Implementazione

Questo capitolo mostra l'implementazione in codice delle scelte metodologiche precedenti. La pipeline è composta da moduli Python riutilizzabili orchestrati da notebook Jupyter. La struttura segue l'ordine di esecuzione della pipeline, in parallelo al capitolo 4.


== Raccolta dati

Il modulo ``` DataIngestor``` gestisce l'accesso a ogni fonte dati tramite metodi dedicati (``` fetch_market_data```, ``` fetch_mining_metrics```, ``` fetch_energy_cost```, ``` fetch_fear_greed```), assicurando ricampionamento uniforme e stessa funzione di aggregazione per il prezzo di chiusura su tutte le fonti.

Un esempio di fetching di una categoria di questi dati:

```python
def fetch_energy_cost(
  self,
  electricity_price_kwh: float = 0.05,
  df_mining: pd.DataFrame = None,
) -> pd.DataFrame:
        try:
            resp = requests.get(
                "https://community-api.coinmetrics.io/v4/timeseries/asset-metrics",
                params={"assets": "btc", "metrics": "HashRate,RevUSD", "frequency": "1d",
                        "start_time": self.start_date.strftime("%Y-%m-%d"),
                        "end_time": self.end_date.strftime("%Y-%m-%d")},
                timeout=30
            )
            resp.raise_for_status()
            df_cm = pd.DataFrame(resp.json().get("data", []))
            df_cm["timestamp"] = pd.to_datetime(df_cm["time"])
            df_cm = df_cm.set_index("timestamp")[["HashRate", "RevUSD"]].astype(float)
            hash_rate_ths = df_cm["HashRate"]
            miners_rev_usd = df_cm["RevUSD"]
        except Exception as e:
            if df_mining is not None:
                hash_rate_ths = df_mining["hash_rate"] / 1e3   # GH/s to TH/s
            else:
                csv = os.path.join(self.output_dir, "bitcoin_mining_metrics.csv")
                df_mining = pd.read_csv(csv, index_col="timestamp", parse_dates=True)
                hash_rate_ths = df_mining["hash_rate"] / 1e3
            miners_rev_usd = None
        EFFICIENCY_J_PER_TH = 20.0
        DAILY_BTC_REWARDS   = 3.125 * 144 + 15
        power_kw     = hash_rate_ths * EFFICIENCY_J_PER_TH / 1000.0
        daily_kwh    = power_kw * 24.0
        cost_per_btc = (daily_kwh * electricity_price_kwh) / DAILY_BTC_REWARDS
        result = pd.DataFrame({
            "hash_rate_ths":        hash_rate_ths,
            "power_gw":             power_kw / 1e6,
            "daily_consumption_gwh": daily_kwh / 1e6,
            "annualised_twh":       (daily_kwh * 365.25) / 1e9,
            "cost_per_btc_usd":     cost_per_btc,
        }, index=hash_rate_ths.index)
        if miners_rev_usd is not None:
            result["miners_revenue_usd"] = miners_rev_usd
        result = result.loc[self.start_date : self.end_date].resample(self.frequency).mean()
        result.index.name = "timestamp"
        result.to_csv(os.path.join(self.output_dir, "bitcoin_energy_cost.csv"))
        return result
```

Nel caso, invece, della raccolta dei post social da Reddit ho utilizzato un archivio pubblico di nome ArticShift nel seguente modo:

```python
def fetch_arctic_shift_feed(self,subreddits: list[str] | None = None, min_score: int = 5, sleep_between_calls: float = 1.0, window_days: int = 7, max_per_window: int = 200) -> pd.DataFrame:
        if subreddits is None:
            subreddits = ["Bitcoin", "CryptoCurrency", "BitcoinMarkets"]
        BASE_URL        = "https://arctic-shift.photon-reddit.com/api/comments/search"
        checkpoint_path = os.path.join(self.output_dir, "bitcoin_arctic_reddit_checkpoint.csv")
        if os.path.exists(checkpoint_path):
            df_existing = pd.read_csv(checkpoint_path)
            df_existing["timestamp"] = pd.to_datetime(df_existing["timestamp"])
            all_rows = df_existing.to_dict("records")
            last_ts  = df_existing["timestamp"].max()
        else:
            all_rows = []
            last_ts  = None
        for sub in subreddits:
            n_sub        = 0
            window_start = self.start_date
            while window_start < self.end_date:
                window_end = min(window_start + timedelta(days=window_days), self.end_date)
                if last_ts is not None and window_end <= last_ts:
                    window_start = window_end
                    continue
                before = window_end.strftime("%Y-%m-%dT%H:%M:%S")
                after  = window_start.strftime("%Y-%m-%dT%H:%M:%S")
                n_window = 0
                while True:
                    url = (
                        f"{BASE_URL}"
                        f"?subreddit={sub}"
                        f"&after={after}"
                        f"&before={before}"
                        f"&limit=100"
                        f"&sort=desc"
                        f"&fields=body,score,created_utc"
                    )
                    try:
                        resp      = requests.get(url, timeout=30)
                        remaining = int(resp.headers.get("X-RateLimit-Remaining", 10))
                        if remaining < 2:
                            reset = int(resp.headers.get("X-RateLimit-Reset", 10))
                            print(f"\n   [rate limit] Aspetto {reset}s...")
                            time.sleep(reset)
                        resp.raise_for_status()
                        data = resp.json().get("data", [])
                    except Exception as e:
                        print(f"\n   [warn] Errore r/{sub} [{after} → {before}]: {e}")
                        data = []
                        break
                    if not data:
                        break
                    for item in data[:max_per_window]:
                        ts = datetime.fromtimestamp(
                            item.get("created_utc", 0),
                            tz=timezone.utc
                        ).replace(tzinfo=None)
                        all_rows.append({
                            "timestamp":      ts,
                            "source":         f"Reddit_r/{sub}",
                            "text":           item.get("body", ""),
                            "user_followers": item.get("score", 0),
                        })
                        n_window += 1
                    n_sub += len(data)
                    print(f"   r/{sub}: {n_sub} commenti finora...", end="\r")
                    pd.DataFrame(all_rows).to_csv(checkpoint_path, index=False)
                    if n_window >= max_per_window:
                        break
                    oldest = min(item["created_utc"] for item in data)
                    before = datetime.fromtimestamp(oldest - 1, tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%S")
                    if oldest <= int(window_start.timestamp()):
                        break
                    time.sleep(sleep_between_calls)
                window_start = window_end
        if not all_rows:
            return pd.DataFrame(columns=["timestamp", "source", "text", "user_followers"])
        df = pd.DataFrame(all_rows)
        df["timestamp"] = pd.to_datetime(df["timestamp"], errors="coerce")
        df = df.dropna(subset=["timestamp", "user_followers"])
        df = df.loc[df["user_followers"] >= min_score]
        df = df.drop_duplicates(subset=["timestamp", "text"]).sort_values("timestamp").reset_index(drop=True)
        output_path = os.path.join(self.output_dir, "bitcoin_arctic_reddit.csv")
        df.to_csv(output_path, index=False)
        if os.path.exists(checkpoint_path):
            os.remove(checkpoint_path)
        return df
```

#figure(
caption: [Metodi della classe DataIngestor],
table(
columns: (1fr, 1fr, 1.4fr),
align: (left, left, left),
fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
table.header([Metodo], [Funzione], [Implementazione]),

[``` __init__```],
[Imposta periodo e frequenza di ricampionamento.],
[Parametri: ``` start_date```, ``` end_date```, ``` frequency="W"```. Crea cartella output.],

[``` fetch_market_data```],
[Scarica e ricampiona quotazioni BTC/USD.],
[Usa yfinance; aggrega con ``` last```, ``` sum```, ``` max```, ``` min```, ``` first```. Salva in CSV.],

[``` fetch_mining_metrics```],
[Scarica hash rate e difficoltà di rete.],
[API blockchain.info; media settimanale con ``` resample(...).mean()```.],

[``` fetch_energy_cost```],
[Stima costo di produzione per BTC.],
[API CoinMetrics, fallback su mining metrics o CSV. Modello costo/energia con parametri fissi.],

[``` fetch_arctic_shift_feed```],
[Raccoglie commenti Reddit su Bitcoin da più subreddit.],
[API arctic-shift con finestre temporali, rate limiting e checkpoint su disco per ripresa.],

[``` fetch_fear_greed```],
[Scarica Fear & Greed Index e statistiche settimanali.],
[API alternative.me; nessuna autenticazione.],
),
)
Tra i pattern implementativi comuni a più metodi, il più rilevante dal punto di vista metodologico è il meccanismo di *checkpoint* di `fetch_arctic_shift_feed`, che permette di riprendere una raccolta dati incrementale (nuovi commenti ogni settimana) senza ri-scaricare l'intero storico a ogni esecuzione:

```python
checkpoint_path = os.path.join(self.output_dir, "bitcoin_arctic_reddit_checkpoint.csv")
if os.path.exists(checkpoint_path):
    df_existing = pd.read_csv(checkpoint_path)
    all_rows = df_existing.to_dict("records")
    last_ts  = df_existing["timestamp"].max()
else:
    all_rows, last_ts = [], None
if last_ts is not None and window_end <= last_ts:
    continue
```

Lo stesso principio è impiegato anche nella classificazione del sentiment (``` SentimentEngine.analyze```), dove evita di ri-analizzare tramite il modello LLM Gemini i post già classificati in esecuzioni precedenti.

Un secondo aspetto implementativo degno di nota è la strategia di resilienza a fonti non critiche: per dati non indispensabili alla costruzione della feature matrix, un fallimento di rete non interrompe l'intera pipeline, ma ricade su un CSV già scaricato in una run precedente, se disponibile, restituendo altrimenti ``` None``` in modo che la fase di join successiva possa escludere la fonte senza propagare l'errore.

#pagebreak()

== Sentiment Analysis

Il modulo ``` SentimentEngine``` incapsula sia l'estrazione del sentiment testuale tramite modello linguistico sia il calcolo delle feature derivate dalle altre fonti dati. La Tabella [ref] (vedi tabella_sentimentengine.typ) riassume i metodi utilizzati nella pipeline finale.

#figure(
  caption: [Metodi della classe `SentimentEngine` (pipeline finale)],
  table(
    columns: (1fr, 1fr, 1fr),
    align: (left + horizon, left + horizon, left + horizon),
    fill: (_, y) => if y == 0 { luma(210) } else if calc.odd(y) { luma(245) } else { white },
    table.header([*Metodo*], [*Cosa fa*], [*Come lo fa*]),

    [`_clean_tweet`],
    [Normalizza il testo grezzo di un post prima della classificazione.],
    [Rimuove HTML, URL, menzioni, converte hashtag in parole, filtra caratteri non ASCII.],

    [`_analyze_batch`],
    [Classifica un batch di post tramite il modello linguistico, restituendo punteggio e label per ciascuno.],
    [Costruisce un prompt strutturato e forza una risposta in formato JSON; gestisce retry su errori di rate limit e risposte malformate.],

    [`analyze`],
    [Orchestra la classificazione dell'intero dataset di post, in batch, con ripresa da checkpoint.],
    [Salta i post già presenti nel checkpoint su disco; aggrega i punteggi a livello settimanale al termine.],

    [`compute_rsi` \ `compute_macd` \ `compute_sharpe`],
    [Calcolano i rispettivi indicatori tecnici sulla serie dei prezzi.],
    [Uso esclusivo di `rolling`/`ewm`, mai statistiche sull'intera serie.],

    [`compute_technical_features`],
    [Assembla le sei feature tecniche in un unico DataFrame.],
    [Chiama i tre metodi precedenti e unisce i risultati sull'indice temporale di `df_market`.],

    [`compute_energy_features`],
    [Calcola costo per bitcoin, sua variazione e hash rate normalizzato.],
    [Trasformazioni dirette (`pct_change`, `rolling`) sulle colonne di `df_energy`.],

    [`compute_sentiment_momentum`],
    [Calcola la differenza tra il sentiment corrente e la media delle 4 settimane precedenti.],
    [`shift(1)` prima di `rolling(4)`, per escludere la settimana corrente dalla propria baseline.],
  ),
)

Il punto di maggior rilievo per la componente NLP della tesi è la costruzione della chiamata al modello linguistico in ``` _analyze_batch```. I post vengono numerati e inseriti in un unico prompt per batch (riducendo il numero di chiamate API rispetto a una classificazione post per post), con una richiesta esplicita di output strutturato:

#pagebreak()


```python
numbered = "\n".join(f"{i+1}. {t}" for i, t in enumerate(tweets))
prompt = f"""
    Analyze the sentiment of each tweet below about Bitcoin/crypto markets.
    For each tweet return ONLY a JSON array with objects containing:
    - "id": the tweet number (integer)
    - "score": float from -1.0 (extremely negative) to +1.0 (extremely positive)
    - "label": one of "positive", "neutral", "negative"
    Tweets: {numbered}
    Return ONLY the JSON array, no other text.
"""

response = self.client.models.generate_content(
    model=self.model,
    contents=prompt,
    config={"response_mime_type": "application/json"},
)
```

== Feature engineering

Ogni trasformazione che genera una feature è implementata in modo da utilizzare esclusivamente operazioni causali (``` rolling```, ``` ewm```, ``` pct_change```, ``` diff```), mai statistiche calcolate sull'intera serie. A titolo di esempio, la feature di momentum del sentiment è implementata come:

```python
def compute_sentiment_momentum(self, df_sentiment, window=4, col="sentiment_score_mean"):
    baseline = df_sentiment[col].shift(1).rolling(window).mean()
    return (df_sentiment[col] - baseline).rename(f"{col}_momentum_{window}w")
```
Lo ``` shift(1)``` prima del ``` rolling(window)``` è l'elemento implementativo che garantisce la causalità: esclude la settimana corrente dal calcolo della propria baseline, cosicché il valore di ciascuna settimana dipenda solo da settimane strettamente precedenti.

Ulteriormente fornisco un esempio di funzione che calcola una feature tecnica, ovverio lo Sharpe Ratio:

```python
def compute_sharpe(
        self,
        returns: pd.Series,
        window: int = 4,
        risk_free: float = 0.0,
    ) -> pd.Series:
        excess = returns - risk_free / 52
        return (
            excess.rolling(window).mean()
            / excess.rolling(window).std()
            * np.sqrt(52)
        )
```

Inoltre ho gestito il caso in cui ci siano gap nel sentiment. Non tutte le settimane presentano un volume di post sufficiente per una stima affidabile del sentiment (o, in casi limite, nessun post disponibile). Il riempimento di queste settimane mancanti è implementato tramite forward-fill limitato, nel seguente modo:

```python
cols_interp = ["sentiment_score_mean", "sentiment_score_weighted", "positive_pct", "negative_pct"]
df_sentiment[cols_interp] = df_sentiment[cols_interp].ffill(limit=4).fillna(0)
```

La scelta del forward-fill al posto dell'interpolazione lineare non è arbitraria: un'interpolazione lineare tra il valore noto precedente e quello noto successivo (``` interpolate(method="linear", limit_direction="both")```) utilizzerebbe, per costruzione, un'osservazione futura per stimare il valore di una settimana mancante, introducendo look-ahead bias esattamente nel punto in cui il dato è più scarso e quindi più vulnerabile. Il forward-fill, al contrario, propaga solo l'ultimo valore osservato in avanti nel tempo, rispettando il vincolo di causalità. Il parametro ``` limit=4``` evita inoltre che un'assenza di dati prolungata (oltre quattro settimane) venga mascherata da un valore ormai stantio: oltre questa soglia la settimana viene invece impostata a un valore neutro (``` fillna(0)```), segnalando implicitamente l'assenza di informazione piuttosto che simularne una non aggiornata. Questa scelta implementativa è quanto emerso dalla verifica di look-ahead bias descritta nel processo di sviluppo della pipeline, che aveva individuato un'implementazione precedente (basata su interpolazione bidirezionale) affetta da questo problema.

Il pruning delle feature è implementato in due passaggi indipendenti dal target, in coerenza con il principio di assenza di leakage nella selezione delle feature discusso nella medesima sezione: rimozione delle feature a varianza nulla (``` nunique(dropna=True) <= 1```) e rimozione automatica, per ogni coppia con correlazione assoluta superiore a una soglia, di una delle due colonne coinvolte, calcolata esclusivamente sulla matrice delle feature (``` feature_matrix[num_cols].corr()```), senza mai includere la colonna target in questo calcolo.

== Costruzione del target
La verifica esplicita del gap temporale è implementata confrontando la distanza tra timestamp consecutivi con il valore atteso, anziché assumerla implicitamente da un offset posizionale:

```python
EXPECTED_GAP = pd.Timedelta(weeks=1)

for t in feature_matrix.index:
    t_idx = close.index.get_loc(t)
    next_ts = close.index[t_idx + 1]
    if (next_ts - t) != EXPECTED_GAP:
        target.append(np.nan)
        continue
    target.append(int(close.iloc[t_idx + 1] > close.iloc[t_idx]))
```

== Ottimizzazione degli iperparametri

Lo spazio di ricerca degli iperparametri è definito esplicitamente per essere deliberatamente contenuto e orientato alla regolarizzazione, coerentemente con l'ampiezza campionaria disponibile:

```python
param_grid = {
    "n_estimators":     [50, 100, 150],
    "max_depth":        [2, 3],
    "learning_rate":    [0.01, 0.05, 0.1],
    "subsample":        [0.7, 0.8, 1.0],
    "colsample_bytree": [0.7, 0.8, 1.0],
    "min_child_weight": [3, 5, 8],
    "gamma":            [0, 0.1],
    "reg_alpha":        [0, 0.1],
    "reg_lambda":       [2, 5, 10],
}
```

La profondità massima è limitata a 2-3 (in contesti con più dati si usa tipicamente valori tra i 4 e 8), e i parametri di regolarizzazione L1/L2 (``` reg_alpha```, ``` reg_lambda```) e di subsampling di righe/colonne (``` subsample```, ``` colsample_bytree```) sono inclusi esplicitamente nello spazio di ricerca anziché lasciati ai valori di default, meno conservativi, della libreria.

La ricerca randomizzata degli iperparametri è incapsulata in una funzione riutilizzabile, richiamata sia nella fase di tuning iniziale sia, con un budget di ricerca ridotto, nei successivi cicli di re-tuning periodico durante il walk-forward:

```python
def tune_hyperparams(X_tr, y_tr, n_iter=20, n_splits=5, gap=2, seed=42):
    tscv = TimeSeriesSplit(n_splits=n_splits, gap=gap)
    search = RandomizedSearchCV(
        estimator=xgb.XGBClassifier(eval_metric="logloss", random_state=seed),
        param_distributions=param_grid,
        n_iter=n_iter, scoring="roc_auc", cv=tscv,
        random_state=seed, n_jobs=-1,
    )
    search.fit(X_tr, y_tr)
    return search.best_params_, search.best_score_
```

== Validazione walk-forward

Il ciclo di validazione implementa la finestra di addestramento crescente, con il re-tuning periodico condizionato al superamento di una soglia minima di dati disponibili:

```python
current_params = best_params
since_retune = 0

for i in range(MIN_TRAIN_SIZE, len(X_clean)):
    X_tr, y_tr = X_clean.iloc[:i], y_clean.iloc[:i]
    X_te = X_clean.iloc[i:i+1]

    if since_retune >= RETUNE_EVERY and len(X_tr) >= MIN_RETUNE_SIZE:
        current_params, _ = tune_hyperparams(X_tr, y_tr, n_iter=10, n_splits=3, gap=2)
        since_retune = 0

    model = xgb.XGBClassifier(**current_params, eval_metric="logloss", random_state=42)
    model.fit(X_tr, y_tr)
    probabilities.append(model.predict_proba(X_te)[0, 1])
    since_retune += 1
```

La quantificazione dell'incertezza statistica è implementata come ricampionamento con reinserimento delle coppie previsione/esito prodotte da questo ciclo:

```python
for _ in range(N_BOOT):
    idx = rng.randint(0, n, n)
    if len(np.unique(actuals[idx])) < 2:
        continue
    boot_auc.append(roc_auc_score(actuals[idx], probabilities[idx]))

auc_ci = np.percentile(boot_auc, [2.5, 97.5])
```

== Interpretabilità

L'analisi SHAP è implementata tramite l'explainer specifico per modelli ad alberi, applicato al modello finale addestrato sull'intero dataset disponibile:

```python
explainer   = shap.TreeExplainer(final_model)
shap_values = explainer.shap_values(X_clean)
mean_abs_shap = pd.Series(
    np.abs(shap_values).mean(axis=0), index=X_clean.columns
).sort_values(ascending=False)
```


== Persistenza e riproducibilità

Il modello finale, l'elenco delle feature attese e le metriche del walk-forward vengono salvati su disco al termine dell'esecuzione:

```python
final_model.save_model("models/xgboost_model.json")
json.dump(X_clean.columns.tolist(), open("models/feature_names.json", "w"))
json.dump(model_stats, open("models/model_stats.json", "w"))
```

Il salvataggio esplicito di ``` feature_names.json``` garantisce che, in fase di inferenza, il modello riceva sempre le feature nello stesso ordine e con lo stesso nome usati in addestramento, indipendentemente da eventuali modifiche future al pruning per correlazione, che potrebbe produrre un insieme di colonne leggermente diverso a fronte di nuovi dati.

#pagebreak()



== Tecnologie utilizzate

=== Strumenti di Sviluppo Software
==== Visual Studio Code
==== Jupyter Notebook

=== Linguaggi di Programmazione
==== Python 3

=== Librerie o Framework
==== Pandas
==== NumPy 
==== Matplotlib
==== XGBoost
==== SciKitLearn

=== Persistenza dei dati
==== File Comma-Separated Values (CSV)
==== File JSON
==== Portable Network Graphics (PNG)

= Bibliografia e Sitografia

- #link("a", "[1]") Y. Xiao, E. Sun, D. Luo, and W. Wang, "Trading Agents: Multi-Agents LLM Financial Trading Framework" arXiv preprint arXiv:2412.20138v7, 2026. \ Disponibile a: #link("https://arxiv.org/pdf/2412.20138", "PDF")

- #link("a", "[2]") A. Hafid, M. Rahouti, L. Kong, M. Ebrahim, and M. A. Serhani, "Predicting Bitcoin Market Trends with Enhanced Technical Indicator Integration and Classification Models" arXiv preprint arXiv:2410.06935v1, 2024. \ Disponibile a: #link("https://arxiv.org/pdf/2410.06935", "PDF")

- #link("a", "[3]") N. Sapra, I. Shaikh, and D. Roubaud, "  " Energy Economics, vol. 156, p. 109216, 2026. \ Disponibile a: #link("https://pdf.sciencedirectassets.com/271683/1-s2.0-S0140988326X20023/1-s2.0-S0140988326000952/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjECgaCXVzLWVhc3QtMSJGMEQCIAkDH%2FgWJM3uoshWL2SDkd8Mm3psQNLTdVLa1bkZcZS6AiBGkoiYNZ1I8TI6HWszQDuFibeV2MhL8nrKHu9Y7%2F%2FuLiq8BQjx%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAUaDDA1OTAwMzU0Njg2NSIMF9Wrxadk8b%2BhgO4KKpAF4NLKTnVhBMxDCU44408ZbFPo2HTVFWeij8yQERT%2B8MdMoj0nJJ0mksy4ybGJ5cL%2BUuP%2FWPEzNmtLFml5%2Ff3OIRLn2dxO1CQ%2FKxARSbBGt4R7TpzjIMH3beUgYB7cYn2ATAq8rnkTCJE5ms1Owm2X5uyJ%2FgvfJUS0UAE0ydP9MQyfFFB3Y6WnYX2LR2%2Bi9fQeukwNtlN3%2FSHoBqlUaSdYXtWPz9RGL11PP1ArrMNOKj6WbWtNxGnkNPjVgfEKrEtB8jSDdDnytaQMuiP1lfmp36GJAnHHYKelgZFJpJ3HDt%2FXI4hUSb%2B1uCOhO0aAQj91sMzcwxgeC43kkAjANkrCTW55olnS47Pn1FynkpKHYPZQeI0WSuZLcVet0H1wg7l3x7DWaF9QIEERz9Q7FYDmX6EA%2BQSzJbrHsT4SwTSa4W2z9psAaIBJy1Z%2BxNeOIYs1NX4CWm6wcnX%2BYiE1qKo4EIsOorNlaRhibw92r2F%2B8sGitLnmGglhLDx3H3UxhYSKflEmnTIhEeEOMc%2FD1gZgK1otQJhZxO%2B7U%2F437rxoD6yONJ0sgSqzTXIeuXgzDCuZ2pQfpyg8PCtNSHZkqUYzbj5llhn6Rnlx65kKHchiI4S3aM%2BncMkEdlw983Le%2Bs%2BsCmDeVZ1AxWk5pBJtNtnMvuSGDOedw4Z03yZ8%2FjK56WKI3LeILFKsMXvn9LwCDrDo9vTUPimNCn91fJDSHRQLBGTNv%2FH0aQqFLcGhAwC0jscNTMCeLHmwL47kp%2F6nQTtpgUyAOxZH3oMWgLOwhanfpHIwX7vdHgp2DYF%2FjOqTn%2Fspo88DNsK5NEFPp2QYy2sUvTk6SY%2B9SPHdvOl5Y3Yh1up8kckp%2FKl9bmdFQG8DYXsw4LW30AY6sgEPtUKmcci5SXnsRpwUmNZJE3yDALKSWgXICoaluwNAuC3C4i6UiZtWkn7PTiCvFNmw0vOF0%2F7cVRP7AzTATipE%2F8Epc1aL%2FBqbndbINsCtMNgif8K%2Bt4bPlNrViyUJmp6C7Q8TnxU6GrvVrXA9hEtLGEdKa3%2FX6p1CXcPJvT8Yvz0f0PMlvanl%2FNbkTXYOD09Z20NlfK8xJ1eAjAolHEwd065j5gXGFzxm%2FNN185UWhlEt&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20260520T170246Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAQ3PHCVTY7YMELQSH%2F20260520%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=4ad904ea57a454420c1b62d14f4e87047427b2f083fcfc3baa24b8af98769508&hash=c73b4e65f4bdaa631c3bb77be981d7921245fcd3fad97e48dbb88e0bcde7531a&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S0140988326000952&tid=spdf-0c385172-31dd-472d-b92d-a936f5605160&sid=dfef7687124c6745d378c1c1425259ef3bcegxrqa&type=client&tsoh=d3d3LnNjaWVuY2VkaXJlY3QuY29t&rh=d3d3LnNjaWVuY2VkaXJlY3QuY29t&ua=071b5b0904070a5a55&rr=9fece9357a45eda3&cc=it", "PDF")

- #link("a", "[4]") C. M. Liapis, A. Karanikola, and S. Kotsiantis, "A Multi-Method Survey on the Use of Sentiment Analysis in Multivariate Financial Time Series Forecasting" Entropy, vol. 23, no. 12, p. 1603, 2021. \ Disponibile a: #link("PDF", "https://www.mdpi.com/1099-4300/23/12/1603")

- #link("a", "[5]") J. Manogna, G. S. Chowdary, G. Meghana, and P. C. Nair, "Bitcoin Price Prediction Based on Sentiment Analysis" in 2023 IEEE 20th India Council International Conference (INDICON), 2023, pp. 1–5. \ Disponibile a: #link("PDF", "https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=10440877")

- #link("a", "[6]") H. Anand and A. Arya, "An Empirical Study of Financial BERT Models for Sentiment Analysis and Cryptocurrency Price Correlation" in 2024 IEEE 9th International Conference for Convergence in Technology (I2CT), 2024, pp. 1–6. \ Disponibile a: #link("PDF", "")

- #link("a", "[7]") C. Kaur, Samrity, R. Uppal, and S. Kaur, "Twitter Sentiment Analysis of Bitcoin Price Fluctuation with Machine Learning Techniques" in 2025 Seventh International Conference on Computational Intelligence and Communication Technologies (CCICT), 2025, pp. 1–6. \ Disponibile a:

- #link("a", "[8]") S. Vasishth, S. K. Sharma, A. K. Nayyar, and K. Vijayakuamar, "Impact of Elon Musk's tweets on the price of Dogecoin using Sentiment Analysis" in 2023 International Conference on Advances in Computing, Communication and Applied Informatics (ACCAI), 2023, pp. 1–6. \ Disponibile a:

- #link("a", "[9]") O. Sattarov and H. S. Jeon, "Forecasting Bitcoin Price Fluctuation by Twitter Sentiment Analysis," in 2020 International Conference on Information Science and Communications Technologies (ICISCT), 2020, pp. 1–4. \ Disponibile a:

- #link("a", "[10]") J. Gomes Jr., H. Bernardino, A. B. Vieira, V. Dorner, and D. Svetinovic, "Cryptoeconomic User Behavior in the Acute Stages of Geopolitical Conflict," IEEE Transactions on Computational Social Systems, vol. 11, no. 5, pp. 7055–7067, Oct. 2024. \ Disponibile a:

- #link("a", "[11]") Kraken Learn, "Cosa determina il calo del prezzo dei Bitcoin?", Kraken.com, 2025.\
  Disponibile a: #link("https://www.kraken.com/it/learn/what-makes-bitcoins-price-go-down")

- #link("a", "[12]") Kraken Learn, "Quanti Bitcoin esistono? Spiegazione della fornitura dei Bitcoin", Kraken.com, 2025 \ Disponibile a: #link("https://www.kraken.com/it/learn/how-many-bitcoin-are-there-bitcoin-supply-explained")
= Glossario
