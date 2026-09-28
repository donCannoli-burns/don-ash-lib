#pragma once
#include "kolmafia_ash/client.hpp"
#include <cstdint>
#include <string>
#include <string_view>

namespace kolmafia_generated {
class Api {
 public:
  explicit Api(const ::kolmafia::ash::Client& client) : client_(client) {}
  [[nodiscard]] std::string my_name() const {
    auto v = client_.call("myName", {});
    if (v.is_string()) return std::string(v.as_string());
    throw ::kolmafia::ash::ApiError("generated wrapper expected string");
  }
  [[nodiscard]] std::int64_t my_meat() const {
    auto v = client_.call("myMeat", {});
    if (v.is_int64()) return v.as_int64();
    throw ::kolmafia::ash::ApiError("generated wrapper expected integer");
  }
  [[nodiscard]] std::int64_t my_adventures() const {
    auto v = client_.call("myAdventures", {});
    if (v.is_int64()) return v.as_int64();
    throw ::kolmafia::ash::ApiError("generated wrapper expected integer");
  }
  [[nodiscard]] std::int64_t available_amount(const ::kolmafia::ash::EnumRef& item) const {
    auto v = client_.call("availableAmount", ::kolmafia::ash::args(item));
    if (v.is_int64()) return v.as_int64();
    throw ::kolmafia::ash::ApiError("generated wrapper expected integer");
  }
  [[nodiscard]] bool have_skill(const ::kolmafia::ash::EnumRef& skill) const {
    auto v = client_.call("haveSkill", ::kolmafia::ash::args(skill));
    if (v.is_bool()) return v.as_bool();
    throw ::kolmafia::ash::ApiError("generated wrapper expected bool");
  }
  [[nodiscard]] boost::json::value identity(const ::kolmafia::ash::EnumRef& value) const {
    auto v = client_.call("identity", ::kolmafia::ash::args(value));
    return v;
  }
 private:
  const ::kolmafia::ash::Client& client_;
};
} // namespace kolmafia_generated
