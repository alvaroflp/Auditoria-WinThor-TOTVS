SELECT *
  FROM (SELECT /*+ INDEX (PCNFSAID PCNFSAID_IDX2) */
         PCNFSAID.NUMTRANSVENDA NUMTRANSVENDA,
         TRUNC(SYSDATE) - PCNFSAID.DTSAIDA DIAS,
         PCNFSAID.NUMCAR NUMCAR,
         PCNFSAID.DTSAIDA DATA,
         PCNFSAID.NUMNOTA,
         PCNFSAID.CODFILIAL FILIALSAIDA,
         FILIALENTRADA.CODIGO FILIALENTRADA,
         PCNFSAID.CODCLI,
         PCCLIENT.CLIENTE,
         PCNFSAID.VLTOTAL
          FROM PCCLIENT, PCNFSAID, PCFILIAL FILIALENTRADA --> Criado para diminuir o acesso
         WHERE PCNFSAID.CODCLI = PCCLIENT.CODCLI
           AND PCNFSAID.DTCANCEL IS NULL
           AND PCNFSAID.ESPECIE = 'NF' --> Colocado para cima
           AND PCNFSAID.CODCLI NOT IN (1, 2)
           AND PCNFSAID.VLTOTAL > 0
           AND PCNFSAID.DTSAIDA BETWEEN TRUNC(SYSDATE) - 360 AND
               TRUNC(SYSDATE) - 10 --> Colocado para cima
           AND REGEXP_REPLACE(PCNFSAID.CGC, '[^0-9]') =
               REGEXP_REPLACE(FILIALENTRADA.CGC, '[^0-9]')
              -->AND REPLACE(REPLACE(REPLACE(PCNFSAID.CGC, '-', ''), '/', ''), '.') IN(SELECT REPLACE(REPLACE(REPLACE(C.CGC, '/', ''), '-', ''), '.', '') FROM PCFILIAL C), substituido pela linha acima
           AND EXISTS
         (SELECT /*+ INDEX (PCMOV PCMOV_IDX21) */
                 1 -->NUMTRANSVENDA, para simplificar
                  FROM PCMOV
                 WHERE PCMOV.NUMTRANSVENDA = PCNFSAID.NUMTRANSVENDA -->Invertido colunas
                   AND PCMOV.NUMNOTA = PCNFSAID.NUMNOTA
                   AND PCMOV.CODFISCAL NOT IN (5102,
                                               6102,
                                               5949,
                                               5926,
                                               6926,
                                               6949,
                                               5914,
                                               5911,
                                               6914,
                                               6911,
                                               5927,
                                               5928,
                                               6928,
                                               6927,
                                               5557,
                                               6557,
                                               5910,
                                               6910,
                                               5912,
                                               6912)
                   AND PCMOV.DTCANCEL IS NULL -->Inserido
                )
           AND NOT EXISTS
         (SELECT 1 --> NUMNOTA, para simplificar
                  FROM PCNFENT, PCFILIAL
                 WHERE PCNFENT.NUMNOTA = PCNFSAID.NUMNOTA
                   AND PCFILIAL.CODIGO =
                       NVL(PCNFSAID.CODFILIALNF, PCNFSAID.CODFILIAL)
                   AND REGEXP_REPLACE(PCNFENT.CGC, '[^0-9]') =
                       REGEXP_REPLACE(PCFILIAL.CGC, '[^0-9]')
                   AND PCNFENT.DTENT >= TRUNC(SYSDATE) - 360
                   AND PCNFENT.ESPECIE = 'NF'
                   AND PCNFENT.DTCANCEL IS NULL --> Inserido
                )
           AND NOT EXISTS
         (SELECT 1 -->SUM(PCESTCOM.VLDEVOLUCAO), para simplificar
                  FROM PCNFENT, PCESTCOM
                 WHERE PCESTCOM.NUMTRANSENT = PCNFENT.NUMTRANSENT
                   AND PCESTCOM.NUMTRANSVENDA = PCNFSAID.NUMTRANSVENDA
                   AND PCNFENT.DTCANCEL IS NULL --> Inserido
                 GROUP BY PCESTCOM.NUMTRANSVENDA
                HAVING SUM(PCESTCOM.VLDEVOLUCAO) >= PCNFSAID.VLTOTAL)
           AND NOT EXISTS
         (SELECT 1 -->PCNFENT.VLTOTAL, para simplificar a consulta
                  FROM PCNFENT
                 WHERE PCNFENT.NUMNOTA = PCNFSAID.NUMNOTA
                   AND PCNFENT.DTCANCEL IS NULL --> Inserido
                   AND PCNFENT.CODFILIAL = PCNFSAID.CODFILIAL
                   AND PCNFENT.CODFORNEC = PCNFSAID.CODCLI
                   AND PCNFENT.TIPODESCARGA IN ('6', '8')
                   AND NVL(PCNFENT.GERANFVENDA, 'N') = 'N'
                   AND NVL(PCNFENT.GERANFDEVCLI, 'N') = 'N'
                   AND PCNFENT.VLTOTAL >= PCNFSAID.VLTOTAL)) TRANSF
 WHERE TRANSF.FILIALENTRADA <> TRANSF.FILIALSAIDA
