#include "ProjectName/ProjectName.h"

#include <iostream>

// This small executable proves that ordinary application code can consume the
// reusable library only through its public interface.
int main()
{
    std::cout << ProjectName::getName() << '\n';

    return 0;
}
