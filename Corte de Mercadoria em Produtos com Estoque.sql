SELECT I.DATA,
         DECODE (C.NUMCAR, NULL, I.NUMCAR, C.NUMCAR) NUMCAR,
         P.CODPROD,
         DECODE (P.PESOVARIAVEL,  'S', 'Sim',  'N', 'Não') AS PESOVARIAVEL,
         P.PESOPECA,
         P.PESOEMBALAGEM,
         DECODE (P.TIPOESTOQUE,  'PA', 'Padrão',  'FR', 'Frios')
            AS TIPOESTOQUE,
         (CASE
             WHEN P.PESOVARIAVEL = 'S' AND P.TIPOESTOQUE = 'FR'
             THEN
                (CEIL (I.QTSEPARADA / DECODE (P.PESOPECA, 0, 1, P.PESOPECA)))
             ELSE
                0
          END)
            AS QTPECAS,
         (SELECT QTESTGER
            FROM PCEST
           WHERE CODPROD = P.CODPROD AND CODFILIAL = :FILIAL)
            QTESTGER,
         P.DESCRICAO,
         (I.QTSEPARADA + I.QTCORTADA) QTORIGINAL,
         ( (I.QTSEPARADA + I.QTCORTADA) * I.PVENDA) VLORIGINAL,
         (I.QTCORTADA) QTCORTADA,
         (I.QTCORTADA * I.PVENDA) VLCORTADO,
         (I.QTSEPARADA) QT,
         (I.QTSEPARADA * I.PVENDA) VLSEPARADO,
         (  (100 * NVL (I.QTCORTADA, 0))
          / (CASE
                WHEN (I.QTSEPARADA + I.QTCORTADA) > 0
                THEN
                   (I.QTSEPARADA + I.QTCORTADA)
                ELSE
                   1
             END))
            PERCORTE,
         I.CODFUNC,
         (SELECT EMP.NOME
            FROM PCEMPR EMP
           WHERE EMP.MATRICULA = I.CODFUNC)
            NOMEFUNC,
         I.NUMPED,
         P.CODEPTO,
         P.CODFORNEC,
         (I.QTSEPARADA * I.PVENDA) VLATENDIDO,
         (P.CODFORNEC || ' - ' || F.FORNECEDOR) FORNECEDOR,
         ('DEPARTAMENTO: ' || P.CODEPTO) DPTOLABEL,
         ('CARREGAMENTO: ' || C.NUMCAR) CARLABEL,
         ('PRODUTO: ' || P.CODPROD) PRODLABEL,
         (SELECT MAX (DEPOSITO)
            FROM PCENDERECO
           WHERE CODENDERECO IN
                    (SELECT K.CODENDERECO
                       FROM PCPRODUTPICKING K
                      WHERE K.CODPROD = P.CODPROD AND K.CODFILIAL = :FILIAL))
            DEPOSITOAP,
         (SELECT MAX (RUA)
            FROM PCENDERECO
           WHERE CODENDERECO IN
                    (SELECT K.CODENDERECO
                       FROM PCPRODUTPICKING K
                      WHERE K.CODPROD = P.CODPROD AND K.CODFILIAL = :FILIAL))
            RUAAP,
         (SELECT MAX (PREDIO)
            FROM PCENDERECO
           WHERE CODENDERECO IN
                    (SELECT K.CODENDERECO
                       FROM PCPRODUTPICKING K
                      WHERE K.CODPROD = P.CODPROD AND K.CODFILIAL = :FILIAL))
            PREDIOAP,
         (SELECT MAX (NIVEL)
            FROM PCENDERECO
           WHERE CODENDERECO IN
                    (SELECT K.CODENDERECO
                       FROM PCPRODUTPICKING K
                      WHERE K.CODPROD = P.CODPROD AND K.CODFILIAL = :FILIAL))
            NIVELAP,
         (SELECT MAX (APTO)
            FROM PCENDERECO
           WHERE CODENDERECO IN
                    (SELECT K.CODENDERECO
                       FROM PCPRODUTPICKING K
                      WHERE K.CODPROD = P.CODPROD AND K.CODFILIAL = :FILIAL))
            APTOAP,
         I.HORA,
         I.MINUTO,
         CASE
            WHEN EXISTS
                    (SELECT DEV.MOTIVO
                       FROM PCTABDEV DEV
                      WHERE CAST (DEV.CODDEVOL AS VARCHAR2 (15)) = I.MOTIVO)
            THEN
               (SELECT DEV.MOTIVO
                  FROM PCTABDEV DEV
                 WHERE DEV.CODDEVOL = NVL (I.MOTIVO, '0'))
            ELSE
               I.MOTIVO
         END
            MOTIVO,
         (SELECT CLI.CLIENTE
            FROM PCCLIENT CLI
           WHERE CLI.CODCLI = DECODE (C.CODCLI, NULL, I.CODCLI, C.CODCLI))
            CLIENTE,
         (SELECT CLI.CODCLI || ' - ' || CLI.CLIENTE
            FROM PCCLIENT CLI
           WHERE CLI.CODCLI = DECODE (C.CODCLI, NULL, I.CODCLI, C.CODCLI))
            CLIENTEDESC,
         (SELECT CLI.FANTASIA
            FROM PCCLIENT CLI
           WHERE CLI.CODCLI = DECODE (C.CODCLI, NULL, I.CODCLI, C.CODCLI))
            NOMEFANTASIA,
         (SELECT PCUSUARI.NOME
            FROM PCUSUARI
           WHERE PCUSUARI.CODUSUR = C.CODUSUR)
            RCA,
         (SELECT CLI.FANTASIA
            FROM PCCLIENT CLI
           WHERE CLI.CODCLI = C.CODCLI)
            NOMEFANTASIA
    FROM PCCORTEI I,
         PCPRODUT P,
         PCPEDC C,
         PCFORNEC F
   WHERE     I.NUMPED = C.NUMPED(+)
         AND I.DATA + (I.HORA / 24) + (I.MINUTO / 1440) BETWEEN TO_DATE (
                                                                   :DTINI,
                                                                   'DD/MM/YYYY')
                                                            AND TO_DATE (
                                                                   :DTFIM,
                                                                   'DD/MM/YYYY')
         AND I.CODPROD = P.CODPROD
         AND F.CODFORNEC = P.CODFORNEC
         AND (SELECT QTESTGER
            FROM PCEST
           WHERE CODPROD = P.CODPROD AND CODFILIAL = :FILIAL) > 0
         AND NVL (I.CODFILIAL, '1') = :FILIAL
         AND I.DATA BETWEEN :DTINI AND :DTFIM
ORDER BY P.CODPROD, P.CODPROD