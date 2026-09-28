#include "kolmafia_ash/client.hpp"

#include <boost/json.hpp>
#include <cassert>
#include <iostream>

int main() {
  using namespace kolmafia::ash;

  const auto item = Item("seal-clubbing club").to_json();
  assert(item.at("objectType").as_string() == "Item");
  assert(item.at("identifierString").as_string() == "seal-clubbing club");

  const auto monster = Monster(123).to_json();
  assert(monster.at("objectType").as_string() == "Monster");
  assert(monster.at("identifierNumber").as_int64() == 123);

  const auto packed = args(1, true, "abc", Item(5));
  assert(packed.size() == 4);
  assert(packed[0].as_int64() == 1);
  assert(packed[1].as_bool());
  assert(packed[2].as_string() == "abc");
  assert(packed[3].as_object().at("identifierNumber").as_int64() == 5);

  bool threw = false;
  try {
    Client bad(ClientOptions{});
  } catch (const Error&) {
    threw = true;
  }
  assert(threw);

  std::cout << "smoke: PASS\n";
  return 0;
}
