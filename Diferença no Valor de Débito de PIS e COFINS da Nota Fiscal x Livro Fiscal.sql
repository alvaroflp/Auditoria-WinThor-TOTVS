/*exibe o valor total = ROUND((round(sum(DIF_COFINS), 2) + round(sum(DIF_PIS), 2)), 2) ====> dentro do primeiro select*/
SELECT *
  FROM (SELECT 'SAIDA' TIPO,
               FILIAL,
               DATA,
               NUMNOTA,
               TRANSACAO,
               SERIE,
               ESPECIE,
               TOTALNF,
               NVL(VLBASEPISCOFINS, 0) VLBASEPISCOFINS,
               NVL(VLPIS_LIVRO, 0) VLPIS_LIVRO,
               NVL(VLPIS_MOV, 0) VLPIS_MOV,
               (NVL(VLPIS_LIVRO, 0) - NVL(VLPIS_MOV, 0)) DIF_PIS,
               NVL(VLCOFINS_LIVRO, 0) VLCOFINS_LIVRO,
               NVL(VLCOFINS_MOV, 0) VLCOFINS_MOV,
               (NVL(VLCOFINS_LIVRO, 0) - NVL(VLCOFINS_MOV, 0)) DIF_COFINS
          FROM (SELECT PCNFSAID.CODFILIAL FILIAL,
                       PCNFSAID.DTSAIDA DATA,
                       PCNFSAID.NUMTRANSVENDA TRANSACAO,
                       PCNFSAID.NUMNOTA,
                       PCNFSAID.ESPECIE,
                       PCNFSAID.SERIE,
                       PCNFSAID.VLTOTAL TOTALNF,
                       LIVRO.VLPIS VLPIS_LIVRO,
                       LIVRO.VLCOFINS VLCOFINS_LIVRO,
                       SUM(PCMOV.VLBASEPISCOFINS * PCMOV.QTCONT) VLBASEPISCOFINS,
                       SUM(PCMOV.VLPIS * PCMOV.QTCONT) VLPIS_MOV,
                       SUM(PCMOV.VLCOFINS * PCMOV.QTCONT) VLCOFINS_MOV
                  FROM PCNFSAID,
                       PCMOV,
                       PCPRODUT,
                       (SELECT PCNFBASESAID.NUMTRANSVENDA,
                               SUM(PCNFBASESAID.VLPIS) VLPIS,
                               SUM(PCNFBASESAID.VLCOFINS) VLCOFINS
                          FROM PCNFBASESAID
                         GROUP BY PCNFBASESAID.NUMTRANSVENDA) LIVRO
                 WHERE PCNFSAID.NUMTRANSVENDA = PCMOV.NUMTRANSVENDA
                   AND PCMOV.CODPROD = PCPRODUT.CODPROD
                   AND PCNFSAID.ESPECIE = 'NF'
                   AND PCNFSAID.DTCANCEL IS NULL
                   AND NVL(PCNFSAID.OBS, 0) <> 'NF CANCELADA'
                   AND PCNFSAID.SERIE NOT IN ('CF', 'OE', '.')
                   AND PCMOV.STATUS IN ('A', 'AB')
                   AND PCMOV.QTCONT > 0
                   AND PCNFSAID.NUMTRANSVENDA = LIVRO.NUMTRANSVENDA(+)
                   AND PCNFSAID.DTSAIDA BETWEEN
                       TO_DATE('01/' || TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE), -1),
                                                'MM/YYYY'),
                               'DD/MM/YYYY') AND
                       LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE), -1))
                 GROUP BY PCNFSAID.CODFILIAL,
                          PCNFSAID.DTSAIDA,
                          PCNFSAID.NUMTRANSVENDA,
                          PCNFSAID.NUMNOTA,
                          PCNFSAID.ESPECIE,
                          PCNFSAID.SERIE,
                          PCNFSAID.VLTOTAL,
                          LIVRO.VLPIS,
                          LIVRO.VLCOFINS)
         WHERE ((ABS(NVL(VLPIS_LIVRO, 0) - NVL(VLPIS_MOV, 0)) > 0.99 OR
               ABS(NVL(VLCOFINS_LIVRO, 0) - NVL(VLCOFINS_MOV, 0)) > 0.99) OR
               NVL(VLPIS_LIVRO, 0) > 0 AND NVL(VLPIS_MOV, 0) = 0))
