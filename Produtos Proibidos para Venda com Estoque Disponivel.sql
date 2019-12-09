SELECT PCPRODFILIAL.CODFILIAL, 
       PCPRODUT.CODPROD,
       PCPRODUT.DESCRICAO, 
       PCPRODUT.UNIDADE,
       PCPRODUT.EMBALAGEM,
       PCPRODUT.QTUNIT,
       PCPRODUT.QTUNITCX,
       PCEST.QTEST AS EST_CONTABIL,
       PCEST.QTESTGER AS EST_GERENCIAL,
       PCPRODUT.STATUS,
       PCPRODFILIAL.PROIBIDAVENDA,
       PCPRODUT.REVENDA,
       PCPRODUT.DTEXCLUSAO,
       PCPRODUT.CODFUNCCADASTRO||'-'||PCEMPR.NOME_GUERRA FUNCCAD,
       PCPRODUT.DTCADASTRO 
FROM PCPRODFILIAL, PCPRODUT, PCEST, PCEMPR
WHERE PCPRODUT.CODPROD=PCPRODFILIAL.CODPROD
AND PCEST.CODPROD = PCPRODUT.CODPROD
AND PCEMPR.MATRICULA=PCPRODUT.CODFUNCCADASTRO
AND PCEST.QTEST > 0 
AND PCEST.QTESTGER > 0
AND PCPRODUT.REVENDA = 'N'
AND PCPRODUT.DTEXCLUSAO IS NOT NULL