#include "ProjectName/ProjectName.h"

namespace ProjectName
{

// Keeping one compiled function in the starter verifies that the library is
// genuinely linked rather than accidentally behaving like a header-only target.
std::string_view getName() noexcept
{
    return PROJECT_NAME;
}

} // namespace ProjectName
