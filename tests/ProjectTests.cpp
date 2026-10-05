#include "ProjectName/ProjectName.h"

#include <gtest/gtest.h>

TEST(ProjectName, ReportsItsName)
{
    EXPECT_EQ(ProjectName::getName(), "ProjectName");
}
