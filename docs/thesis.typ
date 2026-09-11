#show raw.where(block: true): it => pad(
  block(
    inset: 5pt,
    radius: 10pt,
    width: 100%,
    fill: luma(245),
    text(size: 9pt, it)
  )
)
#show table: set text(size: 11pt)

#set text(lang: "it")
#set heading(numbering: none)
#set text(font: "New Computer Modern")
#set page(numbering: none)
#set figure(numbering: "1")
#show link: set text(fill: blue)
#set text(size: 14pt)
#set par(justify: true)

#let unipd-red-dark   = rgb("#dd2d4a")  // intestazione tabella (testo bianco sopra)
#let unipd-red-light1 = rgb("#ffccd5")  // riga alternata più scura
#let unipd-red-light2 = rgb("#fff0f3")  // riga alternata più chiara (quasi bianco)

#let unipd-table-fill(_, y) = if y == 0 {
  unipd-red-dark
} else if calc.odd(y) {
  unipd-red-light1
} else {
  unipd-red-light2
}

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

#set figure(numbering: "1")

#outline(
  title: "Indice delle Figure",
  target: figure.where(kind: image),
)

#pagebreak()

#outline(
  title: "Indice delle Tabelle",
  target: figure.where(kind: table),
)

#set page(numbering: "1")
#counter(page).update(1)

= Sommario

Il presente documento descrive il lavoro svolto durante il periodo di stage, finalizzato allo sviluppo di una _pipeline software_ per la predizione della direzione settimanale del prezzo di Bitcoin, mediante l'integrazione di tecniche di _Natural Language Processing_ (*NLP*), _Sentiment Analysis_ e modelli di _Machine Learning_.

L'obiettivo della tesi è quello di costruire una _pipeline_ strutturata e riproducibile che consenta, insieme all'estrazione automatica dei dati, di effettuare la pulizia, l'analisi e l'elaborazione di dati testuali provenienti dal _social network_ Reddit, integrandoli con indicatori tecnici di mercato, metriche di _blockchain_ di tipo energetico e un indice di _sentiment_ di mercato, per la previsione della direzione del prezzo di Bitcoin su base settimanale.

Attraverso l'integrazione di un modulo di estrazione dati, è stata realizzata una soluzione che consente di raccogliere automaticamente i dati testuali e di mercato, facilitando la creazione di un _dataset_ aggiornato per l'addestramento del modello predittivo (*XGBoost*), unitamente a una metodologia di validazione temporale (_walk-forward_) e ad una analisi rigorosa dei dati ottenuti.

Le conclusioni, a differenza di quanto talvolta riportato in lavori analoghi senza una quantificazione esplicita dell'incertezza statistica, mostrano come, una volta corrette le criticità metodologiche individuate nella fase preliminare (_overfitting_ nella selezione degli iperparametri, rischio di _look-ahead bias_ nelle _feature_ testuali), non emerga una correlazione tra il _sentiment_ dei _post_ e la direzione settimanale del prezzo di Bitcoin statisticamente distinguibile dal caso. Questo risultato, anche se negativo, è coerente con la letteratura sull'efficienza informativa dei mercati di criptovalute su orizzonti brevi ed è reso metodologicamente solido proprio dalla _pipeline_ di validazione sviluppata.

L'esperienza ha creato le precondizioni per un ulteriore sviluppo del progetto, con l'obiettivo di rafforzare la capacità predittiva del sistema, integrando uno storico di dati più ampio (almeno 3 anni), ulteriori fonti non ancora esplorate (come l'uso di _news_ da fonti di settore), _feature_ nuove e un confronto sistematico con modelli a minore complessità.

Il progetto è stato diviso in tre parti: la prima dedicata all'estrazione dei dati, garantendo l'accesso a informazioni aggiornate e utilizzando le *API* di archivi di _post_ Reddit, Yahoo Finance e dei principali indicatori della _blockchain_ o di _sentiment_ di mercato, la seconda parte si è concentrata sull'effettivo sviluppo della _pipeline_, implementando le funzionalità di _Natural Language Processing_, _Sentiment Analysis_ e del modello di _Machine Learning_, con particolare attenzione alla correttezza metodologica della fase di validazione (assenza di _leakage_ temporale e quantificazione dell'incertezza statistica) e, infine, la terza parte ha riguardato l'analisi critica dei risultati ottenuti e la loro interpretazione attraverso metriche statistiche.

#pagebreak()

#set heading(numbering: "1.")

= Introduzione <sec-intro>

== Contesto e motivazione

Bitcoin, dalla sua introduzione nel 2009, si è affermato come l'_asset_ digitale più capitalizzato e maggiormente scambiato tra le criptovalute, caratterizzandosi tuttavia per una volatilità di prezzo sensibilmente superiore a quella degli strumenti finanziari tradizionali. A differenza dei mercati azionari, il cui valore è ancorato a bilanci societari, utili e altri fondamentali quantificabili, il prezzo di Bitcoin è guidato in misura rilevante da dinamiche speculative, dall'evoluzione del quadro regolatorio, da fattori tecnologici e, non ultimo, dal _sentiment_ diffuso tra i partecipanti al mercato attraverso i _social network_ e le piattaforme di discussione _online_.

Questa sensibilità al _sentiment_ pubblico ha motivato negli ultimi anni un crescente filone di ricerca, riassunto e discusso nel capitolo successivo, che tenta di sfruttare l'analisi automatica di testi provenienti da piattaforme come Twitter e Reddit come segnale predittivo per l'andamento futuro del prezzo. Parallelamente, la disponibilità di modelli linguistici sempre più capaci di cogliere sfumature contestuali, ironia e gergo specialistico del dominio finanziario ha reso possibile un'estrazione del _sentiment_ qualitativamente superiore rispetto agli approcci lessicali classici (dizionari statici come *VADER* o TextBlob), storicamente limitati nel catturare la complessità del linguaggio informale tipico delle _community online_.

Un secondo elemento di contesto, altrettanto rilevante per l'impostazione di questo lavoro, riguarda un problema metodologico ricorrente nella letteratura esistente: molti studi che riportano una capacità predittiva elevata basata sul _sentiment_ non accompagnano il risultato con una quantificazione esplicita dell'incertezza statistica, né con verifiche sistematiche dell'assenza di _look-ahead bias_ nella costruzione delle _feature_ o nella selezione degli iperparametri. Questa lacuna, discussa nel dettaglio nel capitolo di analisi della letteratura, rende difficile distinguere un genuino segnale predittivo da un artefatto della procedura sperimentale, un rischio particolarmente concreto quando si lavora, come nel caso della predizione di Bitcoin su base settimanale, con serie storiche di ampiezza campionaria limitata.

== Problema di ricerca

Il presente lavoro affronta la seguente domanda di ricerca: esiste, integrando il _sentiment_ estratto da _post_ Reddit con indicatori tecnici di mercato, metriche di _blockchain_ e un indice di _sentiment_ di mercato aggregato, un segnale predittivo per la direzione settimanale del prezzo di Bitcoin che sia statisticamente distinguibile dal caso?

La domanda è formulata deliberatamente in termini di significatività statistica, e non di sola accuratezza puntuale, per le ragioni esposte sopra: un valore di accuratezza o di area sotto la curva *ROC* superiore al 50% non è di per sé sufficiente a dimostrare l'esistenza di un segnale, se non accompagnato da una stima dell'incertezza associata a quella misura, tanto più in presenza di un _dataset_ di ampiezza contenuta.

== Obiettivi della tesi

Coerentemente con il problema di ricerca, gli obiettivi specifici di questo lavoro sono:

+ Costruire una _pipeline software_ modulare e riproducibile per la raccolta automatica di dati eterogenei e rilevanti per la predizione del prezzo di Bitcoin.
+ Progettare una procedura di _feature engineering_ che sia esente dal _look-ahead bias_, condizione necessaria affinché qualunque risultato di generalizzazione ottenuto sia metodologicamente valido.
+ Addestrare un modello di classificazione (*XGBoost*) per la direzione settimanale del prezzo, integrando il _sentiment_ estratto tramite un modello linguistico con le altre fonti informative disponibili.
+ Adottare una metodologia di validazione temporale (_walk-forward_) accompagnata da una quantificazione esplicita dell'incertezza statistica dei risultati.
+ Fornire un'interpretazione critica e statisticamente fondata dei risultati ottenuti, riportando in modo trasparente anche l'eventuale assenza di un segnale predittivo significativo.

== Organizzazione del documento

I successivi capitoli del documento sono organizzati nel seguente modo:
- *@sec-analisi-lett: Analisi della Letteratura*: colloca il lavoro nel contesto della ricerca esistente su fenomeni correlati al mercato di Bitcoin e su modelli predittivi analoghi, evidenziando i punti di distacco rispetto alle scelte di questa tesi.
- *@sec-tecnologie Tecnologie utilizzate*: descrive le tecnologie usate nello sviluppo del progetto di tirocinio.
- *@sec-metodologia: Metodologia*: descrive le scelte progettuali e il loro razionale, dalla formulazione del problema alla validazione statistica dei risultati, indipendentemente dai dettagli implementativi.
- *@sec-implementazione: Implementazione*: descrive la traduzione in codice delle scelte metodologiche, per fase della pipeline (raccolta dati, feature engineering, addestramento, validazione, interpretabilità).
- *@sec-sperimentazione: Sperimentazione e risultati*: riporta i risultati ottenuti applicando la metodologia, corredati dalla relativa quantificazione dell'incertezza statistica.
- *@sec-conclusioni: Conclusioni*: risponde al problema di ricerca formulato in Introduzione, discute i contributi metodologici, i limiti dello studio e le direttrici di sviluppo futuro.


#pagebreak()

= Analisi della Letteratura <sec-analisi-lett>

Il presente capitolo colloca il lavoro di tesi nel contesto della letteratura esistente su due filoni di ricerca complementari: da un lato gli studi che analizzano fenomeni esterni (energetici, macroeconomici, geopolitici) correlati al comportamento del mercato di Bitcoin, dall'altro i lavori che propongono modelli predittivi diretti sul valore delle criptovalute, con o senza componente di _sentiment analysis_. La rassegna non ha finalità meramente ricognitiva infatti ogni contributo esaminato viene messo a confronto con le scelte progettuali della presente tesi, per motivarne l'impostazione e evidenziarne i punti di distacco rispetto ai limiti riscontrati. La spiegazione dettagliata di come queste differenze sono state implementate è rimandata alla @sec-metodologia (Metodologia), in questa sede si segnalano solo quali siano i punti di distacco.

Come anticipato nell'introduzione in @sec-intro, l'obiettivo della tesi è costruire una _pipeline_ riproducibile per la predizione della direzione settimanale del prezzo di Bitcoin, che integri il _sentiment_ estratto da _post_ Reddit tramite un modello linguistico con indicatori tecnici di mercato, metriche di _blockchain_ e un indice di _sentiment_ di mercato aggregato, sottoponendo i risultati ottenuti a una validazione statisticamente rigorosa. La rassegna che segue è organizzata in due sezioni: @sec-fenomeni-correlati esamina contributi che, pur non proponendo un modello predittivo, forniscono evidenze empiriche utilizzate per motivare l'inclusione di specifiche famiglie di _feature_ nella _pipeline_ sviluppata, @sec-modelli-pred esamina lavori con un impianto sperimentale direttamente comparabile a quello di questa tesi. Per ciascun contributo di quest'ultima categoria viene inoltre fornita una tabella di sintesi degli aspetti metodologici rilevanti, e una tabella comparativa conclusiva riassume l'intero gruppo (@tab-confronto-predittivi), includendo la presente tesi come termine di paragone.

== Fenomeni Correlati al Mercato BTC e Contesto Macroeconomico <sec-fenomeni-correlati>

I seguenti contributi non propongono modelli predittivi diretti sul valore del Bitcoin, ma forniscono evidenze empiriche su dinamiche esterne, energetiche, informative e geopolitiche, che influenzano il mercato e che vengono integrate come contesto fondazionale nella presente tesi.

=== Sapra et al. (2026) - [3]

==== Disamina del _paper_

Questo _paper_ esamina le relazioni dinamiche e non lineari tra il consumo di energia elettrica della rete Bitcoin, il prezzo dell'_asset_ e la volatilità complessiva del mercato delle criptovalute. Gli autori analizzano un _dataset_ di 1.761 osservazioni giornaliere (da marzo 2020 a gennaio 2025) combinando tecniche statistiche avanzate nei domini del tempo e della frequenza, come la _Biwavelet Coherence_ (*BWC*), la _Partial-Wavelet Transform Coherence_ (*PWC*) e i _test_ di causalità non lineare di Diks & Panchenko. L'indice utilizzato per stimare l'energia è il celebre *CBECI* (_Cambridge Bitcoin Electricity Consumption Index_). I risultati empirici rivelano un'importante asimmetria temporale: nel breve periodo, i movimenti di prezzo guidano il consumo energetico (poiché l'aumento dei prezzi rende il _mining_ più redditizio, attirando nuovi nodi computazionali) nel lungo periodo, tuttavia, si verifica una causalità inversa, in cui il consumo di elettricità e i costi infrastrutturali strutturali fungono da _driver_ e predittori per il valore intrinseco del Bitcoin.

==== Limitazioni e Differenze di Applicazione

Il lavoro si limita a presentare le relazioni di causalità tra il consumo di energia per "minare" Bitcoin e il valore stesso della criptovaluta senza porsi il problema della predizione e ignorando completamente altri componenti informative fondamentali come i vari indicatori tecnici di mercato visti prima.

==== Conclusioni

L'evidenza di causalità di lungo periodo qui riportata motiva l'inclusione, nella _pipeline_ sviluppata, di metriche legate al costo di produzione del Bitcoin come famiglia di _feature_ predittiva, accanto a quelle di natura più speculativa a breve termine. Il dettaglio di questa famiglia di _feature_ è presentato nel capitolo di Metodologia.

=== Liapis et al. (2021) - [4]

==== Disamina del _paper_

Questo contributo si configura come una rassegna sistematica e "multi-metodo" della letteratura scientifica riguardante l'integrazione della _Sentiment Analysis_ all'interno di modelli predittivi multivariati per serie temporali finanziarie. Gli autori mappano un vasto ecosistema di pubblicazioni, classificando i lavori in base a tre pilastri fondamentali: la fonte dei dati testuali (notizie giornalistiche, Twitter, Reddit, _blog_), le tecniche di *NLP* (_Natural Language Processing_) impiegate per l'estrazione del _sentiment_ (metodi lessicali basati su dizionari rispetto ad approcci di _Machine Learning_ e _Deep Learning_) e, infine, gli algoritmi di previsione finanziaria utilizzati (dai modelli statistici lineari tradizionali come *ARIMA*, fino ai regressori non lineari e alle reti neurali *LSTM*). La _survey_ dimostra empiricamente come l'inclusione del _sentiment_ esogeno migliori quasi sistematicamente le metriche predittive rispetto ai modelli basati esclusivamente su dati storici di prezzo, evidenziando tuttavia una forte frammentazione metodologica nella letteratura.

==== Limitazioni e Differenze di Applicazione

Trattandosi di un _survey_, il lavoro presenta dei limiti intrinsechi legati alla sua natura descrittiva:

- *Mancanza di un _framework_ sperimentale unificato*: Il _paper_ analizza e confronta i risultati di studi terzi, ciascuno condotto su _dataset_, archi temporali e mercati differenti. Di conseguenza, non fornisce un _benchmark_ volto a stabilire quale combinazione esatta di modello di _sentiment_ e classificatore sia la più efficiente a parità di condizioni di mercato.

- *Focalizzazione pre-*LLM* e mercati tradizionali*: Essendo stato pubblicato alla fine del 2021, la panoramica dei modelli di *NLP* si ferma alle prime architetture *BERT* o a classificatori classici (*SVM*, _Naive Bayes_), non coprendo l'evoluzione recente dei modelli di dominio avanzati come *FinBERT*, *LLM* classici o l'uso di _framework_ multi-agente. Inoltre, la stragrande maggioranza della letteratura censita si focalizza sui mercati azionari tradizionali, lasciando parzialmente scoperto il settore ad alta volatilità delle criptovalute.

==== Conclusioni

Il valore di questa _survey_ nel contesto del presente progetto è di tipo fondazionale e giustificativo. La tesi sfrutta le conclusioni macroscopiche di questo _paper_, in particolare l'evidenza che i modelli ibridi multivariati (con prezzo e _sentiment_) superano quelli univariati, per legittimare l'impostazione della presente tesi.

=== Gomes Jr. et al. (2024) - [10]

==== Disamina del _paper_

Questo _paper_ esamina l'impatto degli _shock_ geopolitici di vasta scala sul comportamento degli utenti all'interno delle _blockchain_ di Bitcoin ed Ethereum, focalizzandosi sulle fasi immediatamente precedenti e successive allo scoppio del conflitto russo-ucraino. Gli autori utilizzano un approccio basato su grafi dinamici variabili nel tempo (_time-varying graphs_) per modellare la rete delle transazioni _on-chain_ in un arco temporale critico di quattro settimane (due settimane prima e due settimane dopo l'inizio delle ostilità). L'obiettivo è analizzare la reattività della rete in una fase definita "acuta". I risultati empirici rivelano anomalie strutturali significative nel comportamento macroeconomico degli utenti: nella fase di pre-conflitto si registra un atteggiamento fortemente cauto e attendista (caratterizzato da una contrazione delle transazioni e da dinamiche di accumulazione), mentre nella fase post-conflitto si osserva un ritorno alla normalità nei volumi, ma con uno spostamento netto (_shift_) nelle traiettorie dei flussi di capitale e nella topologia della rete di trasferimento del valore.

==== Limitazioni e Differenze di Applicazione

Nonostante l'eccellente e rigorosa ricostruzione analitica delle dinamiche operate sui registri distribuiti, il lavoro evidenzia limiti sul piano della tempestività predittiva e algoritmica:

- *Analisi ex-post e focalizzazione esclusivamente _on-chain_*: Lo studio ricostruisce i comportamenti in modo puramente retrospettivo. Inoltre, basandosi solo sulle transazioni registrate sulla _blockchain_, non correla questi mutamenti strutturali con i flussi informativi esterni in tempo reale, come il _sentiment_ espresso dai media finanziari o dai _social network_ nelle ore esatte dello scoppio della crisi.

- *Assenza di finalità predittive e di moduli di _trading_*: Il _framework_ è di stampo prettamente analitico e sociologico-economico. Non traduce la categorizzazione del comportamento degli utenti in presenza di conflitti in _feature_ quantitative spendibili da un algoritmo di _Machine Learning_ per anticipare la direzione del _trend_ o per automatizzare decisioni di portafoglio.

Queste limitazioni sono prettamente dovute al fatto che il _paper_ non si occupa di informatica o _machine learning_ nello specifico ma di analisi sociologica-economica che si rivela comunque utile ai fini dello sviluppo del progetto di questa tesi.

==== Conclusioni

Il presente lavoro converte l'evidenza analitica ex-post qui riportata in un segnale predittivo operante in tempo reale, intercettando _shock_ geopolitici e la conseguente variazione di _sentiment_ pubblico direttamente nel vettore multivariato del modello, e validandone l'efficacia operativa tramite _backtesting_, due aspetti assenti nel lavoro analizzato. I dettagli implementativi sono presentati nel capitolo di Metodologia.

== Modelli Predittivi sul Valore delle Criptovalute <sec-modelli-pred>

I seguenti contributi propongono architetture di _machine learning_ o _deep learning_ per la predizione del valore di criptovalute, con o senza componente di _sentiment analysis_. Per facilitare il confronto, i lavori sono raggruppati in quattro categorie in base alla tecnica di estrazione del _sentiment_ e alla complessità del modello predittivo adottato: assenza di _sentiment_, _sentiment_ lessicale, _sentiment_ basato su Transformer / *BERT*, e architetture avanzate (reti ricorrenti e sistemi multi-agente basati su *LLM*). Ciascun contributo è seguito da una tabella riassuntiva degli aspetti metodologici chiave, inoltre una tabella comparativa generale è riportata al termine del gruppo.

=== Modelli senza componente di _sentiment_

==== Hafid et al. (2024) - [2]

===== Disamina del _paper_

Questo _paper_ descrive un modello di _Machine Learning_ di classificazione per predire il corso del mercato delle criptovalute allenato su dati storici e indicatori tecnici importanti quali _Moving Average Convergence Divergence_, _Relative Strength Index_ e _Bollinger Bands_. Il _paper_, inoltre, fa diverse simulazioni usando Matrici di Confusione e la curva _Receiver Operating Characteristic_ per determinare la _performance_ del modello risultando in una accuratezza dei segnali _Buy_/_Sell_ di oltre il 92%. Il _paper_, inoltre, illustra il diagramma del _research process_ composto da 8 fasi: \

+ _Research Problem_: Fase di ricerca del problema e delle fonti di dati da prendere per risolverlo.
+ _Data Collection_: I dati riguardano lo storico dei prezzi del Bitcoin presi tramite *API* della piattaforma Binance che coprono il periodo 01/02/2021 - 01/02/2022 con un intervallo di tempo di 15 minuti per maggiore accuratezza in un mercato altamente volatile come quello del Bitcoin.
+ _Feature Engineering_: Il modello utilizza dati storici di mercato e indicatori tecnici quali _Bollinger Bands_, _Average True Range_, _Commodity Channel Index_, _Williams %R_, _Chaikin Money Flow_, _On-Balance Volume_, _Moving Average Convergence Divergence_, _Accumulation_/_Distribution Line_.
+ _Data Preprocessing_: I dati vengono scalati usando lo *StandardScaler* della libreria *scikit-learn*. Inoltre i dati sono divisi in due parti in modo _percentage-based_ dove l'80% lo si dedica al _training_ e il 20% al _testing_.
+ _Feature Selection_: Il modello utilizza il $\u{03A7}^2$ come funzione di _scoring_ per selezionare le $k=8$ migliori _feature_ (ovvero gli indicatori tecnici elencati prima) e ottimizza il _feature vector_.
+ _Training *XGBoost*_: Il modello, dopo aver ottimizzato la _cost function_ del *XGBoost* nella fase di _feature selection_ di prima, la minimizza usando l'algoritmo di _gradient boosting_.
+ _Evaluation_: Le _performance_ sono state analizzate tramite varie metriche quali la precisione, accuratezza e la curva *ROC*.
+ _Result Analysis_: I risultati riportati dal modello denotano una accuratezza del 92.4% utilizzando il regressore *XGBoost*, rispetto ad un approccio con _Logistic Regression_ che riporta una precisione del 91.01% e generalmente dei risultati migliori in tutti i parametri di _performance_ analizzati dal _paper_.

===== Limitazioni e Differenze di Applicazione

Nonostante l'elevata accuratezza statistica dichiarata, l'impianto metodologico presenta alcuni limiti critici se traslato in un contesto di operatività reale sul lungo periodo:

- *Assenza di Fattori Esterni*: Il modello si basa esclusivamente su informazioni di mercato (prezzo e volume tradotti in indicatori tecnici). Di conseguenza, ignora completamente l'impatto di _shock_ esterni, notizie macroeconomiche o variazioni repentine del _sentiment_ sui canali informativi, elementi che nel mercato delle criptovalute agiscono spesso da catalizzatori primari per i cambi di _trend_.

- *Granularità Estrema e Rischio di _Overfitting_*: L'orizzonte temporale a 15 minuti, limitato a un solo anno di storico (2021-2022), tende a catturare il rumore microscopico del mercato. Questa impostazione spiega l'accuratezza insolitamente elevata (oltre il 92%), la quale tuttavia rischia di non essere generalizzabile su archi temporali più estesi o di soffrire di fenomeni di _data leakage_ impliciti nella _cross-validation_ standard di serie temporali ad alta frequenza.

===== Conclusioni

Il presente lavoro conferma l'efficacia del classificatore adottato in questo _paper_ rispetto ad approcci lineari più semplici, ma ne corregge l'impostazione su due aspetti: un orizzonte temporale meno esposto a rumore e _overfitting_, e un vettore di _feature_ arricchito con una componente testuale, assente nel lavoro originale. I dettagli di queste scelte sono discussi nella @sec-metodologia relativa alla "Metodologia". Gli aspetti metodologici chiave del _paper_ sono riassunti nella @tab-hafid.

#figure(
  caption: [Riepilogo metodologico, Hafid et al. (2024) [2]],
  table(
    columns: (5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Bitcoin (*BTC*)],
    [*Modello NLP*], [Nessuno, solo indicatori tecnici di mercato],
    [*Tipo NLP*], [Non applicabile],
    [*Modello predittivo*], [*XGBoost* (classificatore binario _Buy_/_Sell_)],
    [*Feature utilizzate*], [BB, ATR, CCI, Williams %R, CMF, OBV, *MACD*, A/D Line (k=8 via $chi^2$)],
    [*Granularità temporale*], [15 minuti (1 anno di storico: 2021–2022)],
    [*Backtesting*], [No (solo metriche statistiche: Accuracy, *ROC*)],
    [*Interpretabilità*], [No (_feature importance_ non discussa)],
    [*Costo computazionale*], [*Basso*, *XGBoost* locale su dati tabulari],
    [*Accuratezza dichiarata*], [92.4% (*XGBoost*) vs 91.01% (_Logistic Regression_)],
  ),
) <tab-hafid>

=== Modelli con _sentiment_ lessicale (dizionari)

==== Kaur et al. (2025) - [7]

===== Disamina del _paper_

Questo studio analizza la capacità predittiva dei _post_ di Twitter nel determinare le fluttuazioni quotidiane dei rendimenti di Bitcoin. Gli autori raccolgono un _dataset_ di _tweet_ a tema criptovalute e utilizzano la libreria lessicale *TextBlob* per l'estrazione e la classificazione del _sentiment_ (positivo, negativo, neutro). Una volta calcolati i punteggi di _sentiment_, questi vengono integrati con le variazioni storiche del prezzo di Bitcoin per addestrare ed effettuare un confronto tra diversi classificatori di _Machine Learning_ tradizionali: _Support Vector Machines_ (*SVM*), _Random Forest_, _Naive Bayes_ e _K-Nearest Neighbors_ (*KNN*). I risultati empirici evidenziano come i modelli come _Random Forest_ riescano a catturare parzialmente la direzione del _trend_ di mercato, confermando l'esistenza di un legame tra l'opinione pubblica sui _social media_ e i movimenti di prezzo dell'_asset_.

===== Limitazioni e Differenze di Applicazione

L'approccio metodologico di questo _paper_ presenta alcune limitazioni strutturali legate all'anzianità degli strumenti di *NLP* e all'orizzonte di validazione:

- *Inadeguatezza del modello NLP lessicale (*TextBlob*)*: L'utilizzo di *TextBlob* rappresenta un limite critico nel contesto finanziario. Essendo un dizionario lessicale generico, non è in grado di cogliere l'ironia, il contesto o il gergo specifico del mercato crittografico generando un segnale di _sentiment_ piatto o distorto.

- *Mancanza di indicatori tecnici complessi e simulazione economica*: I classificatori vengono addestrati unicamente sull'interazione tra _sentiment_ grezzo e prezzo di chiusura, tralasciando indicatori macro-strutturali o di analisi tecnica (*RSI*, *MACD*, _Bollinger Bands_). Inoltre, il lavoro si ferma alle metriche di classificazione pura (_Accuracy_, _Precision_), omettendo un ambiente di _backtesting_ che verifichi l'effettiva profittabilità finanziaria dei segnali generati.

===== Conclusioni

La presente tesi migliora l'approccio di questo _paper_ su due fronti: un'estrazione del _sentiment_ basata su un modello linguistico contestuale anziché su un dizionario statico, e una validazione più completa, comprensiva di una simulazione operativa di _backtesting_ assente nel lavoro originale. I dettagli sono discussi nel capitolo di Metodologia. Gli aspetti metodologici chiave del _paper_ sono riassunti nella Tabella @tab-kaur.

#figure(
  caption: [Riepilogo metodologico, Kaur et al. (2025) [7]],
  table(
    columns: (5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Bitcoin (*BTC*)],
    [*Modello NLP*], [*TextBlob* (dizionario lessicale generico)],
    [*Tipo NLP*], [Modello a dizionario (lessicale)],
    [*Modello predittivo*], [*SVM*, _Random Forest_, _Naive Bayes_, *KNN*],
    [*Feature utilizzate*], [Punteggi *TextBlob* + variazioni storiche prezzo *BTC* (Twitter)],
    [*Granularità temporale*], [Giornaliera],
    [*Backtesting*], [No (solo Accuracy e Precision)],
    [*Interpretabilità*], [No],
    [*Costo computazionale*], [*Molto basso*, classificatori classici su dati tabulari leggeri],
    [*Accuratezza dichiarata*], [_Random Forest_ migliore tra i classificatori (valore esatto non riportato)],
  ),
) <tab-kaur>

==== Vijayakumar et al. (2023) - [8]

===== Disamina del _paper_

Questo contributo investiga l'impatto diretto dei flussi comunicativi generati dai cosiddetti _Key Opinion Leaders_ (*KOL*) sulla volatilità e sulle variazioni di prezzo delle criptovalute. Nello specifico, gli autori esaminano la correlazione tra i _tweet_ di Elon Musk e le oscillazioni di prezzo di Dogecoin (*DOGE*). Il _framework_ si avvale di due motori di *NLP* classici per l'estrazione della polarità del testo, mettendone a confronto i risultati: *TextBlob* e *VADER* (_Valence Aware Dictionary and Sentiment Reasoner_). I punteggi di _sentiment_ ottenuti vengono poi sovrapposti temporalmente alle serie storiche di Dogecoin per misurare l'effetto di _shock_ esterni concentrati. I risultati empirici confermano che i _tweet_ positivi o ironici del multimiliardario agiscono da catalizzatori immediati, innescando fiammate rialziste nel volume di _trading_ e nel valore dell'_asset_, evidenziando l'estrema sensibilità del comparto _crypto_ a singoli attori di rilievo.

===== Limitazioni e Differenze di Applicazione

Nonostante l'efficacia nel dimostrare il fenomeno della manipolazione o dell'influenza mediatica concentrata, l'approccio di questo _paper_ mostra limiti evidenti sul piano della generalizzabilità algoritmica:

- *Focalizzazione su un singolo _asset_ speculativo (_Meme Coin_)*: Dogecoin è una _meme coin_ la cui capitalizzazione risente in modo anomalo della componente speculativa e sociale, rendendo i risultati difficilmente estendibili ad _asset_ strutturati e a grandissima capitalizzazione come Bitcoin, i quali rispondono a dinamiche macroeconomiche e di mercato molto più complesse.

- *Modelli NLP non contestuali e assenza di _Machine Learning_*: L'adozione di *VADER* e *TextBlob*, pur adatta a catturare stringhe testuali brevi, soffre dell'assenza di una comprensione semantica profonda dei _Transformer_. Inoltre, lo studio si limita a mappare una correlazione ex-post, senza addestrare un classificatore predittivo (come *XGBoost*) e senza testare l'efficacia dei segnali in una strategia di _trading_ formalizzata.

===== Conclusioni

La presente tesi evolve l'intuizione di questo _paper_ sul peso dei flussi informativi verso un impianto più generalizzabile: da un singolo _account_ su una _meme coin_ a un aggregato di canali distribuiti su Bitcoin, e da una correlazione ex-post a un classificatore predittivo validato tramite _backtesting_. I dettagli sono discussi nel capitolo di Metodologia. Gli aspetti metodologici chiave del _paper_ sono riassunti nella Tabella @tab-vijayakumar.

#figure(
  caption: [Riepilogo metodologico, Vijayakumar et al. (2023) [8]],
  table(
    columns: (5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Dogecoin (*DOGE*), _meme coin_],
    [*Modello NLP*], [*TextBlob* e *VADER* (dizionari lessicali)],
    [*Tipo NLP*], [Modello a dizionario (lessicale)],
    [*Modello predittivo*], [Nessuno, solo analisi di correlazione ex-post],
    [*Feature utilizzate*], [_Tweet_ di Elon Musk + serie storiche prezzo *DOGE*],
    [*Granularità temporale*], [Non specificata (probabilmente giornaliera/_intraday_)],
    [*Backtesting*], [No],
    [*Interpretabilità*], [No],
    [*Costo computazionale*], [*Molto basso*, dizionari statici senza _training_],
    [*Accuratezza dichiarata*], [Non applicabile (studio correlazionale, non predittivo)],
  ),
) <tab-vijayakumar>

==== Sattarov et al. (2020) - [9]

===== Disamina del _paper_

Questo studio analizza la capacità predittiva dei flussi di opinione di Twitter in merito alle fluttuazioni quotidiane del prezzo di Bitcoin, proponendo un approccio innovativo per l'anno di pubblicazione del _paper_. Gli autori estraggono un _dataset_ di _tweet_ legati all'ecosistema delle criptovalute e utilizzano il modulo *VADER* (_Valence Aware Dictionary and Sentiment Reasoner_), integrato nella libreria *NLTK*, per quantificare la polarità dei testi (positiva, negativa, neutra). Successivamente, combinando i punteggi di _sentiment_ aggregati giornalmente con la serie storica dei prezzi di chiusura dell'_asset_, gli autori addestrano e confrontano modelli di _Machine Learning_ tradizionali, tra cui _Support Vector Machines_ (*SVM*) e modelli di regressione lineare. I risultati empirici dimostrano che il _sentiment_ dei _social media_ possiede un effettivo potere predittivo, consentendo al _framework_ di raggiungere un'accuratezza del 62.48% nella classificazione della direzione del prezzo su base giornaliera.

===== Limitazioni e Differenze di Applicazione

L'impianto metodologico del lavoro risente inevitabilmente dell'anzianità della sua pubblicazione, mostrando limiti evidenti se confrontato con gli standard attuali:

- *Dipendenza da modelli NLP lessicali statici*: L'affidamento esclusivo su *VADER* rappresenta un forte limite intrinseco. Essendo un analizzatore basato su regole e dizionari linguistici statici, non è in grado di decodificare la semantica contestuale profonda, i neologismi, il sarcasmo o il gergo finanziario specialistico tipico della _community crypto_. Questo causa un'elevata percentuale di classificazione errata o neutrale di _tweet_ fortemente orientati.

- *Vettore di _feature_ minimale e assenza di _Backtesting_*: Il modello predittivo si basa esclusivamente sulla combinazione bivariata _Sentiment_-Prezzo storico. Viene del tutto trascurata l'integrazione di indicatori di analisi tecnica (come *RSI* o *MACD*) e di metriche macro-strutturali. Inoltre, il lavoro convalida i risultati solo tramite metriche di classificazione statistica pura (_Accuracy_), omettendo una simulazione di _trading_ reale che ne attesti la profittabilità economica al netto dei costi di transazione.

===== Conclusioni

Il presente lavoro adotta questo _paper_ come _baseline_ storica, rivoluzionandone l'architettura su tre fronti: un'estrazione del _sentiment_ contestuale anziché lessicale, un vettore di _feature_ multivariato anziché bivariato, e una validazione economica tramite _backtesting_ anziché la sola accuratezza statistica. I dettagli sono discussi nel capitolo di Metodologia. Gli aspetti metodologici chiave del _paper_ sono riassunti nella Tabella @tab-sattarov.

#figure(
  caption: [Riepilogo metodologico, Sattarov et al. (2020) [9]],
  table(
    columns: (5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Bitcoin (*BTC*)],
    [*Modello NLP*], [*VADER* (dizionario lessicale, libreria *NLTK*)],
    [*Tipo NLP*], [Modello a dizionario (lessicale)],
    [*Modello predittivo*], [*SVM* e regressione lineare],
    [*Feature utilizzate*], [Punteggi *VADER* aggregati giornalmente + prezzo di chiusura *BTC*],
    [*Granularità temporale*], [Giornaliera],
    [*Backtesting*], [No (solo Accuracy statistica)],
    [*Interpretabilità*], [No],
    [*Costo computazionale*], [*Molto basso*, *SVM* su _feature_ bivariata],
    [*Accuratezza dichiarata*], [62.48% nella classificazione della direzione del prezzo],
  ),
) <tab-sattarov>

=== Modelli con _sentiment_ basato su Transformer / BERT

==== Anand et al. (2024) - [6]

===== Disamina del _paper_

Questo _paper_ presenta un'analisi empirica e comparativa sull'efficacia di diversi strumenti di _Sentiment Analysis_, sia lessicali che basati su architetture _Transformer_ di _Deep Learning_, nel determinare la correlazione tra il _sentiment_ del pubblico e le fluttuazioni di prezzo delle criptovalute, con un focus verticale su Bitcoin. Gli autori mettono a confronto diretto quattro modelli speculativi: *VADER* e *SenticNet* (approcci basati su dizionari), e *FinBERT* e *CryptoBERT* (modelli pre-addestrati basati su *BERT* e specializzati rispettivamente nel dominio finanziario e crittografico). Inoltre, il _paper_ illustra il _fine-tuning_ di un modello *DistilBERT* per catturare le relazioni non lineari tra il testo e i _trend_ di mercato, riportando un coefficiente di correlazione estremamente elevato, pari a 0.88, tra il _sentiment_ aggregato e i movimenti di prezzo.

===== Limitazioni e Differenze di Applicazione

Sebbene il contributo fornisca una validazione cruciale sull'uso di modelli _domain-specific_ (come *FinBERT* e *CryptoBERT*) rispetto a quelli generalisti, esso evidenzia due limiti sul piano dell'architettura predittiva complessiva:

- *Mancanza di un modello di classificazione e _machine learning_ a valle*: Il _paper_ si ferma a un'analisi di tipo puramente statistico e correlazionale. Gli autori dimostrano che esiste un forte legame matematico tra l'andamento del _sentiment_ e quello del prezzo, ma non utilizzano questo segnale come _feature_ di input per addestrare un algoritmo predittivo o di classificazione.

- *Assenza di indicatori tecnici e modulo di Backtesting*: L'analisi si concentra esclusivamente sulla componente testuale esterna. Ignorando gli indicatori di mercato interni (*RSI*, *MACD*) e non traducendo le decisioni in una simulazione di _trading_ reale (_backtesting_), il _framework_ non è in grado di misurare la sostenibilità economica o il rischio finanziario (_Sharpe Ratio_, _Drawdown_) delle metriche estratte.

===== Conclusioni

Il presente lavoro si configura come l'estensione applicativa dei risultati di questo _paper_: la correlazione _sentiment_-prezzo qui dimostrata viene tradotta in una _feature_ di input per un classificatore predittivo, integrata con indicatori tecnici e dati energetici, e le decisioni risultanti vengono validate tramite _backtesting_, aspetti entrambi assenti nel lavoro originale. I dettagli sono discussi nel capitolo di Metodologia. Gli aspetti metodologici chiave del _paper_ sono riassunti nella Tabella @tab-anand.

#figure(
  caption: [Riepilogo metodologico, Anand et al. (2024) [6]],
  table(
    columns: (5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Bitcoin (*BTC*) e altre criptovalute],
    [*Modello NLP*], [*VADER*, *FinBERT*, *CryptoBERT*, *DistilBERT* (Transformer)],
    [*Tipo NLP*], [Ibrido: modelli a dizionario + *LLM* _domain-specific_ (_BERT-based_)],
    [*Modello predittivo*], [Nessuno, solo analisi correlazionale],
    [*Feature utilizzate*], [Punteggi di _sentiment_ aggregati da fonti testuali _crypto_],
    [*Granularità temporale*], [Non specificata],
    [*Backtesting*], [No],
    [*Interpretabilità*], [No (correlazione statistica, non spiegazione causale)],
    [*Costo computazionale*], [*Medio*, inferenza *BERT* / *DistilBERT*, _fine-tuning_ locale],
    [*Accuratezza dichiarata*], [Correlazione _sentiment_-prezzo: r = 0.88 (*DistilBERT* _fine-tuned_)],
  ),
) <tab-anand>

=== Architetture avanzate: reti ricorrenti e sistemi multi-agente LLM

==== Manogna et al. (2023) - [5]

===== Disamina del _paper_

Questo studio propone un _framework_ predittivo a breve termine per i movimenti di prezzo di Bitcoin focalizzandosi sull'estrazione del _sentiment_ in tempo reale dalla piattaforma _social_ Twitter (tramite Twitter *API*) in combinazione con i dati storici di prezzo di CoinMarketCap. Gli autori estraggono le metriche testuali grezze e utilizzano tecniche di _Natural Language Processing_ (*NLP*) per calcolare i punteggi di _sentiment_ (positivo, negativo, neutro). Successivamente, integrano questi dati con lo storico dei prezzi per addestrare modelli di _Deep Learning_ sequenziali, nello specifico reti _Long Short-Term Memory_ (*LSTM*) e _Bidirectional Gated Recurrent Units_ (*BiGRU*). I risultati empirici del _paper_ evidenziano come i modelli basati su reti neurali ricorrenti beneficino sensibilmente dell'aggiunta del _sentiment_ dei _social media_, ottenendo un'elevata precisione nel catturare le fluttuazioni di prezzo giornaliere rispetto ai modelli statistici tradizionali.

===== Limitazioni e Differenze di Applicazione

L'approccio adottato in questo _paper_, pur confermando la reattività del prezzo di Bitcoin ai flussi informativi dei _social_, presenta limiti rilevanti sotto il profilo della stabilità e dell'interpretabilità:

- *Elevato rumore e volatilità dei dati _social_*: L'affidamento esclusivo su Twitter introduce una massiccia quantità di rumore di fondo (_spam_, _bot_, _post_ speculativi o manipolatori). Questa reattività estrema rende il modello adatto principalmente a predizioni su brevissimo termine (giornaliero o intra-giornaliero), ma altamente instabile se applicato a strategie di investimento con un orizzonte temporale più esteso.

- *Natura "_Black Box_" del _Deep Learning_*: L'utilizzo di architetture *LSTM* e *BiGRU* preclude una reale comprensione delle dinamiche interne del modello. Gli autori non integrano strumenti quantitativi di spiegazione algoritmica, rendendo impossibile stabilire in che misura esatta il _sentiment_ pesi sulla decisione finale rispetto ai _trend_ storici del prezzo.

===== Conclusioni

Il presente lavoro conferma l'utilità del _sentiment_ dei _social_ evidenziata da questo _paper_, correggendone i limiti su tre fronti: un orizzonte settimanale anziché giornaliero, meno esposto alla volatilità frenetica dei singoli _post_, un modello predittivo interpretabile anziché una rete neurale _black-box_, e l'integrazione di fonti aggiuntive oltre al solo _sentiment_ testuale. I dettagli sono discussi nel capitolo di Metodologia. Gli aspetti metodologici chiave del _paper_ sono riassunti nella Tabella @tab-manogna.

#figure(
  caption: [Riepilogo metodologico, Manogna et al. (2023) [5]],
  table(
    columns: (5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Bitcoin (*BTC*)],
    [*Modello NLP*], [Tecniche NLP non specificate (_pipeline_ classica di classificazione del testo)],
    [*Tipo NLP*], [NLP classico (non *LLM*, non dizionario, probabile *TF-IDF* o simile)],
    [*Modello predittivo*], [*LSTM* e *BiGRU* (reti neurali ricorrenti)],
    [*Feature utilizzate*], [Punteggi di _sentiment_ da Twitter + storico prezzi (CoinMarketCap)],
    [*Granularità temporale*], [Giornaliera],
    [*Backtesting*], [No (solo metriche di classificazione)],
    [*Interpretabilità*], [Nessuna (_black-box_ neurale)],
    [*Costo computazionale*], [*Medio-alto*, _training_ *LSTM* / *BiGRU* richiede *GPU* ],
    [*Accuratezza dichiarata*], [Elevata precisione nelle fluttuazioni giornaliere (valore esatto non riportato)],
  ),
) <tab-manogna>

==== Xiao et al. (2024) - [1]

===== Disamina del _paper_

Questo _paper_ introduce un _framework_ di _trading_ algoritmico innovativo che utilizza una società di Agenti alimentati da _Large Language Models_ nel tentativo di simulare e replicare le dinamiche collaborative e gerarchiche di una vera e propria società d'investimento. Il sistema non si affida a un singolo modello, ma frammenta il problema assegnando ruoli specializzati a diversi agenti: analisti fondamentali, analisti tecnici, analisti del _sentiment_, ricercatori macroeconomici (divisi in fazioni _Bull_ e _Bear_ per stimolare il dibattito), un _team_ di _risk management_ e, infine, un modulo _Trader_ che sintetizza i _report_ e prende la decisione finale di investimento. Gli esperimenti condotti dagli autori mostrano prestazioni eccellenti rispetto alle _baseline_ tradizionali, evidenziando netti miglioramenti nelle metriche finanziarie chiave come il rendimento cumulativo, lo _Sharpe Ratio_ e il _Maximum Drawdown_.

===== Limitazioni e Differenze di Applicazione

Il _framework_ presenta tre limiti strutturali significativi se analizzato in un'ottica di sostenibilità e applicabilità reale:

- *Complessità Computazionale e Costi*: L'architettura multi-agente richiede continui scambi di _prompt_, "dibattiti" testuali e passaggi di memoria tra decine di istanze di *LLM*. Questo approccio genera un consumo di _token_ e una richiesta di potenza computazionale massiccia, rendendo il sistema estremamente costoso, lento nell'esecuzione e dipendente da *API* commerciali esterne non replicabili localmente su infrastrutture standard.

- *Focus sul Mercato Azionario Tradizionale*: Il modello è nativamente progettato e testato sulle azioni tradizionali (il _paper_ menziona ad esempio l'analisi fondamentale su titoli azionari come *AAPL*), dove i _report_ finanziari, i bilanci trimestrali e le metriche macroeconomiche classiche hanno un peso preponderante. Questo impianto si adatta male alla natura stocastica, altamente speculativa e priva di bilanci societari tipica del mercato delle criptovalute.

- *Opacità della Sintesi Decisionale (Effetto _Black-Box_)*: Sebbene la separazione dei ruoli simuli la trasparenza, la decisione finale del _Trader agent_ avviene attraverso la generazione di testo libero da parte dell'*LLM*. Manca un'ispezione matematica quantitativa (come i valori *SHAP*) in grado di isolare l'esatto peso statistico di un indicatore tecnico rispetto a una notizia di _sentiment_.

===== Conclusioni

Il presente lavoro si distingue da questo approccio per la scelta di un'architettura più snella e mirata al dominio di interesse: un singolo modello linguistico specializzato per l'estrazione del _sentiment_, combinato con un classificatore efficiente e interpretabile, anziché un sistema multi-agente generico e computazionalmente oneroso. Anche il problema dell'opacità decisionale, qui affrontato tramite un'analisi di interpretabilità quantitativa, viene risolto in modo diverso rispetto alla sintesi testuale libera adottata da questo _framework_. I dettagli implementativi di queste scelte sono presentati nel capitolo di Metodologia. Gli aspetti metodologici chiave del _paper_ sono riassunti nella @tab-xiao.

#figure(
  caption: [Riepilogo metodologico, Xiao et al. (2024) [1]],
  table(
    columns: (4.5cm, 8cm),
    align: (left + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*Aspetto*], [*Dettaglio*]),
    [*Asset target*], [Azioni tradizionali (es. *AAPL*), non _crypto_],
    [*Modello NLP*], [*LLM* generici multi-agente (_GPT-class_), nessun modello a dizionario],
    [*Tipo NLP*], [*LLM* (generativo, basato su Transformer)],
    [*Modello predittivo*], [Agente _Trader_ *LLM* (sintesi testuale libera)],
    [*Feature utilizzate*], [Report fondamentali, dati tecnici, _sentiment_, macro, tutto via _prompt_],
    [*Granularità temporale*], [Non specificata (operatività giornaliera)],
    [*Backtesting*], [Sì (rendimento cumulativo, Sharpe Ratio, Max Drawdown)],
    [*Interpretabilità*], [Nessuna (_black-box_ testuale)],
    [*Costo computazionale*], [*Molto elevato*, decine di istanze *LLM* in parallelo, dipendenza da *API* commerciali],
    [*Accuratezza dichiarata*], [Superiore alle _baseline_ tradizionali (metriche finanziarie)],
  ),
) <tab-xiao>

=== Tabella Comparativa dei Paper con Modelli Predittivi

La @tab-confronto-predittivi riassume e mette a confronto i principali _paper_ con approccio predittivo sul valore di criptovalute analizzati in questa sezione, includendo la presente tesi come termine di paragone metodologico.

#set table(inset: 6pt)
#figure(
  caption: [Confronto di metodo tra i _paper_ predittivi su criptovalute],
  table(
    columns: (2cm, 1.8cm, 2.5cm, 2cm, 3.1cm, 2.8cm, 2cm),
    align: center + horizon,
    fill: unipd-table-fill,
    table.header([*Paper*], [*Asset*], [*Modello NLP*], [*Tipo NLP*], [*Classificatore*], [*Backtesting*], [*Interp.*]),
    [Hafid [2]], [*BTC*], [Nessuno], [N/A], [*XGBoost*], [No], [No],
    [Kaur [7]], [*BTC*], [*TextBlob*], [Dizionario], [*SVM*, RF,\ NB, *KNN*], [No], [No],
    [Vijayak. [8]], [*DOGE*], [*TextBlob*,\ *VADER*], [Dizionario], [Nessuno\ (correlaz.)], [No], [No],
    [Sattarov [9]], [*BTC*], [*VADER*], [Dizionario], [*SVM*,\ Regressione], [No], [No],
    [Anand [6]],
    [BTC/_Crypto_],
    [*VADER*, *SenticNet*,\ *FinBERT*, *CryptoBERT*],
    [Dizionario\ + *LLM*],
    [Nessuno\ (correlaz.)],
    [No],
    [No],
    [Manogna [5]], [*BTC*], [NLP classico\ (non specif.)], [Probabilm.\ *TF-IDF*], [*LSTM*,\ *BiGRU*], [No], [No],
    [Xiao [1]], [Azioni], [*LLM* multi-agente\ (*GPT*-class)], [*LLM*], [Agente *LLM*\ (testo libero)], [Sì], [No],
    table.cell(fill: unipd-red-dark)[*Questa\ tesi*],
    table.cell(fill: unipd-red-dark)[*BTC*],
    table.cell(fill: unipd-red-dark)[*Gemini\ 3.1\ flash-lite*],
    table.cell(fill: unipd-red-dark)[*LLM*],
    table.cell(fill: unipd-red-dark)[*XGBoost*],
    table.cell(fill: unipd-red-dark)[*Sì*],
    table.cell(fill: unipd-red-dark)[*Sì*],
  ),
) <tab-confronto-predittivi>

==== Discussione

Dal confronto sintetizzato nella Tabella @tab-confronto-predittivi emergono tre osservazioni rilevanti per collocare la presente tesi rispetto allo stato dell'arte.

In primo luogo, si osserva una relazione inversa tra sofisticazione del modello NLP e completezza della validazione: i lavori che adottano tecniche di _sentiment analysis_ più avanzate (*LLM* multi-agente in Xiao [1], modelli Transformer in Anand [6]) tendono a non tradurre il segnale estratto in un classificatore predittivo validato economicamente, mentre i lavori con un impianto predittivo più semplice (Hafid [2], Kaur [7], Sattarov [9]) si affidano a un'estrazione del _sentiment_ lessicale o ne fanno del tutto a meno. Nessuno dei contributi esaminati combina un'estrazione del _sentiment_ allo stato dell'arte con un classificatore addestrato, un _backtesting_ economico e un'analisi di interpretabilità: è esattamente questa combinazione che la presente tesi propone di colmare, come evidenziato dall'ultima riga della tabella.

In secondo luogo, l'interpretabilità risulta la dimensione più trascurata in assoluto: nessuno dei sette lavori a confronto la implementa, incluso il _framework_ multi-agente di Xiao [1], che pure dispone della maggiore complessità architetturale. Questo conferma come l'integrazione di _Feature Importance_ e valori *SHAP*, discussa nel capitolo di Metodologia, non sia un dettaglio marginale ma un contributo distintivo rispetto all'insieme dei lavori esaminati.

In terzo luogo, un limite trasversale non rilevabile dalla tabella, ma emerso dalla lettura dei singoli contributi, riguarda la granularità temporale: la maggior parte dei lavori opera su base giornaliera o inferiore (Hafid [2] a 15 minuti, Kaur [7] e Sattarov [9] su base giornaliera), un orizzonte che, come discusso nelle rispettive analisi dei limiti, espone a un rischio elevato di catturare rumore di mercato anziché un segnale genuino. Nessuno dei lavori esaminati riporta inoltre una quantificazione esplicita dell'incertezza statistica associata alle proprie metriche di accuratezza, un vuoto metodologico comune all'intero campione che la presente tesi affronta esplicitamente tramite la validazione _bootstrap_ descritta nel capitolo di Metodologia.
#set table(inset: 9pt)

#pagebreak()

= Tecnologie utilizzate <sec-tecnologie>

In questa sezione vengono descritti gli strumenti e le librerie utilizzati per lo sviluppo della _pipeline_.

== Strumenti di sviluppo

=== Visual Studio Code

Visual Studio Code (VS Code) è stato utilizzato come editor principale per lo sviluppo dei moduli Python della _pipeline_ (`DataIngestor`, `SentimentEngine`), grazie al supporto nativo per Python, al _debugging_ integrato e all'integrazione con il terminale.

=== Jupyter Notebook

Jupyter Notebook è stato impiegato per orchestrare l'esecuzione della _pipeline_ (raccolta dati, _feature engineering_, addestramento, validazione), permettendo di combinare in un unico documento codice eseguibile, testo esplicativo e visualizzazioni grafiche, ed eseguire singole fasi in modo incrementale durante lo sviluppo e la sperimentazione.

== Linguaggio di programmazione

=== Python 3

Python 3 è il linguaggio principale del progetto, scelto per l'ecosistema maturo di librerie open source dedicate alla _data science_ e al _machine learning_, e per la sua ampia adozione nella letteratura di riferimento (capitolo 3).

== Librerie per la gestione e l'analisi dei dati

=== Pandas

Pandas è la libreria principale per la lettura, l'elaborazione e la manipolazione dei dati provenienti dalle diverse fonti (quotazioni di mercato, metriche _on-chain_, _post_ Reddit), tutte rappresentate tramite la struttura `DataFrame`. Le operazioni di ricampionamento temporale (`resample`), le trasformazioni causali (`rolling`, `ewm`, `shift`, `pct_change`) e le operazioni di _join_ tra le diverse fonti dati sono implementate interamente tramite questa libreria.

=== NumPy

NumPy fornisce le strutture dati array e le funzioni numeriche di base su cui sono costruite le trasformazioni statistiche della _pipeline_ (es. calcolo di percentili nel _bootstrap_, operazioni vettoriali sulle predizioni del modello).

=== _scikit-learn_

_scikit-learn_ è stata utilizzata per l'ottimizzazione degli iperparametri (`RandomizedSearchCV`) e per la validazione incrociata rispettosa dell'ordine temporale (`TimeSeriesSplit`), oltre che per il calcolo delle metriche di classificazione (_accuracy_, _precision_, _recall_, F1-_score_, *AUC*).

=== _statsmodels_

_statsmodels_ è stata impiegata per la diagnostica statistica del _walk-forward_: il calcolo e la visualizzazione del correlogramma (`plot_acf`) e il test di Ljung-Box (`acorr_ljungbox`), utilizzati per verificare l'assenza di autocorrelazione residua nelle predizioni del modello (sezione @sec-quant-incertezza).

=== XGBoost

*XGBoost* è la libreria che implementa l'algoritmo di classificazione adottato come modello predittivo principale (sezione @sec-metodologia), scelta per l'efficienza computazionale e per i meccanismi di regolarizzazione nativi.

=== SHAP

La libreria *SHAP* implementa il metodo di interpretabilità omonimo, utilizzato tramite l'_explainer_ specializzato per modelli ad alberi (`TreeExplainer`) per calcolare il contributo di ciascuna _feature_ alle singole predizioni del modello (sezione @sec-interpretabilita).

=== _requests_

La libreria _requests_ è stata utilizzata per tutte le chiamate alle *API* esterne della _pipeline_ di raccolta dati (Reddit tramite arctic-shift, CoinMetrics, blockchain.info, _alternative.me_).


==== Arctic Shift

Arctic Shift è un'*API* pubblica non ufficiale che fornisce accesso a un archivio storico di _post_ e commenti Reddit, utilizzata per raccogliere il campione testuale su cui viene poi calcolato il _sentiment_ (metodo `fetch_arctic_shift_feed`, sezione @sec-implementazione). A differenza dell'*API* ufficiale di Reddit, non richiede autenticazione né l'iscrizione a un programma per sviluppatori, e restituisce risultati filtrabili per intervallo temporale e punteggio minimo del _post_.

=== _yfinance_

_yfinance_ fornisce l'accesso ai dati di mercato storici di Bitcoin (quotazioni *OHLCV*) tramite l'*API* non ufficiale di Yahoo Finance.

=== _google-genai_

La libreria ufficiale _google-genai_ è stata utilizzata per l'integrazione con il modello linguistico Gemini, impiegato per la classificazione del _sentiment_ dei _post_ raccolti (sezione @sec-implementazione).

== Visualizzazione e grafici

=== Matplotlib

Matplotlib è la libreria di _plotting_ utilizzata per la generazione di tutti i grafici della tesi: serie temporali di prezzo, correlogrammi, _summary plot_ *SHAP* e grafici di confronto tra strategie di _backtesting_.

== Persistenza dei dati

=== File _Comma-Separated Values_ (CSV)

I file *CSV* sono il formato principale per l'archiviazione dei _dataset_ intermedi prodotti dalla _pipeline_ (dati di mercato, metriche energetiche, _sentiment_ aggregato), scelto per la semplicità e il supporto nativo di Pandas.

=== File _JavaScript Object Notation_ (JSON)

I file *JSON* sono utilizzati per la persistenza di strutture dati gerarchiche non tabellari: l'elenco delle _feature_ attese dal modello (`feature_names.json`) e le metriche riassuntive del _walk-forward_ (`model_stats.json`).

=== File _Portable Network Graphics_ (PNG)

I file *PNG* sono il formato utilizzato per il salvataggio di tutte le visualizzazioni grafiche generate dalla _pipeline_, per la qualità senza perdita di dati.

#pagebreak()

= Metodologia <sec-metodologia>

== Formulazione del problema <sec-formulazione-problema>

Il problema affrontato è di classificazione binaria: dato un insieme di osservazioni settimanali relative al mercato di Bitcoin (*BTC* / *USD*) e a fonti informative correlate elencate precedentemente, si vuole prevedere se il prezzo di chiusura della settimana successiva sarà superiore (_UP_) o inferiore o uguale (_DOWN_) a quello della settimana corrente.

Questa formulazione riprende l'impostazione di classificazione binaria della direzione di prezzo adottata da diversi lavori esaminati nel capitolo precedente (Hafid [2], Kaur [7], Sattarov [9]), modificandone la granularità temporale da giornaliera/infra-giornaliera a settimanale, per rispondere a tre esigenze:
- Come si vede da @fig-daily-weekly attenua il rumore che caratterizza i mercati delle criptovalute, dove le oscillazioni di prezzo su orizzonti brevi sono molto frequenti e tendenzialmente imprevedibili.
#figure(
image("assets/daily_weekly.png", width: 90%),
caption: [Confronto granularità giornaliera e settimanale],
) <fig-daily-weekly>
- Rende compatibili fonti dati con cadenze di aggiornamento eterogenee (dati di mercato continui, indicatori di _blockchain_ aggiornati a intervalli variabili, un campione di _post social_ non uniformemente distribuito nel tempo).
- Riduce la quantità di osservazioni informativamente ridondanti, a fronte di un corrispondente aumento della varianza campionaria dovuto alla ridotta ampiezza del _dataset_ risultante.

È opportuno precisare che la frequenza di campionamento dei dati e l'orizzonte dell'obiettivo di predizione sono, in linea di principio, scelte indipendenti: sarebbe possibile mantenere i dati di mercato alla loro frequenza nativa (giornaliera, si veda @fig-daily-weekly) per il calcolo delle _feature_, aggregandoli internamente a ciascuna settimana, pur definendo il _target_ a un orizzonte settimanale. Questa tesi ricampiona invece l'intero flusso di dati a cadenza settimanale fin dall'origine, oltre che per l'attenuazione del rumore già discussa, per due ragioni pratiche aggiuntive:
- Il campione di _post social_ raccolto non è sufficientemente ampio da consentire una stima giornaliera stabile del _sentiment_.
- Un'aggregazione di più fonti a frequenze eterogenee (giornaliera per il mercato, settimanale o inferiore per le altre) avrebbe introdotto una complessità nella fase di _join_ non giustificata dalla ridotta ampiezza campionaria complessiva del _dataset_, che già di per sé limita la capacità di sfruttare _feature_ aggiuntive senza incorrere in _overfitting_ (si veda la @sec-pruning).

== Fonti di dati

Il sistema integra quattro categorie di fonti dati, raccolte tramite un modulo di _ingestion_ dedicato:

#figure(
caption: [Fonti dati e modalità di raccolta],
table(
columns: (1fr, 1fr, 1fr),
align: (left + horizon, left + horizon, left + horizon),
fill: unipd-table-fill,
table.header([*Fonte*], [*Contenuto*], [*Modalità di accesso*]),
    [Mercato],
    [Quotazioni *OHLCV* settimanali di *BTC* / *USD*],
    [*API* Yahoo Finance],

    [_Blockchain_ o energetiche],
    [Costo di produzione stimato per bitcoin, _hash rate_ della rete],
    [Metriche di _mining_ aggregate],

    [_Sentiment social_],
    [_Post_ da _subreddit_ relativi a Bitcoin e criptovalute],
    [*API* Reddit, classificazione tramite modello linguistico (Gemini)],

    [_Sentiment_ di mercato],
    [_Fear \& Greed Index_],
    [*API* pubblica dedicata],
  ),
) <tab-datasrc>

Ciascuna fonte viene ricampionata a cadenza settimanale con lo stesso criterio, ovvero come etichetta di fine settimana, condizione necessaria affinché le successive operazioni di _join_ tra le diverse serie storiche siano corrette e non introducano disallineamenti tra le osservazioni. L'aggregazione dei valori di chiusura utilizza sempre l'ultimo valore disponibile nella settimana, per preservare il significato di "prezzo di chiusura settimanale".

== _Feature Engineering_

Le _feature_ utilizzate dal modello sono organizzate in quattro famiglie omogenee per natura e fonte del dato: _feature_ tecniche (derivate esclusivamente dalla serie dei prezzi di chiusura) _feature_ di _sentiment_, _feature blockchain_ o energetiche e _feature_ derivate dal _Fear & Greed Index_.

== _Feature_ Tecniche

#figure(
  caption: [_Feature_ tecniche],
  table(
    columns: (1fr, 1fr, 1fr),
    align: (left + horizon, left + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*_Feature_*], [*Descrizione*], [*Motivazione*]),

    [`log_return`], [Rendimento logaritmico settimanale], [Forma stazionaria e additiva, standard in finanza quantitativa],
    [`volatility_w`], [Deviazione standard dei rendimenti (4 settimane)], [Misura l'instabilità recente del prezzo],
    [`rsi_14`], [_Relative Strength Index_ a 14 periodi], [Momentum e condizioni di ipercomprato o ipervenduto],
    [`macd_hist`], [Istogramma *MACD*], [Cattura i _crossover_ di _trend_.],
    [`sharpe_4w`], [_Sharpe ratio_ mobile (4 settimane)], [Rendimento aggiustato per il rischio in un solo indicatore],
    [`volume_norm`], [Volume di scambio settimanale (quantità di *BTC* compravenduti sul mercato) normalizzato sulla propria media mobile], [Rileva anomalie di interesse di mercato indipendenti dal livello assoluto],
  ),
) <tab-featuretech>

== Feature di Sentiment <sec-featuresent>

#figure(
  caption: [_Feature_ di _sentiment_],
  table(
    columns: (1fr, 1fr, 1fr),
    align: (left + horizon, left + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*_Feature_*], [*Descrizione*], [*Motivazione*]),

    [`sentiment_score_mean`], [Punteggio medio di _sentiment_ settimanale in un intervallo tra -1 e +1.], [Tono generale della discussione pubblica],
    [`sentiment_score_weighted`], [Punteggio pesato per _follower_ dell'autore], [Maggior peso agli autori con più _follower_],
    [`positive_pct` \ `negative_pct`], [Percentuale di _post_ positivi o negativi], [Cattura la polarizzazione, non solo il tono medio],
    [`tweet_count`], [Volume di _post_ analizzati], [_Proxy_ dell'attenzione pubblica verso Bitcoin],
    [`sentiment_momentum`], [Differenza dal _sentiment_ medio delle 4 settimane precedenti], [Cattura variazioni brusche di umore],
  ),
) <tab-featuresent>

== _Feature_ di Blockchain o Energetiche

#figure(
  caption: [_Feature_ di _blockchain_ o energetiche],
  table(
    columns: (1fr, 1fr, 1fr),
    align: (left + horizon, left + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*_Feature_*], [*Descrizione*], [*Motivazione*]),

    [`cost_per_btc`], [Costo di produzione stimato per bitcoin], [_Proxy_ del valore "fondamentale".],
    [`cost_per_btc_delta`], [Variazione percentuale settimanale del costo di produzione], [Cattura la dinamica del costo di produzione (se sta aumentando o diminuendo), non solo il suo livello assoluto in una data settimana],
    [`hash_rate_norm`], [_Hash rate_ normalizzato sulla propria media mobile], [_Proxy_ della fiducia dei _miner_ nella rete],
  ),
) <tab-featurebc>

== _Feature_ di _Sentiment_ del Mercato

#figure(
  caption: [_Feature_ di _sentiment_ del mercato],
  table(
    columns: (1fr, 1fr, 1fr),
    align: (left + horizon, left + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*_Feature_*], [*Descrizione*], [*Motivazione*]),

    [`fear_greed_mean` \ `fear_greed_close`], [Valore medio e di chiusura settimanale dell'indice], [_Sentiment_ di mercato aggregato da fonti multiple],
    [`fear_greed_delta`], [Variazione rispetto alla settimana precedente], [Cambi repentini di _sentiment_, coerente col momentum del _sentiment_ testuale],
  ),
) <tab-featurefng>

Il criterio comune a tutte le famiglie, evidente dal confronto delle motivazioni riportate nelle tabelle @tab-featuretech, @tab-featuresent, @tab-featurebc e @tab-featurefng, è la ricerca di complementarità informativa più che di ridondanza: per ciascuna fonte si è privilegiata l'inclusione di misure che catturano aspetti distinti del fenomeno osservato piuttosto che più indicatori sostanzialmente equivalenti, come discusso nella sezione @sec-pruning.

== Selezione e _pruning_ delle _feature_ <sec-pruning>

Data l'ampiezza campionaria contenuta del _dataset_ (dell'ordine di 110-120 osservazioni settimanali) rispetto al numero di _feature_ disponibili, è stata applicata una fase di _pruning_ automatico volta a contenere il rischio di _overfitting_. In questa fase vengono rimosse _feature_ ridondanti dove per ogni coppia di _feature_ con correlazione assoluta superiore a 0.95, viene mantenuta solo una delle due. Infine, le _feature_ costanti su tutto il periodo osservato, poiché non apportano alcuna informazione, vengono scartate.

Un principio metodologico osservato in questa fase è che il _pruning_ delle _feature_ non è mai stato basato sulla correlazione con la variabile _target_ calcolata sull'intero _dataset_. Il problema non risiede nell'uso della correlazione con il _target_ in sé, quanto nel calcolarla su un periodo che include le osservazioni successivamente impiegate come test: utilizzare questa informazione per decidere quali _feature_ includere nel modello equivale a "sbirciare" il risultato prima della validazione (_look-ahead bias_), inficiandone la validità. Un _pruning_ basato sul _target_ sarebbe in linea di principio corretto se ricalcolato di volta in volta utilizzando esclusivamente le osservazioni disponibili in ciascuna finestra di addestramento, secondo lo schema di validazione descritto nella sezione @sec-validazione-wf, questa tesi ha tuttavia preferito un _pruning_ basato esclusivamente su proprietà interne alle _feature_ stesse (correlazione reciproca, varianza), indipendenti dalla variabile _target_, per mantenere la fase di selezione delle _feature_ più semplice e per evitare l'_overhead_ computazionale di un ricalcolo a ogni finestra del _walk-forward_.

== Definizione del _target_

La variabile _target_ è costruita confrontando il prezzo di chiusura della settimana corrente con quello della settimana immediatamente successiva nell'indice temporale. Un aspetto metodologico che richiede attenzione riguarda la costruzione di questo confronto: fare riferimento alla riga successiva nell'indice anziché alla settimana calendariale successiva espone al rischio che, in presenza di anche una sola settimana mancante nella serie storica, il _target_ smetta silenziosamente di rappresentare la "direzione" della settimana successiva senza generare alcun errore. Per questo motivo, la costruzione del _target_ verifica esplicitamente che la distanza temporale tra un'osservazione e la successiva nell'indice sia esattamente di sette giorni e, in caso contrario, l'osservazione viene scartata anziché essere etichettata in modo errato.

== Definizione del modello

Il modello adottato è *XGBoost*, la scelta è motivata da tre proprietà rilevanti per il contesto applicativo:
- La capacità di modellare relazioni non lineari e interazioni tra _feature_ eterogenee senza richiedere una fase di _scaling_.
- La disponibilità di meccanismi di regolarizzazione nativi particolarmente rilevanti data la ridotta ampiezza campionaria del _dataset_.
- La diffusione consolidata dell'algoritmo nella letteratura sulla previsione di serie finanziarie, che rende semplice il confronto con lavori analoghi.


== Metodologia di validazione

La natura sequenziale e temporalmente ordinata dei dati richiede una procedura di validazione che rispetti rigorosamente la cronologia delle osservazioni, per evitare qualunque forma di _leakage_ temporale, ossia l'uso implicito o esplicito di informazione futura durante l'addestramento o la selezione del modello.

== _Split_ iniziale e _purge gap_

Il _dataset_ viene suddiviso in una porzione di _training_ (70%) e una di _testing_ (30%), con l'introduzione di un ulteriore margine di separazione di due settimane tra le due porzioni per prevenire che _feature_ calcolate su finestre al confine tra le due porzioni possano condividere informazione tra addestramento e test.

== Ottimizzazione degli iperparametri

La selezione degli iperparametri avviene tramite ricerca randomizzata (``` RandomizedSearchCV```) su uno spazio di ricerca deliberatamente contenuto e orientato alla regolarizzazione (profondità massima degli alberi limitata a 3, penalizzazioni L1/L2 significative, _subsampling_ di righe e colonne) in modo coerente con la ridotta ampiezza campionaria disponibile. La validazione incrociata durante questa fase utilizza uno schema ``` TimeSeriesSplit``` a 5 _fold_, con un margine di due settimane tra le porzioni di addestramento e validazione di ciascun _fold_, per prevenire _leakage_ tra osservazioni temporalmente adiacenti dovuto a _feature_ con finestre mobili.

Un aspetto metodologico rilevante riguarda l'interpretazione del punteggio massimo ottenuto da questa procedura (``` best_score_```): trattandosi del valore massimo osservato su un numero finito di configurazioni testate, tale punteggio è affetto da un _bias_ di selezione che lo rende sistematicamente ottimistico rispetto alla reale capacità di generalizzazione del modello. Per questo motivo, tale valore non viene utilizzato come stima finale delle prestazioni del sistema, ruolo riservato esclusivamente alla procedura di validazione _walk-forward_.

== Validazione _walk-forward_ <sec-validazione-wf>

Per simulare in modo realistico l'utilizzo del modello, la valutazione principale delle prestazioni avviene tramite una procedura di validazione _walk-forward_ con finestra di addestramento progressivamente crescente dove, a partire da una dimensione minima iniziale, il modello viene riaddestrato a ogni passo temporale sui soli dati disponibili fino a quel momento, e utilizzato per produrre una singola previsione sulla settimana immediatamente successiva, mai osservata durante l'addestramento.

Gli iperparametri vengono riottimizzati periodicamente durante questa procedura (a intervalli di 26 settimane), ma solo quando la finestra di addestramento disponibile supera una soglia minima prestabilita, al di sotto di tale soglia, la riottimizzazione viene omessa poiché condotta su un numero di osservazioni insufficiente a garantire risultati stabili, rischiando di introdurre instabilità nel modello anziché migliorarne l'adattamento a eventuali cambiamenti nel regime di mercato.

== Quantificazione dell'incertezza statistica <sec-quant-incertezza>

Con poche predizioni disponibili nel _walk-forward_, un singolo numero (es. "l'accuratezza è 0.55") non basta a capire quanto ci si può fidare del risultato. Per questo è stato usato il _bootstrap_ non parametrico [13]: dalle coppie previsione/esito del _walk-forward_ se ne estraggono, con reinserimento, tante quante l'originale, e si ricalcola la metrica. Ripetendo l'operazione 2000 volte si ottiene una distribuzione di valori, da cui si ricava un intervallo di confidenza al 95% (i percentili 2.5 e 97.5 di quella distribuzione).

Questo tipo di ricampionamento assume che le osservazioni siano indipendenti tra loro. Su dati temporali questo non è scontato: se il modello sbaglia in modo simile per più settimane di fila (ad esempio durante un cambio di regime di mercato), le osservazioni sono correlate, e trattarle come indipendenti porta a un intervallo di confidenza più stretto di quanto dovrebbe essere. Per controllare che questo non fosse un problema, è stata misurata l'autocorrelazione dei residui del _walk-forward_ (differenza tra esito reale e probabilità predetta) con il test di Ljung-Box, a 1, 4 e 8 settimane di distanza: i _p-value_ ottenuti (0.737, 0.659, 0.931) sono tutti ben sopra la soglia di 0.05, quindi non c'è evidenza di questo tipo di correlazione. Il _bootstrap_ semplice è quindi appropriato in questo caso, e l'intervallo di confidenza calcolato è affidabile.

#figure(
  image("assets/chart_residuals_acf.png", width: 80%),
  caption: [Residui del _walk-forward_ bande di confidenza al 95%],
) <fig-residuals-acf>

Questo passaggio serve a distinguere un risultato solido da uno che sembra buono solo per caso: se l'intervallo di confidenza include il valore di un classificatore che indovina a caso (50% per l'accuratezza), il risultato osservato non è dimostrabilmente migliore del caso, qualunque sia il numero esatto ottenuto.


== _Baseline_ di confronto e _backtesting_ <sec-baseline>

Le prestazioni del modello sono messe a confronto con tre strategie di riferimento:
- _Buy & Hold_: esposizione costante al mercato per l'intero periodo.
- *MACD* _Crossover_: tecnica classica, utile a verificare che il modello non stia replicando un segnale già catturato da un indicatore elementare.
- _Random_: strategia casuale.

È stata inoltre condotta una simulazione di _backtesting_, con un capitale iniziale di esempio e un costo di transazione applicato a ogni variazione di posizione, per stimare rendimento cumulato. Questa analisi va interpretata con cautela quando le metriche di classificazione non risultano statisticamente significative: i costi di transazione tendono a erodere ulteriormente un segnale già debole o assente.

== Interpretabilità del modello <sec-interpretabilita>

Un limite ricorrente nei lavori simili discussi nel capitolo precedente riguarda l'opacità decisionale dei modelli adottati, in particolare per le architetture neurali e per i sistemi multi-agente basati su *LLM*, per i quali risulta difficile isolare il contributo delle singole _feature_ a una predizione. La _pipeline_ qui sviluppata affronta questo limite su due livelli:

- A livello globale, viene calcolata la _feature importance_ nativa del modello (basata sul guadagno informativo relativo a ciascuna _feature_ nella costruzione degli alberi di *XGBoost*), che fornisce un _ranking_ di quanto ciascuna _feature_ venga utilizzata in media dal modello.

- A livello locale, viene condotta un'analisi tramite valori *SHAP*, calcolati con un _explainer_ specifico per modelli ad alberi (*TreeExplainer*), che restituisce valori esatti anziché approssimati. Per ciascuna osservazione, i valori *SHAP* scompongono l'_output_ del modello nella somma dei contributi di ogni _feature_, con segno e valore, aggregando questi contributi su tutte le osservazioni si ottiene inoltre una misura di importanza globale (media del valore assoluto) alternativa e più informativa rispetto alla sola _feature importance_ basata sul _gain_, poiché riflette anche la diversità e la direzione dell'effetto di ciascuna _feature_.

Un principio metodologico da tenere presente quando si interpretano di questi risultati è che l'importanza descrive esclusivamente su quali _feature_ il modello si appoggia per produrre le proprie predizioni, non se tali predizioni siano corrette o generalizzino a dati non osservati.

== Sintesi delle scelte <sec-sintesi-scelte>

L'insieme delle scelte descritte in questo capitolo risponde a un principio metodologico di unione: dato il vincolo strutturale rappresentato dalla ridotta ampiezza campionaria del _dataset_, ogni fase della _pipeline_ (selezione delle _feature_, ottimizzazione degli iperparametri, valutazione delle prestazioni) è stata progettata per minimizzare il rischio di sovrastima delle capacità predittive del sistema, anche a costo di ottenere stime puntuali meno favorevoli.

#pagebreak()

= Implementazione <sec-implementazione>

Questo capitolo mostra l'implementazione in codice delle scelte metodologiche precedenti. La _pipeline_ è composta da moduli Python riutilizzabili orchestrati da notebook Jupyter. La struttura segue l'ordine di esecuzione della _pipeline_.


== Raccolta dati

Il modulo ``` DataIngestor``` gestisce l'accesso a ogni fonte dati tramite metodi dedicati (``` fetch_market_data```, ``` fetch_mining_metrics```, ``` fetch_energy_cost```, ``` fetch_fear_greed```), assicurando ricampionamento uniforme e stessa funzione di aggregazione per il prezzo di chiusura su tutte le fonti.

Un esempio di _fetching_ di una categoria di questi dati:

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

Un'altra funzione degna di nota è il modo con cui vengono recuperati i _post_ Reddit su Bitcoin, ovvero tramite *API* di ArcticShift, suddividendo il tempo in finestre di 7 giorni, gestisce _rate limiting_, salva _checkpoint_ per riprendere interruzioni, filtra per _rating_ minimo di 5, rimuove i duplicati e restituisce un _dataset_ ordinato con _timestamp_, fonte, testo e punteggio, nel seguente modo:

```python
def fetch_arctic_shift_feed(
    self,
    subreddits: list[str] | None = None,
    min_score: int = 5,
    sleep_between_calls: float = 1.0,
    window_days: int = 7,
    max_per_window: int = 200
) -> pd.DataFrame:
    if subreddits is None:
        subreddits = ["Bitcoin", "CryptoCurrency", "BitcoinMarkets"]  # Subreddit di default
    BASE_URL = "https://arctic-shift.photon-reddit.com/api/comments/search"
    # Sistema a checkpoint in caso di caduta di internet
    checkpoint_path = os.path.join(self.output_dir, "bitcoin_arctic_reddit_checkpoint.csv")
    if os.path.exists(checkpoint_path):
        df_existing = pd.read_csv(checkpoint_path)
        df_existing["timestamp"] = pd.to_datetime(df_existing["timestamp"])
        all_rows = df_existing.to_dict("records")
        last_ts = df_existing["timestamp"].max()  # Punto di ripresa
    else:
        all_rows = []
        last_ts = None
    for sub in subreddits:
        n_sub = 0
        window_start = self.start_date
        while window_start < self.end_date:
            window_end = min(window_start + timedelta(days=window_days), self.end_date)
            # Salta finestre già processate in precedenza
            if last_ts is not None and window_end <= last_ts:
                window_start = window_end
                continue
            # Definisce gli estremi temporali per la query API
            before = window_end.strftime("%Y-%m-%dT%H:%M:%S")   # Più recente
            after = window_start.strftime("%Y-%m-%dT%H:%M:%S")  # Più vecchio
            n_window = 0  # Contatore commenti nella finestra corrente
            while True:
                # Costruzione URL con parametri di filtro e paginazione
                url = (
                    f"{BASE_URL}"
                    f"?subreddit={sub}"
                    f"&after={after}"
                    f"&before={before}"
                    f"&limit=100"          # Max 100 commenti per chiamata
                    f"&sort=desc"          # Dal più recente al più vecchio
                    f"&fields=body,score,created_utc"  # Solo campi necessari
                )
                try:
                    resp = requests.get(url, timeout=30)
                    remaining = int(resp.headers.get("X-RateLimit-Remaining", 10))
                    # Se il limite residuo è basso, attende il reset
                    if remaining < 2:
                        reset = int(resp.headers.get("X-RateLimit-Reset", 10))
                        print(f"\n   [rate limit] Aspetto {reset}s...")
                        time.sleep(reset)
                    resp.raise_for_status()
                    data = resp.json().get("data", [])
                except Exception as e:
                    print(f"\n   [warn] Errore r/{sub} [{after} → {before}]: {e}")
                    data = []
                    break  # In caso di errore, passa alla finestra successiva
                # Se non ci sono più dati, esce dal ciclo di paginazione
                if not data:
                    break
                for item in data[:max_per_window]:
                    # Converte timestamp UNIX in datetime UTC
                    ts = datetime.fromtimestamp(
                        item.get("created_utc", 0),
                        tz=timezone.utc
                    ).replace(tzinfo=None)
                    # Memorizza il commento con i metadati essenziali
                    all_rows.append({
                        "timestamp": ts,
                        "source": f"Reddit_r/{sub}",
                        "text": item.get("body", ""),
                        "user_followers": item.get("score", 0),
                    })
                    n_window += 1
                n_sub += len(data)
                print(f"   r/{sub}: {n_sub} commenti finora...", end="\r")
                # Salva progresso dopo ogni batch per permettere ripresa
                pd.DataFrame(all_rows).to_csv(checkpoint_path, index=False)
                # Se ha raggiunto il max per finestra, passa alla successiva
                if n_window >= max_per_window:
                    break
                # Usa il commento più vecchio come punto di partenza
                oldest = min(item["created_utc"] for item in data)
                before = datetime.fromtimestamp(
                    oldest - 1,  # Sottrae 1 secondo per evitare duplicati
                    tz=timezone.utc
                ).strftime("%Y-%m-%dT%H:%M:%S")
                # Se ha raggiunto l'inizio della finestra, esce
                if oldest <= int(window_start.timestamp()):
                    break
                # Pausa tra le chiamate per non sovraccaricare l'API
                time.sleep(sleep_between_calls)
            # Passa alla prossima finestra temporale
            window_start = window_end
    # Se non è stato raccolto nulla, restituisce DataFrame vuoto
    if not all_rows:
        return pd.DataFrame(columns=["timestamp", "source", "text", "user_followers"])
    df = pd.DataFrame(all_rows)
    # Conversione timestamp e rimozione valori nulli
    df["timestamp"] = pd.to_datetime(df["timestamp"], errors="coerce")
    df = df.dropna(subset=["timestamp", "user_followers"])
    # Filtra per punteggio minimo, escludendo quelli sotto una certa soglia
    df = df.loc[df["user_followers"] >= min_score]
    # Rimozione duplicati e sorting
    df = df.drop_duplicates(subset=["timestamp", "text"])
    df = df.sort_values("timestamp").reset_index(drop=True)
    output_path = os.path.join(self.output_dir, "bitcoin_arctic_reddit.csv")
    df.to_csv(output_path, index=False)
    # Rimozione del checkpoint
    if os.path.exists(checkpoint_path):
        os.remove(checkpoint_path)
    return df
```

La @tab-dataingestor riassume le funzionalità del modulo ``` DataIngestor```:

#figure(
caption: [Metodi della classe `DataIngestor`],
table(
columns: (1.4fr, 1fr, 1.4fr),
align: (left, left, left),
fill: unipd-table-fill,
table.header([Metodo], [Funzione], [Implementazione]),

[``` __init__```],
[Imposta periodo e frequenza di ricampionamento.],
[Parametri: ``` start_date```, ``` end_date```, ``` frequency="W"```. Crea cartella _output_.],

[``` fetch_market_data```],
[Scarica e ricampiona quotazioni *BTC* / *USD*.],
[Usa _yfinance_, aggrega con ``` last```, ``` sum```, ``` max```, ``` min```, ``` first```. Salva in *CSV*.],

[``` fetch_mining_metrics```],
[Scarica _hash rate_ e difficoltà di rete.],
[*API* blockchain.info, media settimanale con ``` resample(...).mean()```.],

[``` fetch_energy_cost```],
[Stima costo di produzione per *BTC*.],
[*API* CoinMetrics, _fallback_ su _mining metrics_ o *CSV*. Modello costo/energia con parametri fissi.],

[``` fetch_arctic_shift_feed```],
[Raccoglie commenti Reddit su Bitcoin da più _subreddit_.],
[*API* arctic-shift con finestre temporali, _rate limiting_ e _checkpoint_ su disco per ripresa.],

[``` fetch_fear_greed```],
[Scarica _Fear \& Greed Index_ e statistiche settimanali.],
[*API* alternative.me, nessuna autenticazione.],
),
) <tab-dataingestor>

Tra i _pattern_ implementativi comuni a più metodi, il più rilevante dal punto di vista metodologico è il meccanismo di _checkpoint_ di `fetch_arctic_shift_feed`, che permette di riprendere una raccolta dati incrementale (nuovi commenti ogni settimana) senza riscaricare l'intero storico a ogni esecuzione:

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

Lo stesso principio è impiegato anche nella classificazione del _sentiment_ (``` SentimentEngine.analyze```), dove evita di rianalizzare tramite il modello *LLM* Gemini i _post_ già classificati in esecuzioni precedenti.

#pagebreak()

== _Sentiment Analysis_

Il modulo ``` SentimentEngine``` incapsula sia l'estrazione del _sentiment_ testuale tramite modello linguistico sia il calcolo delle _feature_ derivate dalle altre fonti dati.

La @tab-sentimentengine ne riassume le funzionalità:

#figure(
  caption: [Metodi della classe `SentimentEngine` (_pipeline_ finale)],
  table(
    columns: (1.2fr, 1fr, 1fr),
    align: (left + horizon, left + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*Metodo*], [*Cosa fa*], [*Come lo fa*]),

    [`_clean_tweet`],
    [Normalizza il testo grezzo di un _post_ prima della classificazione.],
    [Rimuove *HTML*, *URL*, menzioni, converte _hashtag_ in parole, filtra caratteri non *ASCII*.],

    [`_analyze_batch`],
    [Classifica un _batch_ di _post_ tramite il modello linguistico, restituendo punteggio e _label_ per ciascuno.],
    [Costruisce un _prompt_ strutturato e forza una risposta in formato *JSON*, gestisce _retry_ su errori di _rate limit_ e risposte malformate.],

    [`analyze`],
    [Orchestra la classificazione dell'intero _dataset_ di _post_, in _batch_, con ripresa da _checkpoint_.],
    [Salta i _post_ già presenti nel _checkpoint_ su disco, inoltre aggrega i punteggi a livello settimanale al termine.],

    [`compute_rsi` \ `compute_macd` \ `compute_sharpe`],
    [Calcolano i rispettivi indicatori tecnici sulla serie dei prezzi.],
    [Uso esclusivo di `rolling` o `ewm`, mai statistiche sull'intera serie.],

    [`compute_technical_features`],
    [Assembla le sei _feature_ tecniche in un unico *DataFrame*.],
    [Chiama i tre metodi precedenti e unisce i risultati sull'indice temporale di `df_market`.],

    [`compute_energy_features`],
    [Calcola costo per bitcoin, sua variazione e _hash rate_ normalizzato.],
    [Trasformazioni dirette (`pct_change`, `rolling`) sulle colonne di `df_energy`.],

    [`compute_sentiment_momentum`],
    [Calcola la differenza tra il _sentiment_ corrente e la media delle 4 settimane precedenti.],
    [`shift(1)` prima di `rolling(4)`, per escludere la settimana corrente dalla propria _baseline_.],
  ),
) <tab-sentimentengine>

Il punto di maggior rilievo per la componente *NLP* della tesi è la costruzione della chiamata al modello linguistico in ``` _analyze_batch```. I _post_ vengono numerati e inseriti in un unico _prompt_ per _batch_ (riducendo il numero di chiamate *API* rispetto a una classificazione _post_ per _post_), con una richiesta esplicita di _output_ strutturato:

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

== _Feature Engineering_

Ogni trasformazione che genera una _feature_ è implementata in modo da utilizzare esclusivamente operazioni causali (``` rolling```, ``` ewm```, ``` pct_change```, ``` diff```), mai statistiche calcolate sull'intera serie. A titolo di esempio, la _feature_ di _momentum_ del _sentiment_ è implementata come:

```python
def compute_sentiment_momentum(self, df_sentiment, window=4, col="sentiment_score_mean"):
    baseline = df_sentiment[col].shift(1).rolling(window).mean()
    return (df_sentiment[col] - baseline).rename(f"{col}_momentum_{window}w")
```
Lo ``` shift(1)``` prima del ``` rolling(window)``` è l'elemento implementativo che garantisce la causalità: esclude la settimana corrente dal calcolo della propria _baseline_, in modo che il valore di ciascuna settimana dipenda solo da settimane strettamente precedenti.

Ulteriormente fornisco un esempio di funzione che calcola una _feature_ tecnica, ovvero lo _Sharpe Ratio_:

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

Inoltre ho gestito il caso in cui ci siano _gap_ nel _sentiment_. Non tutte le settimane presentano un volume di _post_ sufficiente per una stima affidabile del _sentiment_ (o, in casi limite, nessun _post_ disponibile). Il riempimento di queste settimane mancanti è implementato tramite _forward-fill_ limitato, nel seguente modo:

```python
cols_interp = ["sentiment_score_mean", "sentiment_score_weighted", "positive_pct", "negative_pct"]
df_sentiment[cols_interp] = df_sentiment[cols_interp].ffill(limit=4).fillna(0)
```
Il _forward-fill_ propaga solo l'ultimo valore osservato in avanti nel tempo, rispettando il vincolo di causalità. Il parametro `limit=4` evita inoltre che un'assenza di dati prolungata venga mascherata da un valore ormai vecchio: oltre questa soglia la settimana viene invece impostata a un valore neutro (`fillna(0)`), segnalando implicitamente l'assenza di informazione piuttosto che simularne una non aggiornata.

```python
  CORR_THRESHOLD = 0.95
  cols_to_drop = [c for c in ['macd', 'macd_signal'] if c in feature_matrix.columns]
  zero_var_cols = [
      c for c in feature_matrix.select_dtypes(include=[np.number]).columns
      if feature_matrix[c].nunique(dropna=True) <= 1
  ]
  if zero_var_cols:
      print(f'Feature a varianza zero rimosse: {zero_var_cols}')
  cols_to_drop += zero_var_cols
  num_cols = feature_matrix.drop(columns=cols_to_drop).select_dtypes(include=[np.number]).columns
  corr_matrix = feature_matrix[num_cols].corr().abs()
  upper = corr_matrix.where(np.triu(np.ones(corr_matrix.shape), k=1).astype(bool))
  auto_drop = [c for c in upper.columns if any(upper[c] > CORR_THRESHOLD)]
  all_drop = sorted(set(cols_to_drop + auto_drop))
  print(f'Feature rimosse per ridondanza/collinearità: {all_drop}')
  feature_matrix = feature_matrix.drop(columns=all_drop)
  print(f'Feature matrix dopo pruning: {feature_matrix.shape[1]} colonne')
```

Il _pruning_ delle _feature_ è implementato in due passaggi indipendenti dal _target_, in coerenza con il principio di assenza di _leakage_ nella selezione delle _feature_ discusso nella medesima sezione: rimozione delle _feature_ a varianza nulla (``` nunique(dropna=True) <= 1```) e rimozione automatica, per ogni coppia con correlazione assoluta superiore a una soglia, di una delle due colonne coinvolte, calcolata esclusivamente sulla matrice delle _feature_ (``` feature_matrix[num_cols].corr()```), senza mai includere la colonna _target_ in questo calcolo.

== Costruzione del _target_

La verifica esplicita del _gap_ temporale è implementata confrontando la distanza tra _timestamp_ consecutivi con il valore atteso, anziché assumerla implicitamente da un _offset_ posizionale:

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

La profondità massima è limitata a 2-3 (in contesti con più dati si usa tipicamente valori tra i 4 e 8), e i parametri di regolarizzazione L1/L2 (``` reg_alpha```, ``` reg_lambda```) e di _subsampling_ di righe/colonne (``` subsample```, ``` colsample_bytree```) sono inclusi esplicitamente nello spazio di ricerca anziché lasciati ai valori di _default_, meno conservativi, della libreria.

La ricerca randomizzata degli iperparametri è incapsulata in una funzione riutilizzabile, richiamata sia nella fase di _tuning_ iniziale sia, con un _budget_ di ricerca ridotto, nei successivi cicli di _re-tuning_ periodico durante il _walk-forward_:

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

== Validazione _walk-forward_

Il ciclo di validazione implementa la finestra di addestramento crescente, con il _re-tuning_ periodico condizionato al superamento di una soglia minima di dati disponibili:

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

L'analisi *SHAP* è implementata tramite l'_explainer_ specifico per modelli ad alberi, applicato al modello finale addestrato sull'intero _dataset_ disponibile:

```python
explainer   = shap.TreeExplainer(final_model)
shap_values = explainer.shap_values(X_clean)
mean_abs_shap = pd.Series(
    np.abs(shap_values).mean(axis=0), index=X_clean.columns
).sort_values(ascending=False)
```


== Persistenza e riproducibilità

Il modello finale, l'elenco delle _feature_ attese e le metriche del _walk-forward_ vengono salvati su disco al termine dell'esecuzione:

```python
final_model.save_model("models/xgboost_model.json")
json.dump(X_clean.columns.tolist(), open("models/feature_names.json", "w"))
json.dump(model_stats, open("models/model_stats.json", "w"))
```

Il salvataggio esplicito di ``` feature_names.json``` garantisce che il modello riceva sempre le _feature_ nello stesso ordine e con lo stesso nome usati in addestramento, indipendentemente da eventuali modifiche future al _pruning_ per correlazione, che potrebbe produrre un insieme di colonne leggermente diverso a fronte di nuovi dati.

#pagebreak()


= Sperimentazione e risultati <sec-sperimentazione>

Questo capitolo riporta i risultati ottenuti applicando la metodologia descritta nel capitolo 4, sul _dataset_ finale di 107 settimane e 17 _feature_ residue dopo il _pruning_ (sezione @sec-pruning). Coerentemente con l'impostazione dichiarata nell'Introduzione, i risultati sono presentati insieme alla loro significatività statistica, non come sole stime puntuali.

== Ottimizzazione degli iperparametri: esito

La ricerca randomizzata sullo spazio descritto in Implementazione ha selezionato la seguente configurazione, con un punteggio di validazione incrociata (*AUC*) pari a 0.576:

```python
{'subsample': 1.0, 'reg_lambda': 5, 'reg_alpha': 0.1, 'n_estimators': 50,
 'min_child_weight': 3, 'max_depth': 3, 'learning_rate': 0.01, 'gamma': 0.1,
 'colsample_bytree': 0.8}
```

Coerentemente con quanto discusso in Metodologia, questo valore (0.576) non viene interpretato come stima finale delle prestazioni: è un punteggio di selezione, atteso essere ottimistico. Rientra comunque nell'intervallo realisticamente atteso in letteratura per un compito di previsione della direzione settimanale di Bitcoin (tipicamente 0.52-0.58).

== Validazione _walk-forward_

La procedura di validazione _walk-forward_ (sezione @sec-validazione-wf), con un solo _re-tuning_ eseguito durante l'intero periodo (essendo la soglia minima di 100 osservazioni raggiunta solo verso la fine della finestra), ha prodotto 77 predizioni a partire dalle 107 settimane totali disponibili:

#figure(
  caption: [Metriche di classificazione, validazione _walk-forward_],
  table(
    columns: (1fr, 1fr),
    align: (left + horizon, right + horizon),
    fill: unipd-table-fill,
    table.header([*Metrica*], [*Valore*]),
    [Accuracy], [0.442],
    [ROC-AUC], [0.435],
    [Precision], [0.459],
    [Recall], [0.737],
    [F1-score], [0.566],
  ),
) <tab-walkforward>

Il valore puntuale di *ROC-AUC* (0.435) è inferiore a 0.5, e l'_accuracy_ (0.442) è inferiore alla proporzione di settimane rialziste osservata nel campione. Preso isolatamente, questo potrebbe suggerire un modello con prestazioni peggiori del caso, la sezione successiva mostra perché questa conclusione non è statisticamente sostenibile con il numero di osservazioni disponibili.

Il divario tra _recall_ (0.737) e _precision_ (0.459) indica che il modello tende a prevedere la classe *UP* più frequentemente di quanto sia corretto: una possibile spia di uno sbilanciamento nella soglia decisionale piuttosto che di un errore casuale, sebbene, come discusso di seguito, questo _pattern_ rientri comunque nel rumore statistico atteso a questa numerosità campionaria.

== Quantificazione dell'incertezza statistica

Gli intervalli di confidenza _bootstrap_ al 95% (2000 ricampionamenti, N=77) sono riportati in @tab-bootstrap-ci:

#figure(
  caption: [CI di _bootstrap_ al 95% su _walk-forward metrics_],
  table(
    columns: (1fr, 1fr, 1.4fr),
    align: (left + horizon, right + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*Metrica*], [*Valore osservato*], [*CI95%*]),
    [ROC-AUC], [0.435], [\[0.310, 0.562\]: include 0.5],
    [Accuracy], [0.442], [\[0.325, 0.545\]: include 0.5],
    [Precision], [0.459], [\[0.328, 0.582\]],
  ),
) <tab-bootstrap-ci>

Sia l'intervallo di confidenza dell'*AUC* sia quello dell'_accuracy_ includono il valore corrispondente a un classificatore privo di potere predittivo (0.5). Come discusso in Metodologia (sezione @sec-quant-incertezza), questo significa che il risultato osservato non è statisticamente distinguibile dal caso: il valore puntuale sotto 0.5 non costituisce evidenza che il modello performi peggio del caso, così come un valore sopra 0.5 non ne costituirebbe evidenza a favore. Con questa numerosità campionaria, l'errore standard associato a una stima di *AUC* è sufficientemente ampio da rendere entrambe le interpretazioni ugualmente non supportate dai dati.

La verifica dell'indipendenza temporale delle osservazioni, condizione per la validità del _bootstrap_ semplice utilizzato, non ha rilevato autocorrelazione significativa nei residui del _walk-forward_ a nessuno degli orizzonti testati (test di Ljung-Box, _p-value_ pari a 0.737, 0.659 e 0.931 rispettivamente a 1, 4 e 8 settimane di distanza), come mostrato dal correlogramma in @fig-residuals-acf. L'intervallo di confidenza riportato può quindi essere considerato una stima affidabile dell'incertezza.

== Controllo di stabilità del regime di mercato

La proporzione di settimane rialziste osservata nel periodo di addestramento iniziale (53.3%, prime 30 settimane) è simile a quella osservata nella finestra di _walk-forward_ (49.4%, 77 settimane): una differenza di 4 punti percentuali, non indicativa di un cambio di regime marcato. Un classificatore che predicesse sempre la classe maggioritaria del periodo iniziale avrebbe ottenuto un'_accuracy_ del 50.6% se la distribuzione del _target_ fosse rimasta invariata, il fatto che l'_accuracy_ osservata del modello (0.442) sia inferiore anche a questo riferimento _naive_ conferma che il divario rispetto al caso non è spiegabile da un cambiamento nella distribuzione della variabile _target_, ma va attribuito, coerentemente con la sezione precedente, a rumore campionario in un campione di dimensione contenuta.

== Confronto con le _baseline_

Le prestazioni del modello sono state confrontate con le tre strategie di riferimento descritte in Metodologia (sezione @sec-baseline):

#figure(
  caption: [Confronto _walk-forward_:  modello vs _baseline_ di riferimento],
  table(
    columns: (1.3fr, 1fr, 1fr, 1fr),
    align: (left + horizon, right + horizon, right + horizon, right + horizon),
    fill: unipd-table-fill,
    table.header([*Strategia*], [*Accuracy*], [*Precision*], [*ROC-AUC*]),
    [*XGBoost*], [0.442], [0.459], [0.435],
    [_Buy \& Hold_], [0.494], [N/A], [N/A],
    [*MACD* _Crossover_], [0.506], [0.500], [0.494],
    [_Random_ (media)], [0.497], [0.489], [0.513],
  ),
) <tab-baseline-comparison>

Nel periodo di _walk-forward_ considerato, tutte e tre le _baseline_ ottengono un'_accuracy_ puntuale superiore a quella del modello, incluso il semplice incrocio *MACD* (0.506), un indicatore tecnico elementare che il modello dovrebbe idealmente superare o quantomeno eguagliare, dato che le _feature_ tecniche includono lo stesso tipo di informazione (@tab-featuretech). Anche questo confronto, tuttavia, va letto alla luce degli intervalli di confidenza discussi sopra: le differenze tra le quattro strategie rientrano nell'ordine di grandezza del rumore campionario stimato per il modello, e non è stata condotta una verifica di significatività statistica sulle differenze tra strategie in questo lavoro.

== _Backtesting_

La simulazione di _backtesting_ sul periodo di _walk-forward_, con capitale iniziale di 10.000 *USD* e una commissione dello 0.1% per variazione di posizione, ha prodotto i risultati in @tab-backtesting:

#figure(
  caption: [Risultati del _backtesting_: modello vs _Buy \& Hold_],
  table(
    columns: (1.5fr, 1fr, 1fr),
    align: (left + horizon, right + horizon, right + horizon),
    fill: unipd-table-fill,
    table.header([*Metrica*], [*XGBoost*], [*Buy \& Hold*]),
    [Rendimento totale], [-22.8%], [-5.2%],
    [Capitale finale], [\$7.720], [\$9.482],
    [Sharpe Ratio], [-0.669], [-0.100],
    [Max Drawdown], [-48.4%], [-46.8%],
  ),
) <tab-backtesting>

con 12 operazioni eseguite complessivamente. Il periodo di _walk-forward_ coincide con una fase di mercato ribassista (entrambe le strategie chiudono in perdita), e la strategia guidata dal modello sottoperforma nettamente il _Buy \& Hold_ su ogni metrica. Questo risultato è coerente con quanto anticipato in Metodologia (sezione @sec-baseline): un segnale privo di potere predittivo dimostrato, unito ai costi di transazione su 12 operazioni, produce una strategia attiva peggiore della semplice esposizione continua al mercato. Il risultato del _backtesting_ non va quindi interpretato come una proprietà intrinsecamente negativa del modello, ma come una diretta conseguenza dell'assenza di segnale già stabilita nella sezione precedente.

In @fig-backtesting si possono notare gli effetti dei due "metodi" sul capitale iniziale.

#figure(
  image("assets/backtesting.png", width: 80%),
  caption: [Evoluzione del capitale: modello vs _Buy \& Hold_],
) <fig-backtesting>


== Interpretabilità: _Feature Importance_ e SHAP

La _feature importance_ nativa (_gain-based_) e l'importanza media |*SHAP*| del modello finale (allenato sull'intero _dataset_ disponibile, sezione @sec-interpretabilita) sono riportate in @tab-shap-importance, ordinate per importanza *SHAP* decrescente:

#figure(
  image("assets/chart_shap_summary.png", width: 70%),
  caption: [Distribuzione SHAP per _feature_ (_summary plot_).],
) <fig-shap-summary>

#figure(
  caption: [_Feature Importance_ e media \|SHAP\| del modello],
  table(
    columns: (1.6fr, 1fr, 1fr),
    align: (left + horizon, right + horizon, right + horizon),
    fill: unipd-table-fill,
    table.header([*Feature*], [*Gain*], [*\|SHAP\| media*]),
    [`cost_per_btc_delta`], [0.0759], [0.1869],
    [`fear_greed_delta`], [0.0700], [0.1852],
    [`volatility_w`], [0.0756], [0.1829],
    [`log_return`], [0.0553], [0.0887],
    [`tweet_count`], [0.0698], [0.0764],
    [`sharpe_4w`], [0.0664], [0.0721],
    [`positive_pct`], [0.0556], [0.0705],
    [`fear_greed_mean`], [0.0596], [0.0682],
    [`sentiment_score_weighted`], [0.0602], [0.0626],
    [`rsi_14`], [0.0447], [0.0408],
    [`volume_norm`], [0.0688], [0.0243],
    [`negative_pct`], [0.0580], [0.0184],
    [`cost_per_btc`], [0.0412], [0.0155],
    [`hash_rate_norm`], [0.0602], [0.0105],
    [`sentiment_score_mean`], [0.0547], [0.0101],
    [`macd_hist`], [0.0595], [0.0097],
    [`sentiment_momentum`], [0.0243], [0.0017],
  ),
) <tab-shap-importance>

#figure(
  image("assets/feature_importance.png", width: 100%),
  caption: [_Feature Importance_],
) <fig-feature-importance>

Le tre _feature_ con maggiore importanza *SHAP* (`cost_per_btc_delta`, `fear_greed_delta`, `volatility_w`) appartengono a tre famiglie diverse (_on-chain_/energetiche, _sentiment_ di mercato, tecniche), non alla famiglia del _sentiment_ testuale estratto da Reddit, che occupa posizioni intermedie. La _feature_ `sentiment_momentum`, introdotta su indicazione del relatore (sezione @sec-featuresent), ha l'importanza più bassa in assoluto in entrambe le classifiche, un ordine di grandezza sotto le altre: un risultato specifico e onesto da riportare, l'idea aveva un fondamento teorico ragionevole ma il modello non se ne avvale in modo apprezzabile nelle sue predizioni.

Coerentemente con il principio metodologico enunciato nella sezione @sec-interpretabilita, questo _ranking_ descrive esclusivamente su quali _feature_ il modello si appoggia, non se le sue predizioni siano corrette: dato che il modello combinato non è statisticamente distinguibile dal caso (@tab-bootstrap-ci), è plausibile che le _feature_ in cima al _ranking_ spieghino varianza nel campione di addestramento per rumore campionario piuttosto che per una relazione causale reale con la direzione futura del prezzo.

== _Ablation_ per gruppi di _feature_

La procedura di _ablation_ (sezione @sec-interpretabilita), che ripete il _walk-forward_ con iperparametri fissi su ciascuna famiglia di _feature_ isolata, produce i risultati in @tab-ablation:

#figure(
  caption: [_Walk-forward_ per gruppo di _feature_ isolato, con CI95%],
  table(
    columns: (1.4fr, 1fr, 1fr, 1.6fr),
    align: (left + horizon, right + horizon, right + horizon, left + horizon),
    fill: unipd-table-fill,
    table.header([*Gruppo*], [*AUC*], [*Accuracy*], [*CI95% AUC*]),
    [Tecniche], [0.358], [0.442], [\[0.228, 0.491\]: esclude 0.5],
    [_Sentiment_], [0.453], [0.545], [\[0.315, 0.578\]: include 0.5],
    [_On-chain_/energia], [0.440], [0.468], [\[0.318, 0.573\]: include 0.5],
    [_Fear \& Greed_], [0.483], [0.481], [\[0.361, 0.610\]: include 0.5],
    [Tutte le _feature_], [0.430], [0.506], [\[0.300, 0.561\]: include 0.5],
  ),
) <tab-ablation>

Tre dei quattro gruppi, così come il modello con tutte le _feature_ combinate, hanno un *CI* (_Confidence Interval_) che include 0.5: nessun segnale isolato dimostrabile. Il gruppo *tecniche* è l'unico con un *CI* che esclude 0.5, ma dal lato opposto a quello atteso (*AUC* significativamente sotto 0.5): questo non va interpretato come evidenza che le _feature_ tecniche abbiano potere predittivo negativo. È più plausibile un artefatto statistico: l'_ablation_ usa iperparametri fissi e non ottimizzati su un sottoinsieme di sole 6 _feature_, e con un intervallo di confidenza al 95% applicato a 5 test in sequenza (uno per gruppo più il totale) senza correzione per confronti multipli, è statisticamente atteso circa un caso su venti di *CI* che esclude 0.5 per puro rumore. Nessuna delle metriche di questa sezione, in altre parole, offre evidenza credibile di un segnale predittivo isolabile in una specifica famiglia di _feature_.

== Sintesi dei risultati

I risultati sperimentali di questo capitolo, ottenuti applicando rigorosamente la metodologia di validazione statistica descritta nel capitolo 4, non forniscono evidenza di un segnale predittivo per la direzione settimanale del prezzo di Bitcoin, integrando _sentiment_ testuale, indicatori tecnici, metriche _on-chain_/energetiche e _sentiment_ di mercato aggregato, che sia statisticamente distinguibile dal caso. Questa conclusione è supportata da tre linee di evidenza indipendenti e concordanti: gli intervalli di confidenza _bootstrap_ sulle metriche del modello combinato includono sistematicamente il valore corrispondente a un classificatore casuale, l'_ablation_ per famiglia di _feature_ non isola alcun sottoinsieme con potere predittivo dimostrabile e un ampliamento sostanziale del _set_ di _feature_ (esperimento di robustezza) non produce alcun miglioramento misurabile. Il risultato, per quanto negativo rispetto all'ipotesi di ricerca formulata in Introduzione, è metodologicamente solido proprio perché accompagnato, a differenza della maggior parte dei lavori esaminati nel capitolo di analisi della letteratura, da una quantificazione esplicita dell'incertezza statistica. Le implicazioni di questo risultato per il problema di ricerca e per la letteratura esistente sono discusse nel capitolo successivo.

#pagebreak()

= Conclusioni <sec-conclusioni>

== Sintesi del lavoro svolto

Questa tesi ha affrontato la predizione della direzione settimanale del prezzo di Bitcoin integrando _sentiment_ estratto da _post_ Reddit tramite un modello linguistico, indicatori tecnici di mercato, metriche _on-chain_/energetiche e un indice di _sentiment_ di mercato aggregato, all'interno di una _pipeline_ software modulare e riproducibile. A differenza di gran parte dei lavori esaminati nel capitolo di analisi della letteratura, l'intero impianto sperimentale è stato progettato attorno a un vincolo metodologico esplicito: nessun risultato di generalizzazione sarebbe stato accettato senza una verifica sistematica dell'assenza di _look-ahead bias_ e senza una quantificazione esplicita dell'incertezza statistica associata.

== Risposta al problema di ricerca

Il problema di ricerca formulato in Introduzione chiedeva se esistesse un segnale predittivo, per la direzione settimanale del prezzo di Bitcoin, statisticamente distinguibile dal caso. I risultati presentati nel capitolo precedente rispondono a questa domanda in modo negativo: gli intervalli di confidenza _bootstrap_ sulle metriche del modello includono sistematicamente il valore corrispondente a un classificatore privo di potere predittivo, l'_ablation_ per famiglia di _feature_ non isola alcun sottoinsieme con un segnale dimostrabile, e un ampliamento sostanziale del _set_ di _feature_ non produce miglioramenti misurabili.

Questo esito, per quanto in apparente contrasto con alcuni dei lavori esaminati nel capitolo di analisi della letteratura che riportano capacità predittive elevate, non ne è necessariamente in contraddizione: come discusso nella sezione @sec-quant-incertezza, la maggior parte di quei lavori non accompagna i propri risultati con una quantificazione dell'incertezza statistica, rendendo impossibile stabilire se le prestazioni riportate siano distinguibili dal caso con lo stesso rigore applicato in questo lavoro. Il risultato ottenuto è inoltre coerente con l'ipotesi di efficienza informativa dei mercati delle criptovalute su orizzonti temporali brevi, e con i risultati di un precedente lavoro dell'autore condotto con un impianto metodologico differente.

== Contributi metodologici

Indipendentemente dall'esito negativo rispetto al problema di ricerca, questo lavoro fornisce tre contributi che restano validi:

+ Una _pipeline_ software modulare e riproducibile per l'integrazione di fonti dati eterogenee (testuali, di mercato, _on-chain_/energetiche, di _sentiment_ aggregato) nella predizione del prezzo di Bitcoin, verificata sistematicamente per l'assenza di _look-ahead bias_ in ogni fase, dalla costruzione delle _feature_ alla selezione del modello.
+ Una metodologia di validazione temporale che combina _walk-forward_ con _re-tuning_ periodico condizionato e quantificazione _bootstrap_ dell'incertezza, corredata da una verifica esplicita delle assunzioni statistiche sottostanti (indipendenza temporale dei residui, sezione @sec-quant-incertezza), raramente presente nei lavori affini esaminati.
+ Un'analisi di interpretabilità a doppio livello (_Feature Importance_ nativa e valori *SHAP*), che colma una lacuna comune alla quasi totalità dei lavori confrontati nel capitolo di letteratura, indipendentemente dalla loro complessità architetturale.

== Limiti dello studio

Il limite principale di questo lavoro, discusso più volte nei capitoli precedenti, è l'ampiezza campionaria del _dataset_: circa 107 settimane di osservazioni, un vincolo strutturale legato sia alla cadenza settimanale scelta sia alla disponibilità storica delle fonti dati integrate. Questo limite si traduce in intervalli di confidenza ampi per qualunque metrica calcolata, che rendono difficile distinguere un'assenza genuina di segnale da un segnale debole ma reale, non rilevabile con la potenza statistica disponibile.

Un secondo limite riguarda la scelta di accoppiare la frequenza di campionamento dei dati all'orizzonte dell'obiettivo di predizione (sezione @sec-formulazione-problema): sebbene motivata da ragioni pratiche legate alla scarsità del campione di _sentiment_ e alla complessità di integrazione di fonti a frequenze eterogenee, questa scelta non è stata confrontata empiricamente con un'alternativa a granularità disaccoppiata, che potrebbe preservare informazione intra-settimanale attualmente scartata dal ricampionamento.

Un terzo limite riguarda la generalizzabilità temporale dei risultati: il periodo di _walk-forward_ analizzato copre un intervallo relativamente contenuto della storia di Bitcoin, e i risultati potrebbero non essere rappresentativi di regimi di mercato non osservati in questo campione.

== Sviluppi futuri

Sulla base dei limiti individuati, si delineano quattro direttrici di sviluppo prioritarie:

- *Estensione dello storico disponibile*: Un ampliamento del periodo di osservazione (idealmente ad almeno 3 anni di dati settimanali) ridurrebbe l'ampiezza degli intervalli di confidenza, aumentando la potenza statistica disponibile per distinguere un segnale debole ma reale dal rumore campionario, senza richiedere modifiche all'impianto metodologico già validato.

- *Fonti dati non ancora esplorate*: Il posizionamento sui mercati dei derivati (in particolare il _funding rate_ dei contratti perpetui, un _proxy_ della leva e del _sentiment_ speculativo aggregato), i flussi netti di Bitcoin verso e dagli _exchange_ centralizzati, e l'integrazione di notizie da fonti giornalistiche di settore specializzate, non sono stati testati in questo lavoro e rappresentano estensioni naturali del vettore multivariato attualmente impiegato.

- *Disaccoppiamento tra granularità dei dati e orizzonte di predizione*: Come discusso nei limiti, mantenere i dati di mercato alla loro frequenza nativa per il calcolo delle _feature_, aggregandoli internamente a ciascuna settimana anziché ricampionarli fin dall'origine, permetterebbe di preservare informazione intra-settimanale (ad esempio la volatilità realizzata calcolata su rendimenti giornalieri anziché stimata da un singolo prezzo di chiusura) senza alterare l'orizzonte dell'obiettivo di predizione.

- *Confronto sistematico con modelli a minore complessità*: Un confronto diretto con una regressione logistica regolarizzata, o con altri classificatori a minor numero di parametri rispetto a *XGBoost*, permetterebbe di verificare se la ridotta ampiezza campionaria favorisca modelli a minore capacità, un'ipotesi plausibile ma non testata in questo lavoro.

- *Validazione di robustezza aggiuntiva*: Il confronto con _dataset_ storici alternativi di _post social_ (ad esempio un campione Reddit relativo al periodo 2016-2019), utile a verificare se l'assenza di segnale osservata sia specifica al periodo qui analizzato o si estenda a regimi di mercato differenti.

== Possibili utilizzi

Al di là del problema di ricerca specifico affrontato, la _pipeline_ sviluppata in questo lavoro si presta a un uso più ampio di quello di produrre segnali di _trading_. In primo luogo, può essere impiegata come _framework_ metodologico riutilizzabile per future ricerche sulla relazione tra _sentiment social_ e mercati finanziari, in particolare _crypto_: la separazione netta tra raccolta dati, _feature engineering_ causale, ottimizzazione degli iperparametri e validazione statistica rende la _pipeline_ adattabile a nuove fonti dati, nuovi orizzonti temporali o nuovi _asset_ con un impatto limitato sulle componenti già validate.

In secondo luogo, il lavoro si presta a un uso didattico e di riferimento metodologico: la sequenza di criticità individuate e corrette nel corso dello sviluppo (_overfitting_ nella selezione degli iperparametri, rischio di _leakage_ nel _gap-filling_ delle _feature_ testuali, disallineamento nella costruzione del _target_) e gli strumenti diagnostici sviluppati per individuarle (_bootstrap_ con verifica delle assunzioni, controllo di stabilità del regime, _ablation_ per famiglia di _feature_) costituiscono un caso di studio concreto sulle insidie metodologiche tipiche della modellazione predittiva su serie finanziarie con campioni di ampiezza contenuta, un problema più generale della sola predizione di Bitcoin.

Infine, qualora gli sviluppi futuri delineati sopra (in particolare l'estensione dello storico e l'integrazione di nuove fonti dati) producessero un segnale predittivo statisticamente significativo, l'infrastruttura di raccolta dati, addestramento e validazione qui sviluppata è già predisposta per essere collegata a un sistema di notifica operativo, così da tradurre l'_output_ del modello in un segnale consultabile senza ulteriori interventi architetturali sulla _pipeline_ sottostante.

#pagebreak()

#set heading(numbering: none)

= Ringraziamenti

\

_Ringrazio i miei genitori, Rosanna e Agostino, per aver sempre supportato i miei studi e creduto nella mia capacità di specializzarmi in una materia che studio ormai da dieci anni._

_Ringrazio il Professor Navarin per avermi dato l'opportunità di lavorare a questo progetto, in un ambito scientifico interessante e innovativo in cui intendo proseguire. Lo ringrazio inoltre per avermi guidato con disponibilità e chiarezza, sia durante il tirocinio sia nella redazione di questa tesi._

_Ringrazio gli amici storici di Caorle, per essere stati sempre presenti in ogni momento della mia vita, che fosse un fallimento o un traguardo come questo._

_Ringrazio la mia comitiva di Padova, un gruppo di amici in cui riesco sempre a trovare spunti di riflessione e di discussione genuina._

_Ringrazio i miei amici sparsi per l'Italia per aver condiviso le sessioni di studio online durante gli esami, senza i quali non avrei avuto la forza di dedicarmi con continuità allo studio delle materie di questo corso di laurea._

_Ringrazio i miei nonni, zii e cugini che, per quanto alcuni siano geograficamente distanti centinaia di chilometri, hanno sempre mostrato interesse e supportato il mio percorso accademico._

_Grazie._

#pagebreak()

= Bibliografia e Sitografia

- [1] Y. Xiao, E. Sun, D. Luo, and W. Wang, "Trading Agents: Multi-Agents LLM Financial Trading Framework", arXiv preprint arXiv:2412.20138v7, 2026.

- [2] A. Hafid, M. Rahouti, L. Kong, M. Ebrahim, and M. A. Serhani, "Predicting Bitcoin Market Trends with Enhanced Technical Indicator Integration and Classification Models", arXiv preprint arXiv:2410.06935v1, 2024.

- [3] N. Sapra, I. Shaikh, and D. Roubaud, "Unraveling environmental threads: Bitcoin prices, energy consumption, and crypto market volatility", Energy Economics, vol. 156, p. 109216, 2026.

- [4] C. M. Liapis, A. Karanikola, and S. Kotsiantis, "A Multi-Method Survey on the Use of Sentiment Analysis in Multivariate Financial Time Series Forecasting", Entropy, vol. 23, no. 12, p. 1603, 2021.

- [5] J. Manogna, G. S. Chowdary, G. Meghana, and P. C. Nair, "Bitcoin Price Prediction Based on Sentiment Analysis", in 2023 IEEE 20th India Council International Conference (INDICON), 2023, pp. 1–5.

- [6] H. Anand and A. Arya, "An Empirical Study of Financial BERT Models for Sentiment Analysis and Cryptocurrency Price Correlation", in 2024 IEEE 9th International Conference for Convergence in Technology (I2CT), 2024, pp. 1–6.

- [7] C. Kaur, Samrity, R. Uppal, and S. Kaur, "Twitter Sentiment Analysis of Bitcoin Price Fluctuation with Machine Learning Techniques", in 2025 Seventh International Conference on Computational Intelligence and Communication Technologies (CCICT), 2025, pp. 1–6.

- [8] S. Vasishth, S. K. Sharma, A. K. Nayyar, and K. Vijayakuamar, "Impact of Elon Musk's tweets on the price of Dogecoin using Sentiment Analysis", in 2023 International Conference on Advances in Computing, Communication and Applied Informatics (ACCAI), 2023, pp. 1–6.

- [9] O. Sattarov and H. S. Jeon, "Forecasting Bitcoin Price Fluctuation by Twitter Sentiment Analysis", in 2020 International Conference on Information Science and Communications Technologies (ICISCT), 2020, pp. 1–4.

- [10] J. Gomes Jr., H. Bernardino, A. B. Vieira, V. Dorner, and D. Svetinovic, "Cryptoeconomic User Behavior in the Acute Stages of Geopolitical Conflict", IEEE Transactions on Computational Social Systems, vol. 11, no. 5, pp. 7055–7067, Oct. 2024.

- [11] Kraken Learn, "Cosa determina il calo del prezzo dei Bitcoin?", Kraken.com, 2025.

- [12] Kraken Learn, "Quanti Bitcoin esistono? Spiegazione della fornitura dei Bitcoin", Kraken.com, 2025.

- [13] GeeksforGeeks, "Bootstrap Method", geeksforgeeks.org, 2025.

- [14] B. Efron, "Bootstrap methods: another look at the jackknife", The Annals of Statistics, vol. 7, no. 1, 1979, pp. 1–26.

- [15] Kraken Learn, "Bitcoin mining: A complete guide", Kraken.com, 2024

- [16] XGBoost, "XGBoost Documentation", xgboost.readthedocs.io

#pagebreak()

= Glossario

- *Ablation* <gloss-ablation>: Procedura sperimentale che consiste nel rimuovere o isolare sistematicamente componenti di un sistema (in questa tesi, famiglie di _feature_) per misurarne il contributo individuale alle prestazioni del modello.

- *API* <gloss-api>: _Application Programming Interface._ Interfaccia che consente a un programma di accedere a dati o funzionalità offerte da un servizio esterno secondo regole predefinite.

- *ASCII* <gloss-ascii>: _American Standard Code for Information Interchange._ Standard di codifica dei caratteri testuali, limitato all'alfabeto latino di base e a un insieme ristretto di simboli.

- *AUC* <gloss-auc>: _Area Under the Curve._ Area sottesa alla curva *ROC*, sintetizza in un unico valore la capacità di un classificatore binario di distinguere tra le due classi su tutte le possibili soglie decisionali. Assume valore 0.5 per un classificatore privo di potere predittivo e 1.0 per un classificatore perfetto.

- *_Backtesting_* <gloss-backtesting>: Simulazione retrospettiva di una strategia operativa (in questa tesi, di investimento) su dati storici, per stimarne il rendimento e il rischio come se fosse stata effettivamente eseguita in passato.

- *_Baseline_* <gloss-baseline>: Strategia o modello di riferimento, tipicamente semplice, usato come termine di paragone per valutare se un modello più complesso apporti un reale vantaggio.

- *BiGRU* <gloss-bigru>: _Bidirectional Gated Recurrent Unit._ Variante bidirezionale delle _Gated Recurrent Unit_, una tipologia di rete neurale ricorrente usata per l'elaborazione di sequenze (es. testo, serie temporali).

- *_Blockchain_* <gloss-blockchain>: Registro distribuito e immutabile di transazioni, organizzato in blocchi concatenati crittograficamente. È l'infrastruttura sottostante a Bitcoin e alla generalità delle criptovalute.

- *_Bootstrap_* <gloss-bootstrap>: Tecnica statistica di ricampionamento con reinserimento a partire da un campione osservato, utilizzata per stimare la distribuzione empirica di una statistica (in questa tesi, per calcolare intervalli di confidenza) senza assumere una distribuzione teorica nota [13][14].

- *BTC* <gloss-btc>: Simbolo (_ticker_) con cui viene identificato Bitcoin sui mercati finanziari.

- *_Buy \& Hold_* <gloss-buyhold>: Strategia di investimento passiva che consiste nell'acquistare un _asset_ e mantenerlo per l'intero periodo considerato, senza operazioni di compravendita intermedie. Usata in questa tesi come _baseline_ di confronto.

- *BWC* <gloss-bwc>: _Biwavelet Coherence._ Tecnica statistica per l'analisi della coerenza tra due serie temporali nel dominio tempo-frequenza.

- *CBECI* <gloss-cbeci>: _Cambridge Bitcoin Electricity Consumption Index._ Indice sviluppato dall'Università di Cambridge per stimare il consumo energetico della rete Bitcoin.

- *_Checkpoint_* <gloss-checkpoint>: Punto di salvataggio intermedio dello stato di un'elaborazione, che ne consente la ripresa da quel punto in caso di interruzione, senza dover ripetere il lavoro già svolto.

- *CI (_Confidence Interval_)* <gloss-ci>: Intervallo di confidenza. Intervallo di valori, calcolato a partire da un campione, entro cui si stima che il vero valore di un parametro statistico ricada con una probabilità prefissata (in questa tesi, il 95%).

- *Correlogramma* <gloss-correlogramma>: Rappresentazione grafica dell'autocorrelazione di una serie temporale a diversi ritardi (_lag_), utilizzata per verificare la presenza di dipendenza tra osservazioni successive.

- *_Cross-validation_* <gloss-crossvalidation>: Tecnica di validazione che suddivide ripetutamente i dati disponibili in porzioni di addestramento e verifica, per ottenere una stima più robusta delle prestazioni di un modello.

- *CSV* <gloss-csv>: _Comma-Separated Values._ Formato di file testuale per la rappresentazione di dati tabellari, in cui i valori sono separati da virgole.

- *DOGE* <gloss-doge>: Simbolo (_ticker_) con cui viene identificata Dogecoin sui mercati finanziari.

- *_Drawdown_* <gloss-drawdown>: Riduzione percentuale del valore di un portafoglio o di una strategia rispetto al suo massimo storico precedente. Il _Maximum Drawdown_ è la riduzione più ampia osservata nel periodo considerato.

- *_Exchange_* <gloss-exchange>: Piattaforma centralizzata o decentralizzata che consente la compravendita di criptovalute.

- *_Feature_* <gloss-feature>: Variabile di input utilizzata da un modello di _machine learning_ per effettuare una predizione.

- *_Feature Engineering_* <gloss-featureengineering>: Processo di costruzione, trasformazione e selezione delle _feature_ a partire dai dati grezzi, finalizzato a migliorare la capacità predittiva di un modello.

- *_Feature Importance_* <gloss-featureimportance>: Misura di quanto ciascuna _feature_ contribuisca alle predizioni di un modello. Nel caso di modelli ad alberi come *XGBoost*, è tipicamente calcolata in base al guadagno informativo (_gain_) apportato da ciascuna _feature_ nella costruzione degli alberi.

- *FinBERT* <gloss-finbert>: Modello linguistico basato sull'architettura *BERT*, sottoposto a un ulteriore addestramento (_fine-tuning_) su testi del dominio finanziario, per una classificazione del _sentiment_ più accurata in questo contesto.

- *_Funding rate_* <gloss-fundingrate>: Tasso periodico scambiato tra le posizioni lunghe e corte nei contratti _perpetual_ (futures senza scadenza), usato per ancorare il prezzo del derivato a quello dell'_asset_ sottostante. Un _proxy_ comune del sentiment speculativo aggregato.

- *_Gain_* <gloss-gain>: Nel contesto degli alberi di decisione, il miglioramento nella funzione di perdita ottenuto da uno _split_ basato su una determinata _feature_. Alla base del calcolo standard di _Feature Importance_ in *XGBoost*.

- *GPU* <gloss-gpu>: _Graphics Processing Unit._ Processore originariamente progettato per l'elaborazione grafica, oggi ampiamente utilizzato per l'addestramento di modelli di _deep learning_ grazie alla sua capacità di calcolo parallelo.

- *_Halving_* <gloss-halving>: Evento protocollare di Bitcoin, che si verifica circa ogni quattro anni, in cui la ricompensa assegnata ai _miner_ per ogni blocco validato viene dimezzata.

- *_Hash rate_* <gloss-hashrate>: Potenza di calcolo complessiva impiegata dai nodi di una rete _blockchain_ per validare le transazioni, misurata in operazioni di _hashing_ al secondo.

- *HTML* <gloss-html>: _HyperText Markup Language._ Linguaggio di markup standard per la struttura dei contenuti sul web.

- *JSON* <gloss-json>: _JavaScript Object Notation._ Formato testuale leggero per lo scambio di dati strutturati, ampiamente utilizzato nelle *API* web.

- *KNN* <gloss-knn>: _K-Nearest Neighbors._ Algoritmo di classificazione (o regressione) che assegna a una nuova osservazione la classe più frequente tra i suoi $k$ vicini più prossimi nello spazio delle _feature_.

- *KOL* <gloss-kol>: _Key Opinion Leader._ Individuo con un'ampia influenza su un pubblico di riferimento, i cui interventi pubblici (es. sui _social media_) possono avere un impatto misurabile sul comportamento di mercato.

- *_Leakage_ (_look-ahead bias_)* <gloss-leakage>: Introduzione, involontaria o implicita, di informazione non disponibile al momento della predizione all'interno del processo di addestramento o validazione di un modello, che porta a una sovrastima delle sue reali capacità predittive.

- *Ljung-Box (test di)* <gloss-ljungbox>: Test statistico che verifica congiuntamente se le autocorrelazioni di una serie temporale fino a un certo numero di ritardi (_lag_) sono, nel complesso, significativamente diverse da zero.

- *LLM* <gloss-llm>: _Large Language Model._ Modello linguistico di grandi dimensioni, addestrato su ampi corpus testuali, in grado di comprendere e generare testo in linguaggio naturale.

- *LSTM* <gloss-lstm>: _Long Short-Term Memory._ Tipologia di rete neurale ricorrente progettata per apprendere dipendenze a lungo termine in dati sequenziali, mitigando il problema della scomparsa del gradiente.

- *MACD* <gloss-macd>: _Moving Average Convergence Divergence._ Indicatore di analisi tecnica che misura la relazione tra due medie mobili esponenziali del prezzo a periodi diversi. La differenza tra le due medie costituisce la linea *MACD*. Una terza media mobile di questa differenza costituisce la linea di segnale. L'istogramma *MACD*, utilizzato come _feature_ in questa tesi, è la differenza tra la linea *MACD* e la linea di segnale, e ne cattura i cambi di _momentum_.

- *_Mining_* <gloss-mining>: Processo attraverso cui i nodi di una rete _blockchain_ basata su _proof-of-work_ (come Bitcoin) validano le transazioni e generano nuovi blocchi, ricevendo in cambio una ricompensa.

- *NLP* <gloss-nlp>: _Natural Language Processing._ Ambito dell'intelligenza artificiale dedicato all'elaborazione automatica del linguaggio naturale.

- *NLTK* <gloss-nltk>: _Natural Language Toolkit._ Libreria Python per l'elaborazione del linguaggio naturale.

- *OHLCV* <gloss-ohlcv>: Acronimo di _Open, High, Low, Close, Volume_: i cinque valori standard con cui viene descritta una candela di prezzo in un dato intervallo temporale (apertura, massimo, minimo, chiusura, volume scambiato).

- *_On-chain_* <gloss-onchain>: Riferito a dati o attività registrati direttamente sulla _blockchain_ (es. transazioni, indirizzi, flussi di capitale), in contrapposizione a dati _off-chain_ raccolti da fonti esterne.

- *_p-value_* <gloss-pvalue>: Nel contesto di un test di ipotesi statistico, la probabilità di osservare un risultato pari o più estremo di quello effettivamente osservato, assumendo vera l'ipotesi nulla. Convenzionalmente, un _p-value_ inferiore a 0.05 è considerato indicativo di significatività statistica.

- *_Precision_* <gloss-precision>: Proporzione di predizioni positive che risultano effettivamente corrette, tra tutte le predizioni positive effettuate da un classificatore.

- *_Pruning_* <gloss-pruning>: Rimozione sistematica di elementi ridondanti o poco informativi da un insieme (in questa tesi, di _feature_), con l'obiettivo di semplificare il modello e ridurre il rischio di _overfitting_.

- *_Purge gap_* <gloss-purgegap>: Margine temporale introdotto deliberatamente tra la porzione di addestramento e quella di test di un _dataset_ sequenziale, per prevenire che _feature_ calcolate su finestre mobili condividano informazione tra le due porzioni.

- *PWC* <gloss-pwc>: _Partial-Wavelet Transform Coherence._ Estensione della _Wavelet Coherence_ che isola la relazione tra due serie temporali al netto dell'influenza di una terza variabile.

- *_Recall_* <gloss-recall>: Proporzione di casi positivi effettivamente identificati come tali da un classificatore, tra tutti i casi realmente positivi presenti nei dati.

- *Rendimento logaritmico* <gloss-rendimentolog>: Variazione percentuale del prezzo tra due periodi consecutivi, espressa in scala logaritmica anziché come rapporto semplice. A differenza del rendimento semplice, è additivo su più periodi ed è la forma più comunemente utilizzata in finanza quantitativa per le proprietà statistiche più favorevoli (distribuzione più simmetrica, additività temporale).

- *ROC* <gloss-roc>: _Receiver Operating Characteristic._ Curva che rappresenta, al variare della soglia decisionale di un classificatore binario, il tasso di veri positivi in funzione del tasso di falsi positivi. L'area sottesa a questa curva costituisce l'*AUC*.

- *RSI* <gloss-rsi>: _Relative Strength Index._ Indicatore di analisi tecnica che misura la velocità e l'ampiezza delle variazioni di prezzo recenti, su una scala da 0 a 100, per identificare condizioni di ipercomprato (valori elevati) o ipervenduto (valori bassi).

- *SenticNet* <gloss-senticnet>: Risorsa e strumento di _sentiment analysis_ basato su un approccio ibrido tra conoscenza semantica strutturata e tecniche di _deep learning_.

- *_Sentiment_* <gloss-sentiment>: Orientamento emotivo o valutativo (positivo, negativo, neutro) espresso in un testo, oggetto di analisi automatica nella _sentiment analysis_.

- *_Sentiment Analysis_* <gloss-sentimentanalysis>: Insieme di tecniche computazionali per l'identificazione e l'estrazione automatica del _sentiment_ da testi.

- *Sharpe Ratio* <gloss-sharperatio>: Indicatore di rendimento aggiustato per il rischio, calcolato come rapporto tra il rendimento in eccesso di un investimento (rispetto a un tasso privo di rischio) e la sua volatilità.

- *SHAP* <gloss-shap>: _SHapley Additive exPlanations._ Metodo di interpretabilità dei modelli di _machine learning_ basato sulla teoria dei giochi cooperativi di Shapley, che scompone l'_output_ di un modello nella somma dei contributi marginali di ciascuna _feature_.

- *_Subreddit_* <gloss-subreddit>: Comunità tematica all'interno della piattaforma Reddit, dedicata a uno specifico argomento di discussione.

- *SVM* <gloss-svm>: _Support Vector Machines._ Algoritmo di classificazione (o regressione) che individua l'iperpiano ottimale in grado di separare le classi presenti nei dati con il margine più ampio possibile.

- *_Target_* <gloss-target>: Variabile che un modello di _machine learning_ supervisionato è addestrato a predire.

- *TextBlob* <gloss-textblob>: Libreria Python per l'elaborazione del linguaggio naturale, che include un modulo di _sentiment analysis_ basato su un dizionario lessicale.

- *TF-IDF* <gloss-tfidf>: _Term Frequency-Inverse Document Frequency._ Misura statistica che valuta l'importanza di un termine all'interno di un documento rispetto a una collezione di documenti, bilanciando la frequenza del termine nel documento e la sua rarità nella collezione.

- *TreeExplainer* <gloss-treeexplainer>: Implementazione del metodo *SHAP* ottimizzata per modelli ad alberi (come *XGBoost*), in grado di calcolare valori *SHAP* esatti anziché approssimati.

- *URL* <gloss-url>: _Uniform Resource Locator._ Indirizzo che identifica univocamente una risorsa sul web.

- *USD* <gloss-usd>: Codice valutario del dollaro statunitense.

- *VADER* <gloss-vader>: _Valence Aware Dictionary and sEntiment Reasoner._ Strumento di _sentiment analysis_ basato su un dizionario lessicale, ottimizzato per testi brevi e informali tipici dei _social media_.

- *_Volatility_* <gloss-volatility>: Misura statistica della dispersione dei rendimenti di un _asset_ in un dato periodo, tipicamente calcolata come deviazione standard dei rendimenti. Un indicatore comune del livello di rischio o incertezza di mercato.

- *_Walk-forward validation_* <gloss-walkforward>: Procedura di validazione per serie temporali in cui il modello viene riaddestrato progressivamente su una finestra di dati crescente e valutato, a ogni passo, su una singola osservazione futura mai utilizzata in addestramento, per simulare realisticamente l'utilizzo operativo del modello.

- *XGBoost* <gloss-xgboost>: _eXtreme Gradient Boosting._ Libreria e algoritmo di _machine learning_ basato sul _gradient boosting_ di alberi di decisione, noto per l'efficienza computazionale e per i meccanismi di regolarizzazione nativi.