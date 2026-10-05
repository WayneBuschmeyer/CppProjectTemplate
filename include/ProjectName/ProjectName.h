#ifndef PROJECT_TEMPLATE_PROJECT_NAME_H
#define PROJECT_TEMPLATE_PROJECT_NAME_H

#include <string_view>

namespace ProjectName
{

inline constexpr std::string_view PROJECT_NAME{ "ProjectName" };

// Returns the human-readable project name used by the starter application.
[[nodiscard]] std::string_view getName() noexcept;

} // namespace ProjectName

#endif
