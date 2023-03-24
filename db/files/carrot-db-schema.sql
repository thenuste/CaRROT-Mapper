--
-- PostgreSQL database dump
--

-- Dumped from database version 14.6
-- Dumped by pg_dump version 14.1

-- Started on 2023-03-14 14:47:55 GMT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 25197)
-- Name: omop; Type: SCHEMA; Schema: -; Owner: drsnonprodpgadmin
--

CREATE SCHEMA omop;


ALTER SCHEMA omop OWNER TO drsnonprodpgadmin;

--
-- TOC entry 316 (class 1255 OID 25198)
-- Name: maintain_dms_replication_progress_queue(); Type: FUNCTION; Schema: public; Owner: drsnonprodpgadmin
--

CREATE FUNCTION public.maintain_dms_replication_progress_queue() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare num_rows integer;
begin
num_rows := (select count(*) from dms_replication_progress);
if num_rows = 10 then
   delete from dms_replication_progress where update_time = (select min(update_time) from dms_replication_progress);
elsif num_rows > 10 then
   raise exception 'dms_replication_progress table exceeding 10 rows';
end if; 
return new;
end;
$$;


ALTER FUNCTION public.maintain_dms_replication_progress_queue() OWNER TO drsnonprodpgadmin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 210 (class 1259 OID 25199)
-- Name: attribute_definition; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.attribute_definition (
    attribute_definition_id integer NOT NULL,
    attribute_name character varying(255) NOT NULL,
    attribute_description text,
    attribute_type_concept_id integer NOT NULL,
    attribute_syntax text
);


ALTER TABLE omop.attribute_definition OWNER TO drsnonprodpgadmin;

--
-- TOC entry 211 (class 1259 OID 25204)
-- Name: care_site; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.care_site (
    care_site_id bigint NOT NULL,
    care_site_name character varying(255),
    place_of_service_concept_id integer NOT NULL,
    location_id bigint,
    care_site_source_value character varying(50),
    place_of_service_source_value character varying(50)
);


ALTER TABLE omop.care_site OWNER TO drsnonprodpgadmin;

--
-- TOC entry 212 (class 1259 OID 25207)
-- Name: cdm_source; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.cdm_source (
    cdm_source_name character varying(255) NOT NULL,
    cdm_source_abbreviation character varying(25),
    cdm_holder character varying(255),
    source_description text,
    source_documentation_reference character varying(255),
    cdm_etl_reference character varying(255),
    source_release_date date,
    cdm_release_date date,
    cdm_version character varying(10),
    vocabulary_version character varying(20)
);


ALTER TABLE omop.cdm_source OWNER TO drsnonprodpgadmin;

--
-- TOC entry 213 (class 1259 OID 25212)
-- Name: concept; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.concept (
    concept_id integer NOT NULL,
    concept_name character varying(255) NOT NULL,
    domain_id character varying(20) NOT NULL,
    vocabulary_id character varying(20) NOT NULL,
    concept_class_id character varying(20) NOT NULL,
    standard_concept character varying(1),
    concept_code character varying(50) NOT NULL,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason character varying(1)
);


ALTER TABLE omop.concept OWNER TO drsnonprodpgadmin;

--
-- TOC entry 214 (class 1259 OID 25215)
-- Name: concept_ancestor; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.concept_ancestor (
    ancestor_concept_id integer NOT NULL,
    descendant_concept_id integer NOT NULL,
    min_levels_of_separation integer NOT NULL,
    max_levels_of_separation integer NOT NULL
);


ALTER TABLE omop.concept_ancestor OWNER TO drsnonprodpgadmin;

--
-- TOC entry 215 (class 1259 OID 25218)
-- Name: concept_class; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.concept_class (
    concept_class_id character varying(20) NOT NULL,
    concept_class_name character varying(255) NOT NULL,
    concept_class_concept_id integer NOT NULL
);


ALTER TABLE omop.concept_class OWNER TO drsnonprodpgadmin;

--
-- TOC entry 216 (class 1259 OID 25221)
-- Name: concept_relationship; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.concept_relationship (
    concept_id_1 integer NOT NULL,
    concept_id_2 integer NOT NULL,
    relationship_id character varying(20) NOT NULL,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason character varying(1)
);


ALTER TABLE omop.concept_relationship OWNER TO drsnonprodpgadmin;

--
-- TOC entry 217 (class 1259 OID 25224)
-- Name: concept_synonym; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.concept_synonym (
    concept_id integer NOT NULL,
    concept_synonym_name character varying(1000) NOT NULL,
    language_concept_id integer NOT NULL
);


ALTER TABLE omop.concept_synonym OWNER TO drsnonprodpgadmin;

--
-- TOC entry 218 (class 1259 OID 25229)
-- Name: condition_era; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.condition_era (
    condition_era_id bigint NOT NULL,
    person_id bigint NOT NULL,
    condition_concept_id integer NOT NULL,
    condition_era_start_datetime timestamp without time zone NOT NULL,
    condition_era_end_datetime timestamp without time zone NOT NULL,
    condition_occurrence_count integer
);


ALTER TABLE omop.condition_era OWNER TO drsnonprodpgadmin;

--
-- TOC entry 219 (class 1259 OID 25232)
-- Name: condition_occurrence; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.condition_occurrence (
    condition_occurrence_id bigint NOT NULL,
    person_id bigint NOT NULL,
    condition_concept_id integer NOT NULL,
    condition_start_date date,
    condition_start_datetime timestamp without time zone NOT NULL,
    condition_end_date date,
    condition_end_datetime timestamp without time zone,
    condition_type_concept_id integer NOT NULL,
    condition_status_concept_id integer NOT NULL,
    stop_reason character varying(20),
    provider_id bigint,
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    condition_source_value character varying(50),
    condition_source_concept_id integer NOT NULL,
    condition_status_source_value character varying(50)
);


ALTER TABLE omop.condition_occurrence OWNER TO drsnonprodpgadmin;

--
-- TOC entry 220 (class 1259 OID 25235)
-- Name: cost; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.cost (
    cost_id bigint NOT NULL,
    person_id bigint NOT NULL,
    cost_event_id bigint NOT NULL,
    cost_event_field_concept_id integer NOT NULL,
    cost_concept_id integer NOT NULL,
    cost_type_concept_id integer NOT NULL,
    currency_concept_id integer NOT NULL,
    cost numeric,
    incurred_date date NOT NULL,
    billed_date date,
    paid_date date,
    revenue_code_concept_id integer NOT NULL,
    drg_concept_id integer NOT NULL,
    cost_source_value character varying(50),
    cost_source_concept_id integer NOT NULL,
    revenue_code_source_value character varying(50),
    drg_source_value character varying(3),
    payer_plan_period_id bigint
);


ALTER TABLE omop.cost OWNER TO drsnonprodpgadmin;

--
-- TOC entry 221 (class 1259 OID 25240)
-- Name: device_exposure; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.device_exposure (
    device_exposure_id bigint NOT NULL,
    person_id bigint NOT NULL,
    device_concept_id integer NOT NULL,
    device_exposure_start_date date,
    device_exposure_start_datetime timestamp without time zone NOT NULL,
    device_exposure_end_date date,
    device_exposure_end_datetime timestamp without time zone,
    device_type_concept_id integer NOT NULL,
    unique_device_id character varying(50),
    quantity integer,
    provider_id bigint,
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    device_source_value character varying(100),
    device_source_concept_id integer NOT NULL
);


ALTER TABLE omop.device_exposure OWNER TO drsnonprodpgadmin;

--
-- TOC entry 222 (class 1259 OID 25243)
-- Name: domain; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.domain (
    domain_id character varying(20) NOT NULL,
    domain_name character varying(255) NOT NULL,
    domain_concept_id integer NOT NULL
);


ALTER TABLE omop.domain OWNER TO drsnonprodpgadmin;

--
-- TOC entry 223 (class 1259 OID 25246)
-- Name: dose_era; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.dose_era (
    dose_era_id bigint NOT NULL,
    person_id bigint NOT NULL,
    drug_concept_id integer NOT NULL,
    unit_concept_id integer NOT NULL,
    dose_value numeric NOT NULL,
    dose_era_start_datetime timestamp without time zone NOT NULL,
    dose_era_end_datetime timestamp without time zone NOT NULL
);


ALTER TABLE omop.dose_era OWNER TO drsnonprodpgadmin;

--
-- TOC entry 224 (class 1259 OID 25251)
-- Name: drug_era; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.drug_era (
    drug_era_id bigint NOT NULL,
    person_id bigint NOT NULL,
    drug_concept_id integer NOT NULL,
    drug_era_start_datetime timestamp without time zone NOT NULL,
    drug_era_end_datetime timestamp without time zone NOT NULL,
    drug_exposure_count integer,
    gap_days integer
);


ALTER TABLE omop.drug_era OWNER TO drsnonprodpgadmin;

--
-- TOC entry 225 (class 1259 OID 25254)
-- Name: drug_exposure; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.drug_exposure (
    drug_exposure_id bigint NOT NULL,
    person_id bigint NOT NULL,
    drug_concept_id integer NOT NULL,
    drug_exposure_start_date date,
    drug_exposure_start_datetime timestamp without time zone NOT NULL,
    drug_exposure_end_date date,
    drug_exposure_end_datetime timestamp without time zone NOT NULL,
    verbatim_end_date date,
    drug_type_concept_id integer NOT NULL,
    stop_reason character varying(20),
    refills integer,
    quantity numeric,
    days_supply integer,
    sig text,
    route_concept_id integer NOT NULL,
    lot_number character varying(50),
    provider_id bigint,
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    drug_source_value character varying(50),
    drug_source_concept_id integer NOT NULL,
    route_source_value character varying(50),
    dose_unit_source_value character varying(50)
);


ALTER TABLE omop.drug_exposure OWNER TO drsnonprodpgadmin;

--
-- TOC entry 226 (class 1259 OID 25259)
-- Name: drug_strength; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.drug_strength (
    drug_concept_id integer NOT NULL,
    ingredient_concept_id integer NOT NULL,
    amount_value numeric,
    amount_unit_concept_id integer,
    numerator_value numeric,
    numerator_unit_concept_id integer,
    denominator_value numeric,
    denominator_unit_concept_id integer,
    box_size integer,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason character varying(1)
);


ALTER TABLE omop.drug_strength OWNER TO drsnonprodpgadmin;

--
-- TOC entry 227 (class 1259 OID 25264)
-- Name: fact_relationship; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.fact_relationship (
    domain_concept_id_1 integer NOT NULL,
    fact_id_1 bigint NOT NULL,
    domain_concept_id_2 integer NOT NULL,
    fact_id_2 bigint NOT NULL,
    relationship_concept_id integer NOT NULL
);


ALTER TABLE omop.fact_relationship OWNER TO drsnonprodpgadmin;

--
-- TOC entry 228 (class 1259 OID 25267)
-- Name: location; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.location (
    location_id bigint NOT NULL,
    address_1 character varying(50),
    address_2 character varying(50),
    city character varying(50),
    state character varying(2),
    zip character varying(9),
    county character varying(20),
    country character varying(100),
    location_source_value character varying(50),
    latitude numeric,
    longitude numeric
);


ALTER TABLE omop.location OWNER TO drsnonprodpgadmin;

--
-- TOC entry 229 (class 1259 OID 25272)
-- Name: location_history; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.location_history (
    location_history_id bigint NOT NULL,
    location_id bigint NOT NULL,
    relationship_type_concept_id integer NOT NULL,
    domain_id character varying(50) NOT NULL,
    entity_id bigint NOT NULL,
    start_date date NOT NULL,
    end_date date
);


ALTER TABLE omop.location_history OWNER TO drsnonprodpgadmin;

--
-- TOC entry 230 (class 1259 OID 25275)
-- Name: measurement; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.measurement (
    measurement_id bigint NOT NULL,
    person_id bigint NOT NULL,
    measurement_concept_id integer NOT NULL,
    measurement_date date,
    measurement_datetime timestamp without time zone NOT NULL,
    measurement_time character varying(10),
    measurement_type_concept_id integer NOT NULL,
    operator_concept_id integer,
    value_as_number numeric,
    value_as_concept_id integer,
    unit_concept_id integer,
    range_low numeric,
    range_high numeric,
    provider_id bigint,
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    measurement_source_value character varying(50),
    measurement_source_concept_id integer NOT NULL,
    unit_source_value character varying(50),
    value_source_value character varying(50)
);


ALTER TABLE omop.measurement OWNER TO drsnonprodpgadmin;

--
-- TOC entry 231 (class 1259 OID 25280)
-- Name: metadata; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.metadata (
    metadata_concept_id integer NOT NULL,
    metadata_type_concept_id integer NOT NULL,
    name character varying(250) NOT NULL,
    value_as_string text,
    value_as_concept_id integer,
    metadata_date date,
    metadata_datetime timestamp without time zone
);


ALTER TABLE omop.metadata OWNER TO drsnonprodpgadmin;

--
-- TOC entry 232 (class 1259 OID 25285)
-- Name: note; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.note (
    note_id bigint NOT NULL,
    person_id bigint NOT NULL,
    note_event_id bigint,
    note_event_field_concept_id integer NOT NULL,
    note_date date,
    note_datetime timestamp without time zone NOT NULL,
    note_type_concept_id integer NOT NULL,
    note_class_concept_id integer NOT NULL,
    note_title character varying(250),
    note_text text,
    encoding_concept_id integer NOT NULL,
    language_concept_id integer NOT NULL,
    provider_id bigint,
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    note_source_value character varying(50)
);


ALTER TABLE omop.note OWNER TO drsnonprodpgadmin;

--
-- TOC entry 233 (class 1259 OID 25290)
-- Name: note_nlp; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.note_nlp (
    note_nlp_id bigint NOT NULL,
    note_id bigint NOT NULL,
    section_concept_id integer NOT NULL,
    snippet character varying(250),
    "offset" character varying(250),
    lexical_variant character varying(250) NOT NULL,
    note_nlp_concept_id integer NOT NULL,
    nlp_system character varying(250),
    nlp_date date NOT NULL,
    nlp_datetime timestamp without time zone,
    term_exists character varying(1),
    term_temporal character varying(50),
    term_modifiers character varying(2000),
    note_nlp_source_concept_id integer NOT NULL
);


ALTER TABLE omop.note_nlp OWNER TO drsnonprodpgadmin;

--
-- TOC entry 234 (class 1259 OID 25295)
-- Name: observation; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.observation (
    observation_id bigint NOT NULL,
    person_id bigint NOT NULL,
    observation_concept_id integer NOT NULL,
    observation_date date,
    observation_datetime timestamp without time zone NOT NULL,
    observation_type_concept_id integer NOT NULL,
    value_as_number numeric,
    value_as_string character varying(60),
    value_as_concept_id integer,
    qualifier_concept_id integer,
    unit_concept_id integer,
    provider_id bigint,
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    observation_source_value character varying(50),
    observation_source_concept_id integer NOT NULL,
    unit_source_value character varying(50),
    qualifier_source_value character varying(50),
    observation_event_id bigint,
    obs_event_field_concept_id integer NOT NULL,
    value_as_datetime timestamp without time zone
);


ALTER TABLE omop.observation OWNER TO drsnonprodpgadmin;

--
-- TOC entry 235 (class 1259 OID 25300)
-- Name: observation_period; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.observation_period (
    observation_period_id bigint NOT NULL,
    person_id bigint NOT NULL,
    observation_period_start_date date NOT NULL,
    observation_period_end_date date NOT NULL,
    period_type_concept_id integer NOT NULL
);


ALTER TABLE omop.observation_period OWNER TO drsnonprodpgadmin;

--
-- TOC entry 236 (class 1259 OID 25303)
-- Name: payer_plan_period; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.payer_plan_period (
    payer_plan_period_id bigint NOT NULL,
    person_id bigint NOT NULL,
    contract_person_id bigint,
    payer_plan_period_start_date date NOT NULL,
    payer_plan_period_end_date date NOT NULL,
    payer_concept_id integer NOT NULL,
    plan_concept_id integer NOT NULL,
    contract_concept_id integer NOT NULL,
    sponsor_concept_id integer NOT NULL,
    stop_reason_concept_id integer NOT NULL,
    payer_source_value character varying(50),
    payer_source_concept_id integer NOT NULL,
    plan_source_value character varying(50),
    plan_source_concept_id integer NOT NULL,
    contract_source_value character varying(50),
    contract_source_concept_id integer NOT NULL,
    sponsor_source_value character varying(50),
    sponsor_source_concept_id integer NOT NULL,
    family_source_value character varying(50),
    stop_reason_source_value character varying(50),
    stop_reason_source_concept_id integer NOT NULL
);


ALTER TABLE omop.payer_plan_period OWNER TO drsnonprodpgadmin;

--
-- TOC entry 237 (class 1259 OID 25306)
-- Name: person; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.person (
    person_id bigint NOT NULL,
    gender_concept_id integer NOT NULL,
    year_of_birth integer NOT NULL,
    month_of_birth integer,
    day_of_birth integer,
    birth_datetime timestamp without time zone,
    death_datetime timestamp without time zone,
    race_concept_id integer NOT NULL,
    ethnicity_concept_id integer NOT NULL,
    location_id bigint,
    provider_id bigint,
    care_site_id bigint,
    person_source_value character varying(50),
    gender_source_value character varying(50),
    gender_source_concept_id integer NOT NULL,
    race_source_value character varying(50),
    race_source_concept_id integer NOT NULL,
    ethnicity_source_value character varying(50),
    ethnicity_source_concept_id integer NOT NULL
);


ALTER TABLE omop.person OWNER TO drsnonprodpgadmin;

--
-- TOC entry 238 (class 1259 OID 25309)
-- Name: procedure_occurrence; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.procedure_occurrence (
    procedure_occurrence_id bigint NOT NULL,
    person_id bigint NOT NULL,
    procedure_concept_id integer NOT NULL,
    procedure_date date,
    procedure_datetime timestamp without time zone NOT NULL,
    procedure_type_concept_id integer NOT NULL,
    modifier_concept_id integer NOT NULL,
    quantity integer,
    provider_id bigint,
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    procedure_source_value character varying(50),
    procedure_source_concept_id integer NOT NULL,
    modifier_source_value character varying(50)
);


ALTER TABLE omop.procedure_occurrence OWNER TO drsnonprodpgadmin;

--
-- TOC entry 239 (class 1259 OID 25312)
-- Name: relationship; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.relationship (
    relationship_id character varying(20) NOT NULL,
    relationship_name character varying(255) NOT NULL,
    is_hierarchical character varying(1) NOT NULL,
    defines_ancestry character varying(1) NOT NULL,
    reverse_relationship_id character varying(20) NOT NULL,
    relationship_concept_id integer NOT NULL
);


ALTER TABLE omop.relationship OWNER TO drsnonprodpgadmin;

--
-- TOC entry 240 (class 1259 OID 25315)
-- Name: source_to_concept_map; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.source_to_concept_map (
    source_code character varying(50) NOT NULL,
    source_concept_id integer NOT NULL,
    source_vocabulary_id character varying(20) NOT NULL,
    source_code_description character varying(255),
    target_concept_id integer NOT NULL,
    target_vocabulary_id character varying(20) NOT NULL,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason character varying(1)
);


ALTER TABLE omop.source_to_concept_map OWNER TO drsnonprodpgadmin;

--
-- TOC entry 241 (class 1259 OID 25318)
-- Name: specimen; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.specimen (
    specimen_id bigint NOT NULL,
    person_id bigint NOT NULL,
    specimen_concept_id integer NOT NULL,
    specimen_type_concept_id integer NOT NULL,
    specimen_date date,
    specimen_datetime timestamp without time zone NOT NULL,
    quantity numeric,
    unit_concept_id integer,
    anatomic_site_concept_id integer NOT NULL,
    disease_status_concept_id integer NOT NULL,
    specimen_source_id character varying(50),
    specimen_source_value character varying(50),
    unit_source_value character varying(50),
    anatomic_site_source_value character varying(50),
    disease_status_source_value character varying(50)
);


ALTER TABLE omop.specimen OWNER TO drsnonprodpgadmin;

--
-- TOC entry 242 (class 1259 OID 25323)
-- Name: survey_conduct; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.survey_conduct (
    survey_conduct_id bigint NOT NULL,
    person_id bigint NOT NULL,
    survey_concept_id integer NOT NULL,
    survey_start_date date,
    survey_start_datetime timestamp without time zone,
    survey_end_date date,
    survey_end_datetime timestamp without time zone NOT NULL,
    provider_id bigint,
    assisted_concept_id integer NOT NULL,
    respondent_type_concept_id integer NOT NULL,
    timing_concept_id integer NOT NULL,
    collection_method_concept_id integer NOT NULL,
    assisted_source_value character varying(50),
    respondent_type_source_value character varying(100),
    timing_source_value character varying(100),
    collection_method_source_value character varying(100),
    survey_source_value character varying(100),
    survey_source_concept_id integer NOT NULL,
    survey_source_identifier character varying(100),
    validated_survey_concept_id integer NOT NULL,
    validated_survey_source_value character varying(100),
    survey_version_number character varying(20),
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    response_visit_occurrence_id bigint
);


ALTER TABLE omop.survey_conduct OWNER TO drsnonprodpgadmin;

--
-- TOC entry 243 (class 1259 OID 25328)
-- Name: visit_detail; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.visit_detail (
    visit_detail_id bigint NOT NULL,
    person_id bigint NOT NULL,
    visit_detail_concept_id integer NOT NULL,
    visit_detail_start_date date,
    visit_detail_start_datetime timestamp without time zone NOT NULL,
    visit_detail_end_date date,
    visit_detail_end_datetime timestamp without time zone NOT NULL,
    visit_detail_type_concept_id integer NOT NULL,
    provider_id bigint,
    care_site_id bigint,
    discharge_to_concept_id integer NOT NULL,
    admitted_from_concept_id integer NOT NULL,
    admitted_from_source_value character varying(50),
    visit_detail_source_value character varying(50),
    visit_detail_source_concept_id integer NOT NULL,
    discharge_to_source_value character varying(50),
    preceding_visit_detail_id bigint,
    visit_detail_parent_id bigint,
    visit_occurrence_id bigint NOT NULL
);


ALTER TABLE omop.visit_detail OWNER TO drsnonprodpgadmin;

--
-- TOC entry 244 (class 1259 OID 25331)
-- Name: visit_occurrence; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.visit_occurrence (
    visit_occurrence_id bigint NOT NULL,
    person_id bigint NOT NULL,
    visit_concept_id integer NOT NULL,
    visit_start_date date,
    visit_start_datetime timestamp without time zone NOT NULL,
    visit_end_date date,
    visit_end_datetime timestamp without time zone NOT NULL,
    visit_type_concept_id integer NOT NULL,
    provider_id bigint,
    care_site_id bigint,
    visit_source_value character varying(50),
    visit_source_concept_id integer NOT NULL,
    admitted_from_concept_id integer NOT NULL,
    admitted_from_source_value character varying(50),
    discharge_to_source_value character varying(50),
    discharge_to_concept_id integer NOT NULL,
    preceding_visit_occurrence_id bigint
);


ALTER TABLE omop.visit_occurrence OWNER TO drsnonprodpgadmin;

--
-- TOC entry 245 (class 1259 OID 25334)
-- Name: vocabulary; Type: TABLE; Schema: omop; Owner: drsnonprodpgadmin
--

CREATE TABLE omop.vocabulary (
    vocabulary_id character varying(20) NOT NULL,
    vocabulary_name character varying(255) NOT NULL,
    vocabulary_reference character varying(255) NOT NULL,
    vocabulary_version character varying(255),
    vocabulary_concept_id integer NOT NULL
);


ALTER TABLE omop.vocabulary OWNER TO drsnonprodpgadmin;

--
-- TOC entry 246 (class 1259 OID 25339)
-- Name: auth_group; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO drsnonprodpgadmin;

--
-- TOC entry 247 (class 1259 OID 25342)
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4468 (class 0 OID 0)
-- Dependencies: 247
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;


--
-- TOC entry 248 (class 1259 OID 25343)
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO drsnonprodpgadmin;

--
-- TOC entry 249 (class 1259 OID 25346)
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.auth_group_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_permissions_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4469 (class 0 OID 0)
-- Dependencies: 249
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;


--
-- TOC entry 250 (class 1259 OID 25347)
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO drsnonprodpgadmin;

--
-- TOC entry 251 (class 1259 OID 25350)
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4470 (class 0 OID 0)
-- Dependencies: 251
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;


--
-- TOC entry 252 (class 1259 OID 25351)
-- Name: auth_user; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


ALTER TABLE public.auth_user OWNER TO drsnonprodpgadmin;

--
-- TOC entry 253 (class 1259 OID 25356)
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.auth_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.auth_user_groups OWNER TO drsnonprodpgadmin;

--
-- TOC entry 254 (class 1259 OID 25359)
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.auth_user_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_groups_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4471 (class 0 OID 0)
-- Dependencies: 254
-- Name: auth_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.auth_user_groups_id_seq OWNED BY public.auth_user_groups.id;


--
-- TOC entry 255 (class 1259 OID 25360)
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.auth_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4472 (class 0 OID 0)
-- Dependencies: 255
-- Name: auth_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.auth_user_id_seq OWNED BY public.auth_user.id;


--
-- TOC entry 256 (class 1259 OID 25361)
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.auth_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_user_user_permissions OWNER TO drsnonprodpgadmin;

--
-- TOC entry 257 (class 1259 OID 25364)
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.auth_user_user_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_user_permissions_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4473 (class 0 OID 0)
-- Dependencies: 257
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.auth_user_user_permissions_id_seq OWNED BY public.auth_user_user_permissions.id;


--
-- TOC entry 258 (class 1259 OID 25365)
-- Name: authtoken_token; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.authtoken_token (
    key character varying(40) NOT NULL,
    created timestamp with time zone NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.authtoken_token OWNER TO drsnonprodpgadmin;

--
-- TOC entry 259 (class 1259 OID 25368)
-- Name: mapping_datapartner; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_datapartner (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.mapping_datapartner OWNER TO drsnonprodpgadmin;

--
-- TOC entry 260 (class 1259 OID 25371)
-- Name: datapartner_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.datapartner_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.datapartner_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4474 (class 0 OID 0)
-- Dependencies: 260
-- Name: datapartner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.datapartner_id_seq OWNED BY public.mapping_datapartner.id;


--
-- TOC entry 261 (class 1259 OID 25372)
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO drsnonprodpgadmin;

--
-- TOC entry 262 (class 1259 OID 25378)
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_admin_log_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4475 (class 0 OID 0)
-- Dependencies: 262
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;


--
-- TOC entry 263 (class 1259 OID 25379)
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO drsnonprodpgadmin;

--
-- TOC entry 264 (class 1259 OID 25382)
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_content_type_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4476 (class 0 OID 0)
-- Dependencies: 264
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;


--
-- TOC entry 265 (class 1259 OID 25383)
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO drsnonprodpgadmin;

--
-- TOC entry 266 (class 1259 OID 25388)
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.django_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_migrations_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4477 (class 0 OID 0)
-- Dependencies: 266
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;


--
-- TOC entry 267 (class 1259 OID 25389)
-- Name: django_session; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO drsnonprodpgadmin;

--
-- TOC entry 268 (class 1259 OID 25394)
-- Name: dms_persistent_objects; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.dms_persistent_objects (
    table_name character varying NOT NULL,
    obj_name character varying NOT NULL,
    obj_type character(1) NOT NULL,
    create_stmt character varying NOT NULL,
    task_id uuid NOT NULL
);


ALTER TABLE public.dms_persistent_objects OWNER TO drsnonprodpgadmin;

--
-- TOC entry 269 (class 1259 OID 25399)
-- Name: dms_replication_progress; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.dms_replication_progress (
    committed_lsn pg_lsn NOT NULL,
    update_time timestamp without time zone DEFAULT now(),
    task_id uuid NOT NULL
);


ALTER TABLE public.dms_replication_progress OWNER TO drsnonprodpgadmin;

--
-- TOC entry 270 (class 1259 OID 25403)
-- Name: mapping_classificationsystem; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_classificationsystem (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.mapping_classificationsystem OWNER TO drsnonprodpgadmin;

--
-- TOC entry 271 (class 1259 OID 25406)
-- Name: mapping_classificationsystem_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_classificationsystem_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_classificationsystem_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4478 (class 0 OID 0)
-- Dependencies: 271
-- Name: mapping_classificationsystem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_classificationsystem_id_seq OWNED BY public.mapping_classificationsystem.id;


--
-- TOC entry 272 (class 1259 OID 25407)
-- Name: mapping_datadictionary; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_datadictionary (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(256)
);


ALTER TABLE public.mapping_datadictionary OWNER TO drsnonprodpgadmin;

--
-- TOC entry 273 (class 1259 OID 25410)
-- Name: mapping_datadictionary_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_datadictionary_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_datadictionary_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4479 (class 0 OID 0)
-- Dependencies: 273
-- Name: mapping_datadictionary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_datadictionary_id_seq OWNED BY public.mapping_datadictionary.id;


--
-- TOC entry 274 (class 1259 OID 25411)
-- Name: mapping_dataset; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_dataset (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL,
    data_partner_id integer NOT NULL,
    visibility character varying(10) NOT NULL,
    hidden boolean NOT NULL
);


ALTER TABLE public.mapping_dataset OWNER TO drsnonprodpgadmin;

--
-- TOC entry 275 (class 1259 OID 25414)
-- Name: mapping_dataset_admins; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_dataset_admins (
    id integer NOT NULL,
    dataset_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.mapping_dataset_admins OWNER TO drsnonprodpgadmin;

--
-- TOC entry 276 (class 1259 OID 25417)
-- Name: mapping_dataset_admins_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_dataset_admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_dataset_admins_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4480 (class 0 OID 0)
-- Dependencies: 276
-- Name: mapping_dataset_admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_dataset_admins_id_seq OWNED BY public.mapping_dataset_admins.id;


--
-- TOC entry 277 (class 1259 OID 25418)
-- Name: mapping_dataset_editors; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_dataset_editors (
    id integer NOT NULL,
    dataset_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.mapping_dataset_editors OWNER TO drsnonprodpgadmin;

--
-- TOC entry 278 (class 1259 OID 25421)
-- Name: mapping_dataset_editors_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_dataset_editors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_dataset_editors_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4481 (class 0 OID 0)
-- Dependencies: 278
-- Name: mapping_dataset_editors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_dataset_editors_id_seq OWNED BY public.mapping_dataset_editors.id;


--
-- TOC entry 279 (class 1259 OID 25422)
-- Name: mapping_dataset_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_dataset_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_dataset_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4482 (class 0 OID 0)
-- Dependencies: 279
-- Name: mapping_dataset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_dataset_id_seq OWNED BY public.mapping_dataset.id;


--
-- TOC entry 280 (class 1259 OID 25423)
-- Name: mapping_dataset_viewers; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_dataset_viewers (
    id integer NOT NULL,
    dataset_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.mapping_dataset_viewers OWNER TO drsnonprodpgadmin;

--
-- TOC entry 281 (class 1259 OID 25426)
-- Name: mapping_dataset_viewers_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_dataset_viewers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_dataset_viewers_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4483 (class 0 OID 0)
-- Dependencies: 281
-- Name: mapping_dataset_viewers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_dataset_viewers_id_seq OWNED BY public.mapping_dataset_viewers.id;


--
-- TOC entry 282 (class 1259 OID 25427)
-- Name: mapping_mappingrule; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_mappingrule (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    approved boolean NOT NULL,
    omop_field_id integer NOT NULL,
    scan_report_id integer NOT NULL,
    source_field_id integer,
    source_table_id integer,
    concept_id integer NOT NULL
);


ALTER TABLE public.mapping_mappingrule OWNER TO drsnonprodpgadmin;

--
-- TOC entry 283 (class 1259 OID 25430)
-- Name: mapping_nlpmodel; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_nlpmodel (
    id integer NOT NULL,
    user_string text NOT NULL,
    json_response text
);


ALTER TABLE public.mapping_nlpmodel OWNER TO drsnonprodpgadmin;

--
-- TOC entry 284 (class 1259 OID 25436)
-- Name: mapping_nlpmodel_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_nlpmodel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_nlpmodel_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4484 (class 0 OID 0)
-- Dependencies: 284
-- Name: mapping_nlpmodel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_nlpmodel_id_seq OWNED BY public.mapping_nlpmodel.id;


--
-- TOC entry 285 (class 1259 OID 25437)
-- Name: mapping_omopfield; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_omopfield (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    field character varying(64) NOT NULL,
    table_id integer NOT NULL
);


ALTER TABLE public.mapping_omopfield OWNER TO drsnonprodpgadmin;

--
-- TOC entry 286 (class 1259 OID 25440)
-- Name: mapping_omopfield_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_omopfield_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_omopfield_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4485 (class 0 OID 0)
-- Dependencies: 286
-- Name: mapping_omopfield_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_omopfield_id_seq OWNED BY public.mapping_omopfield.id;


--
-- TOC entry 287 (class 1259 OID 25441)
-- Name: mapping_omoptable; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_omoptable (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    "table" character varying(64) NOT NULL
);


ALTER TABLE public.mapping_omoptable OWNER TO drsnonprodpgadmin;

--
-- TOC entry 288 (class 1259 OID 25444)
-- Name: mapping_omoptable_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_omoptable_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_omoptable_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4486 (class 0 OID 0)
-- Dependencies: 288
-- Name: mapping_omoptable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_omoptable_id_seq OWNED BY public.mapping_omoptable.id;


--
-- TOC entry 289 (class 1259 OID 25445)
-- Name: mapping_project; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_project (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.mapping_project OWNER TO drsnonprodpgadmin;

--
-- TOC entry 290 (class 1259 OID 25448)
-- Name: mapping_project_datasets; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_project_datasets (
    id integer NOT NULL,
    project_id integer NOT NULL,
    dataset_id integer NOT NULL
);


ALTER TABLE public.mapping_project_datasets OWNER TO drsnonprodpgadmin;

--
-- TOC entry 291 (class 1259 OID 25451)
-- Name: mapping_project_datasets_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_project_datasets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_project_datasets_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4487 (class 0 OID 0)
-- Dependencies: 291
-- Name: mapping_project_datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_project_datasets_id_seq OWNED BY public.mapping_project_datasets.id;


--
-- TOC entry 292 (class 1259 OID 25452)
-- Name: mapping_project_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_project_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_project_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4488 (class 0 OID 0)
-- Dependencies: 292
-- Name: mapping_project_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_project_id_seq OWNED BY public.mapping_project.id;


--
-- TOC entry 293 (class 1259 OID 25453)
-- Name: mapping_project_members; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_project_members (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.mapping_project_members OWNER TO drsnonprodpgadmin;

--
-- TOC entry 294 (class 1259 OID 25456)
-- Name: mapping_project_members_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_project_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_project_members_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4489 (class 0 OID 0)
-- Dependencies: 294
-- Name: mapping_project_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_project_members_id_seq OWNED BY public.mapping_project_members.id;


--
-- TOC entry 295 (class 1259 OID 25457)
-- Name: mapping_scanreport; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_scanreport (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(256) NOT NULL,
    dataset character varying(128) NOT NULL,
    file character varying(100) NOT NULL,
    author_id integer,
    hidden boolean NOT NULL,
    status character varying(7) NOT NULL,
    data_dictionary_id integer,
    parent_dataset_id integer,
    visibility character varying(10) NOT NULL
);


ALTER TABLE public.mapping_scanreport OWNER TO drsnonprodpgadmin;

--
-- TOC entry 296 (class 1259 OID 25462)
-- Name: mapping_scanreport_editors; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_scanreport_editors (
    id integer NOT NULL,
    scanreport_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.mapping_scanreport_editors OWNER TO drsnonprodpgadmin;

--
-- TOC entry 297 (class 1259 OID 25465)
-- Name: mapping_scanreport_editors_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_scanreport_editors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_scanreport_editors_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4490 (class 0 OID 0)
-- Dependencies: 297
-- Name: mapping_scanreport_editors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_scanreport_editors_id_seq OWNED BY public.mapping_scanreport_editors.id;


--
-- TOC entry 298 (class 1259 OID 25466)
-- Name: mapping_scanreport_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_scanreport_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_scanreport_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4491 (class 0 OID 0)
-- Dependencies: 298
-- Name: mapping_scanreport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_scanreport_id_seq OWNED BY public.mapping_scanreport.id;


--
-- TOC entry 299 (class 1259 OID 25467)
-- Name: mapping_scanreport_viewers; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_scanreport_viewers (
    id integer NOT NULL,
    scanreport_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.mapping_scanreport_viewers OWNER TO drsnonprodpgadmin;

--
-- TOC entry 300 (class 1259 OID 25470)
-- Name: mapping_scanreport_viewers_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_scanreport_viewers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_scanreport_viewers_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4492 (class 0 OID 0)
-- Dependencies: 300
-- Name: mapping_scanreport_viewers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_scanreport_viewers_id_seq OWNED BY public.mapping_scanreport_viewers.id;


--
-- TOC entry 301 (class 1259 OID 25471)
-- Name: mapping_scanreportassertion; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_scanreportassertion (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    negative_assertion character varying(64),
    scan_report_id integer NOT NULL
);


ALTER TABLE public.mapping_scanreportassertion OWNER TO drsnonprodpgadmin;

--
-- TOC entry 302 (class 1259 OID 25474)
-- Name: mapping_scanreportassertion_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_scanreportassertion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_scanreportassertion_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4493 (class 0 OID 0)
-- Dependencies: 302
-- Name: mapping_scanreportassertion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_scanreportassertion_id_seq OWNED BY public.mapping_scanreportassertion.id;


--
-- TOC entry 303 (class 1259 OID 25475)
-- Name: mapping_scanreportconcept; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_scanreportconcept (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    nlp_entity character varying(64),
    nlp_entity_type character varying(64),
    nlp_confidence numeric(3,2),
    nlp_vocabulary character varying(64),
    nlp_concept_code character varying(64),
    nlp_processed_string character varying(256),
    object_id integer NOT NULL,
    concept_id integer NOT NULL,
    content_type_id integer NOT NULL,
    creation_type character varying(1) NOT NULL,
    CONSTRAINT mapping_scanreportconcept_object_id_check CHECK ((object_id >= 0))
);


ALTER TABLE public.mapping_scanreportconcept OWNER TO drsnonprodpgadmin;

--
-- TOC entry 304 (class 1259 OID 25481)
-- Name: mapping_scanreportconcept_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_scanreportconcept_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_scanreportconcept_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4494 (class 0 OID 0)
-- Dependencies: 304
-- Name: mapping_scanreportconcept_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_scanreportconcept_id_seq OWNED BY public.mapping_scanreportconcept.id;


--
-- TOC entry 305 (class 1259 OID 25482)
-- Name: mapping_scanreportfield; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_scanreportfield (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(512) NOT NULL,
    description_column character varying(512) NOT NULL,
    type_column character varying(32) NOT NULL,
    max_length integer NOT NULL,
    nrows integer NOT NULL,
    nrows_checked integer NOT NULL,
    fraction_empty numeric(10,2) NOT NULL,
    nunique_values integer NOT NULL,
    fraction_unique numeric(10,2) NOT NULL,
    is_patient_id boolean NOT NULL,
    is_ignore boolean NOT NULL,
    classification_system character varying(64),
    scan_report_table_id integer NOT NULL,
    ignore_column character varying(64),
    pass_from_source boolean NOT NULL,
    concept_id integer,
    field_description character varying(256)
);


ALTER TABLE public.mapping_scanreportfield OWNER TO drsnonprodpgadmin;

--
-- TOC entry 306 (class 1259 OID 25487)
-- Name: mapping_scanreportfield_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_scanreportfield_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_scanreportfield_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4495 (class 0 OID 0)
-- Dependencies: 306
-- Name: mapping_scanreportfield_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_scanreportfield_id_seq OWNED BY public.mapping_scanreportfield.id;


--
-- TOC entry 307 (class 1259 OID 25488)
-- Name: mapping_scanreporttable; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_scanreporttable (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(256) NOT NULL,
    scan_report_id integer NOT NULL,
    person_id_id integer,
    date_event_id integer
);


ALTER TABLE public.mapping_scanreporttable OWNER TO drsnonprodpgadmin;

--
-- TOC entry 308 (class 1259 OID 25491)
-- Name: mapping_scanreporttable_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_scanreporttable_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_scanreporttable_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4496 (class 0 OID 0)
-- Dependencies: 308
-- Name: mapping_scanreporttable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_scanreporttable_id_seq OWNED BY public.mapping_scanreporttable.id;


--
-- TOC entry 309 (class 1259 OID 25492)
-- Name: mapping_scanreportvalue; Type: TABLE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE TABLE public.mapping_scanreportvalue (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    value character varying(128) NOT NULL,
    frequency integer NOT NULL,
    "conceptID" integer NOT NULL,
    scan_report_field_id integer NOT NULL,
    value_description character varying(512)
);


ALTER TABLE public.mapping_scanreportvalue OWNER TO drsnonprodpgadmin;

--
-- TOC entry 310 (class 1259 OID 25497)
-- Name: mapping_scanreportvalue_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_scanreportvalue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_scanreportvalue_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4497 (class 0 OID 0)
-- Dependencies: 310
-- Name: mapping_scanreportvalue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_scanreportvalue_id_seq OWNED BY public.mapping_scanreportvalue.id;


--
-- TOC entry 311 (class 1259 OID 25498)
-- Name: mapping_structuralmappingrule_id_seq; Type: SEQUENCE; Schema: public; Owner: drsnonprodpgadmin
--

CREATE SEQUENCE public.mapping_structuralmappingrule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapping_structuralmappingrule_id_seq OWNER TO drsnonprodpgadmin;

--
-- TOC entry 4498 (class 0 OID 0)
-- Dependencies: 311
-- Name: mapping_structuralmappingrule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: drsnonprodpgadmin
--

ALTER SEQUENCE public.mapping_structuralmappingrule_id_seq OWNED BY public.mapping_mappingrule.id;


--
-- TOC entry 4080 (class 2604 OID 25499)
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);


--
-- TOC entry 4081 (class 2604 OID 25500)
-- Name: auth_group_permissions id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);


--
-- TOC entry 4082 (class 2604 OID 25501)
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);


--
-- TOC entry 4083 (class 2604 OID 25502)
-- Name: auth_user id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.auth_user ALTER COLUMN id SET DEFAULT nextval('public.auth_user_id_seq'::regclass);


--
-- TOC entry 4084 (class 2604 OID 25503)
-- Name: auth_user_groups id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.auth_user_groups ALTER COLUMN id SET DEFAULT nextval('public.auth_user_groups_id_seq'::regclass);


--
-- TOC entry 4085 (class 2604 OID 25504)
-- Name: auth_user_user_permissions id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.auth_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_user_user_permissions_id_seq'::regclass);


--
-- TOC entry 4087 (class 2604 OID 25505)
-- Name: django_admin_log id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);


--
-- TOC entry 4089 (class 2604 OID 25506)
-- Name: django_content_type id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);


--
-- TOC entry 4090 (class 2604 OID 25507)
-- Name: django_migrations id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);


--
-- TOC entry 4092 (class 2604 OID 25508)
-- Name: mapping_classificationsystem id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_classificationsystem ALTER COLUMN id SET DEFAULT nextval('public.mapping_classificationsystem_id_seq'::regclass);


--
-- TOC entry 4093 (class 2604 OID 25509)
-- Name: mapping_datadictionary id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_datadictionary ALTER COLUMN id SET DEFAULT nextval('public.mapping_datadictionary_id_seq'::regclass);


--
-- TOC entry 4086 (class 2604 OID 25510)
-- Name: mapping_datapartner id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_datapartner ALTER COLUMN id SET DEFAULT nextval('public.datapartner_id_seq'::regclass);


--
-- TOC entry 4094 (class 2604 OID 25511)
-- Name: mapping_dataset id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_dataset ALTER COLUMN id SET DEFAULT nextval('public.mapping_dataset_id_seq'::regclass);


--
-- TOC entry 4095 (class 2604 OID 25512)
-- Name: mapping_dataset_admins id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_dataset_admins ALTER COLUMN id SET DEFAULT nextval('public.mapping_dataset_admins_id_seq'::regclass);


--
-- TOC entry 4096 (class 2604 OID 25513)
-- Name: mapping_dataset_editors id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_dataset_editors ALTER COLUMN id SET DEFAULT nextval('public.mapping_dataset_editors_id_seq'::regclass);


--
-- TOC entry 4097 (class 2604 OID 25514)
-- Name: mapping_dataset_viewers id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_dataset_viewers ALTER COLUMN id SET DEFAULT nextval('public.mapping_dataset_viewers_id_seq'::regclass);


--
-- TOC entry 4098 (class 2604 OID 25515)
-- Name: mapping_mappingrule id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_mappingrule ALTER COLUMN id SET DEFAULT nextval('public.mapping_structuralmappingrule_id_seq'::regclass);


--
-- TOC entry 4099 (class 2604 OID 25516)
-- Name: mapping_nlpmodel id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_nlpmodel ALTER COLUMN id SET DEFAULT nextval('public.mapping_nlpmodel_id_seq'::regclass);


--
-- TOC entry 4100 (class 2604 OID 25517)
-- Name: mapping_omopfield id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_omopfield ALTER COLUMN id SET DEFAULT nextval('public.mapping_omopfield_id_seq'::regclass);


--
-- TOC entry 4101 (class 2604 OID 25518)
-- Name: mapping_omoptable id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_omoptable ALTER COLUMN id SET DEFAULT nextval('public.mapping_omoptable_id_seq'::regclass);


--
-- TOC entry 4102 (class 2604 OID 25519)
-- Name: mapping_project id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_project ALTER COLUMN id SET DEFAULT nextval('public.mapping_project_id_seq'::regclass);


--
-- TOC entry 4103 (class 2604 OID 25520)
-- Name: mapping_project_datasets id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_project_datasets ALTER COLUMN id SET DEFAULT nextval('public.mapping_project_datasets_id_seq'::regclass);


--
-- TOC entry 4104 (class 2604 OID 25521)
-- Name: mapping_project_members id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_project_members ALTER COLUMN id SET DEFAULT nextval('public.mapping_project_members_id_seq'::regclass);


--
-- TOC entry 4105 (class 2604 OID 25522)
-- Name: mapping_scanreport id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreport ALTER COLUMN id SET DEFAULT nextval('public.mapping_scanreport_id_seq'::regclass);


--
-- TOC entry 4106 (class 2604 OID 25523)
-- Name: mapping_scanreport_editors id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreport_editors ALTER COLUMN id SET DEFAULT nextval('public.mapping_scanreport_editors_id_seq'::regclass);


--
-- TOC entry 4107 (class 2604 OID 25524)
-- Name: mapping_scanreport_viewers id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreport_viewers ALTER COLUMN id SET DEFAULT nextval('public.mapping_scanreport_viewers_id_seq'::regclass);


--
-- TOC entry 4108 (class 2604 OID 25525)
-- Name: mapping_scanreportassertion id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreportassertion ALTER COLUMN id SET DEFAULT nextval('public.mapping_scanreportassertion_id_seq'::regclass);


--
-- TOC entry 4109 (class 2604 OID 25526)
-- Name: mapping_scanreportconcept id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreportconcept ALTER COLUMN id SET DEFAULT nextval('public.mapping_scanreportconcept_id_seq'::regclass);


--
-- TOC entry 4111 (class 2604 OID 25527)
-- Name: mapping_scanreportfield id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreportfield ALTER COLUMN id SET DEFAULT nextval('public.mapping_scanreportfield_id_seq'::regclass);


--
-- TOC entry 4112 (class 2604 OID 25528)
-- Name: mapping_scanreporttable id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreporttable ALTER COLUMN id SET DEFAULT nextval('public.mapping_scanreporttable_id_seq'::regclass);


--
-- TOC entry 4113 (class 2604 OID 25529)
-- Name: mapping_scanreportvalue id; Type: DEFAULT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreportvalue ALTER COLUMN id SET DEFAULT nextval('public.mapping_scanreportvalue_id_seq'::regclass);


--
-- TOC entry 4121 (class 2606 OID 25545)
-- Name: care_site xpk_care_site; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.care_site
    ADD CONSTRAINT xpk_care_site PRIMARY KEY (care_site_id);


--
-- TOC entry 4123 (class 2606 OID 25547)
-- Name: concept xpk_concept; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.concept
    ADD CONSTRAINT xpk_concept PRIMARY KEY (concept_id);


--
-- TOC entry 4125 (class 2606 OID 25898)
-- Name: concept_ancestor xpk_concept_ancestor; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.concept_ancestor
    ADD CONSTRAINT xpk_concept_ancestor PRIMARY KEY (ancestor_concept_id, descendant_concept_id);


--
-- TOC entry 4127 (class 2606 OID 25900)
-- Name: concept_class xpk_concept_class; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.concept_class
    ADD CONSTRAINT xpk_concept_class PRIMARY KEY (concept_class_id);


--
-- TOC entry 4129 (class 2606 OID 25902)
-- Name: concept_relationship xpk_concept_relationship; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.concept_relationship
    ADD CONSTRAINT xpk_concept_relationship PRIMARY KEY (concept_id_1, concept_id_2, relationship_id);


--
-- TOC entry 4131 (class 2606 OID 25904)
-- Name: condition_era xpk_condition_era; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.condition_era
    ADD CONSTRAINT xpk_condition_era PRIMARY KEY (condition_era_id);


--
-- TOC entry 4133 (class 2606 OID 25906)
-- Name: condition_occurrence xpk_condition_occurrence; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.condition_occurrence
    ADD CONSTRAINT xpk_condition_occurrence PRIMARY KEY (condition_occurrence_id);


--
-- TOC entry 4137 (class 2606 OID 25910)
-- Name: device_exposure xpk_device_exposure; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.device_exposure
    ADD CONSTRAINT xpk_device_exposure PRIMARY KEY (device_exposure_id);


--
-- TOC entry 4139 (class 2606 OID 25912)
-- Name: domain xpk_domain; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.domain
    ADD CONSTRAINT xpk_domain PRIMARY KEY (domain_id);


--
-- TOC entry 4141 (class 2606 OID 25914)
-- Name: dose_era xpk_dose_era; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.dose_era
    ADD CONSTRAINT xpk_dose_era PRIMARY KEY (dose_era_id);


--
-- TOC entry 4143 (class 2606 OID 25916)
-- Name: drug_era xpk_drug_era; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.drug_era
    ADD CONSTRAINT xpk_drug_era PRIMARY KEY (drug_era_id);


--
-- TOC entry 4145 (class 2606 OID 25918)
-- Name: drug_exposure xpk_drug_exposure; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.drug_exposure
    ADD CONSTRAINT xpk_drug_exposure PRIMARY KEY (drug_exposure_id);


--
-- TOC entry 4147 (class 2606 OID 25920)
-- Name: drug_strength xpk_drug_strength; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.drug_strength
    ADD CONSTRAINT xpk_drug_strength PRIMARY KEY (drug_concept_id, ingredient_concept_id);


--
-- TOC entry 4149 (class 2606 OID 25922)
-- Name: location xpk_location; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.location
    ADD CONSTRAINT xpk_location PRIMARY KEY (location_id);


--
-- TOC entry 4151 (class 2606 OID 25924)
-- Name: location_history xpk_location_history; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.location_history
    ADD CONSTRAINT xpk_location_history PRIMARY KEY (location_history_id);


--
-- TOC entry 4153 (class 2606 OID 25926)
-- Name: measurement xpk_measurement; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.measurement
    ADD CONSTRAINT xpk_measurement PRIMARY KEY (measurement_id);


--
-- TOC entry 4155 (class 2606 OID 25928)
-- Name: note xpk_note; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.note
    ADD CONSTRAINT xpk_note PRIMARY KEY (note_id);


--
-- TOC entry 4157 (class 2606 OID 25930)
-- Name: note_nlp xpk_note_nlp; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.note_nlp
    ADD CONSTRAINT xpk_note_nlp PRIMARY KEY (note_nlp_id);


--
-- TOC entry 4159 (class 2606 OID 25932)
-- Name: observation xpk_observation; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.observation
    ADD CONSTRAINT xpk_observation PRIMARY KEY (observation_id);


--
-- TOC entry 4161 (class 2606 OID 25934)
-- Name: observation_period xpk_observation_period; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.observation_period
    ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id);


--
-- TOC entry 4163 (class 2606 OID 25936)
-- Name: payer_plan_period xpk_payer_plan_period; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.payer_plan_period
    ADD CONSTRAINT xpk_payer_plan_period PRIMARY KEY (payer_plan_period_id);


--
-- TOC entry 4165 (class 2606 OID 25938)
-- Name: person xpk_person; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.person
    ADD CONSTRAINT xpk_person PRIMARY KEY (person_id);


--
-- TOC entry 4167 (class 2606 OID 25940)
-- Name: procedure_occurrence xpk_procedure_occurrence; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.procedure_occurrence
    ADD CONSTRAINT xpk_procedure_occurrence PRIMARY KEY (procedure_occurrence_id);


--
-- TOC entry 4169 (class 2606 OID 25942)
-- Name: relationship xpk_relationship; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.relationship
    ADD CONSTRAINT xpk_relationship PRIMARY KEY (relationship_id);


--
-- TOC entry 4171 (class 2606 OID 25944)
-- Name: source_to_concept_map xpk_source_to_concept_map; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.source_to_concept_map
    ADD CONSTRAINT xpk_source_to_concept_map PRIMARY KEY (source_vocabulary_id, target_concept_id, source_code, valid_end_date);


--
-- TOC entry 4173 (class 2606 OID 25946)
-- Name: specimen xpk_specimen; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.specimen
    ADD CONSTRAINT xpk_specimen PRIMARY KEY (specimen_id);


--
-- TOC entry 4175 (class 2606 OID 25948)
-- Name: survey_conduct xpk_survey; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.survey_conduct
    ADD CONSTRAINT xpk_survey PRIMARY KEY (survey_conduct_id);


--
-- TOC entry 4135 (class 2606 OID 25908)
-- Name: cost xpk_visit_cost; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.cost
    ADD CONSTRAINT xpk_visit_cost PRIMARY KEY (cost_id);


--
-- TOC entry 4177 (class 2606 OID 25950)
-- Name: visit_detail xpk_visit_detail; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.visit_detail
    ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id);


--
-- TOC entry 4179 (class 2606 OID 25952)
-- Name: visit_occurrence xpk_visit_occurrence; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.visit_occurrence
    ADD CONSTRAINT xpk_visit_occurrence PRIMARY KEY (visit_occurrence_id);


--
-- TOC entry 4181 (class 2606 OID 25954)
-- Name: vocabulary xpk_vocabulary; Type: CONSTRAINT; Schema: omop; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY omop.vocabulary
    ADD CONSTRAINT xpk_vocabulary PRIMARY KEY (vocabulary_id);


--
-- TOC entry 4185 (class 2606 OID 25958)
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 4183 (class 2606 OID 25956)
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- TOC entry 4187 (class 2606 OID 25960)
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 4191 (class 2606 OID 25964)
-- Name: auth_user_groups auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 4189 (class 2606 OID 25962)
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- TOC entry 4193 (class 2606 OID 25966)
-- Name: auth_user_user_permissions auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 4195 (class 2606 OID 25968)
-- Name: authtoken_token authtoken_token_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.authtoken_token
    ADD CONSTRAINT authtoken_token_pkey PRIMARY KEY (key);


--
-- TOC entry 4197 (class 2606 OID 25982)
-- Name: mapping_datapartner datapartner_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_datapartner
    ADD CONSTRAINT datapartner_pkey PRIMARY KEY (id);


--
-- TOC entry 4199 (class 2606 OID 25970)
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- TOC entry 4201 (class 2606 OID 25972)
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- TOC entry 4203 (class 2606 OID 25974)
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 4205 (class 2606 OID 25976)
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- TOC entry 4207 (class 2606 OID 25978)
-- Name: mapping_classificationsystem mapping_classificationsystem_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_classificationsystem
    ADD CONSTRAINT mapping_classificationsystem_pkey PRIMARY KEY (id);


--
-- TOC entry 4209 (class 2606 OID 25980)
-- Name: mapping_datadictionary mapping_datadictionary_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_datadictionary
    ADD CONSTRAINT mapping_datadictionary_pkey PRIMARY KEY (id);


--
-- TOC entry 4213 (class 2606 OID 25986)
-- Name: mapping_dataset_admins mapping_dataset_admins_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_dataset_admins
    ADD CONSTRAINT mapping_dataset_admins_pkey PRIMARY KEY (id);


--
-- TOC entry 4215 (class 2606 OID 25988)
-- Name: mapping_dataset_editors mapping_dataset_editors_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_dataset_editors
    ADD CONSTRAINT mapping_dataset_editors_pkey PRIMARY KEY (id);


--
-- TOC entry 4211 (class 2606 OID 25984)
-- Name: mapping_dataset mapping_dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_dataset
    ADD CONSTRAINT mapping_dataset_pkey PRIMARY KEY (id);


--
-- TOC entry 4217 (class 2606 OID 25990)
-- Name: mapping_dataset_viewers mapping_dataset_viewers_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_dataset_viewers
    ADD CONSTRAINT mapping_dataset_viewers_pkey PRIMARY KEY (id);


--
-- TOC entry 4221 (class 2606 OID 25994)
-- Name: mapping_nlpmodel mapping_nlpmodel_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_nlpmodel
    ADD CONSTRAINT mapping_nlpmodel_pkey PRIMARY KEY (id);


--
-- TOC entry 4223 (class 2606 OID 25996)
-- Name: mapping_omopfield mapping_omopfield_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_omopfield
    ADD CONSTRAINT mapping_omopfield_pkey PRIMARY KEY (id);


--
-- TOC entry 4225 (class 2606 OID 25998)
-- Name: mapping_omoptable mapping_omoptable_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_omoptable
    ADD CONSTRAINT mapping_omoptable_pkey PRIMARY KEY (id);


--
-- TOC entry 4229 (class 2606 OID 26002)
-- Name: mapping_project_datasets mapping_project_datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_project_datasets
    ADD CONSTRAINT mapping_project_datasets_pkey PRIMARY KEY (id);


--
-- TOC entry 4231 (class 2606 OID 26004)
-- Name: mapping_project_members mapping_project_members_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_project_members
    ADD CONSTRAINT mapping_project_members_pkey PRIMARY KEY (id);


--
-- TOC entry 4227 (class 2606 OID 26000)
-- Name: mapping_project mapping_project_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_project
    ADD CONSTRAINT mapping_project_pkey PRIMARY KEY (id);


--
-- TOC entry 4235 (class 2606 OID 26008)
-- Name: mapping_scanreport_editors mapping_scanreport_editors_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreport_editors
    ADD CONSTRAINT mapping_scanreport_editors_pkey PRIMARY KEY (id);


--
-- TOC entry 4233 (class 2606 OID 26006)
-- Name: mapping_scanreport mapping_scanreport_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreport
    ADD CONSTRAINT mapping_scanreport_pkey PRIMARY KEY (id);


--
-- TOC entry 4237 (class 2606 OID 26010)
-- Name: mapping_scanreport_viewers mapping_scanreport_viewers_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreport_viewers
    ADD CONSTRAINT mapping_scanreport_viewers_pkey PRIMARY KEY (id);


--
-- TOC entry 4239 (class 2606 OID 26012)
-- Name: mapping_scanreportassertion mapping_scanreportassertion_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreportassertion
    ADD CONSTRAINT mapping_scanreportassertion_pkey PRIMARY KEY (id);


--
-- TOC entry 4241 (class 2606 OID 26014)
-- Name: mapping_scanreportconcept mapping_scanreportconcept_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreportconcept
    ADD CONSTRAINT mapping_scanreportconcept_pkey PRIMARY KEY (id);


--
-- TOC entry 4243 (class 2606 OID 26016)
-- Name: mapping_scanreportfield mapping_scanreportfield_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreportfield
    ADD CONSTRAINT mapping_scanreportfield_pkey PRIMARY KEY (id);


--
-- TOC entry 4245 (class 2606 OID 26018)
-- Name: mapping_scanreporttable mapping_scanreporttable_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreporttable
    ADD CONSTRAINT mapping_scanreporttable_pkey PRIMARY KEY (id);


--
-- TOC entry 4247 (class 2606 OID 26020)
-- Name: mapping_scanreportvalue mapping_scanreportvalue_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_scanreportvalue
    ADD CONSTRAINT mapping_scanreportvalue_pkey PRIMARY KEY (id);


--
-- TOC entry 4219 (class 2606 OID 25992)
-- Name: mapping_mappingrule mapping_structuralmappingrule_pkey; Type: CONSTRAINT; Schema: public; Owner: drsnonprodpgadmin
--

ALTER TABLE ONLY public.mapping_mappingrule
    ADD CONSTRAINT mapping_structuralmappingrule_pkey PRIMARY KEY (id);


--
-- TOC entry 4392 (class 0 OID 0)
-- Dependencies: 3
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: azure_pg_admin
--

REVOKE ALL ON SCHEMA public FROM azuresu;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO azure_pg_admin;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 4393 (class 0 OID 0)
-- Dependencies: 312
-- Name: FUNCTION pg_replication_origin_advance(text, pg_lsn); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_advance(text, pg_lsn) TO azure_pg_admin;


--
-- TOC entry 4394 (class 0 OID 0)
-- Dependencies: 319
-- Name: FUNCTION pg_replication_origin_create(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_create(text) TO azure_pg_admin;


--
-- TOC entry 4395 (class 0 OID 0)
-- Dependencies: 320
-- Name: FUNCTION pg_replication_origin_drop(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_drop(text) TO azure_pg_admin;


--
-- TOC entry 4396 (class 0 OID 0)
-- Dependencies: 321
-- Name: FUNCTION pg_replication_origin_oid(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_oid(text) TO azure_pg_admin;


--
-- TOC entry 4397 (class 0 OID 0)
-- Dependencies: 326
-- Name: FUNCTION pg_replication_origin_progress(text, boolean); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_progress(text, boolean) TO azure_pg_admin;


--
-- TOC entry 4398 (class 0 OID 0)
-- Dependencies: 327
-- Name: FUNCTION pg_replication_origin_session_is_setup(); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_is_setup() TO azure_pg_admin;


--
-- TOC entry 4399 (class 0 OID 0)
-- Dependencies: 313
-- Name: FUNCTION pg_replication_origin_session_progress(boolean); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_progress(boolean) TO azure_pg_admin;


--
-- TOC entry 4400 (class 0 OID 0)
-- Dependencies: 322
-- Name: FUNCTION pg_replication_origin_session_reset(); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_reset() TO azure_pg_admin;


--
-- TOC entry 4401 (class 0 OID 0)
-- Dependencies: 328
-- Name: FUNCTION pg_replication_origin_session_setup(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_setup(text) TO azure_pg_admin;


--
-- TOC entry 4402 (class 0 OID 0)
-- Dependencies: 329
-- Name: FUNCTION pg_replication_origin_xact_reset(); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_xact_reset() TO azure_pg_admin;


--
-- TOC entry 4403 (class 0 OID 0)
-- Dependencies: 330
-- Name: FUNCTION pg_replication_origin_xact_setup(pg_lsn, timestamp with time zone); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_xact_setup(pg_lsn, timestamp with time zone) TO azure_pg_admin;


--
-- TOC entry 4404 (class 0 OID 0)
-- Dependencies: 331
-- Name: FUNCTION pg_show_replication_origin_status(OUT local_id oid, OUT external_id text, OUT remote_lsn pg_lsn, OUT local_lsn pg_lsn); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_show_replication_origin_status(OUT local_id oid, OUT external_id text, OUT remote_lsn pg_lsn, OUT local_lsn pg_lsn) TO azure_pg_admin;


--
-- TOC entry 4405 (class 0 OID 0)
-- Dependencies: 314
-- Name: FUNCTION pg_stat_reset(); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_reset() TO azure_pg_admin;


--
-- TOC entry 4406 (class 0 OID 0)
-- Dependencies: 317
-- Name: FUNCTION pg_stat_reset_shared(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_reset_shared(text) TO azure_pg_admin;


--
-- TOC entry 4407 (class 0 OID 0)
-- Dependencies: 318
-- Name: FUNCTION pg_stat_reset_single_function_counters(oid); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_reset_single_function_counters(oid) TO azure_pg_admin;


--
-- TOC entry 4408 (class 0 OID 0)
-- Dependencies: 315
-- Name: FUNCTION pg_stat_reset_single_table_counters(oid); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_reset_single_table_counters(oid) TO azure_pg_admin;


--
-- TOC entry 4409 (class 0 OID 0)
-- Dependencies: 96
-- Name: COLUMN pg_config.name; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(name) ON TABLE pg_catalog.pg_config TO azure_pg_admin;


--
-- TOC entry 4410 (class 0 OID 0)
-- Dependencies: 96
-- Name: COLUMN pg_config.setting; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(setting) ON TABLE pg_catalog.pg_config TO azure_pg_admin;


--
-- TOC entry 4411 (class 0 OID 0)
-- Dependencies: 93
-- Name: COLUMN pg_hba_file_rules.line_number; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(line_number) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 4412 (class 0 OID 0)
-- Dependencies: 93
-- Name: COLUMN pg_hba_file_rules.type; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(type) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 4413 (class 0 OID 0)
-- Dependencies: 93
-- Name: COLUMN pg_hba_file_rules.database; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(database) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 4414 (class 0 OID 0)
-- Dependencies: 93
-- Name: COLUMN pg_hba_file_rules.user_name; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(user_name) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 4415 (class 0 OID 0)
-- Dependencies: 93
-- Name: COLUMN pg_hba_file_rules.address; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(address) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 4416 (class 0 OID 0)
-- Dependencies: 93
-- Name: COLUMN pg_hba_file_rules.netmask; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(netmask) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 4417 (class 0 OID 0)
-- Dependencies: 93
-- Name: COLUMN pg_hba_file_rules.auth_method; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(auth_method) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 4418 (class 0 OID 0)
-- Dependencies: 93
-- Name: COLUMN pg_hba_file_rules.options; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(options) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 4419 (class 0 OID 0)
-- Dependencies: 93
-- Name: COLUMN pg_hba_file_rules.error; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(error) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 4420 (class 0 OID 0)
-- Dependencies: 140
-- Name: COLUMN pg_replication_origin_status.local_id; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(local_id) ON TABLE pg_catalog.pg_replication_origin_status TO azure_pg_admin;


--
-- TOC entry 4421 (class 0 OID 0)
-- Dependencies: 140
-- Name: COLUMN pg_replication_origin_status.external_id; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(external_id) ON TABLE pg_catalog.pg_replication_origin_status TO azure_pg_admin;


--
-- TOC entry 4422 (class 0 OID 0)
-- Dependencies: 140
-- Name: COLUMN pg_replication_origin_status.remote_lsn; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(remote_lsn) ON TABLE pg_catalog.pg_replication_origin_status TO azure_pg_admin;


--
-- TOC entry 4423 (class 0 OID 0)
-- Dependencies: 140
-- Name: COLUMN pg_replication_origin_status.local_lsn; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(local_lsn) ON TABLE pg_catalog.pg_replication_origin_status TO azure_pg_admin;


--
-- TOC entry 4424 (class 0 OID 0)
-- Dependencies: 97
-- Name: COLUMN pg_shmem_allocations.name; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(name) ON TABLE pg_catalog.pg_shmem_allocations TO azure_pg_admin;


--
-- TOC entry 4425 (class 0 OID 0)
-- Dependencies: 97
-- Name: COLUMN pg_shmem_allocations.off; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(off) ON TABLE pg_catalog.pg_shmem_allocations TO azure_pg_admin;


--
-- TOC entry 4426 (class 0 OID 0)
-- Dependencies: 97
-- Name: COLUMN pg_shmem_allocations.size; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(size) ON TABLE pg_catalog.pg_shmem_allocations TO azure_pg_admin;


--
-- TOC entry 4427 (class 0 OID 0)
-- Dependencies: 97
-- Name: COLUMN pg_shmem_allocations.allocated_size; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(allocated_size) ON TABLE pg_catalog.pg_shmem_allocations TO azure_pg_admin;


--
-- TOC entry 4428 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.starelid; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(starelid) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4429 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.staattnum; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staattnum) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4430 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stainherit; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stainherit) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4431 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stanullfrac; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanullfrac) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4432 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stawidth; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stawidth) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4433 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stadistinct; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stadistinct) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4434 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stakind1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4435 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stakind2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4436 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stakind3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4437 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stakind4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4438 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stakind5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4439 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.staop1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4440 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.staop2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4441 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.staop3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4442 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.staop4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4443 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.staop5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4444 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stacoll1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4445 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stacoll2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4446 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stacoll3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4447 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stacoll4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4448 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stacoll5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4449 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stanumbers1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4450 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stanumbers2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4451 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stanumbers3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4452 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stanumbers4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4453 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stanumbers5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4454 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stavalues1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4455 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stavalues2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4456 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stavalues3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4457 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stavalues4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4458 (class 0 OID 0)
-- Dependencies: 40
-- Name: COLUMN pg_statistic.stavalues5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 4459 (class 0 OID 0)
-- Dependencies: 65
-- Name: COLUMN pg_subscription.oid; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(oid) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 4460 (class 0 OID 0)
-- Dependencies: 65
-- Name: COLUMN pg_subscription.subdbid; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subdbid) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 4461 (class 0 OID 0)
-- Dependencies: 65
-- Name: COLUMN pg_subscription.subname; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subname) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 4462 (class 0 OID 0)
-- Dependencies: 65
-- Name: COLUMN pg_subscription.subowner; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subowner) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 4463 (class 0 OID 0)
-- Dependencies: 65
-- Name: COLUMN pg_subscription.subenabled; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subenabled) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 4464 (class 0 OID 0)
-- Dependencies: 65
-- Name: COLUMN pg_subscription.subconninfo; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subconninfo) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 4465 (class 0 OID 0)
-- Dependencies: 65
-- Name: COLUMN pg_subscription.subslotname; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subslotname) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 4466 (class 0 OID 0)
-- Dependencies: 65
-- Name: COLUMN pg_subscription.subsynccommit; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subsynccommit) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 4467 (class 0 OID 0)
-- Dependencies: 65
-- Name: COLUMN pg_subscription.subpublications; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subpublications) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


-- Completed on 2023-03-14 14:48:03 GMT

--
-- PostgreSQL database dump complete
--

