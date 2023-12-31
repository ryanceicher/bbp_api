-- Create Users Table
CREATE TABLE IF NOT EXISTS public."Users"
(
    "UserID" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "Username" text COLLATE pg_catalog."default",
    "DiscordUsername" text COLLATE pg_catalog."default",
    "DiscordMention" text COLLATE pg_catalog."default",
    "DiscordID" numeric(20,0) NOT NULL,
    "FriendlyName" text COLLATE pg_catalog."default",
    "Points" integer DEFAULT 0,
    "BbpsIssued" integer DEFAULT 0,
    "GbpsIssued" integer DEFAULT 0,
    CONSTRAINT "PK_Users" PRIMARY KEY ("UserID")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

-- Create Gbps Table
CREATE TABLE IF NOT EXISTS public."Gbps"
(
    "GbpID" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "UserID" integer,
    "Value" integer NOT NULL,
    "Description" text COLLATE pg_catalog."default",
    "Timestamp" timestamp without time zone NOT NULL,
    "IssuerID" integer,
    CONSTRAINT "PK_Gbps" PRIMARY KEY ("GbpID"),
    CONSTRAINT "FK_Gbps_Users_UserID" FOREIGN KEY ("UserID")
        REFERENCES public."Users" ("UserID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS "IX_Gbps_UserID"
    ON public."Gbps" USING btree
    ("UserID" ASC NULLS LAST)
    TABLESPACE pg_default;

-- Decrement GBP Trigger
CREATE OR REPLACE FUNCTION public.decrement_points_gbp()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    UPDATE public."Users"
    SET "Points" = "Points" + OLD."Value"
    WHERE "UserID" = OLD."UserID";
    
	UPDATE public."Users"
	SET "GbpsIssued" = "GbpsIssued" - 1
	WHERE "UserID" = OLD."IssuerID";
	
    RETURN OLD;
END;
$BODY$;

CREATE TRIGGER decrement_points_trigger_gbp
    AFTER DELETE
    ON public."Gbps"
    FOR EACH ROW
    EXECUTE FUNCTION public.decrement_points_gbp();

-- Update GBP Trigger
CREATE OR REPLACE FUNCTION public.update_points_gbp()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    UPDATE public."Users"
    SET "Points" = "Points" - NEW."Value"
    WHERE "UserID" = NEW."UserID";
    
	UPDATE public."Users"
    SET "GbpsIssued" = "GbpsIssued" + NEW."Value"
    WHERE "UserID" = NEW."IssuerID";
	
    RETURN NEW;
END;
$BODY$;

CREATE TRIGGER update_points_trigger_gbp
    AFTER INSERT
    ON public."Gbps"
    FOR EACH ROW
    EXECUTE FUNCTION public.update_points_gbp();

-- Create Bbps table
CREATE TABLE IF NOT EXISTS public."Bbps"
(
    "BbpID" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "UserID" integer,
    "Value" integer NOT NULL,
    "Description" text COLLATE pg_catalog."default",
    "Timestamp" timestamp without time zone NOT NULL,
    "IssuerID" integer,
    "Forgiven" boolean DEFAULT false,
    CONSTRAINT "PK_Bbps" PRIMARY KEY ("BbpID"),
    CONSTRAINT "FK_Bbps_Users_UserID" FOREIGN KEY ("UserID")
        REFERENCES public."Users" ("UserID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS "IX_Bbps_UserID"
    ON public."Bbps" USING btree
    ("UserID" ASC NULLS LAST)
    TABLESPACE pg_default;

-- Decrement Bbp Trigger
CREATE OR REPLACE FUNCTION public.decrement_points()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    UPDATE public."Users"
    SET "Points" = "Points" - OLD."Value"
    WHERE "UserID" = OLD."UserID";
    
	UPDATE public."Users"
	SET "BbpsIssued" = "BbpsIssued" - 1
	WHERE "UserID" = OLD."IssuerID";
	
    RETURN OLD;
END;
$BODY$;

CREATE TRIGGER decrement_points_trigger
    AFTER DELETE
    ON public."Bbps"
    FOR EACH ROW
    EXECUTE FUNCTION public.decrement_points();

-- Forgive Bbp Trigger
CREATE OR REPLACE FUNCTION public.forgiven()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF NEW."Forgiven" = true AND OLD."Forgiven" = false THEN
        UPDATE public."Users"
        SET "Points" = "Points" - NEW."Value"
        WHERE "UserID" = NEW."UserID";
		
		UPDATE public."Users"
		SET "BbpsIssued" = "BbpsIssued" - 1
		WHERE "UserID" = NEW."IssuerID";
    END IF;
    RETURN NEW;
END;
$BODY$;

CREATE TRIGGER forgiveness_trigger
    AFTER UPDATE 
    ON public."Bbps"
    FOR EACH ROW
    EXECUTE FUNCTION public.decrement_points();

-- Update Bbp Trigger
CREATE OR REPLACE FUNCTION public.update_points()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    UPDATE public."Users"
    SET "Points" = "Points" + NEW."Value"
    WHERE "UserID" = NEW."UserID";
    
	UPDATE public."Users"
    SET "BbpsIssued" = "BbpsIssued" + NEW."Value"
    WHERE "UserID" = NEW."IssuerID";
	
    RETURN NEW;
END;
$BODY$;

CREATE TRIGGER update_points_trigger
    AFTER INSERT
    ON public."Bbps"
    FOR EACH ROW
    EXECUTE FUNCTION public.update_points();