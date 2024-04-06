-------------------------------------------------------------------
-- SQL skript pre vytvoreníe zakladnych objektov schemy databazy --
-- Autori: Samuel Tuka (xtukas00), Alex Bazo (xbazoa00)          --
-- Posledna verzia: 4.4.2021 16:40                               --
-------------------------------------------------------------------

-- DROP TABLES --

DROP TABLE UZIVATEL CASCADE CONSTRAINTS;
DROP TABLE AUTOMOBIL CASCADE CONSTRAINTS;
DROP TABLE JAZDA CASCADE CONSTRAINTS;
DROP TABLE ZASTAVKA CASCADE CONSTRAINTS;
DROP TABLE VYLET CASCADE CONSTRAINTS;
DROP TABLE HODNOTENIE CASCADE CONSTRAINTS;
DROP TABLE REZERVACIA CASCADE CONSTRAINTS;
DROP TABLE UZIVATEL_VYLET CASCADE CONSTRAINTS;
DROP TABLE PRISPEVOK CASCADE CONSTRAINTS;
DROP SEQUENCE id_hodnotenie;
DROP PROCEDURE priemerna_cena_vyletu;
DROP PROCEDURE pomer_prispevkov;
DROP PROCEDURE zastupenie_znacka;

-- CREATE TABLES --

CREATE TABLE UZIVATEL
(
    id_uzivatel     INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1)                  NOT NULL,
    meno            VARCHAR2(63)                                                                            NOT NULL,
    priezvisko      VARCHAR2(63)                                                                            NOT NULL,
    email           VARCHAR2(127) CHECK (regexp_like(email,
                                                     '^[a-zA-Z0-9._\-]+@[a-zA-Z0-9._\-]+\.[a-zA-Z]{2,4}'))  NOT NULL UNIQUE,
    telefonne_cislo VARCHAR2(13) CHECK (regexp_like(telefonne_cislo, '^[+4219]+[0-9]{8}|^[+420]+[0-9]{9}')) NOT NULL,
    profilova_fotka BLOB,
    popis           VARCHAR2(255),
    fajcenie        CHAR(3) CHECK (fajcenie IN ('ano', 'nie'))                                              NOT NULL,
    zvierata        CHAR(3) CHECK (zvierata IN ('ano', 'nie'))                                              NOT NULL,
    hudba           CHAR(3) CHECK (hudba IN ('ano', 'nie'))                                                 NOT NULL,
    skusenost       VARCHAR2(31) CHECK (skusenost IN
                                        ('nováčik', 'stredne skúsený', 'skúsený', 'expert', 'ambasádor'))   NOT NULL,

    CONSTRAINT PK_UZIVATEL PRIMARY KEY (id_uzivatel)
);

CREATE TABLE AUTOMOBIL
(
    spz          VARCHAR2(7) CHECK (regexp_like(spz, '^[A-Z]{2}+[0-9]{3}+[A-Z]{2}|^[A-Z0-9]{3}+[A-Z0-9]{4}')) NOT NULL,
    znacka       VARCHAR2(31)                                                                                 NOT NULL,
    model        VARCHAR2(31)                                                                                 NOT NULL,
    farba        VARCHAR2(31),
    rok_vyroby   DATE,
    klimatizacia CHAR(3) CHECK (klimatizacia IN ('ano', 'nie'))                                               NOT NULL,
    sedadla      INTEGER CHECK (sedadla >= 1 AND sedadla < 8)                                                 NOT NULL,
    batozina     CHAR(3) CHECK (batozina IN ('ano', 'nie'))                                                   NOT NULL,

    id_uzivatel  INTEGER                                                                                      NOT NULL,

    CONSTRAINT FK_AUTOMOBIL_UZIVATEL FOREIGN KEY (id_uzivatel) REFERENCES UZIVATEL,
    CONSTRAINT PK_AUTOMOBIL PRIMARY KEY (spz)
);

CREATE TABLE JAZDA
(
    id_jazda    INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    datum_jazdy DATE                                                                   NOT NULL,
    cena        NUMERIC(5, 2) CHECK (cena > 0)                                         NOT NULL,
    flexibilita CHAR(3) CHECK (flexibilita IN ('ano', 'nie'))                          NOT NULL,

    id_uzivatel INTEGER                                                                NOT NULL,
    spz         VARCHAR2(7)                                                            NOT NULL,

    CONSTRAINT FK_JAZDA_AUTOMOBIL FOREIGN KEY (spz) REFERENCES AUTOMOBIL,
    CONSTRAINT FK_JAZDA_UZIVATEL FOREIGN KEY (id_uzivatel) REFERENCES UZIVATEL,
    CONSTRAINT PK_JAZDA PRIMARY KEY (id_jazda)
);

CREATE TABLE ZASTAVKA
(
    suradnica      VARCHAR2(127) NOT NULL,
    nazov_zastavky VARCHAR2(127) NOT NULL,

    CONSTRAINT PK_ZASTAVKA PRIMARY KEY (suradnica)
);

CREATE TABLE VYLET
(
    id_vylet    INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    plan        VARCHAR2(511)                                                          NOT NULL,
    ubytovanie  VARCHAR2(127),
    naklady     NUMERIC(6, 2) DEFAULT 0 CHECK (naklady >= 0)                           NOT NULL,
    narocnost   VARCHAR2(31) CHECK (narocnost IN ('ľahký', 'stredne náročný', 'náročný', 'veľmi náročný',
                                                  'extrémne náročný'))                 NOT NULL,
    aktivity    VARCHAR2(127)                                                          NOT NULL,
    miesta      VARCHAR2(127)                                                          NOT NULL,
    vybavenie   VARCHAR2(127),

    id_jazda    INTEGER                                                                NOT NULL,
    id_uzivatel INTEGER                                                                NOT NULL,

    CONSTRAINT FK_VYLET_UZIVATEL_VYTVORIL FOREIGN KEY (id_uzivatel) REFERENCES UZIVATEL,
    CONSTRAINT FK_VYLET_JAZDA FOREIGN KEY (id_jazda) REFERENCES JAZDA,
    CONSTRAINT PK_VYLET PRIMARY KEY (id_vylet)
);

CREATE TABLE HODNOTENIE
(
    id_hodnotenie       INTEGER,
    hviezdicky          INTEGER CHECK (hviezdicky <= 5 AND hviezdicky >= 0),
    spokojnost          VARCHAR2(31) CHECK (spokojnost IN ('Velmi nespokojny', 'Sklamanie', 'Dobre', 'Fajn', 'Super')),
    popis               VARCHAR2(255),

    id_uzivatel         INTEGER NOT NULL,
    id_uzivatel_obdrzal INTEGER NOT NULL,

    CONSTRAINT FK_HODNOTENIE_UZIVATEL_OBDRZAL FOREIGN KEY (id_uzivatel_obdrzal) REFERENCES UZIVATEL,
    CONSTRAINT FK_HODNOTENIE_UZIVATEL FOREIGN KEY (id_uzivatel) REFERENCES UZIVATEL,
    CONSTRAINT PK_HODNOTENIE PRIMARY KEY (id_hodnotenie)
);

CREATE TABLE REZERVACIA
(
    id_rezervacia     INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    datum_rezervacie  DATE                                                                   NOT NULL,

    id_uzivatel       INTEGER                                                                NOT NULL,
    id_jazda          INTEGER                                                                NOT NULL,
    nastupna_zastavka VARCHAR2(31)                                                           NOT NULL,
    vystupna_zastavka VARCHAR2(31)                                                           NOT NULL,


    CONSTRAINT FK_REZERVACIA_NASTUPNA_ZASTAVKA FOREIGN KEY (nastupna_zastavka) REFERENCES ZASTAVKA,
    CONSTRAINT FK_REZERVACIA_VYSTUPNA_ZASTAVKA FOREIGN KEY (vystupna_zastavka) REFERENCES ZASTAVKA,
    CONSTRAINT FK_REZERVACIA_UZIVATEL FOREIGN KEY (id_uzivatel) REFERENCES UZIVATEL,
    CONSTRAINT FK_REZERVACIA_JAZDA FOREIGN KEY (id_jazda) REFERENCES JAZDA,
    CONSTRAINT PK_REZERVACIA PRIMARY KEY (id_rezervacia)
);

CREATE TABLE UZIVATEL_VYLET
(
    id_uzivatel INTEGER NOT NULL,
    id_vylet    INTEGER NOT NULL,

    CONSTRAINT FK_UZIVATEL_VYLET_UZIVATEL FOREIGN KEY (id_uzivatel) REFERENCES UZIVATEL,
    CONSTRAINT FK_UZIVATEL_VYLET_VYLET FOREIGN KEY (id_vylet) REFERENCES VYLET,
    CONSTRAINT PK_UZIVATEL_VYLET PRIMARY KEY (id_uzivatel, id_vylet)
);

CREATE TABLE PRISPEVOK
(
    id_prispevok  INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    opravnenie    VARCHAR2(15) CHECK (opravnenie IN ('verejný', 'súkromný', 'zdieľaný')) NOT NULL,
    obsah         BLOB                                                                   NOT NULL,
    typ_prispevku VARCHAR2(8) CHECK (typ_prispevku IN ('článok', 'vlog'))                NOT NULL,

    id_uzivatel   INTEGER                                                                NOT NULL,
    id_vylet      INTEGER                                                                NOT NULL,

    CONSTRAINT FK_PRISPEVOK_UZIVATEL_VYLET FOREIGN KEY (id_uzivatel, id_vylet) REFERENCES UZIVATEL_VYLET,
    CONSTRAINT PK_PRISPEVOK PRIMARY KEY (id_prispevok)
);

/* TRIGGERS */

/* TRIGER pre prevod penazi z EUR do ceských korun */
CREATE OR REPLACE TRIGGER prevod_penazi
    BEFORE INSERT
    ON JAZDA
    FOR EACH ROW
BEGIN
    :NEW.cena := :NEW.cena * 25.883;
end;
/

/* TRIGER PRE KONTROLU TYPU PRISPEVKU */

CREATE OR REPLACE TRIGGER kontrola_typ_prispevku
    BEFORE INSERT OR UPDATE OF typ_prispevku
    ON PRISPEVOK
    FOR EACH ROW
BEGIN
    IF :NEW.typ_prispevku NOT IN ('článok', 'vlog')
    THEN
        RAISE_APPLICATION_ERROR(-20000, 'Neplatne data');
    END IF;
END;
/

/* TRIGGER pre autoinkrementaciu ID_HODNOTENIA */

CREATE SEQUENCE id_hodnotenie START WITH 50 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER inkrementacia_id_hodnotenie
    BEFORE INSERT
    ON HODNOTENIE
    FOR EACH ROW
BEGIN
    IF :NEW.id_hodnotenie IS NULL THEN
        :NEW.id_hodnotenie := id_hodnotenie.nextval;
    END IF;
END;
/

-- FILL TABLES --

INSERT INTO UZIVATEL (meno, priezvisko, email, telefonne_cislo, profilova_fotka, popis, fajcenie, zvierata, hudba,
                      skusenost)
VALUES ('Jozef', 'Haluška', 'jozef.haluska@gmail.com', '+421910563214', '',
        'Fajn chalan z Galanty, rád spoznávam nových ľudí', 'ano', 'ano', 'ano', 'nováčik');
INSERT INTO UZIVATEL (meno, priezvisko, email, telefonne_cislo, profilova_fotka, popis, fajcenie, zvierata, hudba,
                      skusenost)
VALUES ('Patrik', 'Hranolka', 'hranolka.patrik12@azet.sk', '+421902632478', '',
        'Pochádzam z južnej Moravy a študujem na FIT VUT v Brne', 'nie', 'ano', 'nie', 'skúsený');
INSERT INTO UZIVATEL (meno, priezvisko, email, telefonne_cislo, profilova_fotka, popis, fajcenie, zvierata, hudba,
                      skusenost)
VALUES ('Milan', 'Vyborný', 'milanvyb@seznam.cz', '+420523698741', '', 'Bydlím v Praze', 'nie', 'nie', 'ano', 'expert');
INSERT INTO UZIVATEL (meno, priezvisko, email, telefonne_cislo, profilova_fotka, popis, fajcenie, zvierata, hudba,
                      skusenost)
VALUES ('Andrej', 'Pomaranč', 'pomaranc25@centrum.sk', '+421225417896', '', 'Mám rád cestovanie, športy a dobrých ľudi',
        'ano', 'nie', 'ano', 'ambasádor');
INSERT INTO UZIVATEL (meno, priezvisko, email, telefonne_cislo, profilova_fotka, popis, fajcenie, zvierata, hudba,
                      skusenost)
VALUES ('Tibor', 'Cestovina', 'tibor.cestovina12@gmail.com', '+420774526398', '',
        'So spolujazdami som zacal od roku 2018', 'nie', 'nie', 'nie', 'ambasádor');
INSERT INTO UZIVATEL (meno, priezvisko, email, telefonne_cislo, profilova_fotka, popis, fajcenie, zvierata, hudba,
                      skusenost)
VALUES ('Jaromir', 'Ponozka', 'ponozka.jarko@gmail.com', '+421902854741', '',
        'Mam rad kecup', 'nie', 'ano', 'nie', 'expert');

INSERT INTO AUTOMOBIL (spz, znacka, model, farba, rok_vyroby, klimatizacia, sedadla, batozina, id_uzivatel)
VALUES ('5A17894', 'Audi', 'A4 Combi', 'Biela', TO_DATE('19-NOV-15 10:45', 'YY-MON-DD HH24:MI'), 'ano', 4, 'ano', 04);
INSERT INTO AUTOMOBIL (spz, znacka, model, farba, rok_vyroby, klimatizacia, sedadla, batozina, id_uzivatel)
VALUES ('ZA586FG', 'Toyota', 'RAV4', 'Čierna', TO_DATE('18-AUG-22 14:35', 'YY-MON-DD HH24:MI'), 'ano', 4, 'nie', 03);
INSERT INTO AUTOMOBIL (spz, znacka, model, farba, rok_vyroby, klimatizacia, sedadla, batozina, id_uzivatel)
VALUES ('PP582TZ', 'Mercedes', 'GLE', 'Biela', TO_DATE('02-FEB-02 7:30', 'YY-MON-DD HH24:MI'), 'ano', 2, 'ano', 04);
INSERT INTO AUTOMOBIL (spz, znacka, model, farba, rok_vyroby, klimatizacia, sedadla, batozina, id_uzivatel)
VALUES ('8B14856', 'Daewoo', 'Tico', 'Červená', TO_DATE('17-NOV-02 18:30', 'YY-MON-DD HH24:MI'), 'nie', 4, 'nie', 04);
INSERT INTO AUTOMOBIL (spz, znacka, model, farba, rok_vyroby, klimatizacia, sedadla, batozina, id_uzivatel)
VALUES ('TT789RE', 'Toyota', 'Yaris', 'Modrá', TO_DATE('19-AUG-25 11:28', 'YY-MON-DD HH24:MI'), 'ano', 3, 'ano', 04);

INSERT INTO JAZDA (datum_jazdy, cena, flexibilita, id_uzivatel, spz)
VALUES (TO_DATE('21-AUG-08 17:45', 'YY-MON-DD HH24:MI'), 12.45, 'ano', 01, '5A17894');
INSERT INTO JAZDA (datum_jazdy, cena, flexibilita, id_uzivatel, spz)
VALUES (TO_DATE('20-MAR-14 8:20', 'YY-MON-DD HH24:MI'), 12.00, 'nie', 04, 'TT789RE');
INSERT INTO JAZDA (datum_jazdy, cena, flexibilita, id_uzivatel, spz)
VALUES (TO_DATE('21-FEB-17 6:45', 'YY-MON-DD HH24:MI'), 22.00, 'nie', 02, '8B14856');
INSERT INTO JAZDA (datum_jazdy, cena, flexibilita, id_uzivatel, spz)
VALUES (TO_DATE('20-MAR-12 11:45', 'YY-MON-DD HH24:MI'), 17.45, 'ano', 02, 'PP582TZ');
INSERT INTO JAZDA (datum_jazdy, cena, flexibilita, id_uzivatel, spz)
VALUES (TO_DATE('21-JAN-25 12:30', 'YY-MON-DD HH24:MI'), 16.00, 'nie', 02, 'ZA586FG');

INSERT INTO ZASTAVKA(suradnica, nazov_zastavky)
VALUES ('48.7163857, 21.2610746', 'Autobusová zastávka Košice');
INSERT INTO ZASTAVKA(suradnica, nazov_zastavky)
VALUES ('48.1625219, 17.134744292394267', 'Príkopová Bratislava');
INSERT INTO ZASTAVKA(suradnica, nazov_zastavky)
VALUES ('49.2142074, 19.3030799', 'Dolnooravská nemocnica s poliklinikou');
INSERT INTO ZASTAVKA(suradnica, nazov_zastavky)
VALUES ('48.3293603, 19.6753753', 'Oblastný futbalový zväz Lučenec');
INSERT INTO ZASTAVKA(suradnica, nazov_zastavky)
VALUES ('48.8817843, 18.0194673', 'Slovenský červený kríž Trenčín');
INSERT INTO ZASTAVKA(suradnica, nazov_zastavky)
VALUES ('48.3598862, 17.5938045', 'FCC Trnava');
INSERT INTO ZASTAVKA(suradnica, nazov_zastavky)
VALUES ('49.055986, 20.286705', 'Redakcia Poprad-noviny občanov');
INSERT INTO ZASTAVKA(suradnica, nazov_zastavky)
VALUES ('49.0807262, 19.6094458', 'Mestský hokejový klub Liptovský Mikuláš');
INSERT INTO ZASTAVKA(suradnica, nazov_zastavky)
VALUES ('49.0558153, 19.305185', 'Slovenská ovčiarska spoločnost Ružomberok');
INSERT INTO ZASTAVKA(suradnica, nazov_zastavky)
VALUES ('49.1213207, 18.4589669', 'Profilex Považská Bystrica');

INSERT INTO VYLET (plan, ubytovanie, naklady, narocnost, aktivity, miesta, vybavenie, id_uzivatel, id_jazda)
VALUES ('Phasellus vitae tempus nulla. Duis euismod rhoncus ipsum, quis ultricies purus ullamcorper ut. Phasellus consectetur nisl ac dolor facilisis gravida. Duis semper sed ipsum nec tincidunt. Cras sed dolor in lorem cursus varius. Maecenas luctus lectus felis, non convallis massa lobortis id. Sed et ullamcorper sapien. Nulla facilisi. Aliquam sit amet ullamcorper quam.',
        'Bratislava', 249.99, 'ľahký', 'turistika, chodenie po meste, návšteva pamiatok',
        'Bratislavský hrad, most Apollo, hrad Devín, Stará radnica, Slavín', '', 01, 01);
INSERT INTO VYLET (plan, ubytovanie, naklady, narocnost, aktivity, miesta, vybavenie, id_uzivatel, id_jazda)
VALUES ('Phasellus vitae tempus nulla. Duis euismod rhoncus ipsum, quis ultricies purus ullamcorper ut. Phasellus consectetur nisl ac dolor facilisis gravida. Duis semper sed ipsum nec tincidunt. Cras sed dolor in lorem cursus varius. Maecenas luctus lectus felis, non convallis massa lobortis id. Sed et ullamcorper sapien. Nulla facilisi. Aliquam sit amet ullamcorper quam.',
        'Benátky', 1549.99, 'ľahký', 'turistika, chodenie po meste, kúpanie, plavba loďou',
        'Benátky a príľahlé mestá', 'plavky, opaľovací krém', 02, 02);
INSERT INTO VYLET (plan, ubytovanie, naklady, narocnost, aktivity, miesta, vybavenie, id_uzivatel, id_jazda)
VALUES ('Phasellus vitae tempus nulla. Duis euismod rhoncus ipsum, quis ultricies purus ullamcorper ut. Phasellus consectetur nisl ac dolor facilisis gravida. Duis semper sed ipsum nec tincidunt. Cras sed dolor in lorem cursus varius. Maecenas luctus lectus felis, non convallis massa lobortis id. Sed et ullamcorper sapien. Nulla facilisi. Aliquam sit amet ullamcorper quam.',
        'Paríž', 749.99, 'ľahký', 'výlet po meste, nákup suvenírov', 'Notre Dame, Louvre, Eiffelová veža', '', 03,
        03);
INSERT INTO VYLET (plan, ubytovanie, naklady, narocnost, aktivity, miesta, vybavenie, id_uzivatel, id_jazda)
VALUES ('Phasellus vitae tempus nulla. Duis euismod rhoncus ipsum, quis ultricies purus ullamcorper ut. Phasellus consectetur nisl ac dolor facilisis gravida. Duis semper sed ipsum nec tincidunt. Cras sed dolor in lorem cursus varius. Maecenas luctus lectus felis, non convallis massa lobortis id. Sed et ullamcorper sapien. Nulla facilisi. Aliquam sit amet ullamcorper quam.',
        'Košice', 100.00, 'náročný', 'návšteva divadla', 'Dom sv. Alžbety, národné divadlo Košice', '', 02, 04);
INSERT INTO VYLET (plan, ubytovanie, naklady, narocnost, aktivity, miesta, vybavenie, id_uzivatel, id_jazda)
VALUES ('Phasellus vitae tempus nulla. Duis euismod rhoncus ipsum, quis ultricies purus ullamcorper ut. Phasellus consectetur nisl ac dolor facilisis gravida. Duis semper sed ipsum nec tincidunt. Cras sed dolor in lorem cursus varius. Maecenas luctus lectus felis, non convallis massa lobortis id. Sed et ullamcorper sapien. Nulla facilisi. Aliquam sit amet ullamcorper quam.',
        'Hurghada', 1549.99, 'ľahký', 'turistika, návšteva pamiatok, potápanie',
        'Hurghada a dalsie mestá v Egypte', 'plavky, kyslíková bomba', 01, 05);

INSERT INTO HODNOTENIE (hviezdicky, spokojnost, popis, id_uzivatel, id_uzivatel_obdrzal)
VALUES (2, 'Sklamanie', 'Prišli sme neskôr ako bolo plánované', 01, 02);
INSERT INTO HODNOTENIE (hviezdicky, spokojnost, popis, id_uzivatel, id_uzivatel_obdrzal)
VALUES (5, 'Super', 'S jazdou som nad mieru spokojný', 03, 04);
INSERT INTO HODNOTENIE (hviezdicky, spokojnost, popis, id_uzivatel, id_uzivatel_obdrzal)
VALUES (1, 'Velmi nespokojny', 'Riskantná a nebezpečná jazda', 05, 02);
INSERT INTO HODNOTENIE (hviezdicky, spokojnost, popis, id_uzivatel, id_uzivatel_obdrzal)
VALUES (5, 'Super', 'Všetko fajn bez problémov', 02, 04);
INSERT INTO HODNOTENIE (hviezdicky, spokojnost, popis, id_uzivatel, id_uzivatel_obdrzal)
VALUES (4, 'Fajn', 'Hudba bola príliš nahlas', 03, 04);

INSERT INTO REZERVACIA (datum_rezervacie, id_uzivatel, id_jazda, nastupna_zastavka, vystupna_zastavka)
VALUES (TO_DATE('21-JAN-03 18:44', 'YY-MON-DD HH24:MI'), 01, 01, '48.7163857, 21.2610746',
        '48.1625219, 17.134744292394267');
INSERT INTO REZERVACIA (datum_rezervacie, id_uzivatel, id_jazda, nastupna_zastavka, vystupna_zastavka)
VALUES (TO_DATE('21-APR-22 7:30', 'YY-MON-DD HH24:MI'), 02, 02, '49.2142074, 19.3030799', '48.3293603, 19.6753753');
INSERT INTO REZERVACIA (datum_rezervacie, id_uzivatel, id_jazda, nastupna_zastavka, vystupna_zastavka)
VALUES (TO_DATE('21-DEC-15 9:41', 'YY-MON-DD HH24:MI'), 01, 03, '48.8817843, 18.0194673', '48.3598862, 17.5938045');
INSERT INTO REZERVACIA (datum_rezervacie, id_uzivatel, id_jazda, nastupna_zastavka, vystupna_zastavka)
VALUES (TO_DATE('21-JAN-02 12:35', 'YY-MON-DD HH24:MI'), 02, 04, '48.7163857, 21.2610746', '49.0807262, 19.6094458');
INSERT INTO REZERVACIA (datum_rezervacie, id_uzivatel, id_jazda, nastupna_zastavka, vystupna_zastavka)
VALUES (TO_DATE('21-MAR-08 22:58', 'YY-MON-DD HH24:MI'), 02, 05, '49.0558153, 19.305185', '49.1213207, 18.4589669');

INSERT INTO UZIVATEL_VYLET (id_uzivatel, id_vylet)
VALUES (01, 02);
INSERT INTO UZIVATEL_VYLET (id_uzivatel, id_vylet)
VALUES (02, 02);
INSERT INTO UZIVATEL_VYLET (id_uzivatel, id_vylet)
VALUES (03, 02);
INSERT INTO UZIVATEL_VYLET (id_uzivatel, id_vylet)
VALUES (04, 03);
INSERT INTO UZIVATEL_VYLET (id_uzivatel, id_vylet)
VALUES (05, 03);

INSERT INTO PRISPEVOK (opravnenie, obsah, typ_prispevku, id_uzivatel, id_vylet)
VALUES ('verejný', UTL_RAW.CAST_TO_RAW('videjo'), 'vlog', 01, 02);
INSERT INTO PRISPEVOK (opravnenie, obsah, typ_prispevku, id_uzivatel, id_vylet)
VALUES ('súkromný', UTL_RAW.CAST_TO_RAW('LOREM IPSUM'), 'článok', 02, 02);
INSERT INTO PRISPEVOK (opravnenie, obsah, typ_prispevku, id_uzivatel, id_vylet)
VALUES ('súkromný', UTL_RAW.CAST_TO_RAW('LOREM IPSUM'), 'článok', 03, 02);
INSERT INTO PRISPEVOK (opravnenie, obsah, typ_prispevku, id_uzivatel, id_vylet)
VALUES ('verejný', UTL_RAW.CAST_TO_RAW('videjo'), 'vlog', 04, 03);
INSERT INTO PRISPEVOK (opravnenie, obsah, typ_prispevku, id_uzivatel, id_vylet)
VALUES ('zdieľaný', UTL_RAW.CAST_TO_RAW('LOREM IPSUM'), 'článok', 05, 03);

-- demonstracia auto-increment triggeru
SELECT *
FROM HODNOTENIE;

/* EXPLAIN PLAN */

EXPLAIN PLAN FOR
SELECT id_uzivatel, meno, priezvisko, COUNT(id_rezervacia)
FROM UZIVATEL
         NATURAL JOIN REZERVACIA
WHERE datum_rezervacie BETWEEN TO_DATE('21-JAN-02 12:35', 'YY-MON-DD HH24:MI') AND TO_DATE('21-MAR-08 22:58', 'YY-MON-DD HH24:MI')
GROUP BY id_uzivatel, meno, priezvisko;
SELECT *
FROM TABLE (DBMS_XPLAN.display());

CREATE INDEX index_rezervacia ON REZERVACIA (datum_rezervacie);

EXPLAIN PLAN FOR
SELECT id_uzivatel, meno, priezvisko, COUNT(id_rezervacia)
FROM UZIVATEL
         NATURAL JOIN REZERVACIA
WHERE datum_rezervacie BETWEEN TO_DATE('21-JAN-02 12:35', 'YY-MON-DD HH24:MI') AND TO_DATE('21-MAR-08 22:58', 'YY-MON-DD HH24:MI')
GROUP BY id_uzivatel, meno, priezvisko;
SELECT *
FROM TABLE (DBMS_XPLAN.display());

/* PROCEDURY */

CREATE OR REPLACE PROCEDURE zastupenie_znacka(znacka IN VARCHAR)
    IS
    CURSOR auta IS SELECT *
                   FROM AUTOMOBIL;
    zaznam         auta%ROWTYPE;
    pocet_vsetkych INTEGER;
    pocet_znacka   INTEGER;
BEGIN
    pocet_vsetkych := 0;
    pocet_znacka := 0;
    OPEN auta;
    LOOP
        FETCH auta into zaznam;
        EXIT WHEN auta%NOTFOUND;
        IF (TRIM(zaznam.znacka) = znacka)
        THEN
            pocet_znacka := pocet_znacka + 1;
        end if;
        IF (zaznam.znacka IS NOT NULL)
        THEN
            pocet_vsetkych := pocet_vsetkych + 1;
        end if;
    end loop;
    CLOSE auta;
    dbms_output.put_line(
                'Celkovo ma auto ' || pocet_vsetkych || ' uzivatelov, uzivatelia ktorí vlastnia znacku ' || znacka ||
                ' je celkovo ' || pocet_znacka || ', percentualne zastupenie vlastnikov znacky ' || znacka ||
                ' voci ostatnym znackam je ' || pocet_znacka * 100 / pocet_vsetkych || ' percent');
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20005, 'Nastala chyba');
END;
/

INSERT INTO AUTOMOBIL (spz, znacka, model, farba, rok_vyroby, klimatizacia, sedadla, batozina, id_uzivatel)
VALUES ('PO466CE', 'Mercedes', 'Yaris', 'Modrá', TO_DATE('19-AUG-25 11:28', 'YY-MON-DD HH24:MI'), 'ano', 3, 'ano', 04);
BEGIN
    zastupenie_znacka('Mercedes');
END;

/* POMER CLANKOV */

CREATE OR REPLACE PROCEDURE pomer_prispevkov(prispevok in VARCHAR)
    IS
    CURSOR prispevky IS SELECT *
                        FROM PRISPEVOK;
    zaznam         prispevky%ROWTYPE;
    pocet_vsetkych INTEGER;
    pocet_vlogov   INTEGER;
    pocet_clankov  INTEGER;
    pomer_clankov  NUMERIC(5, 2);
BEGIN
    pocet_vsetkych := 0;
    pocet_vlogov := 0;
    pocet_clankov := 0;
    OPEN prispevky;
    LOOP
        FETCH prispevky into zaznam;
        EXIT WHEN prispevky%NOTFOUND;
        IF (TRIM(zaznam.typ_prispevku) = prispevok)
        THEN
            pocet_clankov := pocet_clankov + 1;
        ELSE
            pocet_vlogov := pocet_vlogov + 1;
        end if;
        IF (zaznam.typ_prispevku IS NOT NULL)
        THEN
            pocet_vsetkych := pocet_vsetkych + 1;
        end if;
    end loop;
    pomer_clankov := pocet_clankov * 100 / pocet_vsetkych;
    dbms_output.put_line('Celkovo je príspevkov ' || pocet_vsetkych || ' počet článkov je ' || pocet_clankov ||
                         ' a počet vlogov je ' || pocet_vlogov ||
                         ', percentualne zastupenie člankov proti vlogom je ' || pomer_clankov || ' percent');
    CLOSE prispevky;
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20001, 'Nastala neocakavana chyba');
end;
/

INSERT INTO PRISPEVOK (opravnenie, obsah, typ_prispevku, id_uzivatel, id_vylet)
VALUES ('zdieľaný', UTL_RAW.CAST_TO_RAW('LOREM IPSUM'), 'článok', 05, 03);
BEGIN
    pomer_prispevkov('článok');
END;

/* PRIEMERNA CENA VYLETU V JEDNOTLIVYCH KATEGORIACH PODLA PARAMETRU */

CREATE OR REPLACE PROCEDURE priemerna_cena_vyletu(narocnost in VARCHAR)
    IS
    CURSOR vylety IS SELECT *
                     FROM VYLET;
    zaznam         vylety%ROWTYPE;
    pocet_vsetkych INTEGER;
    celkova_cena   NUMERIC(6, 2);
    priemerna_cena NUMERIC(6, 2);
BEGIN
    pocet_vsetkych := 0;
    celkova_cena := 0;
    OPEN vylety;
    LOOP
        FETCH vylety into zaznam;
        EXIT WHEN vylety%NOTFOUND;

        IF (zaznam.narocnost = narocnost)
        THEN
            celkova_cena := celkova_cena + zaznam.naklady;
            pocet_vsetkych := pocet_vsetkych + 1;
        END IF;
    END LOOP;
    priemerna_cena := celkova_cena / pocet_vsetkych;
    CLOSE vylety;
    dbms_output.put_line('Priemerná cena v kategorii ' || narocnost || ' výlet je ' || priemerna_cena || '  eur.');
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20001, 'Nastala neočakávaná chyba');
END;
/

BEGIN
    priemerna_cena_vyletu('ľahký');
END;

/* PRISTUPOVE PRAVA PRE POUZIVATELA XBAZOA00*/

GRANT ALL ON UZIVATEL TO XBAZOA00;
GRANT ALL ON AUTOMOBIL TO XBAZOA00;
GRANT ALL ON JAZDA TO XBAZOA00;
GRANT ALL ON ZASTAVKA TO XBAZOA00;
GRANT ALL ON VYLET TO XBAZOA00;
GRANT ALL ON HODNOTENIE TO XBAZOA00;
GRANT ALL ON REZERVACIA TO XBAZOA00;
GRANT ALL ON UZIVATEL_VYLET TO XBAZOA00;
GRANT ALL ON PRISPEVOK TO XBAZOA00;

GRANT EXECUTE ON zastupenie_znacka TO XBAZOA00;
GRANT EXECUTE ON pomer_prispevkov TO XBAZOA00;
GRANT EXECUTE ON priemerna_cena_vyletu TO XBAZOA00;

/* MATERIALIZOVANY POHLAD IMPLEMETOVANY DRUHYM CLENOM TYMU + PRIDELENE VSETKY PRAVA PRVEMU CLENOVI TIMU*/
/*DROP MATERIALIZED VIEW "user_car_count";

CREATE MATERIALIZED VIEW "user_car_count" AS
SELECT
    "u"."ID_UZIVATEL",
    "u"."MENO",
    "u"."PRIEZVISKO",
    COUNT("a"."ID_UZIVATEL") AS "cars_count"
FROM XTUKAS00.UZIVATEL "u"
LEFT JOIN XTUKAS00.AUTOMOBIL "a" ON "a"."ID_UZIVATEL" = "u"."ID_UZIVATEL"
GROUP BY "u"."ID_UZIVATEL", "u"."MENO", "u"."PRIEZVISKO";

GRANT ALL ON "user_car_count" to XTUKAS00;
*/

DROP MATERIALIZED VIEW "user_car_count";

-- PRE DEMONSTRACIU FUNKCNOSTI
CREATE MATERIALIZED VIEW "user_car_count" AS
SELECT
    "u"."ID_UZIVATEL",
    "u"."MENO",
    "u"."PRIEZVISKO",
    COUNT("a"."ID_UZIVATEL") AS "cars_count"
FROM XTUKAS00.UZIVATEL "u"
LEFT JOIN XTUKAS00.AUTOMOBIL "a" ON "a"."ID_UZIVATEL" = "u"."ID_UZIVATEL"
GROUP BY "u"."ID_UZIVATEL", "u"."MENO", "u"."PRIEZVISKO";


-- VYPIS MATERIALIZOVANEHO POHLADU --
-- PRI SPUSTANI OD DRUHEHO CLENA TIMU SA POTOM MUSI ZADAT NAZOV POHLADU AKO XBAZOA00."user_car_count"
SELECT * FROM "user_car_count";

-- UPDATE UZIVATELA S ID 6 NA UZIVATELA S ID 69420 --
UPDATE UZIVATEL set UZIVATEL.ID_UZIVATEL = 69420 where UZIVATEL.ID_UZIVATEL = 6;
COMMIT;
-- UZIVATELOV ID V MATERIALIZOVANOM POHLADE OSTALO NEZMENENE --
SELECT * FROM "user_car_count";

-- UZIVATELOVE ID V TABULKE UZIVATEL SA ZMENILO --
SELECT * FROM UZIVATEL;