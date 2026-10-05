#include "ProjectName/ProjectName.h"

#include <iostream>
#include <string_view>

// This separate project proves that installation exports the public target,
// include path, C++ language requirement, and implementation correctly.
int main()
{
    const std::string_view ACTUAL_PROJECT_NAME{ProjectName::getName()};

    std::cout << ACTUAL_PROJECT_NAME << '\n';

    if (ACTUAL_PROJECT_NAME != ProjectName::PROJECT_NAME)
    {
        return 1;
    }

    return 0;
}
