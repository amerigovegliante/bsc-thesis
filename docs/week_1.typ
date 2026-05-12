#import "log_template.typ": project, week_log
#import "@preview/cheq:0.3.1": checklist
#show: project
#show: checklist

#week_log(
  1, 
  "13/05/2026 - 15/05/2026",
  lun: (),
  mar: (),
  mer: (
    "Analisi approfondita della Tesi triennale precedente, elencandone pregi e difetti.",
    "Analisi approfondita di paper scientifici simili elencando le nozioni utili riscontrate.",
    "Analisi approfondita di progetti simili.",
    "Studio delle tecnologie quali FinBERT come LLM per il Sentiment Analysis, XGBoost, API di CoinDesk e CoinTelegraph, HuggingFace e Google Colab.",
    "Studio delle Metodologie di Backtesting (Buy and Hold, Moving Average Convergence Divergence e Simple Moving Average Crossover).",
  ),
  gio: (),
  ven: (),
  notes: "Non sono stati riscontrati problemi maggiori."
)