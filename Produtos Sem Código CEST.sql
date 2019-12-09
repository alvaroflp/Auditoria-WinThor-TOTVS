SELECT DISTINCT P.CODPROD,
                P.DESCRICAO,
                P.NBM NCM,
                NVL (VINCULO.CODSEQCEST, 0) CODSEQCEST,
                'N' TIPOPROD,
                NVL (VINCULO.CODCESTPROD, 0) CODCESTPROD,
                VINCULO.CODCEST,
                VINCULO.SELECIONADO,
                P.TIPOTRIBUTMEDIC,
                P.EMBALAGEM
  FROM PCPRODUT P,
       (SELECT 0 CODSEQCEST,
               0 CODCESTPROD,
               0 CODPROD,
               'N' SELECIONADO,
               '' CODCEST
          FROM DUAL
         WHERE 0 = 1) VINCULO
 WHERE     0 = 0
       AND P.CODPROD = VINCULO.CODPROD(+)
       AND NOT EXISTS
              (SELECT 1
                 FROM PCCESTPRODUTO
                WHERE CODPROD = P.CODPROD)
       AND NVL (TRIM (P.OBS2), 'A') = 'A'