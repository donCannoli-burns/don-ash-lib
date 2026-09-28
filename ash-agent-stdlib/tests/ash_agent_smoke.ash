script "ash_agent_smoke.ash";
import <ash_agent_stdlib.ash>;

void main() {
    print("ASH Agent Standard Library read-only smoke starting.", "teal");

    print("S01 " + aal_c2eco_repo_role("c2t_lib"));
    print("S02 " + aal_twisted_legacy_risk_score("void main() { print(\"x\"); }"));
    agent_choice_state s03 = aal_c2scripts_choice_state(1);
    print("S03 handling=" + s03.handling);
    print("S04 priority=" + aal_ezeco_task_priority(true, true, 0));
    print("S05 pressure=" + aal_iron_scripts_modernization_pressure("void main() {}"));
    print("S06 " + replace_string(aal_hccs_test_order(), "\n", ","));
    print("S07 " + replace_string(aal_ascend_config_fields(), "\n", ","));
    print("S08 phase=" + aal_ploop_phase_index(""));
    print("S09 key=" + aal_ptrack_checkpoint_key(today_to_string(), "smoke"));
    print("S10 prop=" + aal_pupdates_property_name("smoke"));
    agent_range_state s11 = aal_lowerstats_pressure($stat[muscle], 1000000);
    print("S11 excess=" + s11.remaining);
    print("S12 " + aal_pwrapper_retry_decision(1, 3, false, true));
    print("S13 liquid=" + aal_profit_liquid_meat());
    print("S14 duration=" + aal_time_format_duration(65000));
    print("S15 breakpoints=" + aal_ptrackcli_breakpoint_count("a,b,c"));
    print("S16 owned=" + aal_checklist_total_owned($item[seal tooth]));
    print("S17 deficit=" + aal_stash_deficit($item[seal tooth], 0));
    print("S18 " + aal_guide_task_line("Smoke", "test", "", 1));
    agent_modifier_state s19 = aal_gain_modifier_state("Item Drop", 0.0);
    print("S19 itemdrop=" + s19.current_value);
    print("S20 mods=" + replace_string(aal_astrogain_modifier_names($effect[Leash of Linguini]), "\n", ","));
    print("S21 liver_remaining=" + aal_consume_organ_remaining("liver"));
    print("S22 liquid=" + aal_networth_location_value($item[none], "inventory", 7, 0));
    print("S23 mp_waste=" + aal_rollover_mp_waste(0));
    agent_diagnostic s24 = aal_testout_bool("boolean-self-test", true, true);
    print("S24 " + aal_testout_line(s24));
    print("S25 starter_count_text=" + length(aal_bootstrap_starter_items()));
    print("S26 owned=" + aal_ocd_owned_total($item[seal tooth]));
    agent_option s27 = aal_select2_option("a", "Alpha", true, true);
    print("S27 score=" + aal_select2_match_score(s27, "alp"));
    print("S28 " + aal_htmlform_escape("<smoke>"));
    print("S29 beaten_up_value=" + aal_batbrain_beaten_up_turn_cost(1000));
    print("S30 clamp=" + aal_liba_clamp_normalized(5.0, 0.0, 3.0));
    print("S31 kind=" + aal_functionlib_consumption_kind($item[fortune cookie]));
    print("S32 key=" + aal_c2lib_maximize_key("Item Drop, Meat Drop"));
    print("S33 tier=" + aal_smash_power_band($item[seal-clubbing club]));
    print("S34 pull_score=" + aal_helper_pull_need_score($item[seal tooth], 1, 1));
    print("S35 progress=" + aal_quest_progress_rank("step3"));
    print("S36 familiar_weight=" + aal_sims_familiar_weight(my_familiar()));
    string[int] s37;
    s37[-1] = "0";
    s37[0] = "installed";
    print("S37 checksum=" + aal_pupdateslog_checksum(s37));
    print("S38 pref=" + aal_dics_pref_int("ascensionsToday", 0));
    print("S39 choice=" + aal_choiceoverride_choice_id("<input name='whichchoice' value='123'>"));
    print("S40 bool=" + aal_zlib_normalize_bool("yes"));
    print("S41 kind=" + aal_zman_field_kind("42"));

    print("ASH Agent Standard Library read-only smoke complete.", "green");
}
