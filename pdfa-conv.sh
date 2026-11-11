gs -dPDFA=2 -dBATCH -dNOPAUSE -dPDFACompatibilityPolicy=2 \
  -sDEVICE=pdfwrite -dCompatibilityLevel=1.7 \
  -sColorConversionStrategy=RGB -sProcessColorModel=DeviceRGB \
  -sOutputFile=output-pdfa.pdf \
  PDFA_def.ps ./docs/thesis.pdf
