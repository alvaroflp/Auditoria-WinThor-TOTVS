SELECT nvl(round(sum(comple.vlicms * p.qtcont), 2),0) valor
  FROM PCMOV        P,
       PCPRODFILIAL PF,
       PCNFSAID     NF,
       PCPRODUT     PROD,
       pcmovcomple  comple
 WHERE P.CODPROD = PF.CODPROD
   AND NF.NUMTRANSVENDA = P.NUMTRANSVENDA
   AND NF.CODFILIAL = PF.CODFILIAL
   and comple.numtransitem = p.numtransitem
   AND PF.CODPROD = P.CODPROD
   AND P.CODPROD = PROD.CODPROD
   AND NF.ESPECIE = 'NF'
   AND P.GERAICMSLIVROFISCAL = 'N'
   AND nvl(P.SITTRIBUT, '0') NOT IN ('10', '60', '70')
   AND P.PUNITCONT > 0
   AND P.PERCICM > 0
   AND NF.ESPECIE = 'NF'
   AND (NVL(P.ST, 0) = 0 AND NVL(P.PERCDESPADICIONAL, 0) = 0)
   AND NF.Dtsaida BETWEEN
       TO_DATE('01/' || TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE), -1), 'MM/YYYY'),
               'DD/MM/YYYY') AND ADD_MONTHS(TRUNC(SYSDATE), -1)
