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
  )[Titolo provvisorio]


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

= Analisi della Letteratura

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

== J. Manogna et al. (2023) - _Bitcoin Price Prediction Based on Sentiment Analysis_

=== Disamina del _paper_

Questo studio propone un _framework_ predittivo a breve termine per i movimenti di prezzo di Bitcoin focalizzandosi sull'estrazione del _sentiment_ in tempo reale dalla piattaforma _social_ Twitter (tramite Twitter API) in combinazione con i dati storici di prezzo di CoinMarketCap. Gli autori estraggono le metriche testuali grezze e utilizzano tecniche di _Natural Language Processing_ (*NLP*) per calcolare i punteggi di _sentiment_ (positivo, negativo, neutro). Successivamente, integrano questi dati con lo storico dei prezzi per addestrare modelli di _Deep Learning_ sequenziali, nello specifico reti _Long Short-Term Memory_ (*LSTM*) e _Bidirectional Gated Recurrent Units_ (*BiGRU*). I risultati empirici del _paper_ evidenziano come i modelli basati su reti neurali ricorrenti beneficino sensibilmente dell'aggiunta del _sentiment_ dei _social media_, ottenendo un'elevata precisione nel catturare le fluttuazioni di prezzo giornaliere rispetto ai modelli statistici tradizionali.

=== Limitazioni e Differenze di Applicazione

L'approccio addottato in questo _paper_, pur confermando la reattività del prezzo di Bitcoin ai flussi informativi dei _social_, presenta limiti rilevanti sotto il profilo della stabilità e dell'interpretabilità:

- *Elevato rumore e volatilità dei dati _social_*: L'affidamento esclusivo su Twitter introduce una massiccia quantità di rumore di fondo (spam, bot, post speculativi o manipolatori). Questa reattività estrema rende il modello adatto principalmente a predizioni su brevissimo termine (giornaliero o intra-giornaliero), ma altamente instabile se applicato a strategie di investimento con un orizzonte temporale più esteso.

- *Natura "Black Box" del Deep Learning*: L'utilizzo di architetture *LSTM* e *BiGRU* preclude una reale comprensione delle dinamiche interne del modello. Gli autori non integrano strumenti quantitativi di spiegazione algoritmica, rendendo impossibile stabilire in che misura esatta il sentiment pesi sulla decisione finale rispetto ai trend storici del prezzo.

=== Conclusioni

Il presente lavoro si aggancia alle tesi del presente _paper_ circa l'utilità dei dati _social_, ma ne corregge i limiti strutturali attraverso un disegno sperimentale comparativo e trasparente. In primo luogo, l'orizzonte temporale viene spostato su base settimanale, una granularità più adatta a stabilizzare il segnale macroeconomico rispetto alla volatilità frenetica dei _tweet_ giornalieri. In secondo luogo, per superare il problema del rumore isolato dei _social_, questo progetto introduce un approccio ibrido a due canali: il _sentiment_ estratto dai _social media_ viene messo a confronto diretto e combinato con quello di notizie finanziarie strutturate (CoinDesk, CoinTelegraph). Infine, l'opacità delle reti *LSTM* viene superata a favore del classificatore _*XGBoost*_.

== H. Anand et al. (2024) - _An Empirical Study of Financial BERT Models for Sentiment Analysis and Cryptocurrency Price Correlation_

Questo _paper_ presenta un'analisi empirica e comparativa sull'efficacia di diversi strumenti di _Sentiment Analysis_ – sia lessicali che basati su architetture _Transformer_ di _Deep Learning_ nel determinare la correlazione tra il _sentiment_ del pubblico e le fluttuazioni di prezzo delle criptovalute, con un focus verticale su Bitcoin. Gli autori mettono a confronto diretto quattro modelli speculativi: *VADER* e _*SenticNet*_ (approcci basati su dizionari), e _*FinBERT*_ e _*CryptoBERT*_ (modelli pre-addestrati basati su *BERT* e specializzati rispettivamente nel dominio finanziario e crittografico). Inoltre, il _paper_ illustra il _fine-tuning_ di un modello _*DistilBERT*_ per catturare le relazioni non lineari tra il testo e i trend di mercato, riportando un coefficiente di correlazione estremamente elevato, pari a 0.88, tra il _sentiment_ aggregato e i movimenti di prezzo.

=== Limitazioni e Differenze di Applicazione

Sebbene il contributo fornisca una validazione cruciale sull'uso di modelli _domain-specific_ (come _*FinBERT*_ e _*CryptoBERT*_) rispetto a quelli generalisti, esso evidenzia due limiti sul piano dell'architettura predittiva complessiva:

- *Mancanza di un modello di classificazione e _machine learning_ a valle*: Il _paper_ si ferma a un'analisi di tipo puramente statistico e correlazionale. Gli autori dimostrano che esiste un forte legame matematico tra l'andamento del _sentiment_ e quello del prezzo, ma non utilizzano questo segnale come _feature_ di input per addestrare un algoritmo predittivo o di classificazione.

- *Assenza di indicatori tecnici e modulo di Backtesting*: L'analisi si concentra esclusivamente sulla componente testuale esterna. Ignorando gli indicatori di mercato interni (*RSI*, *MACD*) e non traducendo le decisioni in una simulazione di _trading_ reale (_backtesting_), il _framework_ non è in grado di misurare la sostenibilità economica o il rischio finanziario (_Sharpe Ratio_, _Drawdown_) delle metriche estratte.

=== Conclusioni

Il presente lavoro di tesi si configura come la naturale estensione ingegneristica e algoritmica dei risultati di questo _paper_. Presa per assodata l'eccellente correlazione dei modelli *BERT* finanziari dimostrata nel _paper_, questa tesi raccoglie la sfida e sposta il _framework_ sul piano predittivo ed economico. Il _sentiment_ ottimizzato (estratto e confrontato tramite *VADER* e _*FinBERT*_) non viene studiato in modo isolato, ma viene integrato in un vettore multivariato insieme agli indicatori tecnici e ai dati energetici del _mining_. Questo vettore alimenta direttamente un classificatore _*XGBoost*_ volto a produrre decisioni di _trading_ che, a differenza del _paper_ analizzato, vengono simulate e validate tramite un modulo di _backtesting_ finanziario per calcolare l'effettivo rendimento economico della strategia.

== C. Kaur et al. (2025) - _Twitter Sentiment Analysis of Bitcoin Price Fluctuation with Machine Learning Techniques_

=== Disamina del _paper_

Questo studio analizza la capacità predittiva dei post di Twitter nel determinare le fluttuazioni quotidiane dei rendimenti di Bitcoin. Gli autori raccolgono un _dataset_ di _tweet_ a tema criptovalute e utilizzano la libreria lessicale _*TextBlob*_ per l'estrazione e la classificazione del _sentiment_ (positivo, negativo, neutro). Una volta calcolati i punteggi di _sentiment_, questi vengono integrati con le variazioni storiche del prezzo di Bitcoin per addestrare ed effettuare un confronto tra diversi classificatori di _Machine Learning_ tradizionali: _Support Vector Machines_ (*SVM*), _Random Forest_, _Naive Bayes_ e _K-Nearest Neighbors_ (*KNN*). I risultati empirici evidenziano come i modelli come _Random Forest_ riescano a catturare parzialmente la direzione del _trend_ di mercato, confermando l'esistenza di un legame tra l'opinione pubblica sui _social media_ e i movimenti di prezzo dell'_asset_.

=== Limitazioni e Differenze di Applicazione

L'approccio metodologico di questo _paper_ presenta alcune limitazioni strutturali legate all'anzianità degli strumenti di *NLP* e all'orizzonte di validazione:

- *Inadeguatezza del modello NLP lessicale (TextBlob)*: L'utilizzo di _*TextBlob*_ rappresenta un limite critico nel contesto finanziario. Essendo un dizionario lessicale generico, non è in grado di cogliere l'ironia, il contesto o il gergo specifico del mercato crittografico generando un segnale di _sentiment_ piatto o distorto.

- *Mancanza di indicatori tecnici complessi e simulazione economica*: I classificatori vengono addestrati unicamente sull'interazione tra _sentiment_ grezzo e prezzo di chiusura, tralasciando indicatori macro-strutturali o di analisi tecnica (*RSI*, *MACD*, _Bollinger Bands_). Inoltre, il lavoro si ferma alle metriche di classificazione pura (_Accuracy_, _Precision_), omettendo un ambiente di backtesting che verifichi l'effettiva profittabilità finanziaria dei segnali generati.

=== Conclusioni

La presente tesi supera l'approccio di questo _paper_ introducendo un netto salto di qualità sia nell'estrazione del _sentiment_ che nella robustezza del modello predittivo. Al posto di algoritmi lessicali statici come TextBlob, questo framework adotta FinBERT e altri LLM moderni. Sul fronte predittivo, anziché affidarsi a classificatori standard isolati, si sfrutta la potenza di _*XGBoost*_ alimentato da un vettore di _feature_ ibrido e multivariato, che unisce al _sentiment_ avanzato sia gli indicatori tecnici che i dati energetici di rete. Infine, l'utilità del modello non viene stimata solo tramite metriche statistiche, ma viene validata sul campo simulando una reale strategia _Long/Short_ tramite un modulo di _Backtesting_ dedicato.

== K. Vijayakuamar et al. (2023) - _Impact of Elon Musk’s tweets on the price of Dogecoin using Sentiment Analysis_

=== Disamina del Paper

Questo contributo investiga l'impatto diretto dei flussi comunicativi generati dai cosiddetti _Key Opinion Leaders_ (*KOL*) sulla volatilità e sulle variazioni di prezzo delle criptovalute. Nello specifico, gli autori esaminano la correlazione tra i _tweet_ di Elon Musk e le oscillazioni di prezzo di Dogecoin (*DOGE*). Il _framework_ si avvale di due motori di *NLP* classici per l'estrazione della polarità del testo, mettendone a confronto i risultati: TextBlob e *VADER* (_Valence Aware Dictionary and Sentiment Reasoner_). I punteggi di _sentiment_ ottenuti vengono poi sovrapposti temporalmente alle serie storiche di Dogecoin per misurare l'effetto di _shock_ esterni concentrati. I risultati empirici confermano che i _tweet_ positivi o ironici del multimiliardario agiscono da catalizzatori immediati, innescando fiammate rialziste nel volume di _trading_ e nel valore dell'_asset_, evidenziando l'estrema sensibilità del comparto _crypto_ a singoli attori di rilievo.

=== Limitazioni e Differenze di Applicazione

Nonostante l'efficacia nel dimostrare il fenomeno della manipolazione o dell'influenza mediatica concentrata, l'approccio di questo paper mostra limiti evidenti sul piano della generalizzabilità algoritmica:

- *Focalizzazione su un singolo _asset_ speculativo (_Meme Coin_)*: Dogecoin è una _meme coin_ la cui capitalizzazione risente in modo anomalo della componente speculativa e sociale, rendendo i risultati difficilmente estendibili ad _asset_ strutturati e a grandissima capitalizzazione come Bitcoin, i quali rispondono a dinamiche macroeconomiche e di mercato molto più complesse.

- *Modelli NLP non contestuali e assenza di Machine Learning*: L'adozione di *VADER* e TextBlob, pur adatta a catturare stringhe testuali brevi, soffre dell'assenza di una comprensione semantica profonda dei _Transformer_. Inoltre, lo studio si limita a mappare una correlazione ex-post, senza addestrare un classificatore predittivo (come _*XGBoost*_) e senza testare l'efficacia dei segnali in una strategia di _trading_ formalizzata.

=== Conclusioni

La presente tesi raccoglie l'importante intuizione di questo _paper_ riguardante il peso dei flussi informativi, ma ne evolve l'impianto verso un modello scientificamente più solido e generalizzabile. Invece di monitorare l'effetto isolato di un singolo _account_ su una _meme coin_, questo progetto si focalizza sul Bitcoin, integrando il sentiment_ aggregato_ sia di canali _social_ distribuiti che di testate giornalistiche finanziarie verificate. L'accuratezza lessicale viene drasticamente migliorata sostituendo i dizionari statici con _*FinBERT*_ e altri *LLM*, garantendo la corretta interpretazione del contesto finanziario. Infine, la correlazione statistica viene qui tradotta in ingegneria delle _feature_, combinando il _sentiment_ con indicatori tecnici e metriche energetiche di _mining_ all'interno di un modello predittivo unificato e validato tramite simulazioni di _backtesting_.

== O. Sattarov et al. (2020) - _Forecasting Bitcoin Price Fluctuation by Twitter Sentiment Analysis_

=== Disamina del Paper

Questo studio analizza la capacità predittiva dei flussi di opinione di Twitter in merito alle fluttuazioni quotidiane del prezzo di Bitcoin, proponendo un approccio innovativo per l'anno di pubblicazione del _paper_. Gli autori estraggono un _dataset_ di _tweet_ legati all'ecosistema delle criptovalute e utilizzano il modulo *VADER* (_Valence Aware Dictionary and Sentiment Reasoner_), integrato nella libreria *NLTK*, per quantificare la polarità dei testi (positiva, negativa, neutra). Successivamente, combinando i punteggi di _sentiment_ aggregati giornalmente con la serie storica dei prezzi di chiusura dell'_asset_, gli autori addestrano e confrontano modelli di _Machine Learning_ tradizionali, tra cui _Support Vector Machines_ (*SVM*) e modelli di regressione lineare. I risultati empirici dimostrano che il _sentiment_ dei _social media_ possiede un effettivo potere predittivo, consentendo al _framework_ di raggiungere un'accuratezza del 62.48% nella classificazione della direzione del prezzo su base giornaliera.

=== Limitazioni e Differenze di Applicazione

L'impianto metodologico del lavoro risente inevitabilmente dell'anzianità della sua pubblicazione, mostrando limiti evidenti se confrontato con gli standard attuali:

- *Dipendenza da modelli NLP lessicali statici*: L'affidamento esclusivo su *VADER* rappresenta un forte limite intrinseco. Essendo un analizzatore basato su regole e dizionari linguistici statici, non è in grado di decodificare la semantica contestuale profonda, i neologismi, il sarcasmo o il gergo finanziario specialistico tipico della community crypto. Questo causa un'elevata percentuale di classificazione errata o neutrale di _tweet_ fortemente orientati.

- *Vettore di _feature_ minimale e assenza di _Backtesting_*: Il modello predittivo si basa esclusivamente sulla combinazione bivariata _Sentiment_-Prezzo storico. Viene del tutto trascurata l'integrazione di indicatori di analisi tecnica (come *RSI* o *MACD*) e di metriche macro-strutturali. Inoltre, il lavoro convalida i risultati solo tramite metriche di classificazione statistica pura (_Accuracy_), omettendo una simulazione di _trading_ reale che ne attesti la profittabilità economica al netto dei costi di transazione.

=== Conclusioni

Il presente lavoro adotta le conclusioni di questo _paper_ come una fondamentale _baseline_ storica, ma ne rivoluziona l'architettura per superarne i limiti strutturali. Sul piano del _Natural Language Processing_, l'approccio lessicale rudimentale di *VADER* viene qui sostituito (e messo a confronto) con _*FinBERT*_, un modello basato su _Transformer_ pre-addestrato su termini finanziari in grado di comprendere il contesto semantico specifico. Sul piano predittivo, il vettore delle _feature_ viene espanso in modalità multivariata e ibrida, affiancando al _sentiment_ avanzato sia gli indicatori tecnici che le metriche energetiche di mining. Infine, la capacità predittiva non viene testata su modelli classici isolati come *SVM*, ma viene affidata all'algoritmo _*XGBoost*_ e validata economicamente tramite un modulo di _backtesting_ finanziario su base settimanale, garantendo una stabilità operativa assente nel _paper_ analizzato.

==  Gomes Jr. et al. (2024) - _Cryptoeconomic User Behavior in the Acute Stages of Geopolitical Conflict_

=== Disamina del _paper_

Questo _paper_ esamina l'impatto degli _shock_ geopolitici di vasta scala sul comportamento degli utenti all'interno delle _blockchain_ di Bitcoin ed Ethereum, focalizzandosi sulle fasi immediatamente precedenti e successive allo scoppio del conflitto russo-ucraino. Gli autori utilizzano un approccio basato su grafi dinamici variabili nel tempo (_time-varying graphs_) per modellare la rete delle transazioni _on-chain_ in un arco temporale critico di quattro settimane (due settimane prima e due settimane dopo l'inizio delle ostilità). L'obiettivo è analizzare la reattività della rete in una fase definita "acuta". I risultati empirici rivelano anomalie strutturali significative nel comportamento macroeconomico degli utenti: nella fase di pre-conflitto si registra un atteggiamento fortemente cauto e attendista (caratterizzato da una contrazione delle transazioni e da dinamiche di accumulazione), mentre nella fase post-conflitto si osserva un ritorno alla normalità nei volumi, ma con uno spostamento netto (shift) nelle traiettorie dei flussi di capitale e nella topologia della rete di trasferimento del valore.

=== Limitazioni e Differenze di Applicazione

Nonostante l'eccellente e rigorosa ricostruzione analitica delle dinamiche operate sui registri distribuiti, il lavoro evidenzia limiti sul piano della tempestività predittiva e algoritmica:

- *Analisi ex-post e focalizzazione esclusivamente _on-chain_*: Lo studio ricostruisce i comportamenti in modo puramente retrospettivo. Inoltre, basandosi solo sulle transazioni registrate sulla _blockchain_, non correla questi mutamenti strutturali con i flussi informativi esterni in tempo reale, come il _sentiment_ espresso dai media finanziari o dai _social network_ nelle ore esatte dello scoppio della crisi.

- *Assenza di finalità predittive e di moduli di trading*: Il _framework_ è di stampo prettamente analitico e sociologico-economico. Non traduce la categorizzazione del comportamento degli utenti in presenza di conflitti in feature quantitative spendibili da un algoritmo di _Machine Learning_ per anticipare la direzione del _trend_ o per automatizzare decisioni di portafoglio.

Queste limitazioni sono prettamente dovute al fatto che il _paper_ non si occupa di informatica o _machine learning_ nello specifico ma di analisi sociologica-economica che si rivela comunque utile ai fini dello sviluppo del progetto di questa tesi.

=== Conclusioni

Il presente lavoro di tesi integra ed evolve le scoperte derivate da questo _paper_, convertendo un'evidenza analitica ex-post in un segnale predittivo operante in tempo reale. Il presupposto scientifico che il comportamento degli investitori di Bitcoin cambi in modo drastico durante i conflitti armati viene qui ingegnerizzato all'interno del vettore multivariato di _*XGBoost*_. Per superare il limite dell'analisi puramente _on-chain_, questo _framework_ sfrutta _*FinBERT*_ e altri *LLM* per intercettare istantaneamente il crollo del _sentiment_ e l'esplosione del panico geopolitico dai _feed_ di notizie globali e dai canali _social_ non appena l'evento si manifesta. In questo modo, l'algoritmo apprende la relazione matematica tra l'insorgere di uno _shock_ pubblico internazionale (catturato dal *NLP*) e le repentine fluttuazioni di prezzo di Bitcoin, testandone l'efficacia operativa e la protezione del capitale attraverso un modulo di _backtesting_ finanziario assente nel lavoro analizzato.

= Bibliografia e Sitografia

- #link("a", "[1]") Y. Xiao, E. Sun, D. Luo, and W. Wang, "Trading Agents: Multi-Agents LLM Financial Trading Framework" arXiv preprint arXiv:2412.20138v7, 2026. \ Disponibile a: #link("https://arxiv.org/pdf/2412.20138", "PDF")

- #link("a", "[2]") A. Hafid, M. Rahouti, L. Kong, M. Ebrahim, and M. A. Serhani, "Predicting Bitcoin Market Trends with Enhanced Technical Indicator Integration and Classification Models" arXiv preprint arXiv:2410.06935v1, 2024. \ Disponibile a: #link("https://arxiv.org/pdf/2410.06935", "PDF")

- #link("a", "[3]") N. Sapra, I. Shaikh, and D. Roubaud, "  " Energy Economics, vol. 156, p. 109216, 2026. \ Disponibile a: #link("https://pdf.sciencedirectassets.com/271683/1-s2.0-S0140988326X20023/1-s2.0-S0140988326000952/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjECgaCXVzLWVhc3QtMSJGMEQCIAkDH%2FgWJM3uoshWL2SDkd8Mm3psQNLTdVLa1bkZcZS6AiBGkoiYNZ1I8TI6HWszQDuFibeV2MhL8nrKHu9Y7%2F%2FuLiq8BQjx%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAUaDDA1OTAwMzU0Njg2NSIMF9Wrxadk8b%2BhgO4KKpAF4NLKTnVhBMxDCU44408ZbFPo2HTVFWeij8yQERT%2B8MdMoj0nJJ0mksy4ybGJ5cL%2BUuP%2FWPEzNmtLFml5%2Ff3OIRLn2dxO1CQ%2FKxARSbBGt4R7TpzjIMH3beUgYB7cYn2ATAq8rnkTCJE5ms1Owm2X5uyJ%2FgvfJUS0UAE0ydP9MQyfFFB3Y6WnYX2LR2%2Bi9fQeukwNtlN3%2FSHoBqlUaSdYXtWPz9RGL11PP1ArrMNOKj6WbWtNxGnkNPjVgfEKrEtB8jSDdDnytaQMuiP1lfmp36GJAnHHYKelgZFJpJ3HDt%2FXI4hUSb%2B1uCOhO0aAQj91sMzcwxgeC43kkAjANkrCTW55olnS47Pn1FynkpKHYPZQeI0WSuZLcVet0H1wg7l3x7DWaF9QIEERz9Q7FYDmX6EA%2BQSzJbrHsT4SwTSa4W2z9psAaIBJy1Z%2BxNeOIYs1NX4CWm6wcnX%2BYiE1qKo4EIsOorNlaRhibw92r2F%2B8sGitLnmGglhLDx3H3UxhYSKflEmnTIhEeEOMc%2FD1gZgK1otQJhZxO%2B7U%2F437rxoD6yONJ0sgSqzTXIeuXgzDCuZ2pQfpyg8PCtNSHZkqUYzbj5llhn6Rnlx65kKHchiI4S3aM%2BncMkEdlw983Le%2Bs%2BsCmDeVZ1AxWk5pBJtNtnMvuSGDOedw4Z03yZ8%2FjK56WKI3LeILFKsMXvn9LwCDrDo9vTUPimNCn91fJDSHRQLBGTNv%2FH0aQqFLcGhAwC0jscNTMCeLHmwL47kp%2F6nQTtpgUyAOxZH3oMWgLOwhanfpHIwX7vdHgp2DYF%2FjOqTn%2Fspo88DNsK5NEFPp2QYy2sUvTk6SY%2B9SPHdvOl5Y3Yh1up8kckp%2FKl9bmdFQG8DYXsw4LW30AY6sgEPtUKmcci5SXnsRpwUmNZJE3yDALKSWgXICoaluwNAuC3C4i6UiZtWkn7PTiCvFNmw0vOF0%2F7cVRP7AzTATipE%2F8Epc1aL%2FBqbndbINsCtMNgif8K%2Bt4bPlNrViyUJmp6C7Q8TnxU6GrvVrXA9hEtLGEdKa3%2FX6p1CXcPJvT8Yvz0f0PMlvanl%2FNbkTXYOD09Z20NlfK8xJ1eAjAolHEwd065j5gXGFzxm%2FNN185UWhlEt&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20260520T170246Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAQ3PHCVTY7YMELQSH%2F20260520%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=4ad904ea57a454420c1b62d14f4e87047427b2f083fcfc3baa24b8af98769508&hash=c73b4e65f4bdaa631c3bb77be981d7921245fcd3fad97e48dbb88e0bcde7531a&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S0140988326000952&tid=spdf-0c385172-31dd-472d-b92d-a936f5605160&sid=dfef7687124c6745d378c1c1425259ef3bcegxrqa&type=client&tsoh=d3d3LnNjaWVuY2VkaXJlY3QuY29t&rh=d3d3LnNjaWVuY2VkaXJlY3QuY29t&ua=071b5b0904070a5a55&rr=9fece9357a45eda3&cc=it", "PDF")

- #link("a", "[4]") C. M. Liapis, A. Karanikola, and S. Kotsiantis, "A Multi-Method Survey on the Use of Sentiment Analysis in Multivariate Financial Time Series Forecasting" Entropy, vol. 23, no. 12, p. 1603, 2021. \ Disponibile a: #link("PDF","https://www.mdpi.com/1099-4300/23/12/1603")

- #link("a", "[5]") J. Manogna, G. S. Chowdary, G. Meghana, and P. C. Nair, "Bitcoin Price Prediction Based on Sentiment Analysis" in 2023 IEEE 20th India Council International Conference (INDICON), 2023, pp. 1–5. \ Disponibile a: #link("PDF","https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=10440877")

- #link("a", "[6]") H. Anand and A. Arya, "An Empirical Study of Financial BERT Models for Sentiment Analysis and Cryptocurrency Price Correlation" in 2024 IEEE 9th International Conference for Convergence in Technology (I2CT), 2024, pp. 1–6. \ Disponibile a: #link("PDF","")

- #link("a", "[7]") C. Kaur, Samrity, R. Uppal, and S. Kaur, "Twitter Sentiment Analysis of Bitcoin Price Fluctuation with Machine Learning Techniques" in 2025 Seventh International Conference on Computational Intelligence and Communication Technologies (CCICT), 2025, pp. 1–6. \ Disponibile a: 

- #link("a", "[8]") S. Vasishth, S. K. Sharma, A. K. Nayyar, and K. Vijayakuamar, "Impact of Elon Musk's tweets on the price of Dogecoin using Sentiment Analysis" in 2023 International Conference on Advances in Computing, Communication and Applied Informatics (ACCAI), 2023, pp. 1–6. \ Disponibile a: 

- #link("a", "[9]") O. Sattarov and H. S. Jeon, "Forecasting Bitcoin Price Fluctuation by Twitter Sentiment Analysis," in 2020 International Conference on Information Science and Communications Technologies (ICISCT), 2020, pp. 1–4. \ Disponibile a: 

- #link("a", "[10]") J. Gomes Jr., H. Bernardino, A. B. Vieira, V. Dorner, and D. Svetinovic, "Cryptoeconomic User Behavior in the Acute Stages of Geopolitical Conflict," IEEE Transactions on Computational Social Systems, vol. 11, no. 5, pp. 7055–7067, Oct. 2024. \ Disponibile a: 

- #link("a", "[11]") Kraken Learn, "Cosa determina il calo del prezzo dei Bitcoin?", Kraken.com, 2025.\
  Disponibile a: #link("https://www.kraken.com/it/learn/what-makes-bitcoins-price-go-down")

- #link("a", "[12]") Kraken Learn, "Quanti Bitcoin esistono? Spiegazione della fornitura dei Bitcoin", Kraken.com, 2025 \ Disponibile a: #link("https://www.kraken.com/it/learn/how-many-bitcoin-are-there-bitcoin-supply-explained")
= Glossario

