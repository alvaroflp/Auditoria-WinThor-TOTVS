SELECT *
  FROM (SELECT 'SAIDA' TIPO,
               CODFILIAL,
               NUMTRANSVENDA AS MOVIMENTO,
               PCNFSAID.ESPECIE,
               NUMNOTA,
               DTSAIDA AS DATA,
               VLTOTAL
          FROM PCNFSAID
         WHERE PCNFSAID.DTSAIDA BETWEEN
               TO_DATE('01/' ||
                       TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE), -1), 'MM/YYYY'),
                       'DD/MM/YYYY') AND
               LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE), -1))
           AND PCNFSAID.DTSAIDA <> TRUNC(SYSDATE)
           AND SERIE NOT IN ('CF', 'OE', '.')
           AND ESPECIE = 'NF'
           AND PCNFSAID.DTCANCEL IS NULL
           AND NOT EXISTS
         (SELECT NUMTRANSVENDA
                  FROM PCNFBASESAID
                 WHERE PCNFBASESAID.NUMTRANSVENDA = PCNFSAID.NUMTRANSVENDA)
        
        UNION ALL
        
        SELECT 'ENTRADA' TIPO,
               CODFILIAL,
               NUMTRANSENT AS MOVIMENTO,
               PCNFENT.ESPECIE,
               NUMNOTA,
               PCNFENT.DTENT AS DATA,
               PCNFENT.VLTOTAL
          FROM PCNFENT
         WHERE PCNFENT.DTENT BETWEEN
               TO_DATE('01/' ||
                       TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE), -1), 'MM/YYYY'),
                       'DD/MM/YYYY') AND
               LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE), -1))
           AND ESPECIE IN ('NF')
           AND PCNFENT.DTCANCEL IS NULL
           AND PCNFENT.DTENT <> TRUNC(SYSDATE)
           AND NVL(PCNFENT.OBS, '0') <> 'NF CANCELADA'
           AND NOT EXISTS
         (SELECT NUMTRANSENT
                  FROM PCNFBASEENT
                 WHERE PCNFBASEENT.NUMTRANSENT = PCNFENT.NUMTRANSENT))
