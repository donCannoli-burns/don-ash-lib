#include "kolmafia_ash/client.hpp"

#include <cstdlib>
#include <iostream>
#include <string>

int main() {
  using namespace kolmafia::ash;

  const char* pwd = std::getenv("KOLMAFIA_PWD");
  if (!pwd || std::string(pwd).empty()) {
    std::cerr << "Set KOLMAFIA_PWD for this example. Do not commit or hard-code it.\n";
    return 2;
  }

  Client mafia(ClientOptions{
      .base_url = "http://127.0.0.1:60080",
      .timeout = std::chrono::milliseconds(5000),
      .pwd_provider = [value = std::string(pwd)] { return value; },
  });

  try {
    std::cout << "player: " << mafia.my_name() << '\n';
    std::cout << "meat: " << mafia.my_meat() << '\n';
    std::cout << "adventures: " << mafia.my_adventures() << '\n';
    std::cout << "turns played: " << mafia.turns_played() << '\n';
    std::cout << "seal-clubbing clubs available: "
              << mafia.available_amount(Item("seal-clubbing club")) << '\n';

    // Any Browser JSON API ASH-runtime function remains available dynamically:
    auto version = mafia.call("getVersion");
    std::cout << "KoLmafia version: " << version << '\n';
  } catch (const Error& e) {
    std::cerr << "kolmafia-ash error: " << e.what() << '\n';
    return 1;
  }
}
