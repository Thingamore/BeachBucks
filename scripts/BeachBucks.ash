script "BeachBucks.ash";

boolean quest_done(location quest_location){
  switch {
    default:
      abort("Invalid location provided");

    case(quest_location == $location[Sloppy Seconds Diner]):
      return get_property("questESlCocktail").contains_text("finished");

    case(quest_location == $location[The Fun-guy Mansion]):
      return get_property("questESlAudit").contains_text("finished");

    case(quest_location == $location[The Sunken Party Yacht]):
      return get_property("questESlFish").contains_text("finished");
  }
}

boolean acquire_fishy(){
  if(have_effect($effect[Fishy]).to_boolean())
    return true;

  if(!get_property("_fishyPipeUsed").to_boolean()){
    use(1, $item[Fishy Pipe]);
    return true;
  }

  foreach it in $items[concentrated fish broth, cuppa Gill tea, fish juice box, powdered candy sushi set]{
    if(it.mall_price() < 50000){
      buy(1, it, 50000);
      if(item_amount(it).to_boolean()) 
        use(1, it);
        return true;
    }
  }

  if(get_property("questS01OldGuy") == "unstarted"){
    visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman");
  }

  if(can_adventure($location[The Brinier Deepers])){
    use(1, $item[11-leaf clover]);
    adv1($location[The Brinier Deepers], -1, "abort");
    if(have_effect($effect[Fishy]).to_boolean())
      return true;
  }


  if(!have_effect($effect[Fishy]).to_boolean()){
    buy(1, $item[Pocket Wish], 55000);
    cli_execute("genie effect fishy");
  }

  return have_effect($effect[Fishy]).to_boolean();
}

void refresh(){
  visit_url("main.php");
}

boolean quest_yacht_complete; 
void main(){

// Resetting all quests if everything is complete
if(quest_done($location[Sloppy Seconds Diner]) && quest_done($location[The Fun-guy Mansion]) && quest_done($location[The Sunken Party Yacht])){
  print("All quests are done! Using an ultimate mind destroyer", "teal");

  if(item_amount($item[Ultimate Mind Destroyer]).to_boolean())
    buy(1, $item[Ultimate Mind Destroyer], historical_price($item[One-day ticket to Spring Break Beach]) * 0.9);

  if(item_amount($item[Ultimate Mind Destroyer]).to_boolean()){
    set_property("choiceAdventure920", "2");
    use(1, $item[Ultimate Mind Destroyer]);
    
    visit_url("place.php?whichplace=airport_sleaze&action=airport1_npc2");
    visit_url("choice.php?pwd&whichchoice=916&option=1");
  } else {
    abort("Aborting, as Ultimate Mind Destroyers are greater then the price of 90 funfunds in terms of a ticket!");
  }
}

// Fun-guy quest
if(!quest_done($location[The Fun-guy Mansion])){
  print("Now attempting to complete the fun-guy mansion quest!", "teal");
  string mansion_attack_macro = "if hasskill sing along; skill sing along; endif; if sauceror; skill curse of weaksauce; endif; skill saucegeyser; attack; if hascombatitem 3758; use 3758, 3758; endif;";
  
  if(get_property("questESlAudit").contains_text("unstarted")){
    print("Starting the quest!", "teal");
    visit_url("place.php?whichplace=airport_sleaze&action=airport1_npc2");
    run_choice(1);
    run_choice(1);
  }
  
  while(item_amount($item[Taco Dan's Taco Stand's Taco Receipt]) < 10){
    if(!have_effect($effect[Sleight of Mind]).to_boolean()){
      use(1, $item[sleight-of-hand mushroom]);
    }

    adv1($location[The Fun-guy Mansion], -1, mansion_attack_macro);

    if(!get_property("_lastCombatWon").to_boolean()){
      abort("We got beaten up!");
    }

    if(my_hp() < (my_maxhp() / 2)){
      restore_hp(my_maxhp());
    }
  }

  refresh();

  visit_url("place.php?whichplace=airport_sleaze&action=airport1_npc2");
  run_choice(1);
}

// Sloppy seconds quest
if(!quest_done($location[Sloppy Seconds Diner])){

  if(get_property("questESlCocktail").contains_text("unstarted")){
    print("Starting the quest!", "teal");
    visit_url("place.php?whichplace=airport_sleaze&action=airport1_npc2");
    run_choice(1 + (1 - quest_done($location[The Fun-guy mansion]).to_int())); 
    run_choice(1);
  }

  if(have_familiar($familiar[Grey goose])){
    use_familiar($familiar[Grey goose]);
    maximize("item, -equip broken champagne bottle, 21 familiar exp, equip Taco Dan's Taco Stand Cocktail Sauce Bottle", false);
  } else {
    maximize("item, -equip broken champagne bottle, equip Taco Dan's Taco Stand Cocktail Sauce Bottle", false);
  }

  if(!equipped_amount($item[Taco Dan's Taco Stand Cocktail Sauce Bottle]).to_boolean()){
    abort("We didn't get a sauce bottle, which is concerning...");
  }

  string sloppy_seconds_attack =  "if monsterid 1567; if hasskill 19; skill 19; endif; if hasskill 2043; skill 2043; endif; if hasskill 7302; skill 7302; endif; if hasskill 7437; skill 7437; if sauceror; skill curse of weaksauce; endif; skill saucegeyser; attack; endif; endif; if hasskill 7410; skill 7410; endif; if sauceror; skill curse of weaksauce; endif; skill saucegeyser; attack";

  while(get_property("tacoDanCocktailSauce").to_int() < 15){

    adv1($location[Sloppy Seconds Diner], 1, sloppy_seconds_attack);

    if(!get_property("_lastCombatWon").to_boolean()){
      abort("We got beaten up!");
    }
    
    if(my_hp() < (my_maxhp() / 2)){
      restore_hp(my_maxhp());
    }
    
    if(get_property("olfactedMonster") == "Sloppy Seconds Cocktail"){
      sloppy_seconds_attack = "if monsterid 1567; if sauceror; skill curse of weaksauce; endif; skill saucegeyser; attack; endif; if hasskill 7410; skill 7410; endif; if sauceror; skill curse of weaksauce; endif; skill saucegeyser; attack";
    }
  }

  visit_url("place.php?whichplace=airport_sleaze&action=airport1_npc2");
  run_choice(1);
}

// Yacht quest
if(!quest_done($location[The Sunken Party Yacht])){

  if(get_property("questESlFish").contains_text("unstarted")){
    print("Starting the quest!", "teal");
    visit_url("place.php?whichplace=airport_sleaze&action=airport1_npc2");
    run_choice(1 + (1 - quest_done($location[The Fun-guy mansion]).to_int()) +  (1 - quest_done($location[Sloppy Seconds Diner]).to_int()));
    run_choice(1);
  }


  set_location($location[The Sunken Party Yacht]);
  maximize("meat, switch urchin urchin, 8000 bonus crappy Mer-kin mask, 8000 bonus Mer-kin scholar mask, 8000 bonus Mer-kin gladiator mask", false);
  
  if(have_familiar($familiar[Urchin urchin]))
    use_familiar($familiar[Urchin urchin]);

  if(!have_effect($effect[Fishy]).to_boolean()){
    print("Trying to acquire effect Fishy!", "teal");
    if(!acquire_fishy()){
      abort("We couldn't find a reliable fishy source... somehow.");
    }
  }

  string yacht_attack_macro = "if !monsterid 1573; use pulled indigo taffy; abort; endif; if hasskill sing along; skill sing along; endif; if sauceror; skill curse of weaksauce; endif; skill saucegeyser; attack";
  set_property("choiceAdventure918", 0);

  if(numeric_modifier("Meat drop") < 650);
    cli_execute("gain 650 meat"); // Minimum req. for 4 turn clear

  while(!quest_yacht_complete){

  boolean over_bead_limit = (item_amount($item[string of moist beads]) > 100);
  if(!item_amount($item[pulled indigo taffy]).to_boolean()){
    buy(10, $item[Pulled indigo taffy]);
  }
  
  int prev_advs = my_adventures();
  visit_url("adventure.php?snarfblat=404");

  if(handling_choice()){
    matcher dash = create_matcher("-", get_property("umdLastObtained"));
    int umd_obtained = replace_all(dash, "").substring(6).to_int() + replace_all(dash, "").substring(4, 6).to_int() * 30;
    int mmDD_now = now_to_string("yyyyMMdd").substring(6).to_int() + now_to_string("yyyyMMdd").substring(4, 6).to_int() * 30;

    print(`Last obtained UMD: {umd_obtained}, date now: {mmDD_now}`, "teal");
    if(mmDD_now > (7 + umd_obtained)){
      print("It's been seven days! Getting an ultimate mind destroyer!", "teal");
      run_choice(1);
    } else if (over_bead_limit){
      run_choice(3);
    } else {
      run_choice(2);
    }
  }
  run_combat(yacht_attack_macro);

  if(have_effect($effect[Beaten Up]).to_boolean()){
    abort("We got beaten up!");
  }
    
  if(my_hp() < (my_maxhp() / 2)){
    restore_hp(my_maxhp());
  }

  if(prev_advs != my_adventures()){
    visit_url("place.php?whichplace=airport_sleaze&action=airport1_npc2");
    if(available_choice_options().count() == 2){
      run_choice(1);
      if(quest_done($location[The Sunken Party Yacht])){
        quest_yacht_complete = true;
      } else { abort("Something went wrong..."); }
    } else {
      run_choice(1);
      refresh();
    }
  }
  }
}
print("Done!", "teal");
}
