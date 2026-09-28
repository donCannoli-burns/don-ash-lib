script "ash_agent_types.ash";

/*
  Shared records for ASH Agent Standard Library.
  This file intentionally contains no functions so the corpus function count
  remains exactly 10 exports per supplied source entry.
*/

record agent_check {
    boolean ok;
    string subject;
    string reason;
    string severity;
};

record agent_metric {
    string name;
    float value;
    string unit;
    string note;
};

record agent_delta {
    string label;
    int before_value;
    int after_value;
    int difference;
};

record agent_action_preview {
    boolean valid;
    string operation;
    string reason;
    int meat_cost;
    int adventure_cost;
    string warnings;
};

record agent_item_state {
    item thing;
    int inventory;
    int closet;
    int storage;
    int display;
    int shop;
    int equipped;
    int total;
};

record agent_value_snapshot {
    int liquid_meat;
    int item_value;
    int total_value;
    int turns;
    int stamp;
};

record agent_organ_state {
    int fullness;
    int fullness_limit_value;
    int inebriety;
    int inebriety_limit_value;
    int spleen;
    int spleen_limit_value;
};

record agent_combat_state {
    monster foe;
    int hp;
    int attack;
    int defense;
    int player_hp;
    int player_mp;
    int turn;
};

record agent_kv {
    string key;
    string value;
    string note;
};

record agent_range_state {
    int minimum;
    int maximum;
    int current;
    int remaining;
    boolean satisfied;
};

record agent_resource_state {
    string name;
    int used;
    int limit_value;
    int remaining;
    boolean available;
};

record agent_score {
    string label;
    float score;
    string reason;
};

record agent_plan {
    boolean valid;
    string subject;
    string action;
    string reason;
    int meat_cost;
    int turn_cost;
};

record agent_choice_state {
    int choice_id;
    boolean handling;
    int configured_option;
    string preference_name;
    string note;
};

record agent_breakpoint {
    string name;
    string date;
    int turns;
    int meat;
    int stamp;
};

record agent_modifier_state {
    string modifier_name;
    float current_value;
    float target_value;
    float gap;
    boolean satisfied;
};

record agent_stash_state {
    item thing;
    int expected;
    int actual;
    int difference;
    boolean personal_overlap;
};

record agent_consumption_candidate {
    item thing;
    int size;
    float adventures;
    int price;
    float adventures_per_size;
    float value;
    boolean fits;
};

record agent_option {
    string value;
    string label;
    boolean selected;
    boolean enabled;
    int score;
};

record agent_diagnostic {
    string name;
    boolean passed;
    string expected;
    string actual;
    string note;
};
