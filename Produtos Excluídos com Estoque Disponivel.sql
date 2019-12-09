SELECT PCPRODUT.DTEXCLUSAO,
       PCPRODUT.CODPROD,
       PCPRODUT.DESCRICAO,
       PCPRODUT.UNIDADE,
       PCPRODUT.EMBALAGEM,
       PCEST.QTEST AS EST_CONTABIL,
       PCEST.QTESTGER AS EST_GERENCIAL
  FROM PCPRODUT, PCEST
  WHERE PCPRODUT.CODPROD=PCEST.CODPROD
  AND PCPRODUT.DTEXCLUSAO IS NOT NULL
  AND PCEST.QTESTGER > 0
  AND PCEST.QTEST > 0