#pragma once

#include <boost/json.hpp>
#include <cstdint>
#include <optional>
#include <string>
#include <string_view>

namespace kolmafia::ash {

// KoLmafia's Browser JSON API represents ASH enumerated values using an
// objectType + identifierString/identifierNumber placeholder.
struct EnumRef {
  std::string object_type;
  std::optional<std::string> identifier_string;
  std::optional<std::int64_t> identifier_number;

  [[nodiscard]] boost::json::object to_json() const {
    boost::json::object out;
    out["objectType"] = object_type;
    if (identifier_string) out["identifierString"] = *identifier_string;
    if (identifier_number) out["identifierNumber"] = *identifier_number;
    return out;
  }
};

inline EnumRef by_name(std::string object_type, std::string name) {
  return EnumRef{std::move(object_type), std::move(name), std::nullopt};
}

inline EnumRef by_id(std::string object_type, std::int64_t id) {
  return EnumRef{std::move(object_type), std::nullopt, id};
}

inline EnumRef Item(std::string name) { return by_name("Item", std::move(name)); }
inline EnumRef Item(std::int64_t id) { return by_id("Item", id); }
inline EnumRef Effect(std::string name) { return by_name("Effect", std::move(name)); }
inline EnumRef Effect(std::int64_t id) { return by_id("Effect", id); }
inline EnumRef Familiar(std::string name) { return by_name("Familiar", std::move(name)); }
inline EnumRef Familiar(std::int64_t id) { return by_id("Familiar", id); }
inline EnumRef Location(std::string name) { return by_name("Location", std::move(name)); }
inline EnumRef Location(std::int64_t id) { return by_id("Location", id); }
inline EnumRef Monster(std::string name) { return by_name("Monster", std::move(name)); }
inline EnumRef Monster(std::int64_t id) { return by_id("Monster", id); }
inline EnumRef Skill(std::string name) { return by_name("Skill", std::move(name)); }
inline EnumRef Skill(std::int64_t id) { return by_id("Skill", id); }
inline EnumRef Slot(std::string name) { return by_name("Slot", std::move(name)); }
inline EnumRef Stat(std::string name) { return by_name("Stat", std::move(name)); }
inline EnumRef Path(std::string name) { return by_name("Path", std::move(name)); }
inline EnumRef Class(std::string name) { return by_name("Class", std::move(name)); }

inline boost::json::value json_value(const EnumRef& value) { return value.to_json(); }
inline boost::json::value json_value(std::string_view value) { return boost::json::value(boost::json::string(value)); }
inline boost::json::value json_value(const std::string& value) { return boost::json::value(boost::json::string(value)); }
inline boost::json::value json_value(const char* value) { return boost::json::value(boost::json::string(value)); }
inline boost::json::value json_value(bool value) { return value; }
inline boost::json::value json_value(std::int64_t value) { return value; }
inline boost::json::value json_value(int value) { return value; }
inline boost::json::value json_value(double value) { return value; }
inline boost::json::value json_value(const boost::json::value& value) { return value; }
inline boost::json::value json_value(const boost::json::object& value) { return value; }
inline boost::json::value json_value(const boost::json::array& value) { return value; }

} // namespace kolmafia::ash
